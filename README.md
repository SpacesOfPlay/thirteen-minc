# thirteen-minc

A [minc](https://minc.dev/) - language port of
[Thirteen](https://github.com/Atrix256/Thirteen) — a tiny library
that opens a window and hands back an RGBA pixel buffer. Write to
the buffer, call `thirteen_render`, the bytes show up on screen.

Inspired by Mode 13h: initialize the graphics mode, start drawing
pixels.

## Quickstart

Windows:
```powershell
git clone https://github.com/<your-org>/thirteen-minc
cd thirteen-minc
./tools/get_minc.ps1        # one-time: fetch minc compiler (~1.7 MB)
./build.ps1 examples/simple # builds + runs the Simple example
```

macOS/Linux:
```sh
git clone https://github.com/<your-org>/thirteen-minc
cd thirteen-minc
./tools/get_minc.sh
./build.sh examples/simple
```

## Hello world

```mc
import thirteen;

u8* g_pixels = null;
u32 g_w = 800;
u32 g_h = 600;
u32 g_frame = 0;

void on_frame() {
    for u32 i = 0; i < g_w * g_h * 4; i += 4 {
        g_pixels[i + 0] = 255;                   // R
        g_pixels[i + 1] = cast(u8, g_frame);     // G
        g_pixels[i + 2] = cast(u8, g_frame / 2); // B
        g_pixels[i + 3] = 255;                   // A
    }
    g_frame = g_frame + 1;
}

i32 main() {
    g_pixels = thirteen_init(g_w, g_h, false);
    if g_pixels == null { return 1; }
    thirteen_run(on_frame);
    return 0;
}
```

Drop into `examples/hello.mc`, then `./build.ps1 examples/hello`.

## Platforms

| Target | Backend |
|---|---|
| Windows | D3D12 / DXGI |
| Web (wasm) | raw wasm + canvas 2D |
| Linux | X11 / GLX / OpenGL |
| macOS | Cocoa / Metal |

## Building

First positional arg is either a target (`native` / `windows` / `linux`
/ `macos` / `wasm`) or the source. If a target, the next arg is the
source. Apart from that, PowerShell and bash behave the same.

```powershell
./build.ps1 examples/simple             # native (host OS) build + run
./build.ps1 wasm examples/simple        # wasm build + serve + open browser
./build.ps1 linux examples/simple       # cross-compile (object only)
./build.ps1 macos examples/simple
```

```sh
./build.sh examples/simple              # native
./build.sh wasm examples/simple         # wasm
```

The build script runs `minc` from the dist root so `import thirteen;`
resolves, drops the binary in `build/<example>/`, and runs it.

### Web (wasm)

```powershell
./build.ps1 wasm examples/simple
```

Compiles to `build/simple/main.wasm`, stages `lib/thirteen.js` and a
generated `index.html` next to it, fires up a localhost HTTP server,
and opens the browser. Ctrl+C in the terminal stops the server.

The staging is driven by `@wasm_host "thirteen.js"` in `lib/thirteen.mc`
— minc walks the import graph, finds the annotation, copies the host
file into the build directory, and generates the shell page. No
per-example HTML to maintain. Add `-NoRun` (PowerShell) or `--no-run`
(bash) to skip the browser-open (useful for CI / headless smoke).

### Troubleshooting

- **`minc compiler not found`** — run `./tools/get_minc.{ps1,sh}` or
  put `minc(.exe)` on PATH.
- **`thirteen_init returned null`** — usually a GPU adapter / X
  display / Metal device problem. Check the target's driver setup.
- **wasm: nothing draws** — the canvas needs the same dimensions as
  `thirteen_init(w, h, ...)` or it stays black until the first
  `thirteen_render()` call.

## API

The full API lives at the top of `lib/thirteen.mc`. Summary:

- `thirteen_init(width, height, fullscreen) → u8*` — alloc pixel
  buffer, return pointer
- `thirteen_render() → bool` — pump events, present buffer; false on
  quit
- `thirteen_shutdown()` — free resources
- `thirteen_set_size(w, h) → u8*` — resize, return new buffer
- `thirteen_set_application_name(name)` — window title
- `thirteen_set_vsync(bool)` / `thirteen_get_vsync() → bool`
- `thirteen_set_fullscreen(bool)` / `thirteen_get_fullscreen() → bool`
- `thirteen_get_width() → u32` / `thirteen_get_height() → u32`
- `thirteen_get_delta_time() → f64`
- `thirteen_get_mouse_position(*x, *y)` (+ `_last_frame`)
- `thirteen_get_mouse_button(b) → bool` (+ `_last_frame`)
- `thirteen_get_key(code) → bool` (+ `_last_frame`)
- `thirteen_get_window_handle() → ThirteenNativeWindowHandle`

## Examples

| Example | What it shows |
|---|---|
| [`examples/simple.mc`](examples/simple.mc) | The minimum useful program — animated gradient, V toggles vsync, F toggles fullscreen, ESC quits |
| [`examples/mandelbrot.mc`](examples/mandelbrot.mc) | Interactive Mandelbrot viewer — left/right click to zoom, SPACE to reset camera |
| [`examples/minesweeper.mc`](examples/minesweeper.mc) | Classic minesweeper — left click reveal, right click flag, SPACE restart |
| [`examples/jpeg_viewer.mc`](examples/jpeg_viewer.mc) | Decode a baseline JPEG (stdlib `jpeg` module) and display it. Ships `examples/assets/earth_from_saturn.jpg`; pass a path to view another. Native only |

The first three are ports of the upstream
[Atrix256/Thirteen](https://github.com/Atrix256/Thirteen)
`Examples/`. `jpeg_viewer` is minc-specific, showing the `jpeg` lib
module feeding thirteen's pixel buffer. (Upstream's `ControllerTest` is
not ported.)

## Prerequisites

**minc compiler** — `./tools/get_minc.{ps1,sh}` fetches a pinned
release from <https://github.com/SpacesOfPlay/minc-dev/releases>
(SHA-256 verified, dropped at `tools/minc/`). Or install manually
and put on PATH.

**`minc` is closed-source proprietary software, NOT covered by this
repo's license.** See [`LICENSE.md`](LICENSE.md).

## See also

- [`LICENSE.md`](LICENSE.md)

## Credits

Upstream Thirteen by Alan Wolfe and contributors. The original C++
header is at <https://github.com/Atrix256/Thirteen>. minc port by
Mattias Ljungström, Spaces Of Play UG (haftungsbeschränkt).
