// examples/mandelbrot — port of Atrix256/Thirteen Examples/Mandelbrot.
//
// Per-pixel Mandelbrot escape-time iteration, colored with a 7-band
// gradient (deep blue -> cyan -> green -> yellow -> orange -> red ->
// dark red). Render only when the view changes — full re-render takes
// a moment at zoom levels with lots of cells in the set.
//
//   Left click   zoom in 2x, recenter on click
//   Right click  zoom out 2x, recenter on click
//   SPACE        reset camera
//   V            toggle vsync
//   F            toggle fullscreen
//   ESC          quit
//

import thirteen;

i32 c_width      = 1024;
i32 c_height     = 768;
bool c_fullscreen = false;
i32 c_max_iter   = 1000;

u8* g_pixels   = null;
f32 g_center_x = 0.0f;
f32 g_center_y = 0.0f;
f32 g_height   = 5.0f;
f32 g_aspect   = 0.0f;
bool g_dirty = true;
bool g_prev_v     = false;
bool g_prev_f     = false;
bool g_prev_space = false;
bool g_prev_left  = false;
bool g_prev_right = false;

struct Rgb { u8 r; u8 g; u8 b; }

// 7-band gradient. `t` is escape time in [0, 1].
Rgb mandelbrot_color(f32 t) {
    if t < 0.0f { t = 0.0f; }
    if t > 1.0f { t = 1.0f; }

    f32 r = 0.0f;
    f32 g = 0.0f;
    f32 b = 0.0f;

    if t < 0.16f {
        f32 local = t / 0.16f;
        g = local * 128.0f;
        b = 64.0f + local * 191.0f;
    }
    else if t < 0.33f {
        f32 local = (t - 0.16f) / 0.17f;
        g = 128.0f + local * 127.0f;
        b = 255.0f - local * 255.0f;
    }
    else if t < 0.5f {
        f32 local = (t - 0.33f) / 0.17f;
        r = local * 255.0f;
        g = 255.0f;
    }
    else if t < 0.67f {
        f32 local = (t - 0.5f) / 0.17f;
        r = 255.0f;
        g = 255.0f - local * 100.0f;
    }
    else if t < 0.84f {
        f32 local = (t - 0.67f) / 0.17f;
        r = 255.0f;
        g = 155.0f - local * 155.0f;
    }
    else {
        f32 local = (t - 0.84f) / 0.16f;
        r = 255.0f - local * 128.0f;
    }

    return Rgb{ cast(u8, r), cast(u8, g), cast(u8, b) };
}

// Escape-time iteration. Returns (i / (max-1)) on escape, -1 if the
// orbit stays bounded for all c_max_iter steps. f64 in the inner loop
// to avoid the float-cliff that smears bands at deep zoom.
f32 mandelbrot_iter(f32 x, f32 y) {
    f64 z  = 0.0;
    f64 zi = 0.0;
    f64 cx = x;
    f64 cy = y;

    for i32 i = 0; i < c_max_iter; i++ {
        f64 nz  = z * z - zi * zi + cx;
        f64 nzi = 2.0 * z * zi + cy;
        z  = nz;
        zi = nzi;
        if (z * z + zi * zi) > 4.0 {
            return cast(f32, i) / cast(f32, c_max_iter - 1);
        }
    }
    return -1.0f;
}

void on_frame() {
    bool cur_v = thirteen_get_key(VK_V);
    if cur_v && !g_prev_v { thirteen_set_vsync(!thirteen_get_vsync()); }
    g_prev_v = cur_v;

    bool cur_f = thirteen_get_key(VK_F);
    if cur_f && !g_prev_f { thirteen_set_fullscreen(!thirteen_get_fullscreen()); }
    g_prev_f = cur_f;

    bool cur_space = thirteen_get_key(VK_SPACE);
    if cur_space && !g_prev_space {
        g_center_x = 0.0f;
        g_center_y = 0.0f;
        g_height   = 5.0f;
        g_dirty = true;
    }
    g_prev_space = cur_space;

    // Left click: recenter on click + zoom in 2x. Half the offset
    // because zooming halves the visible extent.
    bool cur_left = thirteen_get_mouse_button(THIRTEEN_MOUSE_LEFT);
    if cur_left && !g_prev_left {
        i32 mx = 0; i32 my = 0;
        thirteen_get_mouse_position(&mx, &my);
        f32 px = cast(f32, mx) / cast(f32, c_width);
        f32 py = cast(f32, my) / cast(f32, c_height);
        g_center_x = g_center_x + (px - 0.5f) * g_height * g_aspect * 0.5f;
        g_center_y = g_center_y + (py - 0.5f) * g_height * 0.5f;
        g_height = g_height * 0.5f;
        g_dirty = true;
    }
    g_prev_left = cur_left;

    bool cur_right = thirteen_get_mouse_button(THIRTEEN_MOUSE_RIGHT);
    if cur_right && !g_prev_right {
        i32 mx = 0; i32 my = 0;
        thirteen_get_mouse_position(&mx, &my);
        f32 px = cast(f32, mx) / cast(f32, c_width);
        f32 py = cast(f32, my) / cast(f32, c_height);
        g_center_x = g_center_x + (px - 0.5f) * g_height * g_aspect * -0.5f;
        g_center_y = g_center_y + (py - 0.5f) * g_height * -0.5f;
        g_height = g_height * 2.0f;
        g_dirty = true;
    }
    g_prev_right = cur_right;

    if g_dirty {
        g_dirty = false;
        for i32 iy = 0; iy < c_height; iy++ {
            f32 py = (cast(f32, iy) + 0.5f) / cast(f32, c_height);
            f32 posY = g_center_y + (py - 0.5f) * g_height;
            for i32 ix = 0; ix < c_width; ix++ {
                f32 px = (cast(f32, ix) + 0.5f) / cast(f32, c_width);
                f32 posX = g_center_x + (px - 0.5f) * g_height * g_aspect;
                i32 i = (iy * c_width + ix) * 4;

                f32 iter = mandelbrot_iter(posX, posY);
                Rgb c = Rgb{ 0, 0, 0 };   // in-set pixels stay black
                if iter >= 0.0f { c = mandelbrot_color(iter); }
                g_pixels[i + 0] = c.r;
                g_pixels[i + 1] = c.g;
                g_pixels[i + 2] = c.b;
                g_pixels[i + 3] = 255;
            }
        }
    }
}

i32 main() {
    thirteen_set_application_name("Thirteen Demo - Mandelbrot");
    g_pixels = thirteen_init(cast(u32, c_width), cast(u32, c_height), c_fullscreen);
    if g_pixels == null { return 1; }
    g_aspect = cast(f32, c_width) / cast(f32, c_height);
    thirteen_run(on_frame);
    return 0;
}
