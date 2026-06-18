// thirteen-minc — open a window, get a pointer to RGBA pixels.
// minc port of github.com/Atrix256/Thirteen.
//
// ----------------------------------------------------------------------------
// QUICK START
// ----------------------------------------------------------------------------
//
//   import thirteen;
//
//   u8* g_pixels = null;
//   u32 g_w = 800;
//   u32 g_h = 600;
//
//   void on_frame() {
//       for u32 y = 0; y < g_h; y++ {
//           for u32 x = 0; x < g_w; x++ {
//               u32 off = (y * g_w + x) * 4;
//               g_pixels[off + 0] = cast(u8, x);   // R
//               g_pixels[off + 1] = cast(u8, y);   // G
//               g_pixels[off + 2] = 0;             // B
//               g_pixels[off + 3] = 255;           // A
//           }
//       }
//   }
//
//   i32 main() {
//       g_pixels = thirteen_init(g_w, g_h, false);
//       if g_pixels == null { return 1; }
//       thirteen_run(on_frame);
//       return 0;
//   }
//
// ----------------------------------------------------------------------------
// PIXEL FORMAT
// ----------------------------------------------------------------------------
//
// width * height * 4 bytes, row-major, top-left origin. R, G, B, A
// per pixel. A is treated as opaque.
//
// ----------------------------------------------------------------------------
// LIFECYCLE
// ----------------------------------------------------------------------------
//
//   u8* thirteen_init(u32 width, u32 height, bool fullscreen)
//     Open a window, allocate the pixel buffer. Returns the buffer or
//     null on failure.
//
//   bool thirteen_render()
//     Pump platform events, present the pixel buffer. Returns false
//     when the user closes the window.
//
//   void thirteen_run(fn(): void on_frame)
//     Call on_frame once per frame until the window closes or ESC is
//     pressed. Calls thirteen_shutdown before returning.
//
//   void thirteen_shutdown()
//     Free resources. thirteen_run calls this automatically.
//
//   u8* thirteen_set_size(u32 width, u32 height)
//     Resize. May return a different pointer than thirteen_init did.
//
// WINDOW
//
//   void thirteen_set_application_name(u8* name)         // NUL-terminated
//   void thirteen_set_vsync(bool enabled)
//   bool thirteen_get_vsync()
//   void thirteen_set_fullscreen(bool fullscreen)
//   bool thirteen_get_fullscreen()
//   u32  thirteen_get_width()
//   u32  thirteen_get_height()
//   f64  thirteen_get_delta_time()                       // seconds since last render
//
// INPUT
//
//   void thirteen_get_mouse_position(i32* x, i32* y)
//   void thirteen_get_mouse_position_last_frame(i32* x, i32* y)
//   bool thirteen_get_mouse_button(i32 button)           // 0=left 1=right 2=middle
//   bool thirteen_get_mouse_button_last_frame(i32 button)
//   bool thirteen_get_key(i32 keycode)                   // VK_* constants below
//   bool thirteen_get_key_last_frame(i32 keycode)
//
// `_last_frame` variants return the value from the previous render.
// Use them to detect transitions:
//
//     bool pressed_this_frame = thirteen_get_key(VK_SPACE)
//                            && !thirteen_get_key_last_frame(VK_SPACE);
//
// ----------------------------------------------------------------------------
// KEY CODES
// ----------------------------------------------------------------------------
//
// Win32 Virtual-Key codes. VK_A..VK_Z, VK_0..VK_9 follow ASCII.
//
// ----------------------------------------------------------------------------
// PLATFORMS
// ----------------------------------------------------------------------------
//
//   windows  D3D12 + DXGI
//   linux    X11 + GLX + OpenGL
//   macos    Cocoa + Metal
//   wasm     raw wasm + canvas 2D (host JS at thirteen.js)
//
// ----------------------------------------------------------------------------

@gui    // windowed app, no console

// Wasm runtime metadata for `minc run/serve --target wasm`.
@wasm_host "thirteen.js"
@wasm_html "thirteen_shell.html"
@wasm_requires_export "thirteen_frame"

when os(windows) || os(linux) || os(macos) {
    void thirteen_run(fn(): void on_frame) {
        while thirteen_render() && !thirteen_get_key(VK_ESCAPE) {
            on_frame();
        }
        thirteen_shutdown();
    }
}

// Mouse button indices.
i32 THIRTEEN_MOUSE_LEFT   = 0;
i32 THIRTEEN_MOUSE_RIGHT  = 1;
i32 THIRTEEN_MOUSE_MIDDLE = 2;

// Win32 Virtual-Key codes. Per-platform arms translate native
// scancodes to these.
i32 VK_LBUTTON     = 0x01;
i32 VK_RBUTTON     = 0x02;
i32 VK_MBUTTON     = 0x04;
i32 VK_BACK        = 0x08;
i32 VK_TAB         = 0x09;
i32 VK_RETURN      = 0x0D;
i32 VK_SHIFT       = 0x10;
i32 VK_CONTROL     = 0x11;
i32 VK_MENU        = 0x12;   // Alt
i32 VK_PAUSE       = 0x13;
i32 VK_CAPITAL     = 0x14;
i32 VK_ESCAPE      = 0x1B;
i32 VK_SPACE       = 0x20;
i32 VK_PRIOR       = 0x21;   // Page Up
i32 VK_NEXT        = 0x22;   // Page Down
i32 VK_END         = 0x23;
i32 VK_HOME        = 0x24;
i32 VK_LEFT        = 0x25;
i32 VK_UP          = 0x26;
i32 VK_RIGHT       = 0x27;
i32 VK_DOWN        = 0x28;
i32 VK_INSERT      = 0x2D;
i32 VK_DELETE      = 0x2E;

i32 VK_0 = 0x30; i32 VK_1 = 0x31; i32 VK_2 = 0x32; i32 VK_3 = 0x33;
i32 VK_4 = 0x34; i32 VK_5 = 0x35; i32 VK_6 = 0x36; i32 VK_7 = 0x37;
i32 VK_8 = 0x38; i32 VK_9 = 0x39;

i32 VK_A = 0x41; i32 VK_B = 0x42; i32 VK_C = 0x43; i32 VK_D = 0x44;
i32 VK_E = 0x45; i32 VK_F = 0x46; i32 VK_G = 0x47; i32 VK_H = 0x48;
i32 VK_I = 0x49; i32 VK_J = 0x4A; i32 VK_K = 0x4B; i32 VK_L = 0x4C;
i32 VK_M = 0x4D; i32 VK_N = 0x4E; i32 VK_O = 0x4F; i32 VK_P = 0x50;
i32 VK_Q = 0x51; i32 VK_R = 0x52; i32 VK_S = 0x53; i32 VK_T = 0x54;
i32 VK_U = 0x55; i32 VK_V = 0x56; i32 VK_W = 0x57; i32 VK_X = 0x58;
i32 VK_Y = 0x59; i32 VK_Z = 0x5A;

i32 VK_F1  = 0x70; i32 VK_F2  = 0x71; i32 VK_F3  = 0x72; i32 VK_F4  = 0x73;
i32 VK_F5  = 0x74; i32 VK_F6  = 0x75; i32 VK_F7  = 0x76; i32 VK_F8  = 0x77;
i32 VK_F9  = 0x78; i32 VK_F10 = 0x79; i32 VK_F11 = 0x7A; i32 VK_F12 = 0x7B;

// ObjC runtime bridge (objc_msgSend / objc_getClass / sel_registerName).
// Gated so the windows/linux/wasm targets don't pull it in.
when os(macos) {
    import objc_runtime;
}

// ----------------------------------------------------------------------------
// libc helpers
// ----------------------------------------------------------------------------
// thirteen_libc — libc-shaped helpers the thirteen dist needs.

import str;

@must_use void* malloc(u64 size) { return alloc(cast(i32, size)); }

// Bounded strcpy.
void _thirteen_strcpy(u8* dst, u64 cap, u8* src) {
    if cap == 0 { return; }
    u64 i = 0;
    while i < cap - 1 && *(src + i) != 0 {
        *(dst + i) = *(src + i);
        i = i + 1;
    }
    *(dst + i) = 0;
}

// Formats the FPS title bar.
void _thirteen_fmt_fps_title(u8* dst, u64 cap, u8* app_name, f64 fps, f64 ms) {
    i64 fps_t = cast(i64, fps * 10.0 + 0.5);
    i64 ms_t  = cast(i64, ms  * 10.0 + 0.5);
    string s = format("{} - {}.{} FPS ({}.{} ms)",
                      str_from_cstr(app_name),
                      fps_t / 10, fps_t % 10,
                      ms_t  / 10, ms_t  % 10);
    if cap != 0 {
        u64 n = cast(u64, s.len);
        u64 limit = cap - 1;
        if n > limit { n = limit; }
        for u64 i = 0; i < n; i = i + 1 {
            *(dst + i) = *(s.data + i);
        }
        *(dst + n) = 0;
    }
    free(s);
}

// POSIX timespec + clock_gettime stub. Used by the FPS counter on
// linux/macos. CLOCK_MONOTONIC is the clk_id the macOS + Linux arms
// pass; the stub ignores it, so the value is immaterial (it's the
// macOS <time.h> value).
struct timespec { i64 tv_sec; i64 tv_nsec; }
i32 CLOCK_MONOTONIC = 6;
i32 clock_gettime(i32 clk_id, timespec* tp) { return 0; }

// Widen an ASCII string to UTF-16 for the wide-char Win32 entry points.
u16* __wide_literal(u8* s) {
    if s == null { return null; }
    i32 n = 0;
    while *(s + n) != 0 { n = n + 1; }
    u16* buf = alloc<u16>(n + 1);
    for i32 i = 0; i < n; i = i + 1 {
        *(buf + i) = cast(u16, *(s + i));
    }
    *(buf + n) = 0;
    return buf;
}

// ----------------------------------------------------------------------------
// Windows arm (D3D12 + DXGI)
// ----------------------------------------------------------------------------
// win32_thirteen — Win32, D3D12 and DXGI surface the Windows arm calls.

when os(windows) {

// --- kernel32 ---------------------------------------------------------------
extern "kernel32.dll" void* GetModuleHandleA(u8* lpModuleName);
extern "kernel32.dll" i32 QueryPerformanceCounter(void* lpPerformanceCount);
extern "kernel32.dll" i32 QueryPerformanceFrequency(void* lpFrequency);
extern "kernel32.dll" u32 GetLastError();
extern "kernel32.dll" i32 CloseHandle(void* hObject);
extern "kernel32.dll" void* CreateEventA(void* lpEventAttributes, i32 bManualReset,
                                         i32 bInitialState, u8* lpName);
extern "kernel32.dll" u32 WaitForSingleObject(void* hHandle, u32 dwMilliseconds);

// --- user32: window class + lifecycle ---------------------------------------
extern "user32.dll" u16 RegisterClassExW(void* arg);
extern "user32.dll" i32 UnregisterClassW(u16* lpClassName, void* hInstance);
extern "user32.dll" void* LoadCursorA(void* hInstance, u8* lpCursorName);
extern "user32.dll" void* CreateWindowExW(u32 dwExStyle, u16* lpClassName, u16* lpWindowName,
                                          u32 dwStyle, i32 X, i32 Y, i32 nWidth, i32 nHeight,
                                          void* hWndParent, void* hMenu, void* hInstance,
                                          void* lpParam);
extern "user32.dll" i32 DestroyWindow(void* hWnd);
extern "user32.dll" i64 DefWindowProcW(void* hWnd, u32 Msg, u64 wParam, i64 lParam);
extern "user32.dll" i32 ShowWindow(void* hWnd, i32 nCmdShow);
extern "user32.dll" i32 SetWindowPos(void* hWnd, void* hWndInsertAfter, i32 X, i32 Y,
                                     i32 cx, i32 cy, u32 uFlags);
extern "user32.dll" i32 SetWindowLongW(void* hWnd, i32 nIndex, i32 dwNewLong);
extern "user32.dll" i32 AdjustWindowRect(void* lpRect, u32 dwStyle, i32 bMenu);
extern "user32.dll" i32 GetClientRect(void* hWnd, void* lpRect);
extern "user32.dll" i32 SetWindowTextA(void* hWnd, u8* lpString);
extern "user32.dll" void* MonitorFromWindow(void* hWnd, u32 dwFlags);
extern "user32.dll" i32 GetMonitorInfoA(void* hMonitor, void* lpmi);
extern "user32.dll" i32 GetSystemMetrics(i32 nIndex);

// --- user32: message pump ---------------------------------------------------
extern "user32.dll" i32 PeekMessageW(void* lpMsg, void* hWnd, u32 wMsgFilterMin,
                                     u32 wMsgFilterMax, u32 wRemoveMsg);
extern "user32.dll" i32 TranslateMessage(void* lpMsg);
extern "user32.dll" i64 DispatchMessageW(void* lpMsg);

// --- d3d12 + dxgi -----------------------------------------------------------
extern "d3d12.dll" i32 D3D12CreateDevice(void* pAdapter, i32 MinimumFeatureLevel,
                                         void* riid, void** ppDevice);
extern "dxgi.dll" i32 CreateDXGIFactory1(void* riid, void** ppFactory);

}  // when os(windows) — externs

when os(windows) {

i32 FALSE = 0;
i32 TRUE  = 1;

// WindowClass styles.
u32 CS_HREDRAW = cast(u32, 2);
u32 CS_VREDRAW = cast(u32, 1);

// Window styles.
u32 WS_OVERLAPPEDWINDOW = cast(u32, 13565952);    // 0x00CF0000
u32 WS_POPUP            = cast(u32, 2147483648);  // 0x80000000
u32 WS_THICKFRAME       = cast(u32, 262144);      // 0x00040000
u32 WS_MAXIMIZEBOX      = cast(u32, 65536);       // 0x00010000
u32 WS_VISIBLE          = cast(u32, 268435456);   // 0x10000000

// ShowWindow nCmdShow.
i32 SW_SHOW = 5;

// GetWindowLong / SetWindowLong indices.
i32 GWL_STYLE = -16;

// SetWindowPos flags.
u32 SWP_FRAMECHANGED = cast(u32, 32);   // 0x0020
u32 SWP_NOMOVE       = cast(u32, 2);
u32 SWP_NOSIZE       = cast(u32, 1);
u32 SWP_NOZORDER     = cast(u32, 4);

i32 HWND_TOP = 0;
i32 IDC_ARROW = 32512;

// CW_USEDEFAULT = 0x80000000 as a signed i32.
i32 CW_USEDEFAULT = -2147483648;

// WindowMessage codes.
u32 WM_DESTROY       = cast(u32, 2);
u32 WM_CLOSE         = cast(u32, 16);
u32 WM_KEYDOWN       = cast(u32, 256);
u32 WM_KEYUP         = cast(u32, 257);
u32 WM_SYSKEYDOWN    = cast(u32, 260);
u32 WM_SYSKEYUP      = cast(u32, 261);
u32 WM_MOUSEMOVE     = cast(u32, 512);
u32 WM_LBUTTONDOWN   = cast(u32, 513);
u32 WM_LBUTTONUP     = cast(u32, 514);
u32 WM_RBUTTONDOWN   = cast(u32, 516);
u32 WM_RBUTTONUP     = cast(u32, 517);
u32 WM_MBUTTONDOWN   = cast(u32, 519);
u32 WM_MBUTTONUP     = cast(u32, 520);

// PeekMessage wRemoveMsg flags.
u32 PM_REMOVE = cast(u32, 1);

u32 ERROR_CLASS_ALREADY_EXISTS = cast(u32, 1410);

// D3D feature levels.
i32 D3D_FEATURE_LEVEL_11_0 = 45056;   // 0xb000

// D3D12 heap / resource enums.
i32 D3D12_HEAP_TYPE_UPLOAD                   = 2;
i32 D3D12_HEAP_FLAG_NONE                     = 0;
i32 D3D12_RESOURCE_DIMENSION_BUFFER          = 1;
i32 D3D12_RESOURCE_BARRIER_TYPE_TRANSITION   = 0;
u32 D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES  = cast(u32, 4294967295);   // 0xFFFFFFFF
i32 D3D12_RESOURCE_STATE_COPY_DEST           = 1024;
i32 D3D12_RESOURCE_STATE_GENERIC_READ        = 2755;   // 0x0AC3
i32 D3D12_RESOURCE_STATE_PRESENT             = 0;
i32 D3D12_TEXTURE_LAYOUT_ROW_MAJOR           = 1;
i32 D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX = 0;
i32 D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT  = 1;
u32 D3D12_TEXTURE_DATA_PITCH_ALIGNMENT       = cast(u32, 256);

// D3D12 command / descriptor enums.
i32 D3D12_COMMAND_LIST_TYPE_DIRECT   = 0;
i32 D3D12_COMMAND_QUEUE_FLAG_NONE    = 0;
i32 D3D12_DESCRIPTOR_HEAP_TYPE_RTV   = 2;
i32 D3D12_DESCRIPTOR_HEAP_FLAG_NONE  = 0;
i32 D3D12_FENCE_FLAG_NONE            = 0;

i32 D3D12_FEATURE_D3D12_OPTIONS13 = 42;

// DXGI surface format / usage / swap-effect.
i32 DXGI_FORMAT_UNKNOWN                = 0;
i32 DXGI_FORMAT_R8G8B8A8_UNORM         = 28;
u32 DXGI_USAGE_RENDER_TARGET_OUTPUT    = cast(u32, 32);
i32 DXGI_SWAP_EFFECT_FLIP_DISCARD      = 4;
u32 DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING = cast(u32, 2048);
u32 DXGI_PRESENT_ALLOW_TEARING         = cast(u32, 512);
u32 DXGI_MWA_NO_ALT_ENTER              = cast(u32, 2);
i32 DXGI_FEATURE_PRESENT_ALLOW_TEARING = 0;

u32 INFINITE = cast(u32, 4294967295);
u32 MONITOR_DEFAULTTONEAREST = cast(u32, 2);

// GetSystemMetrics indices.
i32 SM_CXSCREEN = 0;
i32 SM_CYSCREEN = 1;

// HIWORD / LOWORD: extract upper / lower 16 bits of an LPARAM.
u16 LOWORD(i64 v) { return cast(u16, cast(u32, v) & cast(u32, 65535)); }
u16 HIWORD(i64 v) { return cast(u16, (cast(u32, v) >> cast(u32, 16)) & cast(u32, 65535)); }

// COM IIDs.
struct THIRTEEN_GUID {
    u32 Data1;
    u16 Data2;
    u16 Data3;
    u8[8] Data4;
}

THIRTEEN_GUID IID_ID3D12Device = THIRTEEN_GUID{ cast(u32, 0x189819f1), cast(u16, 0x1db6), cast(u16, 0x4b57),
    { cast(u8, 0xbe), cast(u8, 0x54), cast(u8, 0x18), cast(u8, 0x21),
      cast(u8, 0x33), cast(u8, 0x9b), cast(u8, 0x85), cast(u8, 0xf7) } };

THIRTEEN_GUID IID_ID3D12CommandQueue = THIRTEEN_GUID{ cast(u32, 0x0ec870a6), cast(u16, 0x5d7e), cast(u16, 0x4c22),
    { cast(u8, 0x8c), cast(u8, 0xfc), cast(u8, 0x5b), cast(u8, 0xaa),
      cast(u8, 0xe0), cast(u8, 0x76), cast(u8, 0x16), cast(u8, 0xed) } };

THIRTEEN_GUID IID_ID3D12Resource = THIRTEEN_GUID{ cast(u32, 0x696442be), cast(u16, 0xa72e), cast(u16, 0x4059),
    { cast(u8, 0xbc), cast(u8, 0x79), cast(u8, 0x5b), cast(u8, 0x5c),
      cast(u8, 0x98), cast(u8, 0x04), cast(u8, 0x0f), cast(u8, 0xad) } };

THIRTEEN_GUID IID_ID3D12CommandAllocator = THIRTEEN_GUID{ cast(u32, 0x6102dee4), cast(u16, 0xaf59), cast(u16, 0x4b09),
    { cast(u8, 0xb9), cast(u8, 0x99), cast(u8, 0xb4), cast(u8, 0x4d),
      cast(u8, 0x73), cast(u8, 0xf0), cast(u8, 0x9b), cast(u8, 0x24) } };

THIRTEEN_GUID IID_ID3D12Fence = THIRTEEN_GUID{ cast(u32, 0x0a753dcf), cast(u16, 0xc4d8), cast(u16, 0x4b91),
    { cast(u8, 0xad), cast(u8, 0xf6), cast(u8, 0xbe), cast(u8, 0x5a),
      cast(u8, 0x60), cast(u8, 0xd9), cast(u8, 0x5a), cast(u8, 0x76) } };

THIRTEEN_GUID IID_ID3D12DescriptorHeap = THIRTEEN_GUID{ cast(u32, 0x8efb471d), cast(u16, 0x616c), cast(u16, 0x4f49),
    { cast(u8, 0x90), cast(u8, 0xf7), cast(u8, 0x12), cast(u8, 0x7b),
      cast(u8, 0xb7), cast(u8, 0x63), cast(u8, 0xfa), cast(u8, 0x51) } };

THIRTEEN_GUID IID_ID3D12GraphicsCommandList = THIRTEEN_GUID{ cast(u32, 0x5b160d0f), cast(u16, 0xac1b), cast(u16, 0x4185),
    { cast(u8, 0x8b), cast(u8, 0xa8), cast(u8, 0xb3), cast(u8, 0xae),
      cast(u8, 0x42), cast(u8, 0xa5), cast(u8, 0xa4), cast(u8, 0x55) } };

THIRTEEN_GUID IID_IDXGIFactory4 = THIRTEEN_GUID{ cast(u32, 0x1bc6ea02), cast(u16, 0xef36), cast(u16, 0x464f),
    { cast(u8, 0xbf), cast(u8, 0x0c), cast(u8, 0x21), cast(u8, 0xca),
      cast(u8, 0x39), cast(u8, 0xe5), cast(u8, 0x16), cast(u8, 0x8a) } };

THIRTEEN_GUID IID_IDXGIFactory5 = THIRTEEN_GUID{ cast(u32, 0x7632e1f5), cast(u16, 0xee65), cast(u16, 0x4dca),
    { cast(u8, 0x87), cast(u8, 0xfd), cast(u8, 0x84), cast(u8, 0xcd),
      cast(u8, 0x75), cast(u8, 0xf8), cast(u8, 0x83), cast(u8, 0x8d) } };

THIRTEEN_GUID IID_IDXGISwapChain3 = THIRTEEN_GUID{ cast(u32, 0x94d99bdb), cast(u16, 0xf1f8), cast(u16, 0x4ab0),
    { cast(u8, 0xb2), cast(u8, 0x36), cast(u8, 0x7d), cast(u8, 0xa0),
      cast(u8, 0x17), cast(u8, 0x0e), cast(u8, 0xda), cast(u8, 0xb1) } };

THIRTEEN_GUID IID_ID3D12Debug = THIRTEEN_GUID{ cast(u32, 0x344488B7), cast(u16, 0x6846), cast(u16, 0x474B),
    { cast(u8, 0xB9), cast(u8, 0x89), cast(u8, 0xF0), cast(u8, 0x27),
      cast(u8, 0x44), cast(u8, 0x82), cast(u8, 0x45), cast(u8, 0xE0) } };

}  // when os(windows) — constants

when os(windows) {
enum __enum_PROCESS_DPI_UNAWARE {
    PROCESS_DPI_UNAWARE = 0,
    PROCESS_SYSTEM_DPI_AWARE = 1,
    PROCESS_PER_MONITOR_DPI_AWARE = 2,
    MDT_EFFECTIVE_DPI = 0,
    MDT_ANGULAR_DPI = 1,
    MDT_RAW_DPI = 2,
}

type PROCESS_DPI_AWARENESS = i32;
type MONITOR_DPI_TYPE = i32;
type BOOL = i32;
type BYTE = u8;
type WORD = u16;
type DWORD = u32;
type UINT = u32;
type INT = i32;
type LONG = i32;
type ULONG = u32;
type LONGLONG = i64;
type ULONGLONG = u64;
type SHORT = i16;
type USHORT = u16;
type CHAR = u8;
type UCHAR = u8;
type WCHAR = u16;
type FLOAT = f32;
type HRESULT = i32;
type ATOM = u16;
type UINT_PTR = u64;
type INT_PTR = i64;
type ULONG_PTR = u64;
type LONG_PTR = i64;
type DWORD_PTR = u64;
type SIZE_T = u64;
type SSIZE_T = i64;
type WPARAM = u64;
type LPARAM = i64;
type LRESULT = i64;
type HANDLE = void*;
type HWND = void*;
type HDC = void*;
type HGLRC = void*;
type HINSTANCE = void*;
type HMODULE = void*;
type HMENU = void*;
type HICON = void*;
type HCURSOR = void*;
type HBRUSH = void*;
type HMONITOR = void*;
type HDROP = void*;
type HBITMAP = void*;
type HGDIOBJ = void*;
type HKL = void*;
type HRAWINPUT = void*;
type HLOCAL = void*;
type FARPROC = void*;
type PROC = void*;
type PVOID = void*;
type LPVOID = void*;
type LPCVOID = void*;
type LPSTR = u8*;
type LPCSTR = u8*;
type LPWSTR = WCHAR*;
type LPCWSTR = WCHAR*;
type LPBYTE = BYTE*;
type LPDWORD = DWORD*;
type LPWORD = WORD*;
type LPLONG = LONG*;
type LPINT = i32*;
type LPUINT = UINT*;
type LPUNKNOWN = void*;
type WNDPROC = fn(HWND, UINT, WPARAM, LPARAM): LRESULT;
type LPRECT = RECT*;
type errno_t = i32;
type handle_type = i64;
type DPI_AWARENESS_CONTEXT_T = void*;
type UINT64 = u64;
type DXGI_SAMPLE_DESC_int = i32;
type IID = GUID;
// ========== Type Definitions ==========
type thirteen_uint8 = u8;
type thirteen_uint32 = u32;
type ThirteenNativeWindowHandle = HWND;
struct LARGE_INTEGER {
    i64 QuadPart;
}

struct POINT {
    LONG x;
    LONG y;
}

struct POINTL {
    LONG x;
    LONG y;
}

struct RECT {
    LONG left;
    LONG top;
    LONG right;
    LONG bottom;
}

struct SIZE {
    WORD cx;
    WORD cy;
}

struct MSG {
    HWND hwnd;
    UINT message;
    WPARAM wParam;
    LPARAM lParam;
    DWORD time;
    POINT pt;
}

struct WNDCLASSW {
    UINT style;
    WNDPROC lpfnWndProc;
    i32 cbClsExtra;
    i32 cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    LPCWSTR lpszMenuName;
    LPCWSTR lpszClassName;
}

struct WNDCLASSEXW {
    UINT cbSize;
    UINT style;
    WNDPROC lpfnWndProc;
    i32 cbClsExtra;
    i32 cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    LPCWSTR lpszMenuName;
    LPCWSTR lpszClassName;
    HICON hIconSm;
}

struct PIXELFORMATDESCRIPTOR {
    WORD nSize;
    WORD nVersion;
    DWORD dwFlags;
    BYTE iPixelType;
    BYTE cColorBits;
    BYTE cRedBits;
    BYTE cRedShift;
    BYTE cGreenBits;
    BYTE cGreenShift;
    BYTE cBlueBits;
    BYTE cBlueShift;
    BYTE cAlphaBits;
    BYTE cAlphaShift;
    BYTE cAccumBits;
    BYTE cAccumRedBits;
    BYTE cAccumGreenBits;
    BYTE cAccumBlueBits;
    BYTE cAccumAlphaBits;
    BYTE cDepthBits;
    BYTE cStencilBits;
    BYTE cAuxBuffers;
    BYTE iLayerType;
    BYTE bReserved;
    DWORD dwLayerMask;
    DWORD dwVisibleMask;
    DWORD dwDamageMask;
}

struct TRACKMOUSEEVENT {
    DWORD cbSize;
    DWORD dwFlags;
    HWND hwndTrack;
    DWORD dwHoverTime;
}

struct CURSORINFO {
    DWORD cbSize;
    DWORD flags;
    HCURSOR hCursor;
    POINT ptScreenPos;
}

struct MONITORINFO {
    DWORD cbSize;
    RECT rcMonitor;
    RECT rcWork;
    DWORD dwFlags;
}

struct SIZEL {
    LONG cx;
    LONG cy;
}

struct WINDOWPLACEMENT_STUB {
    DWORD style;
    DWORD dwExtendedStyle;
    DWORD cdxStyle;
    LONG x;
    LONG y;
    LONG cx;
    LONG cy;
}

struct DEVMODEW {
    LONG dmType;
    DWORD dmFields;
    DWORD dmPelsWidth;
    DWORD dmPelsHeight;
    DWORD dmBitsPerPel;
    DWORD dmDisplayFrequency;
}

struct OSVERSIONINFOW {
    DWORD dwOSVersionInfoSize;
    DWORD dwMajorVersion;
    DWORD dwMinorVersion;
    DWORD dwBuildNumber;
    DWORD dwPlatformId;
}

struct RAWINPUTHEADER {
    DWORD dwType;
    DWORD dwSize;
    HANDLE hDevice;
    WPARAM wParam;
}

struct RAWINPUTDEVICE {
    USHORT usUsagePage;
    USHORT usUsage;
    DWORD dwFlags;
    HWND hwndTarget;
}

struct RAWMOUSE {
    USHORT usFlags;
    ULONG _pad_buttons;
    ULONG ulRawButtons;
    LONG lLastX;
    LONG lLastY;
    ULONG ulExtraInformation;
}

struct RAWINPUT {
    RAWINPUTHEADER header;
    struct {
        RAWMOUSE mouse;
    } data;
}

struct BITMAPV5HEADER {
    DWORD bV5Size;
    LONG bV5Width;
    LONG bV5Height;
    WORD bV5Planes;
    WORD bV5BitCount;
    DWORD bV5Compression;
    DWORD bV5SizeImage;
    LONG bV5XPelsPerMeter;
    LONG bV5YPelsPerMeter;
    DWORD bV5ClrUsed;
    DWORD bV5ClrImportant;
    DWORD bV5RedMask;
    DWORD bV5GreenMask;
    DWORD bV5BlueMask;
    DWORD bV5AlphaMask;
}

struct BITMAPINFO {
    DWORD _unused;
}

struct ICONINFO {
    BOOL fIcon;
    DWORD xHotspot;
    DWORD yHotspot;
    HBITMAP hbmMask;
    HBITMAP hbmColor;
}

struct IUnknownVtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
}

struct IUnknown {
    IUnknownVtbl* lpVtbl;
}

struct DXGI_RATIONAL {
    u32 Numerator;
    u32 Denominator;
}

struct DXGI_SAMPLE_DESC {
    u32 Count;
    u32 Quality;
}

struct DXGI_SWAP_CHAIN_DESC1 {
    u32 Width;
    u32 Height;
    i32 Format;
    BOOL Stereo;
    DXGI_SAMPLE_DESC SampleDesc;
    u32 BufferUsage;
    u32 BufferCount;
    i32 Scaling;
    i32 SwapEffect;
    i32 AlphaMode;
    u32 Flags;
}

struct D3D12_HEAP_PROPERTIES {
    i32 Type;
    i32 CPUPageProperty;
    i32 MemoryPoolPreference;
    u32 CreationNodeMask;
    u32 VisibleNodeMask;
}

struct D3D12_RESOURCE_DESC {
    i32 Dimension;
    u64 Alignment;
    u64 Width;
    u32 Height;
    u16 DepthOrArraySize;
    u16 MipLevels;
    i32 Format;
    DXGI_SAMPLE_DESC SampleDesc;
    i32 Layout;
    u32 Flags;
}

struct D3D12_COMMAND_QUEUE_DESC {
    i32 Type;
    i32 Priority;
    u32 Flags;
    u32 NodeMask;
}

struct D3D12_DESCRIPTOR_HEAP_DESC {
    i32 Type;
    u32 NumDescriptors;
    u32 Flags;
    u32 NodeMask;
}

struct D3D12_RESOURCE_TRANSITION_BARRIER {
    void* pResource;
    u32 Subresource;
    u32 StateBefore;
    u32 StateAfter;
}

struct D3D12_RESOURCE_BARRIER {
    i32 Type;
    u32 Flags;
    D3D12_RESOURCE_TRANSITION_BARRIER Transition;
}

struct D3D12_RANGE {
    u64 Begin;
    u64 End;
}

struct D3D12_SUBRESOURCE_FOOTPRINT {
    i32 Format;
    u32 Width;
    u32 Height;
    u32 Depth;
    u32 RowPitch;
}

struct D3D12_PLACED_SUBRESOURCE_FOOTPRINT {
    u64 Offset;
    D3D12_SUBRESOURCE_FOOTPRINT Footprint;
}

struct D3D12_TEXTURE_COPY_LOCATION {
    void* pResource;
    i32 Type;
    D3D12_PLACED_SUBRESOURCE_FOOTPRINT PlacedFootprint;
    u32 SubresourceIndex;
}

struct D3D12_CPU_DESCRIPTOR_HANDLE {
    u64 ptr;
}

struct D3D12_GPU_DESCRIPTOR_HANDLE {
    u64 ptr;
}

struct D3D12_FEATURE_DATA_D3D12_OPTIONS13 {
    BOOL UnrestrictedBufferTextureCopyPitchSupported;
    BOOL UnrestrictedVertexElementAlignmentSupported;
    BOOL InvertedViewportHeightFlipsYSupported;
    BOOL InvertedViewportDepthFlipsZSupported;
    BOOL TextureCopyBetweenDimensionsSupported;
    BOOL AlphaBlendFactorSupported;
}

struct ID3D12DebugVtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    fn(void*): void EnableDebugLayer;
}

struct ID3D12Debug {
    ID3D12DebugVtbl* lpVtbl;
}

struct ID3D12Debug1Vtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    fn(void*): void EnableDebugLayer;
    fn(void*, BOOL): void SetEnableGPUBasedValidation;
    fn(void*, BOOL): void SetEnableSynchronizedCommandQueueValidation;
}

struct ID3D12Debug1 {
    ID3D12Debug1Vtbl* lpVtbl;
}

struct ID3D12InfoQueueVtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad6;
    void* _pad7;
    void* _pad8;
    void* _pad9;
    void* _pad10;
    void* _pad11;
    void* _pad12;
    void* _pad13;
    void* _pad14;
    void* _pad15;
    void* _pad16;
    void* _pad17;
    void* _pad18;
    void* _pad19;
    fn(void*, void*): i32 AddStorageFilterEntries;
}

struct ID3D12InfoQueue {
    ID3D12InfoQueueVtbl* lpVtbl;
}

struct ID3D12CommandListVtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad_setname;
    void* _pad6;
    fn(void*): i32 GetType;
}

struct ID3D12CommandList {
    ID3D12CommandListVtbl* lpVtbl;
}

struct ID3D12GraphicsCommandListVtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad_setname;
    void* _pad6;
    void* _pad7;
    fn(void*): i32 Close;
    fn(void*, void*, void*): i32 Reset;
    void* _pad10;
    void* _pad11;
    void* _pad12;
    void* _pad13;
    void* _pad14;
    fn(void*, D3D12_TEXTURE_COPY_LOCATION*, u32, u32, u32, D3D12_TEXTURE_COPY_LOCATION*, void*): void CopyTextureRegion;
    void* _pad16;
    void* _pad17;
    void* _pad18;
    void* _pad19;
    void* _pad20;
    void* _pad21;
    void* _pad22;
    void* _pad23;
    void* _pad24;
    fn(void*, u32, D3D12_RESOURCE_BARRIER*): void ResourceBarrier;
    void* _pad26;
    void* _pad27;
    void* _pad28;
    void* _pad29;
    void* _pad30;
    void* _pad31;
    void* _pad32;
    void* _pad33;
    void* _pad34;
    void* _pad35;
    void* _pad36;
    void* _pad37;
    void* _pad38;
    void* _pad39;
    void* _pad40;
    void* _pad41;
    void* _pad42;
    void* _pad43;
    void* _pad44;
    fn(void*, u32, D3D12_CPU_DESCRIPTOR_HANDLE*, BOOL, D3D12_CPU_DESCRIPTOR_HANDLE*): void OMSetRenderTargets;
    fn(void*, D3D12_CPU_DESCRIPTOR_HANDLE, i32, f32, u8, u32, void*): void ClearDepthStencilView;
    fn(void*, D3D12_CPU_DESCRIPTOR_HANDLE, f32*, u32, void*): void ClearRenderTargetView;
}

struct ID3D12GraphicsCommandList {
    ID3D12GraphicsCommandListVtbl* lpVtbl;
}

struct ID3D12CommandAllocatorVtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad_setname;
    void* _pad6;
    fn(void*): i32 Reset;
}

struct ID3D12CommandAllocator {
    ID3D12CommandAllocatorVtbl* lpVtbl;
}

struct ID3D12CommandQueueVtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad_setname;
    void* _pad6;
    void* _pad7;
    void* _pad8;
    fn(void*, u32, void*): void ExecuteCommandLists;
    void* _pad10;
    void* _pad11;
    void* _pad12;
    fn(void*, void*, u64): i32 Signal;
    void* _pad14;
    void* _pad15;
    void* _pad16;
    fn(void*): D3D12_COMMAND_QUEUE_DESC GetDesc;
}

struct ID3D12CommandQueue {
    ID3D12CommandQueueVtbl* lpVtbl;
}

struct ID3D12DescriptorHeapVtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad_setname;
    void* _pad6;
    void* _pad_getdesc;
    fn(void*, D3D12_CPU_DESCRIPTOR_HANDLE*): void GetCPUDescriptorHandleForHeapStart;
    fn(void*, D3D12_GPU_DESCRIPTOR_HANDLE*): void GetGPUDescriptorHandleForHeapStart;
}

struct ID3D12DescriptorHeap {
    ID3D12DescriptorHeapVtbl* lpVtbl;
}

struct ID3D12ResourceVtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad_setname;
    void* _pad6;
    fn(void*, u32, D3D12_RANGE*, void**): i32 Map;
    fn(void*, u32, D3D12_RANGE*): void Unmap;
    fn(void*): D3D12_RESOURCE_DESC GetDesc;
    fn(void*): u64 GetGPUVirtualAddress;
}

struct ID3D12Resource {
    ID3D12ResourceVtbl* lpVtbl;
}

struct ID3D12FenceVtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad_setname;
    void* _pad6;
    fn(void*): u64 GetCompletedValue;
    fn(void*, u64, HANDLE): i32 SetEventOnCompletion;
    fn(void*, u64): i32 Signal;
}

struct ID3D12Fence {
    ID3D12FenceVtbl* lpVtbl;
}

struct ID3D12DeviceVtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad6;
    void* _pad7;
    fn(void*, D3D12_COMMAND_QUEUE_DESC*, void*, void**): i32 CreateCommandQueue;
    fn(void*, i32, void*, void**): i32 CreateCommandAllocator;
    void* _pad10;
    void* _pad11;
    fn(void*, u32, i32, void*, void*, void*, void**): i32 CreateCommandList;
    fn(void*, i32, void*, u32): i32 CheckFeatureSupport;
    fn(void*, D3D12_DESCRIPTOR_HEAP_DESC*, void*, void**): i32 CreateDescriptorHeap;
    fn(void*, i32): u32 GetDescriptorHandleIncrementSize;
    void* _pad16;
    void* _pad17;
    void* _pad18;
    void* _pad19;
    fn(void*, void*, void*, D3D12_CPU_DESCRIPTOR_HANDLE): void CreateRenderTargetView;
    void* _pad21;
    void* _pad22;
    void* _pad23;
    void* _pad24;
    void* _pad25;
    void* _pad26;
    fn(void*, D3D12_HEAP_PROPERTIES*, i32, D3D12_RESOURCE_DESC*, u32, void*, void*, void**): i32 CreateCommittedResource;
    void* _pad28;
    void* _pad29;
    void* _pad30;
    void* _pad31;
    void* _pad32;
    void* _pad33;
    void* _pad34;
    void* _pad35;
    fn(void*, u64, i32, void*, void**): i32 CreateFence;
    void* _pad37;
    fn(void*, D3D12_RESOURCE_DESC*, u32, u32, u64, D3D12_PLACED_SUBRESOURCE_FOOTPRINT*, u32*, u64*, u64*): void GetCopyableFootprints;
}

struct ID3D12Device {
    ID3D12DeviceVtbl* lpVtbl;
}

struct ID3D12DebugVtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    fn(void*): void EnableDebugLayer;
}

struct ID3D12Debug {
    ID3D12DebugVtbl* lpVtbl;
}

struct IDXGISwapChain1Vtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad6;
    void* _pad7;
    void* _pad8;
    void* _pad9;
    void* _pad10;
    void* _pad11;
    void* _pad12;
    void* _pad13;
    void* _pad14;
    void* _pad15;
    void* _pad16;
    void* _pad17;
}

struct IDXGISwapChain1 {
    IDXGISwapChain1Vtbl* lpVtbl;
}

struct IDXGISwapChain3Vtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad6;
    void* _pad7;
    fn(void*, u32, u32): i32 Present;
    fn(void*, u32, void*, void**): i32 GetBuffer;
    void* _pad10;
    void* _pad11;
    void* _pad12;
    fn(void*, u32, u32, u32, i32, u32): i32 ResizeBuffers;
    void* _pad14;
    void* _pad15;
    void* _pad16;
    void* _pad17;
    void* _pad18;
    void* _pad19;
    void* _pad20;
    void* _pad21;
    void* _pad22;
    void* _pad23;
    void* _pad24;
    void* _pad25;
    void* _pad26;
    void* _pad27;
    void* _pad28;
    void* _pad29;
    void* _pad30;
    void* _pad31;
    void* _pad32;
    void* _pad33;
    void* _pad34;
    void* _pad35;
    fn(void*): u32 GetCurrentBackBufferIndex;
}

struct IDXGISwapChain3 {
    IDXGISwapChain3Vtbl* lpVtbl;
}

struct IDXGIFactory4Vtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad6;
    void* _pad7;
    fn(void*, HWND, u32): i32 MakeWindowAssociation;
    void* _pad9;
    void* _pad10;
    void* _pad11;
    void* _pad12;
    void* _pad13;
    void* _pad14;
    fn(void*, void*, HWND, DXGI_SWAP_CHAIN_DESC1*, void*, void*, void**): i32 CreateSwapChainForHwnd;
    void* _pad16;
    void* _pad17;
    void* _pad18;
    void* _pad19;
    void* _pad20;
    void* _pad21;
    void* _pad22;
    void* _pad23;
    void* _pad24;
    void* _pad25;
    void* _pad26;
    void* _pad27;
}

struct IDXGIFactory4 {
    IDXGIFactory4Vtbl* lpVtbl;
}

struct IDXGIFactory5Vtbl {
    fn(void*, void*, void**): i32 QueryInterface;
    fn(void*): u32 AddRef;
    fn(void*): u32 Release;
    void* _pad3;
    void* _pad4;
    void* _pad5;
    void* _pad6;
    void* _pad7;
    fn(void*, HWND, u32): i32 MakeWindowAssociation;
    void* _pad9;
    void* _pad10;
    void* _pad11;
    void* _pad12;
    void* _pad13;
    void* _pad14;
    fn(void*, void*, HWND, DXGI_SWAP_CHAIN_DESC1*, void*, void*, void**): i32 CreateSwapChainForHwnd;
    void* _pad16;
    void* _pad17;
    void* _pad18;
    void* _pad19;
    void* _pad20;
    void* _pad21;
    void* _pad22;
    void* _pad23;
    void* _pad24;
    void* _pad25;
    void* _pad26;
    void* _pad27;
    fn(void*, i32, void*, u32): i32 CheckFeatureSupport;
}

struct IDXGIFactory5 {
    IDXGIFactory5Vtbl* lpVtbl;
}

struct GUID {
    u32 Data1;
    u16 Data2;
    u16 Data3;
    u8[8] Data4;
}

struct ThirteenPlatform {
    HWND hwnd;
    bool ownsClassRegistration;
}

struct ThirteenRenderer {
    ID3D12Device* device;
    ID3D12CommandQueue* commandQueue;
    IDXGISwapChain3* swapChain;
    ID3D12DescriptorHeap* rtvHeap;
    ID3D12Resource*[2] renderTargets;
    ID3D12CommandAllocator* commandAllocator;
    ID3D12GraphicsCommandList* commandList;
    ID3D12Resource* uploadBuffer;
    u64 uploadBufferPitch;
    ID3D12Fence* fence;
    HANDLE fenceEvent;
    UINT64 fenceValue;
    UINT frameIndex;
    UINT rtvDescriptorSize;
    bool tearingSupported;
    bool unrestrictedBufferTextureCopyPitchSupported;
}

// ========== Platform-Specific Includes ==========
// ========== Common Includes ==========
when !defined(THIRTEEN_PLATFORM_WINDOWS) {
}
// ========== Internal State ==========
private { thirteen_uint32 thirteen_width = 320; }
private { thirteen_uint32 thirteen_height = 200; }
private { bool thirteen_should_quit = false; }
private { bool thirteen_vsync_enabled = true; }
private { bool thirteen_is_fullscreen = false; }
private { u8[256] thirteen_app_name = {84, 104, 105, 114, 116, 101, 101, 110, 65, 112, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; }
private { f64 thirteen_last_frame_time = 0.0; }
private { f64 thirteen_last_delta_time = 0.0; }
private { f64 thirteen_frame_time_sum = 0.0; }
private { i32 thirteen_frame_count = 0; }
private { f64 thirteen_average_fps = 0.0; }
private { f64 thirteen_title_update_timer = 0.0; }
private { i32 thirteen_mouse_x = 0; }
private { i32 thirteen_mouse_y = 0; }
private { i32 thirteen_prev_mouse_x = 0; }
private { i32 thirteen_prev_mouse_y = 0; }
private { bool[3] thirteen_mouse_buttons = {false, false, false}; }
private { bool[3] thirteen_prev_mouse_buttons = {false, false, false}; }
private { bool[256] thirteen_keys; }
private { bool[256] thirteen_prev_keys; }
private { thirteen_uint8* thirteen_pixels_buf = null; }
// ========== Timing ==========
private {
f64 thirteen_now_seconds() {
    LARGE_INTEGER freq;
    LARGE_INTEGER counter;
    QueryPerformanceFrequency(&freq);
    QueryPerformanceCounter(&counter);
    return cast(f64, counter.QuadPart) / cast(f64, freq.QuadPart);
}
}
// ==========================================================================
// WINDOWS BACKEND
// ==========================================================================
private { u16[20] THIRTEEN_WND_CLASS = {84, 104, 105, 114, 116, 101, 101, 110, 87, 105, 110, 100, 111, 119, 67, 108, 97, 115, 115, 0}; }
// --- Platform functions ---
private {
bool thirteen_platform_init_window(ThirteenPlatform* p, thirteen_uint32 width, thirteen_uint32 height) {
    WNDCLASSEXW wc;
    DWORD style;
    RECT rect;
    memset(&wc, 0, cast(u64, sizeof(wc)));
    wc.cbSize = cast(UINT, sizeof(WNDCLASSEXW));
    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc = thirteen_wnd_proc;
    wc.hInstance = GetModuleHandleA(null);
    wc.hCursor = LoadCursorA(null, cast(u8*, 32512));
    wc.lpszClassName = THIRTEEN_WND_CLASS;
    if RegisterClassExW(&wc) != 0 {
        p.ownsClassRegistration = true;
    } else if GetLastError() == ERROR_CLASS_ALREADY_EXISTS {
        p.ownsClassRegistration = false;
    } else {
        return false;
    }
    style = WS_OVERLAPPEDWINDOW & ~(WS_THICKFRAME | WS_MAXIMIZEBOX);
    rect.left = 0;
    rect.top = 0;
    rect.right = cast(LONG, width);
    rect.bottom = cast(LONG, height);
    AdjustWindowRect(&rect, style, FALSE);
    p.hwnd = CreateWindowExW(0, THIRTEEN_WND_CLASS, cast(u16*, __wide_literal("Thirteen")), style, cast(i32, 2147483648), cast(i32, 2147483648), rect.right - rect.left, rect.bottom - rect.top, null, null, GetModuleHandleA(null), null);
    if p.hwnd == null {
        return false;
    }
    ShowWindow(p.hwnd, SW_SHOW);
    return true;
}
}
private {
void thirteen_platform_pump_messages(ThirteenPlatform* p) {
    MSG msg;
    ignore p;
    while PeekMessageW(&msg, null, 0, 0, PM_REMOVE) != 0 {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);
    }
}
}
private {
void thirteen_platform_set_title(ThirteenPlatform* p, u8* title) {
    if p.hwnd != null {
        SetWindowTextA(p.hwnd, title);
    }
}
}
private {
void thirteen_platform_set_fullscreen(ThirteenPlatform* p, bool fullscreen, thirteen_uint32 width, thirteen_uint32 height) {
    if p.hwnd == null {
        return;
    }
    if fullscreen != 0 {
        HMONITOR hMonitor;
        MONITORINFO mi;
        SetWindowLongW(p.hwnd, GWL_STYLE, WS_POPUP | WS_VISIBLE);
        hMonitor = MonitorFromWindow(p.hwnd, MONITOR_DEFAULTTONEAREST);
        mi.cbSize = cast(DWORD, sizeof(mi));
        GetMonitorInfoA(hMonitor, &mi);
        SetWindowPos(p.hwnd, null, mi.rcMonitor.left, mi.rcMonitor.top, mi.rcMonitor.right - mi.rcMonitor.left, mi.rcMonitor.bottom - mi.rcMonitor.top, SWP_FRAMECHANGED);
    } else {
        DWORD style = WS_OVERLAPPEDWINDOW & ~(WS_THICKFRAME | WS_MAXIMIZEBOX);
        RECT rect;
        i32 screenWidth;
        i32 screenHeight;
        i32 windowWidth;
        i32 windowHeight;
        i32 x;
        i32 y;
        SetWindowLongW(p.hwnd, GWL_STYLE, style | WS_VISIBLE);
        rect.left = 0;
        rect.top = 0;
        rect.right = cast(LONG, width);
        rect.bottom = cast(LONG, height);
        AdjustWindowRect(&rect, style, FALSE);
        screenWidth = GetSystemMetrics(SM_CXSCREEN);
        screenHeight = GetSystemMetrics(SM_CYSCREEN);
        windowWidth = rect.right - rect.left;
        windowHeight = rect.bottom - rect.top;
        x = (screenWidth - windowWidth) / 2;
        y = (screenHeight - windowHeight) / 2;
        SetWindowPos(p.hwnd, null, x, y, windowWidth, windowHeight, SWP_FRAMECHANGED);
    }
}
}
private {
void thirteen_platform_resize_window(ThirteenPlatform* p, thirteen_uint32 width, thirteen_uint32 height, bool isFullscreen) {
    DWORD style;
    RECT rect;
    i32 screenWidth;
    i32 screenHeight;
    i32 windowWidth;
    i32 windowHeight;
    i32 x;
    i32 y;
    if !p.hwnd || isFullscreen {
        return;
    }
    style = WS_OVERLAPPEDWINDOW & ~(WS_THICKFRAME | WS_MAXIMIZEBOX);
    rect.left = 0;
    rect.top = 0;
    rect.right = cast(LONG, width);
    rect.bottom = cast(LONG, height);
    AdjustWindowRect(&rect, style, FALSE);
    screenWidth = GetSystemMetrics(SM_CXSCREEN);
    screenHeight = GetSystemMetrics(SM_CYSCREEN);
    windowWidth = rect.right - rect.left;
    windowHeight = rect.bottom - rect.top;
    x = (screenWidth - windowWidth) / 2;
    y = (screenHeight - windowHeight) / 2;
    SetWindowPos(p.hwnd, null, x, y, windowWidth, windowHeight, SWP_FRAMECHANGED);
}
}
private {
ThirteenNativeWindowHandle thirteen_platform_get_window_handle(ThirteenPlatform* p) {
    return p.hwnd;
}
}
private {
void thirteen_platform_shutdown_window(ThirteenPlatform* p) {
    if p.hwnd != null {
        DestroyWindow(p.hwnd);
        p.hwnd = null;
    }
    if p.ownsClassRegistration != 0 {
        UnregisterClassW(THIRTEEN_WND_CLASS, GetModuleHandleA(null));
        p.ownsClassRegistration = false;
    }
}
}
// --- Renderer functions ---
private {
void thirteen_renderer_wait_for_gpu(ThirteenRenderer* r) {
    UINT64 currentFenceValue;
    if !r.fence || !r.commandQueue {
        return;
    }
    currentFenceValue = r.fenceValue;
    r.commandQueue.lpVtbl.Signal(r.commandQueue, r.fence, currentFenceValue);
    r.fenceValue++;
    if r.fence.lpVtbl.GetCompletedValue(r.fence) < currentFenceValue {
        r.fence.lpVtbl.SetEventOnCompletion(r.fence, currentFenceValue, r.fenceEvent);
        WaitForSingleObject(r.fenceEvent, INFINITE);
    }
}
}
private {
void thirteen_renderer_release_render_targets(ThirteenRenderer* r) {
    if r.renderTargets[0] != null {
        r.renderTargets[0].lpVtbl.Release(r.renderTargets[0]);
        r.renderTargets[0] = null;
    }
    if r.renderTargets[1] != null {
        r.renderTargets[1].lpVtbl.Release(r.renderTargets[1]);
        r.renderTargets[1] = null;
    }
}
}
private {
bool thirteen_renderer_create_upload_buffer(ThirteenRenderer* r, thirteen_uint32 width, thirteen_uint32 height) {
    D3D12_HEAP_PROPERTIES heapProps;
    D3D12_RESOURCE_DESC bufferDesc;
    u64 rowBytes;
    u64 pitch;
    memset(&heapProps, 0, cast(u64, sizeof(heapProps)));
    heapProps.Type = D3D12_HEAP_TYPE_UPLOAD;
    rowBytes = cast(u64, width) * 4;
    if r.unrestrictedBufferTextureCopyPitchSupported != 0 {
        pitch = rowBytes;
    } else {
        pitch = (rowBytes + D3D12_TEXTURE_DATA_PITCH_ALIGNMENT - 1) / D3D12_TEXTURE_DATA_PITCH_ALIGNMENT * D3D12_TEXTURE_DATA_PITCH_ALIGNMENT;
    }
    r.uploadBufferPitch = pitch;
    memset(&bufferDesc, 0, cast(u64, sizeof(bufferDesc)));
    bufferDesc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
    bufferDesc.Width = cast(UINT64, pitch) * height;
    bufferDesc.Height = 1;
    bufferDesc.DepthOrArraySize = 1;
    bufferDesc.MipLevels = 1;
    bufferDesc.Format = DXGI_FORMAT_UNKNOWN;
    bufferDesc.SampleDesc.Count = 1;
    bufferDesc.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
    return r.device.lpVtbl.CreateCommittedResource(r.device, &heapProps, D3D12_HEAP_FLAG_NONE, &bufferDesc, D3D12_RESOURCE_STATE_GENERIC_READ, null, &IID_ID3D12Resource, cast(void**, &r.uploadBuffer)) >= 0;
}
}
private {
bool thirteen_renderer_init(ThirteenRenderer* r, ThirteenPlatform* p, thirteen_uint32 width, thirteen_uint32 height) {
    ThirteenNativeWindowHandle hwnd = thirteen_platform_get_window_handle(p);
    IDXGIFactory4* factory = null;
    IDXGISwapChain1* swapChain1 = null;
    HRESULT hr;
    D3D12_CPU_DESCRIPTOR_HANDLE rtvHandle;
    UINT i;
    if D3D12CreateDevice(null, D3D_FEATURE_LEVEL_11_0, &IID_ID3D12Device, cast(void**, &r.device)) < 0 {
        return false;
    }
    {
        D3D12_FEATURE_DATA_D3D12_OPTIONS13 options;
        if r.device.lpVtbl.CheckFeatureSupport(r.device, D3D12_FEATURE_D3D12_OPTIONS13, &options, cast(u32, sizeof(options))) >= 0 {
            r.unrestrictedBufferTextureCopyPitchSupported = options.UnrestrictedBufferTextureCopyPitchSupported != 0 ? true : false;
        }
    }
    {
        D3D12_COMMAND_QUEUE_DESC queueDesc;
        queueDesc.Type = D3D12_COMMAND_LIST_TYPE_DIRECT;
        queueDesc.Flags = D3D12_COMMAND_QUEUE_FLAG_NONE;
        if r.device.lpVtbl.CreateCommandQueue(r.device, &queueDesc, &IID_ID3D12CommandQueue, cast(void**, &r.commandQueue)) < 0 {
            return false;
        }
    }
    if CreateDXGIFactory1(&IID_IDXGIFactory4, cast(void**, &factory)) < 0 {
        return false;
    }
    {
        IDXGIFactory5* factory5 = null;
        if factory.lpVtbl.QueryInterface(factory, &IID_IDXGIFactory5, cast(void**, &factory5)) >= 0 {
            BOOL allowTearing = FALSE;
            if factory5.lpVtbl.CheckFeatureSupport(factory5, DXGI_FEATURE_PRESENT_ALLOW_TEARING, &allowTearing, cast(u32, sizeof(allowTearing))) >= 0 {
                r.tearingSupported = allowTearing == TRUE;
            }
            factory5.lpVtbl.Release(factory5);
        }
    }
    {
        DXGI_SWAP_CHAIN_DESC1 swapChainDesc;
        swapChainDesc.BufferCount = 2;
        swapChainDesc.Width = width;
        swapChainDesc.Height = height;
        swapChainDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
        swapChainDesc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
        swapChainDesc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_DISCARD;
        swapChainDesc.SampleDesc.Count = 1;
        swapChainDesc.Flags = cast(u32, r.tearingSupported != 0 ? DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING : 0);
        hr = factory.lpVtbl.CreateSwapChainForHwnd(factory, cast(IUnknown*, r.commandQueue), hwnd, &swapChainDesc, null, null, cast(void**, &swapChain1));
    }
    factory.lpVtbl.MakeWindowAssociation(factory, hwnd, DXGI_MWA_NO_ALT_ENTER);
    factory.lpVtbl.Release(factory);
    if hr < 0 {
        return false;
    }
    swapChain1.lpVtbl.QueryInterface(swapChain1, &IID_IDXGISwapChain3, cast(void**, &r.swapChain));
    swapChain1.lpVtbl.Release(swapChain1);
    r.frameIndex = r.swapChain.lpVtbl.GetCurrentBackBufferIndex(r.swapChain);
    {
        D3D12_DESCRIPTOR_HEAP_DESC rtvHeapDesc;
        rtvHeapDesc.NumDescriptors = 2;
        rtvHeapDesc.Type = D3D12_DESCRIPTOR_HEAP_TYPE_RTV;
        rtvHeapDesc.Flags = D3D12_DESCRIPTOR_HEAP_FLAG_NONE;
        if r.device.lpVtbl.CreateDescriptorHeap(r.device, &rtvHeapDesc, &IID_ID3D12DescriptorHeap, cast(void**, &r.rtvHeap)) < 0 {
            return false;
        }
    }
    r.rtvDescriptorSize = r.device.lpVtbl.GetDescriptorHandleIncrementSize(r.device, D3D12_DESCRIPTOR_HEAP_TYPE_RTV);
    r.rtvHeap.lpVtbl.GetCPUDescriptorHandleForHeapStart(r.rtvHeap, &rtvHandle);
    for i = 0; i < 2; i++ {
        if r.swapChain.lpVtbl.GetBuffer(r.swapChain, i, &IID_ID3D12Resource, cast(void**, &r.renderTargets[i])) < 0 {
            return false;
        }
        r.device.lpVtbl.CreateRenderTargetView(r.device, r.renderTargets[i], null, rtvHandle);
        rtvHandle.ptr += r.rtvDescriptorSize;
    }
    if r.device.lpVtbl.CreateCommandAllocator(r.device, D3D12_COMMAND_LIST_TYPE_DIRECT, &IID_ID3D12CommandAllocator, cast(void**, &r.commandAllocator)) < 0 {
        return false;
    }
    if r.device.lpVtbl.CreateCommandList(r.device, 0, D3D12_COMMAND_LIST_TYPE_DIRECT, r.commandAllocator, null, &IID_ID3D12GraphicsCommandList, cast(void**, &r.commandList)) < 0 {
        return false;
    }
    r.commandList.lpVtbl.Close(r.commandList);
    if thirteen_renderer_create_upload_buffer(r, width, height) == 0 {
        return false;
    }
    if r.device.lpVtbl.CreateFence(r.device, 0, D3D12_FENCE_FLAG_NONE, &IID_ID3D12Fence, cast(void**, &r.fence)) < 0 {
        return false;
    }
    r.fenceValue = 1;
    r.fenceEvent = CreateEventA(null, FALSE, FALSE, null);
    return r.fenceEvent != null;
}
}
private {
bool thirteen_renderer_render(ThirteenRenderer* r, thirteen_uint8* pixels, thirteen_uint32 width, thirteen_uint32 height, bool vsyncEnabled) {
    void* mappedData = null;
    D3D12_RANGE readRange;
    D3D12_RESOURCE_BARRIER barrier;
    D3D12_TEXTURE_COPY_LOCATION dst;
    D3D12_TEXTURE_COPY_LOCATION src;
    ID3D12CommandList*[1] cmdLists;
    UINT syncInterval;
    UINT presentFlags;
    thirteen_renderer_wait_for_gpu(r);
    r.frameIndex = r.swapChain.lpVtbl.GetCurrentBackBufferIndex(r.swapChain);
    readRange.Begin = 1;
    readRange.End = 0;
    r.uploadBuffer.lpVtbl.Map(r.uploadBuffer, 0, &readRange, &mappedData);
    if r.uploadBufferPitch != cast(u64, width) * 4 {
        thirteen_uint32 row;
        u64 rowBytes = cast(u64, width) * 4;
        for row = 0; row < height; row++ {
            thirteen_uint8* dst = cast(thirteen_uint8*, mappedData) + cast(u64, row) * r.uploadBufferPitch;
            thirteen_uint8* srcRow = pixels + cast(u64, row) * rowBytes;
            memcpy(dst, srcRow, rowBytes);
        }
    } else {
        memcpy(mappedData, pixels, cast(u64, width) * height * 4);
    }
    r.uploadBuffer.lpVtbl.Unmap(r.uploadBuffer, 0, null);
    r.commandAllocator.lpVtbl.Reset(r.commandAllocator);
    r.commandList.lpVtbl.Reset(r.commandList, r.commandAllocator, null);
    memset(&barrier, 0, cast(u64, sizeof(barrier)));
    barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    barrier.Transition.pResource = r.renderTargets[r.frameIndex];
    barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_PRESENT;
    barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_COPY_DEST;
    barrier.Transition.Subresource = D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES;
    r.commandList.lpVtbl.ResourceBarrier(r.commandList, 1, &barrier);
    memset(&dst, 0, cast(u64, sizeof(dst)));
    dst.pResource = r.renderTargets[r.frameIndex];
    dst.Type = D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX;
    dst.SubresourceIndex = 0;
    memset(&src, 0, cast(u64, sizeof(src)));
    src.pResource = r.uploadBuffer;
    src.Type = D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT;
    src.PlacedFootprint.Footprint.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    src.PlacedFootprint.Footprint.Width = width;
    src.PlacedFootprint.Footprint.Height = height;
    src.PlacedFootprint.Footprint.Depth = 1;
    src.PlacedFootprint.Footprint.RowPitch = cast(UINT, r.uploadBufferPitch);
    r.commandList.lpVtbl.CopyTextureRegion(r.commandList, &dst, 0, 0, 0, &src, null);
    barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_COPY_DEST;
    barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT;
    r.commandList.lpVtbl.ResourceBarrier(r.commandList, 1, &barrier);
    r.commandList.lpVtbl.Close(r.commandList);
    cmdLists[0] = cast(ID3D12CommandList*, r.commandList);
    r.commandQueue.lpVtbl.ExecuteCommandLists(r.commandQueue, 1, cmdLists);
    syncInterval = cast(u32, vsyncEnabled != 0 ? 1 : 0);
    presentFlags = cast(u32, !vsyncEnabled && r.tearingSupported ? DXGI_PRESENT_ALLOW_TEARING : 0);
    return r.swapChain.lpVtbl.Present(r.swapChain, syncInterval, presentFlags) >= 0;
}
}
private {
bool thirteen_renderer_resize(ThirteenRenderer* r, thirteen_uint32 width, thirteen_uint32 height) {
    HRESULT hr;
    D3D12_CPU_DESCRIPTOR_HANDLE rtvHandle;
    UINT i;
    thirteen_renderer_wait_for_gpu(r);
    thirteen_renderer_release_render_targets(r);
    if r.uploadBuffer != null {
        r.uploadBuffer.lpVtbl.Release(r.uploadBuffer);
        r.uploadBuffer = null;
    }
    hr = r.swapChain.lpVtbl.ResizeBuffers(r.swapChain, 2, width, height, DXGI_FORMAT_R8G8B8A8_UNORM, cast(u32, r.tearingSupported != 0 ? DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING : 0));
    if hr < 0 {
        return false;
    }
    r.rtvHeap.lpVtbl.GetCPUDescriptorHandleForHeapStart(r.rtvHeap, &rtvHandle);
    for i = 0; i < 2; i++ {
        if r.swapChain.lpVtbl.GetBuffer(r.swapChain, i, &IID_ID3D12Resource, cast(void**, &r.renderTargets[i])) < 0 {
            return false;
        }
        r.device.lpVtbl.CreateRenderTargetView(r.device, r.renderTargets[i], null, rtvHandle);
        rtvHandle.ptr += r.rtvDescriptorSize;
    }
    if thirteen_renderer_create_upload_buffer(r, width, height) == 0 {
        return false;
    }
    r.frameIndex = r.swapChain.lpVtbl.GetCurrentBackBufferIndex(r.swapChain);
    return true;
}
}
private {
void thirteen_renderer_shutdown(ThirteenRenderer* r) {
    thirteen_renderer_wait_for_gpu(r);
    if r.fenceEvent != null {
        CloseHandle(r.fenceEvent);
    }
    if r.fence != null {
        r.fence.lpVtbl.Release(r.fence);
    }
    if r.uploadBuffer != null {
        r.uploadBuffer.lpVtbl.Release(r.uploadBuffer);
    }
    if r.commandList != null {
        r.commandList.lpVtbl.Release(r.commandList);
    }
    if r.commandAllocator != null {
        r.commandAllocator.lpVtbl.Release(r.commandAllocator);
    }
    thirteen_renderer_release_render_targets(r);
    if r.rtvHeap != null {
        r.rtvHeap.lpVtbl.Release(r.rtvHeap);
    }
    if r.swapChain != null {
        r.swapChain.lpVtbl.Release(r.swapChain);
    }
    if r.commandQueue != null {
        r.commandQueue.lpVtbl.Release(r.commandQueue);
    }
    if r.device != null {
        r.device.lpVtbl.Release(r.device);
    }
}
}
// ==========================================================================
// WEB BACKEND
// ==========================================================================
// ========== Platform/Renderer Pointers ==========
private { ThirteenPlatform* thirteen_platform_ptr = null; }
private { ThirteenRenderer* thirteen_renderer_ptr = null; }
// ========== WndProc (Windows only) ==========
private {
LRESULT thirteen_wnd_proc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch msg {
        case WM_DESTROY, WM_CLOSE: {
            thirteen_should_quit = true;
            return 0;
        }
        case WM_MOUSEMOVE: {
            {
                var rawX = cast(i32, cast(i16, LOWORD(lParam)));
                var rawY = cast(i32, cast(i16, HIWORD(lParam)));
                if thirteen_is_fullscreen != 0 {
                    RECT clientRect;
                    i32 windowWidth;
                    i32 windowHeight;
                    GetClientRect(hwnd, &clientRect);
                    windowWidth = clientRect.right - clientRect.left;
                    windowHeight = clientRect.bottom - clientRect.top;
                    thirteen_mouse_x = cast(i32, cast(f32, rawX) * cast(f32, thirteen_width) / cast(f32, windowWidth));
                    thirteen_mouse_y = cast(i32, cast(f32, rawY) * cast(f32, thirteen_height) / cast(f32, windowHeight));
                } else {
                    thirteen_mouse_x = rawX;
                    thirteen_mouse_y = rawY;
                }
                return 0;
            }
        }
        case WM_LBUTTONDOWN: {
            thirteen_mouse_buttons[0] = true;
            return 0;
        }
        case WM_LBUTTONUP: {
            thirteen_mouse_buttons[0] = false;
            return 0;
        }
        case WM_RBUTTONDOWN: {
            thirteen_mouse_buttons[1] = true;
            return 0;
        }
        case WM_RBUTTONUP: {
            thirteen_mouse_buttons[1] = false;
            return 0;
        }
        case WM_MBUTTONDOWN: {
            thirteen_mouse_buttons[2] = true;
            return 0;
        }
        case WM_MBUTTONUP: {
            thirteen_mouse_buttons[2] = false;
            return 0;
        }
        case WM_KEYDOWN: {
            if wParam < 256 {
                thirteen_keys[wParam] = true;
            }
            return 0;
        }
        case WM_KEYUP: {
            if wParam < 256 {
                thirteen_keys[wParam] = false;
            }
            return 0;
        }
        case WM_SYSKEYDOWN: {
            if cast(i64, wParam) == VK_RETURN && lParam & 1 << 29 {
                thirteen_set_fullscreen(!thirteen_get_fullscreen());
                return 0;
            }
        }
    }
    return DefWindowProcW(hwnd, msg, wParam, lParam);
}
}
// ========== Public API ==========
thirteen_uint8* thirteen_init(thirteen_uint32 width, thirteen_uint32 height, bool fullscreen) {
    thirteen_width = width;
    thirteen_height = height;
    thirteen_pixels_buf = cast(thirteen_uint8*, alloc(cast(i64, cast(u64, width) * height * 4)));
    if thirteen_pixels_buf == null {
        return null;
    }
    thirteen_platform_ptr = new(ThirteenPlatform[1]);
    if !thirteen_platform_ptr || !thirteen_platform_init_window(thirteen_platform_ptr, width, height) {
        free(thirteen_platform_ptr);
        thirteen_platform_ptr = null;
        free(thirteen_pixels_buf);
        thirteen_pixels_buf = null;
        return null;
    }
    thirteen_renderer_ptr = new(ThirteenRenderer[1]);
    if !thirteen_renderer_ptr || !thirteen_renderer_init(thirteen_renderer_ptr, thirteen_platform_ptr, width, height) {
        if thirteen_renderer_ptr != null {
            thirteen_renderer_shutdown(thirteen_renderer_ptr);
            free(thirteen_renderer_ptr);
            thirteen_renderer_ptr = null;
        }
        thirteen_platform_shutdown_window(thirteen_platform_ptr);
        free(thirteen_platform_ptr);
        thirteen_platform_ptr = null;
        free(thirteen_pixels_buf);
        thirteen_pixels_buf = null;
        return null;
    }
    thirteen_last_frame_time = thirteen_now_seconds();
    if fullscreen != 0 {
        thirteen_set_fullscreen(true);
    }
    return thirteen_pixels_buf;
}

bool thirteen_render() {
    f64 currentTime;
    u8[256] titleBuffer;
    thirteen_prev_mouse_x = thirteen_mouse_x;
    thirteen_prev_mouse_y = thirteen_mouse_y;
    memcpy(thirteen_prev_mouse_buttons, thirteen_mouse_buttons, cast(u64, sizeof(thirteen_mouse_buttons)));
    memcpy(thirteen_prev_keys, thirteen_keys, cast(u64, sizeof(thirteen_keys)));
    currentTime = thirteen_now_seconds();
    thirteen_last_delta_time = currentTime - thirteen_last_frame_time;
    thirteen_last_frame_time = currentTime;
    thirteen_frame_time_sum += thirteen_last_delta_time;
    thirteen_frame_count++;
    if thirteen_frame_time_sum >= 1.0 {
        thirteen_average_fps = cast(f64, thirteen_frame_count) / thirteen_frame_time_sum;
        thirteen_frame_time_sum = 0.0;
        thirteen_frame_count = 0;
    }
    thirteen_title_update_timer += thirteen_last_delta_time;
    if thirteen_title_update_timer >= 0.25 {
        thirteen_title_update_timer = 0.0;
        _thirteen_fmt_fps_title(titleBuffer, sizeof(titleBuffer), thirteen_app_name, thirteen_average_fps, 1000.0 / thirteen_average_fps);
        if thirteen_platform_ptr != null {
            thirteen_platform_set_title(thirteen_platform_ptr, titleBuffer);
        }
    }
    if thirteen_platform_ptr != null {
        thirteen_platform_pump_messages(thirteen_platform_ptr);
    }
    if thirteen_should_quit != 0 {
        return false;
    }
    if thirteen_renderer_ptr == null {
        return false;
    }
    thirteen_renderer_render(thirteen_renderer_ptr, thirteen_pixels_buf, thirteen_width, thirteen_height, thirteen_vsync_enabled);
    return !thirteen_should_quit;
}

void thirteen_set_vsync(bool enabled) {
    thirteen_vsync_enabled = enabled;
}

bool thirteen_get_vsync() {
    return thirteen_vsync_enabled;
}

void thirteen_set_application_name(u8* name) {
    _thirteen_strcpy(thirteen_app_name, sizeof(thirteen_app_name), name);
}

void thirteen_set_fullscreen(bool fullscreen) {
    if thirteen_is_fullscreen == fullscreen {
        return;
    }
    thirteen_is_fullscreen = fullscreen;
    if thirteen_platform_ptr != null {
        thirteen_platform_set_fullscreen(thirteen_platform_ptr, fullscreen, thirteen_width, thirteen_height);
    }
}

bool thirteen_get_fullscreen() {
    return thirteen_is_fullscreen;
}

thirteen_uint32 thirteen_get_width() {
    return thirteen_width;
}

thirteen_uint32 thirteen_get_height() {
    return thirteen_height;
}

ThirteenNativeWindowHandle thirteen_get_window_handle() {
    return thirteen_platform_get_window_handle(thirteen_platform_ptr);
}

thirteen_uint8* thirteen_set_size(thirteen_uint32 width, thirteen_uint32 height) {
    thirteen_uint8* reallocResult;
    if width == thirteen_width && height == thirteen_height {
        return thirteen_pixels_buf;
    }
    reallocResult = cast(thirteen_uint8*, realloc(thirteen_pixels_buf, cast(u64, width) * height * 4));
    if reallocResult == null {
        return null;
    }
    thirteen_pixels_buf = reallocResult;
    thirteen_width = width;
    thirteen_height = height;
    if !thirteen_renderer_ptr || !thirteen_renderer_resize(thirteen_renderer_ptr, width, height) {
        return null;
    }
    if thirteen_platform_ptr != null {
        thirteen_platform_resize_window(thirteen_platform_ptr, width, height, thirteen_is_fullscreen);
    }
    return thirteen_pixels_buf;
}

f64 thirteen_get_delta_time() {
    return thirteen_last_delta_time;
}

void thirteen_get_mouse_position(i32* x, i32* y) {
    *x = thirteen_mouse_x;
    *y = thirteen_mouse_y;
}

void thirteen_get_mouse_position_last_frame(i32* x, i32* y) {
    *x = thirteen_prev_mouse_x;
    *y = thirteen_prev_mouse_y;
}

bool thirteen_get_mouse_button(i32 button) {
    if button >= 0 && button < 3 {
        return thirteen_mouse_buttons[button];
    }
    return false;
}

bool thirteen_get_mouse_button_last_frame(i32 button) {
    if button >= 0 && button < 3 {
        return thirteen_prev_mouse_buttons[button];
    }
    return false;
}

bool thirteen_get_key(i32 keyCode) {
    if keyCode >= 0 && keyCode < 256 {
        return thirteen_keys[keyCode];
    }
    return false;
}

bool thirteen_get_key_last_frame(i32 keyCode) {
    if keyCode >= 0 && keyCode < 256 {
        return thirteen_prev_keys[keyCode];
    }
    return false;
}

void thirteen_shutdown() {
    if thirteen_renderer_ptr != null {
        thirteen_renderer_shutdown(thirteen_renderer_ptr);
        free(thirteen_renderer_ptr);
        thirteen_renderer_ptr = null;
    }
    if thirteen_platform_ptr != null {
        thirteen_platform_shutdown_window(thirteen_platform_ptr);
        free(thirteen_platform_ptr);
        thirteen_platform_ptr = null;
    }
    free(thirteen_pixels_buf);
    thirteen_pixels_buf = null;
}


}

// ----------------------------------------------------------------------------
// Linux arm (X11 + GLX + OpenGL)
// ----------------------------------------------------------------------------
// linux_thirteen — X11 / GLX / OpenGL surface the Linux arm calls that
// isn't covered by minc builtins (malloc/free/memset/memcpy) or the
// common thirteen_libc helpers (timespec/clock_gettime). The Linux twin
// of ext/win32_thirteen.mc and ext/macos_thirteen.mc: a per-OS hand shim
// concatenated AHEAD of the transpiled body.
//
// The Linux backend in thirteen.h is pure-dlopen: every X11/GLX/GL entry
// point is dlsym'd into a function pointer at init, so this shim does NOT
// re-declare them. It supplies three things the transpiled body needs to
// type-check and link:
//   1. dlopen/dlsym/dlclose (the loader itself, from libc),
//   2. the GLX/GL/X11 *constant* values (compile-time ints — Xlib/GL
//      header facts, mirrored from GL/glx.h, GL/gl.h, X11/X.h), and
//   3. DefaultScreen()/RootWindow() — Xlib macros in the C header that
//      reach into the opaque Display struct; re-expressed here as thin
//      wrappers over the real exported XDefaultScreen/XRootWindow.
//
// Constant *types* match each value's single use site in the transpiled
// body (minc is strict about signedness), e.g. GL_RGBA8 is the i32
// `internalformat` arg to glTexImage2D, while the other GL enums are u32.

when os(linux) {

// --- loader (libc) ----------------------------------------------------------
// dlopen/dlsym/dlclose live in libc.so.6 on modern glibc (>= 2.34).
extern "libc.so.6" void* dlopen(u8* filename, i32 flags);
extern "libc.so.6" void* dlsym(void* handle, u8* symbol);
extern "libc.so.6" i32   dlclose(void* handle);

const i32 RTLD_LAZY  = 0x00001;
const i32 RTLD_LOCAL = 0x00000;

// --- Xlib screen/root macros (real exported function forms) -----------------
// The header writes DefaultScreen(dpy)/RootWindow(dpy, scr), which are
// macros reaching into the (here-opaque) Display struct. libX11 also
// exports them as functions; wrap those. This adds a load-time dependency
// on libX11.so.6 (always present alongside the libX11.so the header
// dlopens at runtime).
extern "libX11.so.6" i32  XDefaultScreen(Display* display);
extern "libX11.so.6" u64  XRootWindow(Display* display, i32 screen);

i32 DefaultScreen(Display* display) {
    return XDefaultScreen(display);
}

Window RootWindow(Display* display, i32 screen) {
    return XRootWindow(display, screen);
}

// --- X11 boolean / null-resource sentinels ----------------------------------
const i32 True  = 1;
const i32 False = 0;
const i32 None  = 0;

// --- X11 event types (compared against XEvent.type, an i32) -----------------
const i32 KeyPress      = 2;
const i32 KeyRelease    = 3;
const i32 ButtonPress   = 4;
const i32 ButtonRelease = 5;
const i32 MotionNotify  = 6;
const i32 ClientMessage = 33;

// --- X11 event-mask bits (OR'd into XSetWindowAttributes.event_mask, i64) ---
const i64 KeyPressMask      = 1 << 0;
const i64 KeyReleaseMask    = 1 << 1;
const i64 ButtonPressMask   = 1 << 2;
const i64 ButtonReleaseMask = 1 << 3;
const i64 PointerMotionMask = 1 << 6;

// --- XCreateWindow valuemask bits (u64) + window class (u32) ----------------
const u64 CWColormap  = 1 << 13;
const u64 CWEventMask = 1 << 11;
const u32 InputOutput = 1;

// --- XCreateColormap alloc + XSizeHints.flags bits --------------------------
const i32 AllocNone = 0;
const i64 PSize     = 8;
const i64 PMinSize  = 16;
const i64 PMaxSize  = 32;

// --- GLX framebuffer-config / context attribute tokens (i32 attrib arrays) --
const i32 GLX_X_RENDERABLE   = 0x8012;
const i32 GLX_DRAWABLE_TYPE  = 0x8010;
const i32 GLX_WINDOW_BIT     = 0x0001;
const i32 GLX_RENDER_TYPE    = 0x8011;
const i32 GLX_RGBA_BIT       = 0x0001;
const i32 GLX_X_VISUAL_TYPE  = 0x0022;
const i32 GLX_TRUE_COLOR     = 0x8002;
const i32 GLX_RED_SIZE       = 8;
const i32 GLX_GREEN_SIZE     = 9;
const i32 GLX_BLUE_SIZE      = 10;
const i32 GLX_ALPHA_SIZE     = 11;
const i32 GLX_DOUBLEBUFFER   = 5;

const i32 GLX_CONTEXT_MAJOR_VERSION_ARB   = 0x2091;
const i32 GLX_CONTEXT_MINOR_VERSION_ARB   = 0x2092;
const i32 GLX_CONTEXT_PROFILE_MASK_ARB    = 0x9126;
const i32 GLX_CONTEXT_CORE_PROFILE_BIT_ARB = 0x0001;

// --- OpenGL enums -----------------------------------------------------------
const u32 GL_TEXTURE_2D        = 0x0DE1;
const i32 GL_RGBA8             = 0x8058;  // glTexImage2D internalformat (GLint)
const u32 GL_RGBA              = 0x1908;
const u32 GL_UNSIGNED_BYTE     = 0x1401;
const u32 GL_READ_FRAMEBUFFER  = 0x8CA8;
const u32 GL_DRAW_FRAMEBUFFER  = 0x8CA9;
const u32 GL_COLOR_ATTACHMENT0 = 0x8CE0;
const u32 GL_COLOR_BUFFER_BIT  = 0x4000;
const u32 GL_NEAREST           = 0x2600;

}  // when os(linux)

when os(linux) {
// transminc: C #define values surfaced as compile-time configuration
@define "VK_ESCAPE" 27
@define "VK_SPACE" 32

type XID = u64;
type VisualID = u64;
type Time = u64;
type Window = XID;
type Drawable = XID;
type Pixmap = XID;
type Cursor = XID;
type Colormap = XID;
type Atom = XID;
type KeySym = XID;
type GLXDrawable = XID;
type GLXWindow = XID;
type GLXPixmap = XID;
type Bool = i32;
type Status = i32;
type CARD32 = u32;
type Display = _XDisplay;
type Visual = _XVisual;
type Screen = _XScreen;
type XrmDatabase = _XrmHashBucketRec*;
type XIC = _XIC_*;
type XIM = _XIM_*;
type GLXContext = _GLXcontextRec*;
type GLXFBConfig = _GLXFBConfigRec*;
type GLuint = u32;
type GLsizei = i32;
type GLbitfield = u32;
type GLubyte = u8;
type XComposeStatus = _XComposeStatus;
// ========== Platform-Specific Includes ==========
// ========== Common Includes ==========
// ========== Type Definitions ==========
type thirteen_uint8 = u8;
type thirteen_uint32 = u32;
type ThirteenNativeWindowHandle = i32;
type glx_proc_t = fn(): void;
struct XrmValue {
    u32 size;
    u8* addr;
}

struct XClassHint {
    u8* res_name;
    u8* res_class;
}

struct XWMHints {
    i64 flags;
    Bool input;
    i32 initial_state;
    Pixmap icon_pixmap;
    Window icon_window;
    i32 icon_x;
    i32 icon_y;
    Pixmap icon_mask;
    XID window_group;
}

struct _XDisplay {
    i32 _opaque;
}

struct _XVisual {
    i32 _opaque;
}

struct _XScreen {
    i32 _opaque;
}

struct _XrmHashBucketRec {
    i32 _opaque;
}

struct _XIC_ {
    i32 _opaque;
}

struct _XIM_ {
    i32 _opaque;
}

struct _GLXcontextRec {
    i32 _opaque;
}

struct _GLXFBConfigRec {
    i32 _opaque;
}

struct _XComposeStatus {
    u8* compose_ptr;
    i32 chars_matched;
}

struct XVisualInfo {
    Visual* visual;
    VisualID visualid;
    i32 screen;
    i32 depth;
    i32 class;
    u64 red_mask;
    u64 green_mask;
    u64 blue_mask;
    i32 colormap_size;
    i32 bits_per_rgb;
}

struct XSetWindowAttributes {
    Pixmap background_pixmap;
    u64 background_pixel;
    Pixmap border_pixmap;
    u64 border_pixel;
    i32 bit_gravity;
    i32 win_gravity;
    i32 backing_store;
    u64 backing_planes;
    u64 backing_pixel;
    Bool save_under;
    i64 event_mask;
    i64 do_not_propagate_mask;
    Bool override_redirect;
    Colormap colormap;
    Cursor cursor;
}

struct XWindowAttributes {
    i32 x;
    i32 y;
    i32 width;
    i32 height;
    i32 border_width;
    i32 depth;
    Visual* visual;
    Window root;
    i32 class;
    i32 bit_gravity;
    i32 win_gravity;
    i32 backing_store;
    u64 backing_planes;
    u64 backing_pixel;
    Bool save_under;
    Colormap colormap;
    Bool map_installed;
    i32 map_state;
    i64 all_event_masks;
    i64 your_event_mask;
    i64 do_not_propagate_mask;
    Bool override_redirect;
    Screen* screen;
}

struct XSizeHints {
    i64 flags;
    i32 x;
    i32 y;
    i32 width;
    i32 height;
    i32 min_width;
    i32 min_height;
    i32 max_width;
    i32 max_height;
    i32 width_inc;
    i32 height_inc;
    struct {
        i32 x;
        i32 y;
    } min_aspect;
    struct {
        i32 x;
        i32 y;
    } max_aspect;
    i32 base_width;
    i32 base_height;
    i32 win_gravity;
}

struct XAnyEvent {
    i32 type;
    u64 serial;
    Bool send_event;
    Display* display;
    Window window;
}

struct XKeyEvent {
    i32 type;
    u64 serial;
    Bool send_event;
    Display* display;
    Window window;
    Window root;
    Window subwindow;
    Time time;
    i32 x;
    i32 y;
    i32 x_root;
    i32 y_root;
    u32 state;
    u32 keycode;
    Bool same_screen;
}

struct XButtonEvent {
    i32 type;
    u64 serial;
    Bool send_event;
    Display* display;
    Window window;
    Window root;
    Window subwindow;
    Time time;
    i32 x;
    i32 y;
    i32 x_root;
    i32 y_root;
    u32 state;
    u32 button;
    Bool same_screen;
}

struct XMotionEvent {
    i32 type;
    u64 serial;
    Bool send_event;
    Display* display;
    Window window;
    Window root;
    Window subwindow;
    Time time;
    i32 x;
    i32 y;
    i32 x_root;
    i32 y_root;
    u32 state;
    u8 is_hint;
    Bool same_screen;
}

struct XCrossingEvent {
    i32 type;
    u64 serial;
    Bool send_event;
    Display* display;
    Window window;
    Window root;
    Window subwindow;
    Time time;
    i32 x;
    i32 y;
    i32 x_root;
    i32 y_root;
    i32 mode;
    i32 detail;
    Bool same_screen;
    Bool focus;
    u32 state;
}

struct XConfigureEvent {
    i32 type;
    u64 serial;
    Bool send_event;
    Display* display;
    Window event;
    Window window;
    i32 x;
    i32 y;
    i32 width;
    i32 height;
    i32 border_width;
    Window above;
    Bool override_redirect;
}

struct XClientMessageEvent {
    i32 type;
    u64 serial;
    Bool send_event;
    Display* display;
    Window window;
    Atom message_type;
    i32 format;
    unsafe_union {
        u8[20] b;
        i16[10] s;
        i64[5] l;
    } data;
}

struct XPropertyEvent {
    i32 type;
    u64 serial;
    Bool send_event;
    Display* display;
    Window window;
    Atom atom;
    Time time;
    i32 state;
}

struct XErrorEvent {
    i32 type;
    Display* display;
    XID resourceid;
    u64 serial;
    u8 error_code;
    u8 request_code;
    u8 minor_code;
}

unsafe_union XEvent {
    i32 type;
    XAnyEvent xany;
    XKeyEvent xkey;
    XButtonEvent xbutton;
    XMotionEvent xmotion;
    XCrossingEvent xcrossing;
    XConfigureEvent xconfigure;
    XClientMessageEvent xclient;
    XPropertyEvent xproperty;
    i64[24] pad;
}

// ==========================================================================
// WINDOWS BACKEND
// ==========================================================================
struct ThirteenPlatform {
    void* x11Library;
    void* glLibrary;
    Display* x11Display;
    Window x11Window;
    Atom closeWindowAtom;
    GLXContext glxContext;
    fn(void*): i32 XFree;
    fn(Display*, Window, u8*): i32 XStoreName;
    fn(Display*): i32 XPending;
    fn(Display*, XEvent*): i32 XNextEvent;
    fn(XKeyEvent*, u8*, i32, KeySym*, XComposeStatus*): i32 XLookupString;
    fn(Display*, Window): i32 XDestroyWindow;
    fn(Display*): i32 XCloseDisplay;
    fn(): XSizeHints* XAllocSizeHints;
    fn(Display*, Window, XSizeHints*): void XSetWMNormalHints;
    fn(Display*, Window, u32, u32): i32 XResizeWindow;
    fn(Display*, GLXDrawable): void glXSwapBuffers;
    fn(Display*, GLXContext): void glXDestroyContext;
    fn(u32): void glClear;
    fn(i32, u32*): void glGenTextures;
    fn(i32, u32*): void glDeleteTextures;
    fn(u32, u32): void glBindTexture;
    fn(u32, i32, i32, i32, i32, i32, u32, u32, void*): void glTexImage2D;
    fn(u32, i32, i32, i32, i32, i32, u32, u32, void*): void glTexSubImage2D;
    fn(i32, u32*): void glGenFramebuffers;
    fn(i32, u32*): void glDeleteFramebuffers;
    fn(u32, u32): void glBindFramebuffer;
    fn(u32, u32, u32, i32): void glFramebufferTexture;
    fn(i32, i32, i32, i32, i32, i32, i32, i32, u32, u32): void glBlitFramebuffer;
    u32 texture;
    u32 framebuffer;
}

// --- Linux Renderer (thin wrapper) ---
struct ThirteenRenderer {
    ThirteenPlatform* platform;
}

// ========== Internal State ==========
private { thirteen_uint32 thirteen_width = 320; }
private { thirteen_uint32 thirteen_height = 200; }
private { bool thirteen_should_quit = false; }
private { bool thirteen_vsync_enabled = true; }
private { bool thirteen_is_fullscreen = false; }
private { u8[256] thirteen_app_name = {84, 104, 105, 114, 116, 101, 101, 110, 65, 112, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; }
private { f64 thirteen_last_frame_time = 0.0; }
private { f64 thirteen_last_delta_time = 0.0; }
private { f64 thirteen_frame_time_sum = 0.0; }
private { i32 thirteen_frame_count = 0; }
private { f64 thirteen_average_fps = 0.0; }
private { f64 thirteen_title_update_timer = 0.0; }
private { i32 thirteen_mouse_x = 0; }
private { i32 thirteen_mouse_y = 0; }
private { i32 thirteen_prev_mouse_x = 0; }
private { i32 thirteen_prev_mouse_y = 0; }
private { bool[3] thirteen_mouse_buttons = {false, false, false}; }
private { bool[3] thirteen_prev_mouse_buttons = {false, false, false}; }
private { bool[256] thirteen_keys; }
private { bool[256] thirteen_prev_keys; }
private { thirteen_uint8* thirteen_pixels_buf = null; }
// ========== Timing ==========
private {
f64 thirteen_now_seconds() {
    when defined(THIRTEEN_PLATFORM_WINDOWS) {
        // TODO transminc: untranslatable platform branch
    } else when arch(wasm) {
    } else {
        timespec ts;
        clock_gettime(CLOCK_MONOTONIC, &ts);
        return cast(f64, ts.tv_sec) + cast(f64, ts.tv_nsec) / 1000000000.0;
    }
}
}
private {
i32 thirteen_platform_remap_mouse_button(i32 x11Button) {
    switch x11Button {
        case 1: {
            return 0;
        }
        case 2: {
            return 2;
        }
        case 3: {
            return 1;
        }
        default: {
            return 0;
        }
    }
}
}
private {
i32 thirteen_platform_remap_key_event(ThirteenPlatform* p, XKeyEvent* event) {
    KeySym keysym = 0;
    u8[8] buf;
    i32 rc = p.XLookupString(event, buf, cast(i32, sizeof(buf)), &keysym, null);
    if rc != 1 {
        return -1;
    }
    return buf[0];
}
}
private {
bool thirteen_platform_init_window(ThirteenPlatform* p, thirteen_uint32 width, thirteen_uint32 height) {
    fn(u8*): Display* XOpenDisplay;
    fn(Display*, i32): Screen* XScreenOfDisplay;
    fn(Display*, Window, Visual*, i32): Colormap XCreateColormap;
    fn(Display*, Window, i32, i32, u32, u32, u32, i32, u32, Visual*, u64, XSetWindowAttributes*): Window XCreateWindow;
    fn(Display*, Window): i32 XMapWindow;
    fn(Display*, u8*, Bool): Atom XInternAtom;
    fn(Display*, Window, Atom*, i32): Status XSetWMProtocols;
    fn(Display*, i32, i32*, i32*): GLXFBConfig* glXChooseFBConfig;
    fn(Display*, GLXFBConfig): XVisualInfo* glXGetVisualFromFBConfig;
    fn(Display*, GLXFBConfig, GLXContext, Bool, i32*): GLXContext glXCreateContextAttribsARB;
    fn(Display*, GLXDrawable, GLXContext): Bool glXMakeCurrent;
    fn(u8*): glx_proc_t glXGetProcAddress;
    i32[19] fbConfigAttribs = {GLX_X_RENDERABLE, True, GLX_DRAWABLE_TYPE, GLX_WINDOW_BIT, GLX_RENDER_TYPE, GLX_RGBA_BIT, GLX_X_VISUAL_TYPE, GLX_TRUE_COLOR, GLX_RED_SIZE, 8, GLX_GREEN_SIZE, 8, GLX_BLUE_SIZE, 8, GLX_ALPHA_SIZE, 8, GLX_DOUBLEBUFFER, True, None};
    i32 fbConfigCount;
    GLXFBConfig* fbConfigs;
    GLXFBConfig fbConfig;
    XVisualInfo* visualInfo;
    Window rootWindow;
    XSetWindowAttributes windowAttributes;
    XSizeHints* sizeHints;
    u8* closeWindowName = "WM_DELETE_WINDOW";
    i32[7] glxContextAttributes = {GLX_CONTEXT_MAJOR_VERSION_ARB, 3, GLX_CONTEXT_MINOR_VERSION_ARB, 2, GLX_CONTEXT_PROFILE_MASK_ARB, GLX_CONTEXT_CORE_PROFILE_BIT_ARB, None};
    p.x11Library = dlopen("libX11.so", RTLD_LAZY | RTLD_LOCAL);
    if p.x11Library == null {
        return false;
    }
    XOpenDisplay = cast(fn(u8*): Display*, dlsym(p.x11Library, "XOpenDisplay"));
    if XOpenDisplay == null {
        return false;
    }
    p.XFree = cast(fn(void*): i32, dlsym(p.x11Library, "XFree"));
    if p.XFree == null {
        return false;
    }
    XScreenOfDisplay = cast(fn(Display*, i32): Screen*, dlsym(p.x11Library, "XScreenOfDisplay"));
    if XScreenOfDisplay == null {
        return false;
    }
    XCreateColormap = cast(fn(Display*, Window, Visual*, i32): Colormap, dlsym(p.x11Library, "XCreateColormap"));
    if XCreateColormap == null {
        return false;
    }
    XCreateWindow = cast(fn(Display*, Window, i32, i32, u32, u32, u32, i32, u32, Visual*, u64, XSetWindowAttributes*): Window, dlsym(p.x11Library, "XCreateWindow"));
    if XCreateWindow == null {
        return false;
    }
    XMapWindow = cast(fn(Display*, Window): i32, dlsym(p.x11Library, "XMapWindow"));
    if XMapWindow == null {
        return false;
    }
    p.XStoreName = cast(fn(Display*, Window, u8*): i32, dlsym(p.x11Library, "XStoreName"));
    if p.XStoreName == null {
        return false;
    }
    p.XPending = cast(fn(Display*): i32, dlsym(p.x11Library, "XPending"));
    if p.XPending == null {
        return false;
    }
    p.XNextEvent = cast(fn(Display*, XEvent*): i32, dlsym(p.x11Library, "XNextEvent"));
    if p.XNextEvent == null {
        return false;
    }
    p.XLookupString = cast(fn(XKeyEvent*, u8*, i32, KeySym*, XComposeStatus*): i32, dlsym(p.x11Library, "XLookupString"));
    if p.XLookupString == null {
        return false;
    }
    p.XDestroyWindow = cast(fn(Display*, Window): i32, dlsym(p.x11Library, "XDestroyWindow"));
    if p.XDestroyWindow == null {
        return false;
    }
    p.XCloseDisplay = cast(fn(Display*): i32, dlsym(p.x11Library, "XCloseDisplay"));
    if p.XCloseDisplay == null {
        return false;
    }
    p.XAllocSizeHints = cast(fn(): XSizeHints*, dlsym(p.x11Library, "XAllocSizeHints"));
    if p.XAllocSizeHints == null {
        return false;
    }
    p.XSetWMNormalHints = cast(fn(Display*, Window, XSizeHints*): void, dlsym(p.x11Library, "XSetWMNormalHints"));
    if p.XSetWMNormalHints == null {
        return false;
    }
    p.XResizeWindow = cast(fn(Display*, Window, u32, u32): i32, dlsym(p.x11Library, "XResizeWindow"));
    if p.XResizeWindow == null {
        return false;
    }
    XInternAtom = cast(fn(Display*, u8*, Bool): Atom, dlsym(p.x11Library, "XInternAtom"));
    if XInternAtom == null {
        return false;
    }
    XSetWMProtocols = cast(fn(Display*, Window, Atom*, i32): Status, dlsym(p.x11Library, "XSetWMProtocols"));
    if XSetWMProtocols == null {
        return false;
    }
    p.glLibrary = dlopen("libGL.so", RTLD_LAZY | RTLD_LOCAL);
    if p.glLibrary == null {
        return false;
    }
    glXChooseFBConfig = cast(fn(Display*, i32, i32*, i32*): GLXFBConfig*, dlsym(p.glLibrary, "glXChooseFBConfig"));
    if glXChooseFBConfig == null {
        return false;
    }
    glXGetVisualFromFBConfig = cast(fn(Display*, GLXFBConfig): XVisualInfo*, dlsym(p.glLibrary, "glXGetVisualFromFBConfig"));
    if glXGetVisualFromFBConfig == null {
        return false;
    }
    glXCreateContextAttribsARB = cast(fn(Display*, GLXFBConfig, GLXContext, Bool, i32*): GLXContext, dlsym(p.glLibrary, "glXCreateContextAttribsARB"));
    if glXCreateContextAttribsARB == null {
        return false;
    }
    glXMakeCurrent = cast(fn(Display*, GLXDrawable, GLXContext): Bool, dlsym(p.glLibrary, "glXMakeCurrent"));
    if glXMakeCurrent == null {
        return false;
    }
    p.glXSwapBuffers = cast(fn(Display*, GLXDrawable): void, dlsym(p.glLibrary, "glXSwapBuffers"));
    if p.glXSwapBuffers == null {
        return false;
    }
    p.glXDestroyContext = cast(fn(Display*, GLXContext): void, dlsym(p.glLibrary, "glXDestroyContext"));
    if p.glXDestroyContext == null {
        return false;
    }
    glXGetProcAddress = cast(fn(u8*): glx_proc_t, dlsym(p.glLibrary, "glXGetProcAddress"));
    if glXGetProcAddress == null {
        return false;
    }
    p.x11Display = XOpenDisplay(null);
    if p.x11Display == null {
        return false;
    }
    fbConfigs = glXChooseFBConfig(p.x11Display, DefaultScreen(p.x11Display), fbConfigAttribs, &fbConfigCount);
    if fbConfigs == null {
        return false;
    }
    fbConfig = fbConfigs[0];
    p.XFree(fbConfigs);
    visualInfo = glXGetVisualFromFBConfig(p.x11Display, fbConfig);
    rootWindow = RootWindow(p.x11Display, visualInfo.screen);
    memset(&windowAttributes, 0, cast(u64, sizeof(windowAttributes)));
    windowAttributes.colormap = XCreateColormap(p.x11Display, rootWindow, visualInfo.visual, AllocNone);
    windowAttributes.event_mask = KeyPressMask | KeyReleaseMask | ButtonPressMask | ButtonReleaseMask | PointerMotionMask;
    p.x11Window = XCreateWindow(p.x11Display, rootWindow, 0, 0, width, height, 0, visualInfo.depth, InputOutput, visualInfo.visual, CWColormap | CWEventMask, &windowAttributes);
    sizeHints = p.XAllocSizeHints();
    sizeHints.flags = PSize | PMinSize | PMaxSize;
    sizeHints.width = cast(i32, width);
    sizeHints.min_width = cast(i32, width);
    sizeHints.max_width = cast(i32, width);
    sizeHints.height = cast(i32, height);
    sizeHints.min_height = cast(i32, height);
    sizeHints.max_height = cast(i32, height);
    p.XSetWMNormalHints(p.x11Display, p.x11Window, sizeHints);
    p.XFree(sizeHints);
    p.XResizeWindow(p.x11Display, p.x11Window, width, height);
    XMapWindow(p.x11Display, p.x11Window);
    p.XStoreName(p.x11Display, p.x11Window, thirteen_app_name);
    p.closeWindowAtom = XInternAtom(p.x11Display, closeWindowName, False);
    XSetWMProtocols(p.x11Display, p.x11Window, &p.closeWindowAtom, 1);
    p.glxContext = glXCreateContextAttribsARB(p.x11Display, fbConfig, null, True, glxContextAttributes);
    if p.glxContext == null {
        return false;
    }
    if glXMakeCurrent(p.x11Display, p.x11Window, p.glxContext) != True {
        return false;
    }
    p.glClear = cast(fn(u32): void, glXGetProcAddress(cast(u8*, "glClear")));
    if p.glClear == null {
        return false;
    }
    p.glGenTextures = cast(fn(i32, u32*): void, glXGetProcAddress(cast(u8*, "glGenTextures")));
    if p.glGenTextures == null {
        return false;
    }
    p.glDeleteTextures = cast(fn(i32, u32*): void, glXGetProcAddress(cast(u8*, "glDeleteTextures")));
    if p.glDeleteTextures == null {
        return false;
    }
    p.glBindTexture = cast(fn(u32, u32): void, glXGetProcAddress(cast(u8*, "glBindTexture")));
    if p.glBindTexture == null {
        return false;
    }
    p.glTexImage2D = cast(fn(u32, i32, i32, i32, i32, i32, u32, u32, void*): void, glXGetProcAddress(cast(u8*, "glTexImage2D")));
    if p.glTexImage2D == null {
        return false;
    }
    p.glTexSubImage2D = cast(fn(u32, i32, i32, i32, i32, i32, u32, u32, void*): void, glXGetProcAddress(cast(u8*, "glTexSubImage2D")));
    if p.glTexSubImage2D == null {
        return false;
    }
    p.glGenFramebuffers = cast(fn(i32, u32*): void, glXGetProcAddress(cast(u8*, "glGenFramebuffers")));
    if p.glGenFramebuffers == null {
        return false;
    }
    p.glDeleteFramebuffers = cast(fn(i32, u32*): void, glXGetProcAddress(cast(u8*, "glDeleteFramebuffers")));
    if p.glDeleteFramebuffers == null {
        return false;
    }
    p.glBindFramebuffer = cast(fn(u32, u32): void, glXGetProcAddress(cast(u8*, "glBindFramebuffer")));
    if p.glBindFramebuffer == null {
        return false;
    }
    p.glFramebufferTexture = cast(fn(u32, u32, u32, i32): void, glXGetProcAddress(cast(u8*, "glFramebufferTexture")));
    if p.glFramebufferTexture == null {
        return false;
    }
    p.glBlitFramebuffer = cast(fn(i32, i32, i32, i32, i32, i32, i32, i32, u32, u32): void, glXGetProcAddress(cast(u8*, "glBlitFramebuffer")));
    if p.glBlitFramebuffer == null {
        return false;
    }
    p.glGenTextures(1, &p.texture);
    p.glBindTexture(GL_TEXTURE_2D, p.texture);
    p.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, cast(i32, width), cast(i32, height), 0, GL_RGBA, GL_UNSIGNED_BYTE, null);
    p.glGenFramebuffers(1, &p.framebuffer);
    p.glBindFramebuffer(GL_READ_FRAMEBUFFER, p.framebuffer);
    p.glFramebufferTexture(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, p.texture, 0);
    return true;
}
}
private {
void thirteen_platform_pump_messages(ThirteenPlatform* p) {
    XEvent event;
    while p.XPending(p.x11Display) != 0 {
        p.XNextEvent(p.x11Display, &event);
        switch event.type {
            case KeyPress: {
                {
                    i32 keycode = thirteen_platform_remap_key_event(p, &event.xkey);
                    if cast(u32, keycode) < 256 {
                        thirteen_keys[keycode] = true;
                    }
                    break case;
                }
            }
            case KeyRelease: {
                {
                    i32 keycode = thirteen_platform_remap_key_event(p, &event.xkey);
                    if cast(u32, keycode) < 256 {
                        thirteen_keys[keycode] = false;
                    }
                    break case;
                }
            }
            case ButtonPress: {
                thirteen_mouse_buttons[thirteen_platform_remap_mouse_button(cast(i32, event.xbutton.button))] = true;
            }
            case ButtonRelease: {
                thirteen_mouse_buttons[thirteen_platform_remap_mouse_button(cast(i32, event.xbutton.button))] = false;
            }
            case MotionNotify: {
                thirteen_mouse_x = event.xmotion.x;
                thirteen_mouse_y = event.xmotion.y;
            }
            case ClientMessage: {
                if cast(Atom, event.xclient.data.l[0]) == p.closeWindowAtom {
                    thirteen_should_quit = true;
                }
            }
        }
    }
}
}
private {
void thirteen_platform_set_title(ThirteenPlatform* p, u8* title) {
    p.XStoreName(p.x11Display, p.x11Window, title);
}
}
private {
void thirteen_platform_set_fullscreen(ThirteenPlatform* p, bool fullscreen, thirteen_uint32 width, thirteen_uint32 height) {
    ignore p;
    ignore fullscreen;
    ignore width;
    ignore height;
}
}
private {
void thirteen_platform_resize_window(ThirteenPlatform* p, thirteen_uint32 width, thirteen_uint32 height, bool isFullscreen) {
    ignore isFullscreen;
    p.XResizeWindow(p.x11Display, p.x11Window, width, height);
    p.glBindTexture(GL_TEXTURE_2D, p.texture);
    p.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, cast(i32, width), cast(i32, height), 0, GL_RGBA, GL_UNSIGNED_BYTE, null);
}
}
private {
ThirteenNativeWindowHandle thirteen_platform_get_window_handle(ThirteenPlatform* p) {
    ignore p;
    return 0;
}
}
private {
bool thirteen_platform_do_render(ThirteenPlatform* p, thirteen_uint8* pixels) {
    p.glClear(GL_COLOR_BUFFER_BIT);
    p.glBindTexture(GL_TEXTURE_2D, p.texture);
    p.glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, cast(i32, thirteen_width), cast(i32, thirteen_height), GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    p.glBindFramebuffer(GL_READ_FRAMEBUFFER, p.framebuffer);
    p.glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
    p.glBlitFramebuffer(0, 0, cast(i32, thirteen_width), cast(i32, thirteen_height), 0, cast(i32, thirteen_height), cast(i32, thirteen_width), 0, GL_COLOR_BUFFER_BIT, GL_NEAREST);
    p.glXSwapBuffers(p.x11Display, p.x11Window);
    return true;
}
}
private {
void thirteen_platform_shutdown_window(ThirteenPlatform* p) {
    p.glDeleteFramebuffers(1, &p.framebuffer);
    p.glDeleteTextures(1, &p.texture);
    p.glXDestroyContext(p.x11Display, p.glxContext);
    p.XDestroyWindow(p.x11Display, p.x11Window);
    p.XCloseDisplay(p.x11Display);
    dlclose(p.glLibrary);
    dlclose(p.x11Library);
}
}
private {
bool thirteen_renderer_init(ThirteenRenderer* r, ThirteenPlatform* p, thirteen_uint32 w, thirteen_uint32 h) {
    ignore w;
    ignore h;
    r.platform = p;
    return true;
}
}
private {
bool thirteen_renderer_render(ThirteenRenderer* r, thirteen_uint8* pixels, thirteen_uint32 w, thirteen_uint32 h, bool vsync) {
    ignore w;
    ignore h;
    ignore vsync;
    return thirteen_platform_do_render(r.platform, pixels);
}
}
private {
bool thirteen_renderer_resize(ThirteenRenderer* r, thirteen_uint32 w, thirteen_uint32 h) {
    ignore r;
    ignore w;
    ignore h;
    return true;
}
}
private {
void thirteen_renderer_shutdown(ThirteenRenderer* r) {
    ignore r;
}
}
// ==========================================================================
// STUB BACKEND
// ==========================================================================
// ========== Platform/Renderer Pointers ==========
private { ThirteenPlatform* thirteen_platform_ptr = null; }
private { ThirteenRenderer* thirteen_renderer_ptr = null; }
// ========== Public API ==========
thirteen_uint8* thirteen_init(thirteen_uint32 width, thirteen_uint32 height, bool fullscreen) {
    thirteen_width = width;
    thirteen_height = height;
    thirteen_pixels_buf = cast(thirteen_uint8*, alloc(cast(i64, cast(u64, width) * height * 4)));
    if thirteen_pixels_buf == null {
        return null;
    }
    thirteen_platform_ptr = new(ThirteenPlatform[1]);
    if !thirteen_platform_ptr || !thirteen_platform_init_window(thirteen_platform_ptr, width, height) {
        free(thirteen_platform_ptr);
        thirteen_platform_ptr = null;
        free(thirteen_pixels_buf);
        thirteen_pixels_buf = null;
        return null;
    }
    thirteen_renderer_ptr = new(ThirteenRenderer[1]);
    if !thirteen_renderer_ptr || !thirteen_renderer_init(thirteen_renderer_ptr, thirteen_platform_ptr, width, height) {
        if thirteen_renderer_ptr != null {
            thirteen_renderer_shutdown(thirteen_renderer_ptr);
            free(thirteen_renderer_ptr);
            thirteen_renderer_ptr = null;
        }
        thirteen_platform_shutdown_window(thirteen_platform_ptr);
        free(thirteen_platform_ptr);
        thirteen_platform_ptr = null;
        free(thirteen_pixels_buf);
        thirteen_pixels_buf = null;
        return null;
    }
    thirteen_last_frame_time = thirteen_now_seconds();
    if fullscreen != 0 {
        thirteen_set_fullscreen(true);
    }
    return thirteen_pixels_buf;
}

bool thirteen_render() {
    f64 currentTime;
    u8[256] titleBuffer;
    thirteen_prev_mouse_x = thirteen_mouse_x;
    thirteen_prev_mouse_y = thirteen_mouse_y;
    memcpy(thirteen_prev_mouse_buttons, thirteen_mouse_buttons, cast(u64, sizeof(thirteen_mouse_buttons)));
    memcpy(thirteen_prev_keys, thirteen_keys, cast(u64, sizeof(thirteen_keys)));
    currentTime = thirteen_now_seconds();
    thirteen_last_delta_time = currentTime - thirteen_last_frame_time;
    thirteen_last_frame_time = currentTime;
    thirteen_frame_time_sum += thirteen_last_delta_time;
    thirteen_frame_count++;
    if thirteen_frame_time_sum >= 1.0 {
        thirteen_average_fps = cast(f64, thirteen_frame_count) / thirteen_frame_time_sum;
        thirteen_frame_time_sum = 0.0;
        thirteen_frame_count = 0;
    }
    thirteen_title_update_timer += thirteen_last_delta_time;
    if thirteen_title_update_timer >= 0.25 {
        thirteen_title_update_timer = 0.0;
        _thirteen_fmt_fps_title(titleBuffer, sizeof(titleBuffer), thirteen_app_name, thirteen_average_fps, 1000.0 / thirteen_average_fps);
        if thirteen_platform_ptr != null {
            thirteen_platform_set_title(thirteen_platform_ptr, titleBuffer);
        }
    }
    if thirteen_platform_ptr != null {
        thirteen_platform_pump_messages(thirteen_platform_ptr);
    }
    if thirteen_should_quit != 0 {
        return false;
    }
    if thirteen_renderer_ptr == null {
        return false;
    }
    thirteen_renderer_render(thirteen_renderer_ptr, thirteen_pixels_buf, thirteen_width, thirteen_height, thirteen_vsync_enabled);
    return !thirteen_should_quit;
}

void thirteen_set_vsync(bool enabled) {
    thirteen_vsync_enabled = enabled;
}

bool thirteen_get_vsync() {
    return thirteen_vsync_enabled;
}

void thirteen_set_application_name(u8* name) {
    _thirteen_strcpy(thirteen_app_name, sizeof(thirteen_app_name), name);
}

void thirteen_set_fullscreen(bool fullscreen) {
    if thirteen_is_fullscreen == fullscreen {
        return;
    }
    thirteen_is_fullscreen = fullscreen;
    if thirteen_platform_ptr != null {
        thirteen_platform_set_fullscreen(thirteen_platform_ptr, fullscreen, thirteen_width, thirteen_height);
    }
}

bool thirteen_get_fullscreen() {
    return thirteen_is_fullscreen;
}

thirteen_uint32 thirteen_get_width() {
    return thirteen_width;
}

thirteen_uint32 thirteen_get_height() {
    return thirteen_height;
}

ThirteenNativeWindowHandle thirteen_get_window_handle() {
    return thirteen_platform_get_window_handle(thirteen_platform_ptr);
}

thirteen_uint8* thirteen_set_size(thirteen_uint32 width, thirteen_uint32 height) {
    thirteen_uint8* reallocResult;
    if width == thirteen_width && height == thirteen_height {
        return thirteen_pixels_buf;
    }
    reallocResult = cast(thirteen_uint8*, realloc(thirteen_pixels_buf, cast(u64, width) * height * 4));
    if reallocResult == null {
        return null;
    }
    thirteen_pixels_buf = reallocResult;
    thirteen_width = width;
    thirteen_height = height;
    if !thirteen_renderer_ptr || !thirteen_renderer_resize(thirteen_renderer_ptr, width, height) {
        return null;
    }
    if thirteen_platform_ptr != null {
        thirteen_platform_resize_window(thirteen_platform_ptr, width, height, thirteen_is_fullscreen);
    }
    return thirteen_pixels_buf;
}

f64 thirteen_get_delta_time() {
    return thirteen_last_delta_time;
}

void thirteen_get_mouse_position(i32* x, i32* y) {
    *x = thirteen_mouse_x;
    *y = thirteen_mouse_y;
}

void thirteen_get_mouse_position_last_frame(i32* x, i32* y) {
    *x = thirteen_prev_mouse_x;
    *y = thirteen_prev_mouse_y;
}

bool thirteen_get_mouse_button(i32 button) {
    if button >= 0 && button < 3 {
        return thirteen_mouse_buttons[button];
    }
    return false;
}

bool thirteen_get_mouse_button_last_frame(i32 button) {
    if button >= 0 && button < 3 {
        return thirteen_prev_mouse_buttons[button];
    }
    return false;
}

bool thirteen_get_key(i32 keyCode) {
    if keyCode >= 0 && keyCode < 256 {
        return thirteen_keys[keyCode];
    }
    return false;
}

bool thirteen_get_key_last_frame(i32 keyCode) {
    if keyCode >= 0 && keyCode < 256 {
        return thirteen_prev_keys[keyCode];
    }
    return false;
}

void thirteen_shutdown() {
    if thirteen_renderer_ptr != null {
        thirteen_renderer_shutdown(thirteen_renderer_ptr);
        free(thirteen_renderer_ptr);
        thirteen_renderer_ptr = null;
    }
    if thirteen_platform_ptr != null {
        thirteen_platform_shutdown_window(thirteen_platform_ptr);
        free(thirteen_platform_ptr);
        thirteen_platform_ptr = null;
    }
    free(thirteen_pixels_buf);
    thirteen_pixels_buf = null;
}


}

// ----------------------------------------------------------------------------
// macOS arm (Cocoa + Metal)
// ----------------------------------------------------------------------------
// cocoa_consts.mc — curated Cocoa value constants + data globals the
// transpiled sokol_app macOS arm references. Split out of
// cocoa_objc.mc's tail: that file bundles a hermetic *bridge mirror*
// (struct objc_super / ObjcMsgTable / libobjc stubs) with these
// constants, for the off-Mac compile gate. For a REAL on-Mac build the
// bridge comes from `import objc_runtime` (../minc/lib/objc_runtime.mc,
// dlsym-backed) — but that module does NOT carry these AppKit/Foundation
// constants, so they live here and are concatenated alongside it.
//
// Concatenate AFTER the bridge and BEFORE the transpiled .mc.
//
// The data globals (NSApp, NSDefaultRunLoopMode, NSPasteboardTypeString)
// are declared null here and must be initialised at runtime from the
// frameworks (dlsym / sharedApplication) before sapp_run — see the
// macOS demo main. Values are the real enum/bitmask constants (system-
// API facts, like win32gl_shim's WM_*/WS_*).

when os(macos) || os(ios) {

// NSApplication
void* NSApp;
const i64 NSApplicationActivationPolicyRegular = 0;

// NSWindow style mask (NSUInteger bitset)
const u64 NSWindowStyleMaskBorderless     = 0;
const u64 NSWindowStyleMaskTitled         = 1;
const u64 NSWindowStyleMaskClosable       = 2;
const u64 NSWindowStyleMaskMiniaturizable = 4;
const u64 NSWindowStyleMaskResizable      = 8;

const u64 NSBackingStoreBuffered = 2;

// NSEvent modifier flags (NSUInteger bitset)
const u64 NSEventModifierFlagCapsLock   = 65536;
const u64 NSEventModifierFlagShift      = 131072;
const u64 NSEventModifierFlagControl    = 262144;
const u64 NSEventModifierFlagOption     = 524288;
const u64 NSEventModifierFlagCommand    = 1048576;

// NSEvent type / subtype (used to synthesize an app-activation event)
const u64 NSEventTypeAppKitDefined            = 13;
const i32 NSEventSubtypeApplicationActivated  = 1;
// Foundation's zero point ({0,0}); the foreground-kick passes it as the
// synthetic event's location. A plain zero-init global (mirrors v1).
NSPoint NSZeroPoint;
// NSEventMask = 1 << NSEventType. KeyUp type is 11.
const u64 NSEventMaskKeyUp                     = 2048;

// NSTrackingArea options (NSUInteger bitset)
const u64 NSTrackingMouseEnteredAndExited   = 1;
const u64 NSTrackingCursorUpdate            = 4;
const u64 NSTrackingActiveInKeyWindow       = 32;
const u64 NSTrackingInVisibleRect           = 512;
const u64 NSTrackingEnabledDuringMouseDrag  = 1024;
const u64 NSTrackingAssumeInside            = 256;

// NSOpenGLPixelFormatAttribute
const u32 NSOpenGLPFADoubleBuffer  = 5;
const u32 NSOpenGLPFAStereo        = 6;
const u32 NSOpenGLPFAColorSize     = 8;
const u32 NSOpenGLPFAAlphaSize     = 11;
const u32 NSOpenGLPFADepthSize     = 12;
const u32 NSOpenGLPFAStencilSize   = 13;
const u32 NSOpenGLPFASampleBuffers = 55;
const u32 NSOpenGLPFASamples       = 56;
const u32 NSOpenGLPFAMultisample   = 59;
const u32 NSOpenGLPFAAccelerated   = 73;
const u32 NSOpenGLPFAOpenGLProfile = 99;
const u32 NSOpenGLProfileVersion3_2Core = 12800;
const i32 NSOpenGLContextParameterSwapInterval = 222;

// Run-loop mode + pasteboard type — Cocoa NSString* globals, linked at load
// (data externs) so reading the name yields the framework's constant
// directly; no dlsym. Frameworks are .tbd-verified: the run-loop modes are
// CoreFoundation symbols (toll-free bridged, NOT Foundation); the pasteboard
// type is AppKit. (Both already linked via objc_classref binds.)
extern "CoreFoundation" void* NSDefaultRunLoopMode;
extern "CoreFoundation" void* NSRunLoopCommonModes;
extern "AppKit" void* NSPasteboardTypeString;

const u64 NSStringEncodingUTF8 = 4;

// NSViewLayerContentsPlacement (NSInteger) — used to pin the layer's
// contents corner while the window resizes.
const i64 NSViewLayerContentsPlacementScaleAxesIndependently  = 0;
const i64 NSViewLayerContentsPlacementScaleProportionallyToFit = 1;
const i64 NSViewLayerContentsPlacementScaleProportionallyToFill = 2;
const i64 NSViewLayerContentsPlacementCenter                  = 3;
const i64 NSViewLayerContentsPlacementTop                     = 4;
const i64 NSViewLayerContentsPlacementTopRight                = 5;
const i64 NSViewLayerContentsPlacementRight                   = 6;
const i64 NSViewLayerContentsPlacementBottomRight             = 7;
const i64 NSViewLayerContentsPlacementBottom                  = 8;
const i64 NSViewLayerContentsPlacementBottomLeft              = 9;
const i64 NSViewLayerContentsPlacementLeft                    = 10;
const i64 NSViewLayerContentsPlacementTopLeft                 = 11;

// NSBitmapImageRep (window-icon construction)
const u64 NSBitmapFormatAlphaNonpremultiplied = 2;   // 1 << 1

// NSWindow occlusion state (NSUInteger bitset)
const u64 NSWindowOcclusionStateVisible = 2;   // 1 << 1

// NSDragOperation (NSUInteger bitset) — drag-and-drop result codes
const u64 NSDragOperationNone    = 0;
const u64 NSDragOperationCopy    = 1;
const u64 NSDragOperationLink    = 2;
const u64 NSDragOperationGeneric = 4;
const u64 NSDragOperationPrivate = 8;
const u64 NSDragOperationMove    = 16;
const u64 NSDragOperationDelete  = 32;
const u64 NSDragOperationEvery   = 18446744073709551615;   // NSUIntegerMax
// NSColorSpaceName (an NSString* global) — AppKit, linked at load.
extern "AppKit" void* NSCalibratedRGBColorSpace;

// --- Metal / MetalKit -----------------------------------------
// The one Metal C entry point (the rest of Metal is Objective-C, sent
// through the runtime bridge). Metal enum constants are in
// cocoa_metal_consts.mc.
extern "/System/Library/Frameworks/Metal.framework/Metal" void* MTLCreateSystemDefaultDevice();
const u64 MTLCPUCacheModeDefaultCache = 0;
const u64 MTLCPUCacheModeWriteCombined = 1;

// QuartzCore CALayer filter name (an NSString* global) — linked at load.
extern "QuartzCore" void* kCAFilterNearest;

// --- libdispatch (GCD) ----------------------------------------
// C entry points (in libSystem) for the frame semaphore and the
// shader-library data buffer.
extern "libSystem.B.dylib" {
    void* dispatch_semaphore_create(i64 value);
    i64   dispatch_semaphore_wait(void* sema, u64 timeout);
    i64   dispatch_semaphore_signal(void* sema);
    void* dispatch_data_create(void* buffer, i64 size, void* queue, void* destructor);
}
const u64 DISPATCH_TIME_FOREVER = 18446744073709551615;
void* DISPATCH_DATA_DESTRUCTOR_DEFAULT = null;

// --- CoreFoundation / CoreGraphics ----------------------------
// C entry points for the window-icon (CGImage from pixels) and
// cursor show/hide paths.
extern "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation" {
    void* CFDataCreate(void* allocator, void* bytes, i64 length);
    void  CFRelease(void* cf);
}
extern "/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics" {
    void* CGColorSpaceCreateDeviceRGB();
    void  CGColorSpaceRelease(void* space);
    void* CGDataProviderCreateWithCFData(void* data);
    void  CGDataProviderRelease(void* provider);
    void* CGImageCreate(u64 width, u64 height, u64 bits_per_component,
                        u64 bits_per_pixel, u64 bytes_per_row, void* space,
                        u32 bitmap_info, void* provider, void* decode,
                        bool should_interpolate, u32 intent);
    void  CGImageRelease(void* image);
    i32   CGDisplayHideCursor(u32 display);
    i32   CGDisplayShowCursor(u32 display);
    i32   CGAssociateMouseAndMouseCursorPosition(bool connected);
}
void* kCFAllocatorDefault = null;          // NULL = default allocator
const u32 kCGDirectMainDisplay      = 0;   // ignored by show/hide cursor
const u32 kCGImageAlphaLast          = 3;
const u32 kCGImageByteOrderDefault   = 0;
const u32 kCGRenderingIntentDefault  = 0;

}

// macos_thirteen — Cocoa/CoreGraphics surface the macOS arm calls that
// isn't covered by `import objc_runtime` (the libobjc bridge) or
// ext/cocoa_consts.mc (the AppKit/Foundation/Metal constants + linked
// externs). The macOS twin of ext/win32_thirteen.mc: a per-OS hand
// shim concatenated AHEAD of the transpiled body.
//
// The Foundation/CoreGraphics geometry constructors (CGRectMake etc.)
// are `static inline` in <CoreGraphics/CGGeometry.h>; transminc parses
// ext/cocoa_types.h types-only, so the inline bodies don't survive the
// transpile. Re-declare them here. CGRect/CGSize/CGPoint come from the
// transpiled cocoa_types.h (layout-identical to the system structs).

when os(macos) {

CGRect CGRectMake(f64 x, f64 y, f64 w, f64 h) {
    CGRect r;
    r.origin.x = x;
    r.origin.y = y;
    r.size.width = w;
    r.size.height = h;
    return r;
}

CGSize CGSizeMake(f64 w, f64 h) {
    CGSize s;
    s.width = w;
    s.height = h;
    return s;
}

CGPoint CGPointMake(f64 x, f64 y) {
    CGPoint p;
    p.x = x;
    p.y = y;
    return p;
}

}

when os(macos) {
// transminc: C #define values surfaced as compile-time configuration
@define "TARGET_OS_IPHONE" 0
@define "TARGET_OS_OSX" 1
@define "TARGET_OS_MAC" 1
@define "TARGET_OS_SIMULATOR" 0
@define "VK_ESCAPE" 27
@define "VK_SPACE" 32
@define "THIRTEEN_NS_LEFT_MOUSE_DOWN" 1
@define "THIRTEEN_NS_LEFT_MOUSE_UP" 2
@define "THIRTEEN_NS_RIGHT_MOUSE_DOWN" 3
@define "THIRTEEN_NS_RIGHT_MOUSE_UP" 4
@define "THIRTEEN_NS_MOUSE_MOVED" 5
@define "THIRTEEN_NS_LEFT_MOUSE_DRAGGED" 6
@define "THIRTEEN_NS_RIGHT_MOUSE_DRAGGED" 7
@define "THIRTEEN_NS_KEY_DOWN" 10
@define "THIRTEEN_NS_KEY_UP" 11
@define "THIRTEEN_NS_OTHER_MOUSE_DOWN" 25
@define "THIRTEEN_NS_OTHER_MOUSE_UP" 26
@define "THIRTEEN_NS_OTHER_MOUSE_DRAGGED" 27

type NSInteger = i64;
type NSUInteger = u64;
type CGFloat = f64;
type CFTimeInterval = f64;
type unichar = u16;
type BOOL = i8;
type size_t = u64;
type UInt8 = u8;
type CFIndex = i64;
type CFDataRef = void*;
type CGColorSpaceRef = void*;
type CGDataProviderRef = void*;
type CGImageRef = void*;
type NSImageView = void;
type NSDockTile = void;
type id = void*;
type SEL = void*;
type Class = void*;
type IMP = void*;
type Protocol = void*;
type instancetype = void*;
type NSEventModifierFlags = NSUInteger;
type NSEventMask = NSUInteger;
type NSWindowStyleMask = NSUInteger;
type NSEventType = NSUInteger;
type NSEventSubtype = NSUInteger;
type NSWindowButton = NSUInteger;
type NSApplicationActivationPolicy = NSUInteger;
type NSApplicationPresentationOptions = NSUInteger;
type NSBackingStoreType = NSUInteger;
type NSTrackingAreaOptions = NSUInteger;
type NSDragOperation = NSUInteger;
type NSStringEncoding = NSUInteger;
type NSOpenGLPixelFormatAttribute = NSUInteger;
type NSViewLayerContentsPlacement = NSInteger;
type NSApplicationDelegateReply = NSInteger;
type NSModalResponse = NSInteger;
type NSWindowLevel = NSInteger;
type NSObject = void;
type NSNull = void;
type NSString = void;
type NSArray = void;
type NSDictionary = void;
type NSSet = void;
type NSMutableArray = void;
type NSMutableDictionary = void;
type NSData = void;
type NSDate = void;
type NSError = void;
type NSNotification = void;
type NSNotificationCenter = void;
type NSValue = void;
type NSNumber = void;
type NSURL = void;
type NSBundle = void;
type NSProcessInfo = void;
type NSThread = void;
type NSRunLoop = void;
type NSApplication = void;
type NSWindow = void;
type NSView = void;
type NSScreen = void;
type NSEvent = void;
type NSResponder = void;
type NSColor = void;
type NSCursor = void;
type NSImage = void;
type NSBitmapImageRep = void;
type NSMenu = void;
type NSMenuItem = void;
type NSTimer = void;
type NSTrackingArea = void;
type NSPasteboard = void;
type NSPasteboardType = void;
type NSString_ = void;
type NSOpenGLContext = void;
type NSOpenGLPixelFormat = void;
type NSOpenGLView = void;
type NSColorSpace = void;
type NSTextField = void;
type NSTextView = void;
type NSDraggingInfo = void;
type NSFileManager = void;
type CALayer = void;
type CAMetalLayer = void;
type CADisplayLink = void;
type NSAutoreleasePool = void;
type MTLPixelFormat = NSUInteger;
type MTKView = void;
type MTKViewDelegate = void;
type MTLDevice = void;
type MTLCommandQueue = void;
type MTLCommandBuffer = void;
type MTLRenderCommandEncoder = void;
type MTLRenderPassDescriptor = void;
type MTLRenderPipelineState = void;
type MTLDrawable = void;
type CAMetalDrawable = void;
type MTLTexture = void;
type MTLLibrary = void;
type MTLFunction = void;
type MTLBuffer = void;
type MTLPrimitiveType = NSUInteger;
type MTLIndexType = NSUInteger;
type MTLCullMode = NSUInteger;
type MTLWinding = NSUInteger;
type MTLVertexFormat = NSUInteger;
type MTLVertexStepFunction = NSUInteger;
type MTLStencilOperation = NSUInteger;
type MTLCompareFunction = NSUInteger;
type MTLBlendFactor = NSUInteger;
type MTLBlendOperation = NSUInteger;
type MTLColorWriteMask = NSUInteger;
type MTLLoadAction = NSUInteger;
type MTLStoreAction = NSUInteger;
type MTLStorageMode = NSUInteger;
type MTLResourceOptions = NSUInteger;
type MTLCPUCacheMode = NSUInteger;
type MTLTextureType = NSUInteger;
type MTLTextureUsage = NSUInteger;
type MTLSamplerMinMagFilter = NSUInteger;
type MTLSamplerMipFilter = NSUInteger;
type MTLSamplerAddressMode = NSUInteger;
type MTLSamplerBorderColor = NSUInteger;
type MTLPurgeableState = NSUInteger;
type MTLDataType = NSUInteger;
type MTLLanguageVersion = NSUInteger;
type MTLMutability = NSUInteger;
type MTLFeatureSet = NSUInteger;
type MTLClipMode = NSUInteger;
type MTLDepthClipMode = NSUInteger;
type MTLTriangleFillMode = NSUInteger;
type MTLCommandEncoder = void;
type MTLBlitCommandEncoder = void;
type MTLComputeCommandEncoder = void;
type MTLDepthStencilState = void;
type MTLSamplerState = void;
type MTLComputePipelineState = void;
type MTLComputePipelineDescriptor = void;
type MTLTextureDescriptor = void;
type MTLRenderPipelineDescriptor = void;
type MTLSamplerDescriptor = void;
type MTLStencilDescriptor = void;
type MTLDepthStencilDescriptor = void;
type MTLVertexDescriptor = void;
type MTLCompileOptions = void;
type MTLRenderPipelineReflection = void;
type MTLArgument = void;
type MTLFunctionConstantValues = void;
type MTLRenderPipelineColorAttachmentDescriptor = void;
type MTLRenderPipelineColorAttachmentDescriptorArray = void;
type MTLVertexAttributeDescriptor = void;
type MTLVertexAttributeDescriptorArray = void;
type MTLVertexBufferLayoutDescriptor = void;
type MTLVertexBufferLayoutDescriptorArray = void;
type MTLRenderPassColorAttachmentDescriptor = void;
type MTLRenderPassColorAttachmentDescriptorArray = void;
type MTLRenderPassDepthAttachmentDescriptor = void;
type MTLRenderPassStencilAttachmentDescriptor = void;
type MTLStencilAttachmentDescriptor = void;
type dispatch_semaphore_t = void*;
type dispatch_data_t = void*;
type dispatch_queue_t = void*;
type dispatch_object_t = void*;
type dispatch_block_t = void*;
// ========== Platform-Specific Includes ==========
// ========== Common Includes ==========
// ========== Type Definitions ==========
type thirteen_uint8 = u8;
type thirteen_uint32 = u32;
type ThirteenNativeWindowHandle = void*;
type ThirteenNSUInteger = u64;
type ThirteenNSInteger = i64;
struct CGPoint {
    CGFloat x;
    CGFloat y;
}

struct CGSize {
    CGFloat width;
    CGFloat height;
}

struct CGRect {
    CGPoint origin;
    CGSize size;
}

struct NSPoint {
    CGFloat x;
    CGFloat y;
}

struct NSSize {
    CGFloat width;
    CGFloat height;
}

struct NSRect {
    NSPoint origin;
    NSSize size;
}

struct NSRange {
    NSUInteger location;
    NSUInteger length;
}

struct CAFrameRateRange {
    f32 minimum;
    f32 maximum;
    f32 preferred;
}

struct MTLClearColor {
    f64 red;
    f64 green;
    f64 blue;
    f64 alpha;
}

struct MTLOrigin {
    NSUInteger x;
    NSUInteger y;
    NSUInteger z;
}

struct MTLSize {
    NSUInteger width;
    NSUInteger height;
    NSUInteger depth;
}

struct MTLRegion {
    MTLOrigin origin;
    MTLSize size;
}

struct MTLViewport {
    f64 originX;
    f64 originY;
    f64 width;
    f64 height;
    f64 znear;
    f64 zfar;
}

struct MTLScissorRect {
    NSUInteger x;
    NSUInteger y;
    NSUInteger width;
    NSUInteger height;
}

struct ThirteenMTLSize {
    ThirteenNSUInteger width;
    ThirteenNSUInteger height;
    ThirteenNSUInteger depth;
}

struct ThirteenMTLOrigin {
    ThirteenNSUInteger x;
    ThirteenNSUInteger y;
    ThirteenNSUInteger z;
}

struct ThirteenPlatform {
    id app;
    id window;
    id contentView;
}

// --- Metal Renderer ---
struct ThirteenRenderer {
    id device;
    id commandQueue;
    id metalLayer;
    id uploadBuffer;
    ThirteenNativeWindowHandle hostView;
    thirteen_uint32 bufferWidth;
    thirteen_uint32 bufferHeight;
    u64 uploadSize;
}

private {
NSRect NSMakeRect(CGFloat x, CGFloat y, CGFloat w, CGFloat h) {
    NSRect r;
    r.origin.x = x;
    r.origin.y = y;
    r.size.width = w;
    r.size.height = h;
    return r;
}
}
private {
NSPoint NSMakePoint(CGFloat x, CGFloat y) {
    NSPoint p;
    p.x = x;
    p.y = y;
    return p;
}
}
private {
NSSize NSMakeSize(CGFloat w, CGFloat h) {
    NSSize s;
    s.width = w;
    s.height = h;
    return s;
}
}
private {
NSRange NSMakeRange(NSUInteger location, NSUInteger length) {
    NSRange r;
    r.location = location;
    r.length = length;
    return r;
}
}
private {
MTLOrigin MTLOriginMake(NSUInteger x, NSUInteger y, NSUInteger z) {
    MTLOrigin o;
    o.x = x;
    o.y = y;
    o.z = z;
    return o;
}
}
private {
MTLSize MTLSizeMake(NSUInteger w, NSUInteger h, NSUInteger d) {
    MTLSize s;
    s.width = w;
    s.height = h;
    s.depth = d;
    return s;
}
}
private {
MTLRegion MTLRegionMake2D(NSUInteger x, NSUInteger y, NSUInteger w, NSUInteger h) {
    MTLRegion r;
    r.origin.x = x;
    r.origin.y = y;
    r.origin.z = 0;
    r.size.width = w;
    r.size.height = h;
    r.size.depth = 1;
    return r;
}
}
private {
MTLRegion MTLRegionMake3D(NSUInteger x, NSUInteger y, NSUInteger z, NSUInteger w, NSUInteger h, NSUInteger d) {
    MTLRegion r;
    r.origin.x = x;
    r.origin.y = y;
    r.origin.z = z;
    r.size.width = w;
    r.size.height = h;
    r.size.depth = d;
    return r;
}
}
private {
MTLClearColor MTLClearColorMake(f64 red, f64 green, f64 blue, f64 alpha) {
    MTLClearColor c;
    c.red = red;
    c.green = green;
    c.blue = blue;
    c.alpha = alpha;
    return c;
}
}
// ========== Internal State ==========
private { thirteen_uint32 thirteen_width = 320; }
private { thirteen_uint32 thirteen_height = 200; }
private { bool thirteen_should_quit = false; }
private { bool thirteen_vsync_enabled = true; }
private { bool thirteen_is_fullscreen = false; }
private { u8[256] thirteen_app_name = {84, 104, 105, 114, 116, 101, 101, 110, 65, 112, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; }
private { f64 thirteen_last_frame_time = 0.0; }
private { f64 thirteen_last_delta_time = 0.0; }
private { f64 thirteen_frame_time_sum = 0.0; }
private { i32 thirteen_frame_count = 0; }
private { f64 thirteen_average_fps = 0.0; }
private { f64 thirteen_title_update_timer = 0.0; }
private { i32 thirteen_mouse_x = 0; }
private { i32 thirteen_mouse_y = 0; }
private { i32 thirteen_prev_mouse_x = 0; }
private { i32 thirteen_prev_mouse_y = 0; }
private { bool[3] thirteen_mouse_buttons = {false, false, false}; }
private { bool[3] thirteen_prev_mouse_buttons = {false, false, false}; }
private { bool[256] thirteen_keys; }
private { bool[256] thirteen_prev_keys; }
private { thirteen_uint8* thirteen_pixels_buf = null; }
// ========== Timing ==========
private {
f64 thirteen_now_seconds() {
    when defined(THIRTEEN_PLATFORM_WINDOWS) {
        // TODO transminc: untranslatable platform branch
    } else when arch(wasm) {
    } else {
        timespec ts;
        clock_gettime(CLOCK_MONOTONIC, &ts);
        return cast(f64, ts.tv_sec) + cast(f64, ts.tv_nsec) / 1000000000.0;
    }
}
}
private {
SEL thirteen_sel(u8* name) {
    return sel_registerName(name);
}
}
private {
bool thirteen_platform_init_window(ThirteenPlatform* p, thirteen_uint32 width, thirteen_uint32 height) {
    id nsApplicationClass;
    id nsWindowClass;
    id windowAlloc;
    ThirteenNSUInteger styleMask;
    ThirteenNSUInteger backingStoreBuffered;
    CGRect frame;
    nsApplicationClass = cast(id, objc_getClass("NSApplication"));
    p.app = cast(fn(id, SEL): id, objc_msgSend)(nsApplicationClass, thirteen_sel("sharedApplication"));
    if p.app == null {
        return false;
    }
    cast(fn(id, SEL, ThirteenNSInteger): void, objc_msgSend)(p.app, thirteen_sel("setActivationPolicy:"), 0);
    nsWindowClass = cast(id, objc_getClass("NSWindow"));
    windowAlloc = cast(fn(id, SEL): id, objc_msgSend)(nsWindowClass, thirteen_sel("alloc"));
    if windowAlloc == null {
        return false;
    }
    styleMask = cast(u64, 1 << 0 | 1 << 1 | 1 << 2);
    backingStoreBuffered = 2;
    frame = CGRectMake(100.0, 100.0, cast(f64, width), cast(f64, height));
    p.window = cast(fn(id, SEL, CGRect, ThirteenNSUInteger, ThirteenNSUInteger, bool): id, objc_msgSend)(windowAlloc, thirteen_sel("initWithContentRect:styleMask:backing:defer:"), frame, styleMask, backingStoreBuffered, false);
    if p.window == null {
        return false;
    }
    cast(fn(id, SEL, bool): void, objc_msgSend)(p.window, thirteen_sel("setReleasedWhenClosed:"), false);
    p.contentView = cast(fn(id, SEL): id, objc_msgSend)(p.window, thirteen_sel("contentView"));
    if p.contentView == null {
        return false;
    }
    cast(fn(id, SEL, id): void, objc_msgSend)(p.window, thirteen_sel("makeKeyAndOrderFront:"), cast(id, null));
    cast(fn(id, SEL, bool): void, objc_msgSend)(p.app, thirteen_sel("activateIgnoringOtherApps:"), true);
    return true;
}
}
private {
void thirteen_platform_pump_messages(ThirteenPlatform* p) {
    id dateClass;
    id distantPast;
    id nsStringClass;
    id defaultMode;
    u64 anyMask;
    if p.app == null {
        return;
    }
    dateClass = cast(id, objc_getClass("NSDate"));
    distantPast = cast(fn(id, SEL): id, objc_msgSend)(dateClass, thirteen_sel("distantPast"));
    nsStringClass = cast(id, objc_getClass("NSString"));
    defaultMode = cast(fn(id, SEL, u8*): id, objc_msgSend)(nsStringClass, thirteen_sel("stringWithUTF8String:"), "kCFRunLoopDefaultMode");
    anyMask = cast(u64, ~0);
    while true {
        ThirteenNSInteger eventType;
        bool isMouseDownEvent;
        bool isMouseUpEvent;
        bool isMousePositionEvent;
        id event = cast(fn(id, SEL, u64, id, id, bool): id, objc_msgSend)(p.app, thirteen_sel("nextEventMatchingMask:untilDate:inMode:dequeue:"), anyMask, distantPast, defaultMode, true);
        if event == null {
            break;
        }
        eventType = cast(fn(id, SEL): ThirteenNSInteger, objc_msgSend)(event, thirteen_sel("type"));
        isMouseDownEvent = eventType == 1 || eventType == 3 || eventType == 25;
        isMouseUpEvent = eventType == 2 || eventType == 4 || eventType == 26;
        isMousePositionEvent = eventType == 5 || eventType == 6 || eventType == 7 || eventType == 27 || isMouseDownEvent || isMouseUpEvent;
        if eventType == 10 {
            id chars = cast(fn(id, SEL): id, objc_msgSend)(event, thirteen_sel("charactersIgnoringModifiers"));
            if chars != null {
                u8* utf8 = cast(fn(id, SEL): u8*, objc_msgSend)(chars, thirteen_sel("UTF8String"));
                if utf8 && utf8[0] != 0 {
                    thirteen_keys[cast(u8, utf8[0])] = true;
                }
            }
        } else if eventType == 11 {
            id chars = cast(fn(id, SEL): id, objc_msgSend)(event, thirteen_sel("charactersIgnoringModifiers"));
            if chars != null {
                u8* utf8 = cast(fn(id, SEL): u8*, objc_msgSend)(chars, thirteen_sel("UTF8String"));
                if utf8 && utf8[0] != 0 {
                    thirteen_keys[cast(u8, utf8[0])] = false;
                }
            }
        } else if isMouseDownEvent != 0 {
            ThirteenNSInteger buttonNumber = cast(fn(id, SEL): ThirteenNSInteger, objc_msgSend)(event, thirteen_sel("buttonNumber"));
            if buttonNumber >= 0 && buttonNumber < 3 {
                thirteen_mouse_buttons[buttonNumber] = true;
            }
        } else if isMouseUpEvent != 0 {
            ThirteenNSInteger buttonNumber = cast(fn(id, SEL): ThirteenNSInteger, objc_msgSend)(event, thirteen_sel("buttonNumber"));
            if buttonNumber >= 0 && buttonNumber < 3 {
                thirteen_mouse_buttons[buttonNumber] = false;
            }
        }
        if isMousePositionEvent != 0 {
            CGPoint pt = cast(fn(id, SEL): CGPoint, objc_msgSend)(event, thirteen_sel("locationInWindow"));
            thirteen_mouse_x = cast(i32, pt.x);
            thirteen_mouse_y = cast(i32, thirteen_height - pt.y);
        }
        if eventType != 10 && eventType != 11 {
            cast(fn(id, SEL, id): void, objc_msgSend)(p.app, thirteen_sel("sendEvent:"), event);
        }
    }
    if p.window != null {
        bool visible = cast(fn(id, SEL): bool, objc_msgSend)(p.window, thirteen_sel("isVisible")) != 0;
        if visible == 0 {
            thirteen_should_quit = true;
        }
    }
}
}
private {
void thirteen_platform_set_title(ThirteenPlatform* p, u8* title) {
    id nsStringClass;
    id nsTitle;
    if p.window == null {
        return;
    }
    nsStringClass = cast(id, objc_getClass("NSString"));
    nsTitle = cast(fn(id, SEL, u8*): id, objc_msgSend)(nsStringClass, thirteen_sel("stringWithUTF8String:"), title);
    cast(fn(id, SEL, id): void, objc_msgSend)(p.window, thirteen_sel("setTitle:"), nsTitle);
}
}
private {
void thirteen_platform_set_fullscreen(ThirteenPlatform* p, bool fullscreen, thirteen_uint32 width, thirteen_uint32 height) {
    ignore fullscreen;
    ignore width;
    ignore height;
    if p.window != null {
        cast(fn(id, SEL, id): void, objc_msgSend)(p.window, thirteen_sel("toggleFullScreen:"), cast(id, null));
    }
}
}
private {
void thirteen_platform_resize_window(ThirteenPlatform* p, thirteen_uint32 width, thirteen_uint32 height, bool isFullscreen) {
    CGSize contentSize;
    if !p.window || isFullscreen {
        return;
    }
    contentSize = CGSizeMake(cast(f64, width), cast(f64, height));
    cast(fn(id, SEL, CGSize): void, objc_msgSend)(p.window, thirteen_sel("setContentSize:"), contentSize);
}
}
private {
ThirteenNativeWindowHandle thirteen_platform_get_window_handle(ThirteenPlatform* p) {
    return p.contentView;
}
}
private {
void thirteen_platform_shutdown_window(ThirteenPlatform* p) {
    if p.window != null {
        cast(fn(id, SEL): void, objc_msgSend)(p.window, thirteen_sel("close"));
        p.window = null;
    }
    p.contentView = null;
    p.app = null;
}
}
private {
bool thirteen_renderer_ensure_upload_buffer(ThirteenRenderer* r, thirteen_uint32 width, thirteen_uint32 height) {
    u64 requiredSize = cast(u64, width) * cast(u64, height) * 4;
    if r.uploadBuffer && requiredSize == r.uploadSize {
        return true;
    }
    if r.uploadBuffer != null {
        cast(fn(id, SEL): void, objc_msgSend)(r.uploadBuffer, thirteen_sel("release"));
        r.uploadBuffer = null;
    }
    r.uploadBuffer = cast(fn(id, SEL, ThirteenNSUInteger, ThirteenNSUInteger): id, objc_msgSend)(r.device, thirteen_sel("newBufferWithLength:options:"), cast(ThirteenNSUInteger, requiredSize), cast(ThirteenNSUInteger, 0));
    if r.uploadBuffer == null {
        return false;
    }
    r.uploadSize = requiredSize;
    return true;
}
}
private {
bool thirteen_renderer_init(ThirteenRenderer* r, ThirteenPlatform* p, thirteen_uint32 width, thirteen_uint32 height) {
    id layerClass;
    CGRect layerFrame;
    r.hostView = thirteen_platform_get_window_handle(p);
    r.device = cast(id, MTLCreateSystemDefaultDevice());
    if r.device == null {
        return false;
    }
    r.commandQueue = cast(fn(id, SEL): id, objc_msgSend)(r.device, thirteen_sel("newCommandQueue"));
    if r.commandQueue == null {
        return false;
    }
    layerClass = cast(id, objc_getClass("CAMetalLayer"));
    r.metalLayer = cast(fn(id, SEL): id, objc_msgSend)(layerClass, thirteen_sel("layer"));
    if r.metalLayer == null {
        return false;
    }
    cast(fn(id, SEL, id): void, objc_msgSend)(r.metalLayer, thirteen_sel("setDevice:"), r.device);
    cast(fn(id, SEL, ThirteenNSUInteger): void, objc_msgSend)(r.metalLayer, thirteen_sel("setPixelFormat:"), cast(ThirteenNSUInteger, 70));
    cast(fn(id, SEL, bool): void, objc_msgSend)(r.metalLayer, thirteen_sel("setFramebufferOnly:"), false);
    layerFrame = CGRectMake(0.0, 0.0, cast(f64, width), cast(f64, height));
    cast(fn(id, SEL, CGRect): void, objc_msgSend)(r.metalLayer, thirteen_sel("setFrame:"), layerFrame);
    if r.hostView != null {
        var view = cast(id, r.hostView);
        cast(fn(id, SEL, bool): void, objc_msgSend)(view, thirteen_sel("setWantsLayer:"), true);
        cast(fn(id, SEL, id): void, objc_msgSend)(view, thirteen_sel("setLayer:"), r.metalLayer);
    }
    r.bufferWidth = width;
    r.bufferHeight = height;
    return thirteen_renderer_ensure_upload_buffer(r, width, height);
}
}
private {
bool thirteen_renderer_render(ThirteenRenderer* r, thirteen_uint8* pixels, thirteen_uint32 width, thirteen_uint32 height, bool vsync) {
    id drawable;
    id texture;
    id commandBuffer;
    id blit;
    void* mapped;
    ThirteenMTLSize sourceSize;
    ThirteenMTLOrigin destOrigin;
    ignore vsync;
    if !r.metalLayer || !r.commandQueue || !thirteen_renderer_ensure_upload_buffer(r, width, height) {
        return false;
    }
    drawable = cast(fn(id, SEL): id, objc_msgSend)(r.metalLayer, thirteen_sel("nextDrawable"));
    if drawable == null {
        return true;
    }
    mapped = cast(fn(id, SEL): void*, objc_msgSend)(r.uploadBuffer, thirteen_sel("contents"));
    if mapped == null {
        return false;
    }
    memcpy(mapped, pixels, cast(u64, width) * cast(u64, height) * 4);
    texture = cast(fn(id, SEL): id, objc_msgSend)(drawable, thirteen_sel("texture"));
    commandBuffer = cast(fn(id, SEL): id, objc_msgSend)(r.commandQueue, thirteen_sel("commandBuffer"));
    if !texture || !commandBuffer {
        return false;
    }
    blit = cast(fn(id, SEL): id, objc_msgSend)(commandBuffer, thirteen_sel("blitCommandEncoder"));
    if blit == null {
        return false;
    }
    sourceSize.width = cast(ThirteenNSUInteger, width);
    sourceSize.height = cast(ThirteenNSUInteger, height);
    sourceSize.depth = 1;
    destOrigin.x = 0;
    destOrigin.y = 0;
    destOrigin.z = 0;
    cast(fn(id, SEL, id, ThirteenNSUInteger, ThirteenNSUInteger, ThirteenNSUInteger, ThirteenMTLSize, id, ThirteenNSUInteger, ThirteenNSUInteger, ThirteenMTLOrigin): void, objc_msgSend)(blit, thirteen_sel("copyFromBuffer:sourceOffset:sourceBytesPerRow:sourceBytesPerImage:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:"), r.uploadBuffer, cast(ThirteenNSUInteger, 0), cast(ThirteenNSUInteger, width * 4), cast(ThirteenNSUInteger, width * height * 4), sourceSize, texture, cast(ThirteenNSUInteger, 0), cast(ThirteenNSUInteger, 0), destOrigin);
    cast(fn(id, SEL): void, objc_msgSend)(blit, thirteen_sel("endEncoding"));
    cast(fn(id, SEL, id): void, objc_msgSend)(commandBuffer, thirteen_sel("presentDrawable:"), drawable);
    cast(fn(id, SEL): void, objc_msgSend)(commandBuffer, thirteen_sel("commit"));
    return true;
}
}
private {
bool thirteen_renderer_resize(ThirteenRenderer* r, thirteen_uint32 width, thirteen_uint32 height) {
    r.bufferWidth = width;
    r.bufferHeight = height;
    if r.metalLayer != null {
        CGRect layerFrame = CGRectMake(0.0, 0.0, cast(f64, width), cast(f64, height));
        cast(fn(id, SEL, CGRect): void, objc_msgSend)(r.metalLayer, thirteen_sel("setFrame:"), layerFrame);
    }
    return thirteen_renderer_ensure_upload_buffer(r, width, height);
}
}
private {
void thirteen_renderer_shutdown(ThirteenRenderer* r) {
    if r.uploadBuffer != null {
        cast(fn(id, SEL): void, objc_msgSend)(r.uploadBuffer, thirteen_sel("release"));
        r.uploadBuffer = null;
    }
    if r.commandQueue != null {
        cast(fn(id, SEL): void, objc_msgSend)(r.commandQueue, thirteen_sel("release"));
        r.commandQueue = null;
    }
    r.device = null;
    r.metalLayer = null;
    r.hostView = null;
    r.bufferWidth = 0;
    r.bufferHeight = 0;
    r.uploadSize = 0;
}
}
// ==========================================================================
// LINUX BACKEND
// ==========================================================================
// ========== Platform/Renderer Pointers ==========
private { ThirteenPlatform* thirteen_platform_ptr = null; }
private { ThirteenRenderer* thirteen_renderer_ptr = null; }
// ========== Public API ==========
thirteen_uint8* thirteen_init(thirteen_uint32 width, thirteen_uint32 height, bool fullscreen) {
    thirteen_width = width;
    thirteen_height = height;
    thirteen_pixels_buf = cast(thirteen_uint8*, alloc(cast(i64, cast(u64, width) * height * 4)));
    if thirteen_pixels_buf == null {
        return null;
    }
    thirteen_platform_ptr = new(ThirteenPlatform[1]);
    if !thirteen_platform_ptr || !thirteen_platform_init_window(thirteen_platform_ptr, width, height) {
        free(thirteen_platform_ptr);
        thirteen_platform_ptr = null;
        free(thirteen_pixels_buf);
        thirteen_pixels_buf = null;
        return null;
    }
    thirteen_renderer_ptr = new(ThirteenRenderer[1]);
    if !thirteen_renderer_ptr || !thirteen_renderer_init(thirteen_renderer_ptr, thirteen_platform_ptr, width, height) {
        if thirteen_renderer_ptr != null {
            thirteen_renderer_shutdown(thirteen_renderer_ptr);
            free(thirteen_renderer_ptr);
            thirteen_renderer_ptr = null;
        }
        thirteen_platform_shutdown_window(thirteen_platform_ptr);
        free(thirteen_platform_ptr);
        thirteen_platform_ptr = null;
        free(thirteen_pixels_buf);
        thirteen_pixels_buf = null;
        return null;
    }
    thirteen_last_frame_time = thirteen_now_seconds();
    if fullscreen != 0 {
        thirteen_set_fullscreen(true);
    }
    return thirteen_pixels_buf;
}

bool thirteen_render() {
    f64 currentTime;
    u8[256] titleBuffer;
    thirteen_prev_mouse_x = thirteen_mouse_x;
    thirteen_prev_mouse_y = thirteen_mouse_y;
    memcpy(thirteen_prev_mouse_buttons, thirteen_mouse_buttons, cast(u64, sizeof(thirteen_mouse_buttons)));
    memcpy(thirteen_prev_keys, thirteen_keys, cast(u64, sizeof(thirteen_keys)));
    currentTime = thirteen_now_seconds();
    thirteen_last_delta_time = currentTime - thirteen_last_frame_time;
    thirteen_last_frame_time = currentTime;
    thirteen_frame_time_sum += thirteen_last_delta_time;
    thirteen_frame_count++;
    if thirteen_frame_time_sum >= 1.0 {
        thirteen_average_fps = cast(f64, thirteen_frame_count) / thirteen_frame_time_sum;
        thirteen_frame_time_sum = 0.0;
        thirteen_frame_count = 0;
    }
    thirteen_title_update_timer += thirteen_last_delta_time;
    if thirteen_title_update_timer >= 0.25 {
        thirteen_title_update_timer = 0.0;
        _thirteen_fmt_fps_title(titleBuffer, sizeof(titleBuffer), thirteen_app_name, thirteen_average_fps, 1000.0 / thirteen_average_fps);
        if thirteen_platform_ptr != null {
            thirteen_platform_set_title(thirteen_platform_ptr, titleBuffer);
        }
    }
    if thirteen_platform_ptr != null {
        thirteen_platform_pump_messages(thirteen_platform_ptr);
    }
    if thirteen_should_quit != 0 {
        return false;
    }
    if thirteen_renderer_ptr == null {
        return false;
    }
    thirteen_renderer_render(thirteen_renderer_ptr, thirteen_pixels_buf, thirteen_width, thirteen_height, thirteen_vsync_enabled);
    return !thirteen_should_quit;
}

void thirteen_set_vsync(bool enabled) {
    thirteen_vsync_enabled = enabled;
}

bool thirteen_get_vsync() {
    return thirteen_vsync_enabled;
}

void thirteen_set_application_name(u8* name) {
    _thirteen_strcpy(thirteen_app_name, sizeof(thirteen_app_name), name);
}

void thirteen_set_fullscreen(bool fullscreen) {
    if thirteen_is_fullscreen == fullscreen {
        return;
    }
    thirteen_is_fullscreen = fullscreen;
    if thirteen_platform_ptr != null {
        thirteen_platform_set_fullscreen(thirteen_platform_ptr, fullscreen, thirteen_width, thirteen_height);
    }
}

bool thirteen_get_fullscreen() {
    return thirteen_is_fullscreen;
}

thirteen_uint32 thirteen_get_width() {
    return thirteen_width;
}

thirteen_uint32 thirteen_get_height() {
    return thirteen_height;
}

ThirteenNativeWindowHandle thirteen_get_window_handle() {
    return thirteen_platform_get_window_handle(thirteen_platform_ptr);
}

thirteen_uint8* thirteen_set_size(thirteen_uint32 width, thirteen_uint32 height) {
    thirteen_uint8* reallocResult;
    if width == thirteen_width && height == thirteen_height {
        return thirteen_pixels_buf;
    }
    reallocResult = cast(thirteen_uint8*, realloc(thirteen_pixels_buf, cast(u64, width) * height * 4));
    if reallocResult == null {
        return null;
    }
    thirteen_pixels_buf = reallocResult;
    thirteen_width = width;
    thirteen_height = height;
    if !thirteen_renderer_ptr || !thirteen_renderer_resize(thirteen_renderer_ptr, width, height) {
        return null;
    }
    if thirteen_platform_ptr != null {
        thirteen_platform_resize_window(thirteen_platform_ptr, width, height, thirteen_is_fullscreen);
    }
    return thirteen_pixels_buf;
}

f64 thirteen_get_delta_time() {
    return thirteen_last_delta_time;
}

void thirteen_get_mouse_position(i32* x, i32* y) {
    *x = thirteen_mouse_x;
    *y = thirteen_mouse_y;
}

void thirteen_get_mouse_position_last_frame(i32* x, i32* y) {
    *x = thirteen_prev_mouse_x;
    *y = thirteen_prev_mouse_y;
}

bool thirteen_get_mouse_button(i32 button) {
    if button >= 0 && button < 3 {
        return thirteen_mouse_buttons[button];
    }
    return false;
}

bool thirteen_get_mouse_button_last_frame(i32 button) {
    if button >= 0 && button < 3 {
        return thirteen_prev_mouse_buttons[button];
    }
    return false;
}

bool thirteen_get_key(i32 keyCode) {
    if keyCode >= 0 && keyCode < 256 {
        return thirteen_keys[keyCode];
    }
    return false;
}

bool thirteen_get_key_last_frame(i32 keyCode) {
    if keyCode >= 0 && keyCode < 256 {
        return thirteen_prev_keys[keyCode];
    }
    return false;
}

void thirteen_shutdown() {
    if thirteen_renderer_ptr != null {
        thirteen_renderer_shutdown(thirteen_renderer_ptr);
        free(thirteen_renderer_ptr);
        thirteen_renderer_ptr = null;
    }
    if thirteen_platform_ptr != null {
        thirteen_platform_shutdown_window(thirteen_platform_ptr);
        free(thirteen_platform_ptr);
        thirteen_platform_ptr = null;
    }
    free(thirteen_pixels_buf);
    thirteen_pixels_buf = null;
}


}

// ----------------------------------------------------------------------------
// wasm arm (raw wasm + canvas 2D, host JS at thirteen.js)
// ----------------------------------------------------------------------------
when os(wasm) {
// thirteen_wasm — raw-wasm implementation of the thirteen API. The JS
// host (thirteen.js) provides the env.thirteen_js_* imports below and
// calls the exported thirteen_frame / thirteen_set_* setters.

extern "env" {
    void thirteen_js_init(i32 width, i32 height, u8* name_ptr, i32 name_len);
    void thirteen_js_present(u8* pixels, i32 width, i32 height);
    void thirteen_js_resize(i32 width, i32 height);
    i64 thirteen_js_now_nanos();
    void thirteen_js_set_vsync(bool enabled);
    void thirteen_js_set_fullscreen(bool fullscreen);
    void thirteen_js_set_title(u8* name_ptr, i32 name_len);
}

u32 thirteen_width  = 320;
u32 thirteen_height = 200;
bool thirteen_should_quit  = false;
bool thirteen_vsync_enabled = true;
bool thirteen_is_fullscreen = false;

f64 thirteen_last_frame_time   = 0.0;
f64 thirteen_last_delta_time   = 0.0;

i32 thirteen_mouse_x = 0;
i32 thirteen_mouse_y = 0;
i32 thirteen_prev_mouse_x = 0;
i32 thirteen_prev_mouse_y = 0;
bool[3] thirteen_mouse_buttons;
bool[3] thirteen_prev_mouse_buttons;
bool[256] thirteen_keys;
bool[256] thirteen_prev_keys;

u8* thirteen_pixels_buf = null;

u8* thirteen_init(u32 width, u32 height, bool fullscreen) {
    thirteen_width = width;
    thirteen_height = height;
    thirteen_is_fullscreen = fullscreen;
    thirteen_pixels_buf = alloc<u8>(cast(i32, width * height * cast(u32, 4)));
    if thirteen_pixels_buf == null { return null; }
    u8[12] default_name = { 84, 104, 105, 114, 116, 101, 101, 110, 65, 112, 112, 0 };  // "ThirteenApp"
    thirteen_js_init(cast(i32, width), cast(i32, height), &default_name[0], 11);
    if fullscreen { thirteen_js_set_fullscreen(true); }
    thirteen_last_frame_time = cast(f64, thirteen_js_now_nanos()) * 1.0e-9;
    return thirteen_pixels_buf;
}

bool thirteen_render() {
    if thirteen_should_quit { return false; }
    for i32 i = 0; i < 3; i++ {
        thirteen_prev_mouse_buttons[i] = thirteen_mouse_buttons[i];
    }
    for i32 i = 0; i < 256; i++ {
        thirteen_prev_keys[i] = thirteen_keys[i];
    }
    thirteen_prev_mouse_x = thirteen_mouse_x;
    thirteen_prev_mouse_y = thirteen_mouse_y;

    f64 now = cast(f64, thirteen_js_now_nanos()) * 1.0e-9;
    thirteen_last_delta_time = now - thirteen_last_frame_time;
    thirteen_last_frame_time = now;

    thirteen_js_present(thirteen_pixels_buf, cast(i32, thirteen_width), cast(i32, thirteen_height));
    return true;
}

void thirteen_set_vsync(bool enabled) {
    thirteen_vsync_enabled = enabled;
    thirteen_js_set_vsync(enabled);
}

bool thirteen_get_vsync() { return thirteen_vsync_enabled; }

void thirteen_set_application_name(u8* name) {
    i32 n = 0;
    while *(name + n) != cast(u8, 0) && n < 256 { n = n + 1; }
    thirteen_js_set_title(name, n);
}

void thirteen_set_fullscreen(bool fullscreen) {
    if thirteen_is_fullscreen == fullscreen { return; }
    thirteen_is_fullscreen = fullscreen;
    thirteen_js_set_fullscreen(fullscreen);
}

bool thirteen_get_fullscreen() { return thirteen_is_fullscreen; }
u32 thirteen_get_width()  { return thirteen_width; }
u32 thirteen_get_height() { return thirteen_height; }

u8* thirteen_set_size(u32 width, u32 height) {
    if width == thirteen_width && height == thirteen_height {
        return thirteen_pixels_buf;
    }
    free(cast(void*, thirteen_pixels_buf));
    thirteen_pixels_buf = alloc<u8>(cast(i32, width * height * cast(u32, 4)));
    if thirteen_pixels_buf == null { return null; }
    thirteen_width = width;
    thirteen_height = height;
    thirteen_js_resize(cast(i32, width), cast(i32, height));
    return thirteen_pixels_buf;
}

f64 thirteen_get_delta_time() { return thirteen_last_delta_time; }

void thirteen_get_mouse_position(i32* x, i32* y) {
    *x = thirteen_mouse_x;
    *y = thirteen_mouse_y;
}

void thirteen_get_mouse_position_last_frame(i32* x, i32* y) {
    *x = thirteen_prev_mouse_x;
    *y = thirteen_prev_mouse_y;
}

bool thirteen_get_mouse_button(i32 button) {
    if button >= 0 && button < 3 { return thirteen_mouse_buttons[button]; }
    return false;
}

bool thirteen_get_mouse_button_last_frame(i32 button) {
    if button >= 0 && button < 3 { return thirteen_prev_mouse_buttons[button]; }
    return false;
}

bool thirteen_get_key(i32 keycode) {
    if keycode >= 0 && keycode < 256 { return thirteen_keys[keycode]; }
    return false;
}

bool thirteen_get_key_last_frame(i32 keycode) {
    if keycode >= 0 && keycode < 256 { return thirteen_prev_keys[keycode]; }
    return false;
}

void thirteen_shutdown() {
    if thirteen_pixels_buf != null {
        free(cast(void*, thirteen_pixels_buf));
        thirteen_pixels_buf = null;
    }
}

// thirteen_run stores the callback. The JS host calls thirteen_frame
// once per requestAnimationFrame.
fn(): void g_user_on_frame = null;

void thirteen_run(fn(): void on_frame) {
    g_user_on_frame = on_frame;
}

export void thirteen_frame() {
    if g_user_on_frame != null { g_user_on_frame(); }
    thirteen_render();
}

// Input setters called from JS event handlers.
export void thirteen_set_mouse_pos(i32 x, i32 y) {
    thirteen_mouse_x = x;
    thirteen_mouse_y = y;
}

export void thirteen_set_mouse_button(i32 button, bool down) {
    if button >= 0 && button < 3 { thirteen_mouse_buttons[button] = down; }
}

export void thirteen_set_key(i32 keycode, bool down) {
    if keycode >= 0 && keycode < 256 { thirteen_keys[keycode] = down; }
}

export void thirteen_signal_quit() {
    thirteen_should_quit = true;
}

}
