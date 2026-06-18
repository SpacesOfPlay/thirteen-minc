// examples/simple — port of Atrix256/Thirteen Examples/Simple.
//
// Animated RGB gradient: R from frame+ix, G from frame+iy, B from
// frame.
//
//   ESC  quit
//   V    toggle vsync
//   F    toggle fullscreen
//

import thirteen;

u32 c_width      = 1024;
u32 c_height     = 768;
bool c_fullscreen = false;

u8* g_pixels  = null;
u32 g_frame   = 0;
bool g_prev_v = false;
bool g_prev_f = false;

void on_frame() {
    bool cur_v = thirteen_get_key(VK_V);
    if cur_v && !g_prev_v { thirteen_set_vsync(!thirteen_get_vsync()); }
    g_prev_v = cur_v;

    bool cur_f = thirteen_get_key(VK_F);
    if cur_f && !g_prev_f { thirteen_set_fullscreen(!thirteen_get_fullscreen()); }
    g_prev_f = cur_f;

    for u32 iy = 0; iy < c_height; iy++ {
        for u32 ix = 0; ix < c_width; ix++ {
            u32 i = (iy * c_width + ix) * 4;
            g_pixels[i + 0] = cast(u8, g_frame + ix);
            g_pixels[i + 1] = cast(u8, g_frame + iy);
            g_pixels[i + 2] = cast(u8, g_frame);
            g_pixels[i + 3] = 255;
        }
    }
    g_frame = g_frame + 1;
}

i32 main() {
    thirteen_set_application_name("Thirteen Demo - Simple");
    g_pixels = thirteen_init(c_width, c_height, c_fullscreen);
    if g_pixels == null { return 1; }
    thirteen_run(on_frame);
    return 0;
}
