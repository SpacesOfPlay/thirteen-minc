// thirteen_wasm.js — JS host for the raw-wasm thirteen binding.
//
// Loads a thirteen wasm module, wires the `env.thirteen_js_*`
// imports it expects, installs canvas + DOM event listeners that
// poke the wasm-exported input setters, and runs a
// requestAnimationFrame loop that calls the exported
// `thirteen_frame` and copies the pixel buffer to the canvas via
// ImageData.
//
// Use:
//   <canvas id="thirteen"></canvas>
//   <script type="module">
//     import { startThirteen } from "./thirteen_wasm.js";
//     await startThirteen({
//       wasmPath: "./my_program.wasm",
//       canvas: document.getElementById("thirteen"),
//     });
//   </script>

export async function startThirteen({ wasmPath, canvas }) {
  if (!canvas) throw new Error("thirteen: canvas element is required");
  const ctx = canvas.getContext("2d");
  if (!ctx) throw new Error("thirteen: failed to get 2D canvas context");

  // The wasm instance exposes memory; we read pixels through this.
  let inst = null;
  let memoryU8 = null;
  let imageData = null;
  let canvasW = 0;
  let canvasH = 0;

  // Decode a (ptr, len) UTF-8 slice from wasm linear memory.
  const decoder = new TextDecoder("utf-8");
  function decodeStr(ptr, len) {
    if (!ptr || !len) return "";
    return decoder.decode(new Uint8Array(memoryU8.buffer, ptr, len));
  }

  // Mouse button index. DOM event.button uses {0=left, 1=middle, 2=right};
  // thirteen's index is {0=left, 1=right, 2=middle} (matches Win32's
  // WM_*BUTTONDOWN ordering — see THIRTEEN_MOUSE_* in lib/thirteen.mc).
  // Remap on the JS side so user code sees one convention everywhere.
  const buttonMap = [0, 2, 1];

  // Input arrives via pointer events so mouse and touch share one path.
  // thirteen input is polled once per frame, so a press must span a poll
  // to be seen. Safari's synthesized mouse events for a tap (down+up in
  // one burst after the finger lifts) do not. Touch gets an explicit
  // mapping instead: tap = left click, long-press = right click, drag =
  // held left button. Programmatic presses queue on pulseUp and release
  // one frame after the poll.
  const LONG_PRESS_MS = 500;
  const TOUCH_SLOP_PX = 12;
  let touch = null;      // active touch gesture: {id, x0, y0, mode, timer}
  const pulseUp = [];    // button indices to release after the next frame

  function setPos(e) {
    const rect = canvas.getBoundingClientRect();
    inst.exports.thirteen_set_mouse_pos(
      Math.round((e.clientX - rect.left) * canvas.width / rect.width),
      Math.round((e.clientY - rect.top) * canvas.height / rect.height));
  }
  function press(idx, down) { inst.exports.thirteen_set_mouse_button(idx, down); }
  function pulse(idx) { press(idx, 1); pulseUp.push(idx); }
  function flushPulses() {
    while (pulseUp.length) press(pulseUp.pop(), 0);
  }
  function onPointerDown(e) {
    if (!inst) return;
    setPos(e);
    try { canvas.setPointerCapture(e.pointerId); } catch (_) {}
    if (e.pointerType === "mouse") {
      const idx = buttonMap[e.button];
      if (idx !== undefined) press(idx, 1);
      return;
    }
    e.preventDefault();
    if (touch) return;  // first touch wins; extra fingers are ignored
    touch = {
      id: e.pointerId, x0: e.clientX, y0: e.clientY, mode: "pending",
      timer: setTimeout(() => {
        if (inst && touch && touch.mode === "pending") { touch.mode = "done"; pulse(1); }
      }, LONG_PRESS_MS),
    };
  }
  function onPointerMove(e) {
    if (!inst) return;
    if (e.pointerType !== "mouse" && (!touch || e.pointerId !== touch.id)) return;
    setPos(e);
    if (touch && e.pointerId === touch.id && touch.mode === "pending") {
      const dx = e.clientX - touch.x0, dy = e.clientY - touch.y0;
      if (dx * dx + dy * dy > TOUCH_SLOP_PX * TOUCH_SLOP_PX) {
        clearTimeout(touch.timer);
        touch.mode = "drag";
        press(0, 1);
      }
    }
  }
  function onPointerUp(e) {
    if (!inst) return;
    if (e.pointerType === "mouse") {
      setPos(e);
      const idx = buttonMap[e.button];
      if (idx !== undefined) press(idx, 0);
      return;
    }
    e.preventDefault();
    if (!touch || e.pointerId !== touch.id) return;
    clearTimeout(touch.timer);
    if (e.type === "pointerup") {
      setPos(e);
      if (touch.mode === "pending") pulse(0);  // tap
    }
    if (touch.mode === "drag") press(0, 0);
    touch = null;
  }

  // Map JS KeyboardEvent.keyCode (or .code) to a 0..255 slot. Keep
  // this lookup minimal — thirteen's keys[256] table is a coarse
  // tally, not a full keymap. event.keyCode is deprecated but
  // still wired through on every desktop browser.
  function onKeyEvent(e) {
    if (!inst) return;
    const code = e.keyCode | 0;
    if (code >= 0 && code < 256) {
      inst.exports.thirteen_set_key(code, e.type === "keydown" ? 1 : 0);
    }
  }

  // `env` imports the wasm module declares (matches the
  // thirteen_wasm.mc `extern "env" { ... }` block plus minc's
  // runtime bootstrap stubs). `clock` returns i64 nanoseconds —
  // must be BigInt in JS.
  const env = {
    // --- minc runtime stubs ---
    write: (_fd, ptr, len) => {      // stdout write — pipe to console.
      // Signature is (i64, i64, i64) → i64; convert to Number for the
      // memory slice, return a BigInt for the byte count.
      const lenNum = Number(len);
      if (lenNum > 0) {
        const s = decoder.decode(new Uint8Array(memoryU8.buffer, Number(ptr), lenNum));
        if (s) console.log(s.replace(/\n$/, ""));
      }
      return BigInt(lenNum);
    },
    clock: () => BigInt(Math.round(performance.now() * 1e6)),

    // --- thirteen helpers ---
    // minc emits a uniform i64 ABI for env imports — every integer
    // arg arrives as BigInt and every "void" return needs a BigInt
    // back. Wrap each helper so the body works in plain Numbers.
    thirteen_js_init(width, height, name_ptr, name_len) {
      const w = Number(width), h = Number(height);
      canvas.width = w;
      canvas.height = h;
      canvasW = w;
      canvasH = h;
      imageData = ctx.createImageData(w, h);
      const name = decodeStr(Number(name_ptr), Number(name_len));
      if (name) document.title = name;

      // Install DOM listeners exactly once.
      canvas.addEventListener("pointerdown", onPointerDown);
      canvas.addEventListener("pointerup", onPointerUp);
      canvas.addEventListener("pointercancel", onPointerUp);
      canvas.addEventListener("pointermove", onPointerMove);
      // Suppress the right-click context menu so right-click events
      // reach the wasm instead of being eaten by the browser default.
      canvas.addEventListener("contextmenu", e => e.preventDefault());
      window.addEventListener("keydown", onKeyEvent);
      window.addEventListener("keyup", onKeyEvent);
      // No browser gestures on the canvas — pan/zoom would eat game input.
      canvas.style.touchAction = "none";
      // Tab needs the canvas focusable for keyboard input.
      if (canvas.tabIndex < 0) canvas.tabIndex = 0;
      canvas.focus();
      return 0n;
    },

    thirteen_js_present(pixels_ptr, width, height) {
      const w = Number(width), h = Number(height);
      if (!imageData || w !== canvasW || h !== canvasH) {
        canvas.width = w;
        canvas.height = h;
        canvasW = w;
        canvasH = h;
        imageData = ctx.createImageData(w, h);
      }
      // Copy w*h*4 RGBA bytes from wasm memory into the ImageData
      // backing buffer. `set()` is the fast path; the browser does
      // the byte copy in a single call.
      const wasmBytes = new Uint8ClampedArray(memoryU8.buffer, Number(pixels_ptr), w * h * 4);
      imageData.data.set(wasmBytes);
      ctx.putImageData(imageData, 0, 0);
      return 0n;
    },

    thirteen_js_resize(width, height) {
      const w = Number(width), h = Number(height);
      canvas.width = w;
      canvas.height = h;
      canvasW = w;
      canvasH = h;
      imageData = ctx.createImageData(w, h);
      return 0n;
    },

    thirteen_js_now_nanos() {
      // BigInt nanoseconds — same convention as env.clock.
      return BigInt(Math.round(performance.now() * 1e6));
    },

    thirteen_js_set_vsync(_enabled) {
      // vsync is implicit in requestAnimationFrame; the bit is
      // accepted and ignored.
      return 0n;
    },

    thirteen_js_set_fullscreen(fullscreen) {
      if (fullscreen) {
        if (canvas.requestFullscreen) canvas.requestFullscreen();
      } else {
        if (document.exitFullscreen) document.exitFullscreen();
      }
      return 0n;
    },

    thirteen_js_set_title(name_ptr, name_len) {
      const name = decodeStr(Number(name_ptr), Number(name_len));
      if (name) document.title = name;
      return 0n;
    },
  };

  // Math import group — only needed when user code does `import math;`
  // (minc's standard math library, lib/math.mc). The thirteen library
  // itself doesn't call any math.h functions. Wired here so user examples
  // that import math work without further setup.
  //
  // sinf/cosf/tanf/roundf are intentionally omitted: lib/math.mc inlines
  // them as polynomial approximations on the wasm target, so they're
  // never imported. The f64 versions and the remaining f32 functions
  // do still resolve through this object.
  const math = {
    sin: Math.sin, cos: Math.cos, tan: Math.tan, sqrt: Math.sqrt,
    asin: Math.asin, acos: Math.acos, atan: Math.atan, atan2: Math.atan2,
    exp: Math.exp, log: Math.log, log2: Math.log2, log10: Math.log10,
    pow: Math.pow, fmod: (a, b) => a % b, fabs: Math.abs,
    floor: Math.floor, ceil: Math.ceil, round: Math.round,
    sqrtf: Math.sqrt, asinf: Math.asin, acosf: Math.acos, atanf: Math.atan,
    atan2f: Math.atan2, expf: Math.exp, logf: Math.log, powf: Math.pow,
    fmodf: (a, b) => a % b, fabsf: Math.abs, floorf: Math.floor, ceilf: Math.ceil,
  };

  const wasmBytes = await fetch(wasmPath).then((r) => r.arrayBuffer());
  const { instance } = await WebAssembly.instantiate(wasmBytes, { env, math });
  inst = instance;
  memoryU8 = inst.exports.memory;

  // Run main() once for setup.
  if (typeof inst.exports.main === "function") {
    inst.exports.main();
  }

  // Drive the frame loop.
  if (typeof inst.exports.thirteen_frame === "function") {
    const tick = () => {
      inst.exports.thirteen_frame();
      flushPulses();
      requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }

  return inst;
}

// `start` is the entry point name `minc run --target wasm` looks for
// in the generated stock shell. Same call shape as startThirteen.
export const start = startThirteen;
