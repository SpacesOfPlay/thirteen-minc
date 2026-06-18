// examples/jpeg_viewer — decode a baseline JPEG and show it in a window.
//
// Loads a .jpg with the lib `jpeg` module (RGBA8 out), opens a
// window sized to fit the image, and blits it into thirteen's pixel
// buffer with nearest-neighbor scaling. The default image ships at
// examples/assets/earth_from_saturn.jpg; pass a path to view another:
//
//   ./build.ps1 examples/jpeg_viewer                 # the bundled image
//   ./build.ps1 examples/jpeg_viewer -NoRun          # compile only
//   build/jpeg_viewer/jpeg_viewer.exe path/to.jpg    # any baseline JPEG
//
//   V    toggle vsync
//   F    toggle fullscreen
//   ESC  quit
//
// Native only — decoding reads from disk, so there is no wasm arm.
//
// Image Credit: NASA/JPL-Caltech/Space Science Institute
//


import thirteen;
import jpeg;

// Largest window we open; bigger images are scaled down to fit.
const i32 c_max_w = 1600;
const i32 c_max_h = 1000;

u8* g_pixels  = null;
bool g_prev_v = false;
bool g_prev_f = false;

// True if `path` names a readable file.
// This only exists so that the executable can run from different CWDs.
bool path_readable(str path) {
    u8* cpath = str_to_cstr(path);
    i64 fd = open(cpath, 0);
    if cpath != path.data { free(cpath); }
    if fd == cast(i64, 0) - 1 { return false; }
    close(fd);
    return true;
}

// Find where the default asset image is located by looking in all the places.
// Only needed because you might cd into the example folder and run it from there.
// Or run using ./build.ps1 examples/jpeg_viewer
str resolve_image_path() {
    if get_argc() > 1 { return str_from_cstr(get_arg(1)); }

    str c;
    c = "earth_from_saturn.jpg";                       if path_readable(c) { return c; }
    c = "assets/earth_from_saturn.jpg";                if path_readable(c) { return c; }
    c = "examples/assets/earth_from_saturn.jpg";       if path_readable(c) { return c; }
    c = "../../examples/assets/earth_from_saturn.jpg"; if path_readable(c) { return c; }
    return "examples/assets/earth_from_saturn.jpg";
}

// Blit src (sw x sh RGBA8) into dst (dw x dh RGBA8) with nearest-
// neighbor sampling. dst aspect matches src.
void blit_scaled(u8* dst, i32 dw, i32 dh, u8* src, i32 sw, i32 sh) {
    for i32 dy = 0; dy < dh; dy++ {
        i32 sy = dy * sh / dh;
        u8* srow = src + sy * sw * 4;
        u8* drow = dst + dy * dw * 4;
        for i32 dx = 0; dx < dw; dx++ {
            i32 sx = dx * sw / dw;
            i32 si = sx * 4;
            i32 di = dx * 4;
            drow[di + 0] = srow[si + 0];
            drow[di + 1] = srow[si + 1];
            drow[di + 2] = srow[si + 2];
            drow[di + 3] = 255;
        }
    }
}

void on_frame() {
    bool cur_v = thirteen_get_key(VK_V);
    if cur_v && !g_prev_v { thirteen_set_vsync(!thirteen_get_vsync()); }
    g_prev_v = cur_v;

    bool cur_f = thirteen_get_key(VK_F);
    if cur_f && !g_prev_f { thirteen_set_fullscreen(!thirteen_get_fullscreen()); }
    g_prev_f = cur_f;

    // The image is static, so the buffer painted at startup keeps
    // presenting — nothing to redraw here.
}

i32 main() {
    str path = resolve_image_path();
    JpegImage img = jpeg_load(path);
    if img.pixels == null { return 1; }
    defer free(img.pixels);

    // We need to do scale math in f32, cast these upfront.
    f32 img_w = cast(f32, img.width);
    f32 img_h = cast(f32, img.height);
    f32 max_w = cast(f32, c_max_w);
    f32 max_h = cast(f32, c_max_h);

    // Fit the image inside the max window box, never scaling it up.
    f32 scale = 1.0f;
    if img_w > max_w {
        scale = max_w / img_w;
    }
    if img_h > max_h {
        f32 scale_h = max_h / img_h;
        if scale_h < scale { scale = scale_h; }
    }

    i32 win_w = cast(i32, img_w * scale);
    i32 win_h = cast(i32, img_h * scale);
    if win_w < 1 { win_w = 1; }
    if win_h < 1 { win_h = 1; }

    thirteen_set_application_name("Thirteen Demo - JPEG Viewer");
    g_pixels = thirteen_init(cast(u32, win_w), cast(u32, win_h), false);
    if g_pixels == null { return 1; }

    blit_scaled(g_pixels, win_w, win_h, img.pixels, img.width, img.height);

    thirteen_run(on_frame);
    return 0;
}
