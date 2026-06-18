// examples/minesweeper — port of Atrix256/Thirteen Examples/Minesweeper.
//
// Cells are drawn per-pixel into the RGBA buffer (no font, no helpers
// beyond a circle test).
//
//   Left click   reveal a cell. Mine = game over.
//   Right click  toggle a flag.
//   SPACE        restart with a fresh board.
//   V            toggle vsync
//   F            toggle fullscreen
//   ESC          quit
//

import thirteen;

// --- Geometry ----------------------------------------------------------------
i32 c_width      = 768;
i32 c_height     = 768;
bool c_fullscreen = false;

i32 BOARD_COLS = 16;
i32 BOARD_ROWS = 16;
i32 MINE_COUNT = 40;

// --- Game state --------------------------------------------------------------
bool[256] g_mines;
bool[256] g_revealed;
bool[256] g_flagged;
bool g_initialized = false;
u32  g_rng         = 1;

i32 GS_UNDECIDED = 0;
i32 GS_WIN       = 1;
i32 GS_LOSE      = 2;

// --- Xorshift32 --------------------------------------------------------------
// Upstream uses std::mt19937; Xorshift32 is good enough
// Returns a non-negative i32.
i32 rng_next() {
    u32 x = g_rng;
    x = x ^ (x << 13);
    x = x ^ (x >> 17);
    x = x ^ (x << 5);
    g_rng = x;
    return cast(i32, x & 0x7fffffff);
}

i32 cell_idx(i32 col, i32 row) { return row * BOARD_COLS + col; }

bool in_bounds(i32 col, i32 row) {
    return col >= 0 && col < BOARD_COLS && row >= 0 && row < BOARD_ROWS;
}

// --- Board logic -------------------------------------------------------------
void board_initialize(u32 seed) {
    g_rng = seed;
    for i32 i = 0; i < BOARD_COLS * BOARD_ROWS; i++ {
        g_mines[i]    = false;
        g_revealed[i] = false;
        g_flagged[i]  = false;
    }
    i32 placed = 0;
    while placed < MINE_COUNT {
        i32 idx = cell_idx(rng_next() % BOARD_COLS, rng_next() % BOARD_ROWS);
        if g_mines[idx] { continue; }
        g_mines[idx] = true;
        placed = placed + 1;
    }
    g_initialized = true;
}

bool revealed_at(i32 x, i32 y) { return g_revealed[cell_idx(x, y)]; }
bool flagged_at(i32 x, i32 y)  { return g_flagged[cell_idx(x, y)]; }
bool mine_at(i32 x, i32 y)     { return g_mines[cell_idx(x, y)]; }

i32 num_neighbors(i32 cellX, i32 cellY) {
    i32 ret = 0;
    for i32 iy = -1; iy <= 1; iy++ {
        for i32 ix = -1; ix <= 1; ix++ {
            if ix == 0 && iy == 0 { continue; }
            i32 x = cellX + ix;
            i32 y = cellY + iy;
            if !in_bounds(x, y) { continue; }
            if mine_at(x, y) { ret = ret + 1; }
        }
    }
    return ret;
}

i32 game_result() {
    i32 n = BOARD_COLS * BOARD_ROWS;
    // Any revealed mine -> lose.
    for i32 i = 0; i < n; i++ {
        if g_revealed[i] && g_mines[i] { return GS_LOSE; }
    }
    // Any unrevealed non-mine -> still going.
    for i32 i = 0; i < n; i++ {
        if !g_revealed[i] && !g_mines[i] { return GS_UNDECIDED; }
    }
    return GS_WIN;
}

// Iterative flood-fill — mirrors upstream's std::vector-based loop.
// 256 cells max so a fixed stack is safe; saves an alloc.
i32[256] g_reveal_stack;
i32 g_reveal_sp = 0;

void handle_left_click(i32 x, i32 y) {
    g_revealed[cell_idx(x, y)] = true;
    if mine_at(x, y) { return; }

    g_reveal_sp = 0;
    g_reveal_stack[g_reveal_sp] = cell_idx(x, y);
    g_reveal_sp = g_reveal_sp + 1;

    while g_reveal_sp > 0 {
        g_reveal_sp = g_reveal_sp - 1;
        i32 idx = g_reveal_stack[g_reveal_sp];
        i32 cx  = idx % BOARD_COLS;
        i32 cy  = idx / BOARD_COLS;
        if num_neighbors(cx, cy) != 0 { continue; }
        for i32 iy = -1; iy <= 1; iy++ {
            for i32 ix = -1; ix <= 1; ix++ {
                if ix == 0 && iy == 0 { continue; }
                i32 nx = cx + ix;
                i32 ny = cy + iy;
                if !in_bounds(nx, ny) { continue; }
                if !revealed_at(nx, ny) {
                    g_revealed[cell_idx(nx, ny)] = true;
                    g_reveal_stack[g_reveal_sp] = cell_idx(nx, ny);
                    g_reveal_sp = g_reveal_sp + 1;
                }
            }
        }
    }
}

void handle_right_click(i32 x, i32 y) {
    i32 idx = cell_idx(x, y);
    g_flagged[idx] = !g_flagged[idx];
}

void screen_to_board(i32 screenX, i32 screenY, i32* boardX, i32* boardY) {
    f32 percentX = (cast(f32, screenX) + 0.5f) / cast(f32, c_width);
    f32 percentY = (cast(f32, screenY) + 0.5f) / cast(f32, c_height);
    *boardX = cast(i32, percentX * cast(f32, BOARD_COLS));
    *boardY = cast(i32, percentY * cast(f32, BOARD_ROWS));
}

// --- Pixel drawing -----------------------------------------------------------
void set_rgb(u8* out, u8 r, u8 g, u8 b) {
    out[0] = r;
    out[1] = g;
    out[2] = b;
}

// Squared-distance circle test — saves the sqrt the upstream uses.
bool in_circle(i32 x, i32 y, i32 cx, i32 cy, i32 radius) {
    i32 dx = x - cx;
    i32 dy = y - cy;
    return (dx * dx + dy * dy) < (radius * radius);
}

// A dark-gray dot at cell-relative (cx, cy) if this pixel lands inside it.
void dot(u8* out, i32 relX, i32 relY, i32 cx, i32 cy, i32 radius) {
    if in_circle(relX, relY, cx, cy, radius) { set_rgb(out, 64, 64, 64); }
}

// Classic-domino dot layout for neighbor counts 1..8. Each tier of dots
// switches on at the count where that face of the die gains it.
void draw_dots(u8* out, i32 n, i32 relX, i32 relY, i32 cellW, i32 cellH) {
    i32 r  = cellW / 8;
    i32 lo = cellW / 4;
    i32 hi = cellW * 3 / 4;
    i32 mx = cellW / 2;
    i32 my = cellH / 2;
    i32 ty = cellH / 4;
    i32 by = cellH * 3 / 4;

    if n == 1 || n == 3 || n == 5 || n == 7 { dot(out, relX, relY, mx, my, r); }   // center
    if n >= 2 { dot(out, relX, relY, lo, ty, r); dot(out, relX, relY, hi, by, r); } // UL + LR
    if n >= 4 { dot(out, relX, relY, lo, by, r); dot(out, relX, relY, hi, ty, r); } // LL + UR
    if n >= 6 { dot(out, relX, relY, lo, my, r); dot(out, relX, relY, hi, my, r); } // L + R mid
    if n == 8 { dot(out, relX, relY, mx, ty, r); dot(out, relX, relY, mx, by, r); } // T + B mid
}

void draw_pixel(i32 x, i32 y, u8* out, i32 game_state) {
    out[3] = 255;

    i32 cellX = 0;
    i32 cellY = 0;
    screen_to_board(x, y, &cellX, &cellY);

    i32 cellW = c_width  / BOARD_COLS;
    i32 cellH = c_height / BOARD_ROWS;

    i32 relX = x % cellW;
    i32 relY = y % cellH;

    if !revealed_at(cellX, cellY) {
        // 3D-bevel: light top/left, dark bottom/right.
        if relX < 2 || relY < 2 {
            set_rgb(out, 255, 255, 255);
        }
        else if relX >= cellW - 2 || relY >= cellH - 2 {
            set_rgb(out, 128, 128, 128);
        }
        else {
            set_rgb(out, 192, 192, 192);
        }
        if flagged_at(cellX, cellY) && in_circle(relX, relY, cellW / 2, cellH / 2, cellW / 4) {
            set_rgb(out, 0, 255, 0);
        }
    }
    else if mine_at(cellX, cellY) {
        // Revealed mine: red circle on pink background.
        if in_circle(relX, relY, cellW / 2, cellH / 2, cellW / 3) {
            set_rgb(out, 255, 0, 0);
        }
        else {
            set_rgb(out, 255, 128, 128);
        }
    }
    else {
        // Revealed empty: thin dark border + flat fill, then domino dots.
        if relX < 1 || relY < 1 || relX >= cellW - 1 || relY >= cellH - 1 {
            set_rgb(out, 100, 100, 100);
        }
        else {
            set_rgb(out, 164, 164, 164);
        }
        draw_dots(out, num_neighbors(cellX, cellY), relX, relY, cellW, cellH);
    }

    // Whole-image tint for game-over.
    if game_state == GS_WIN {
        out[1] = 255;
    }
    else if game_state == GS_LOSE {
        out[1] = cast(u8, out[1] / 2);
        out[2] = cast(u8, out[2] / 2);
    }
}

// --- Main loop ---------------------------------------------------------------
u8* g_pixels = null;
bool g_dirty = true;
i32 g_last_game_state = 0;   // = GS_UNDECIDED; literal because globals can't init from other globals
bool g_prev_v     = false;
bool g_prev_f     = false;
bool g_prev_space = false;
bool g_prev_left  = false;
bool g_prev_right = false;
u32 g_frame       = 0;

void on_frame() {
    bool cur_v = thirteen_get_key(VK_V);
    if cur_v && !g_prev_v { thirteen_set_vsync(!thirteen_get_vsync()); }
    g_prev_v = cur_v;

    bool cur_f = thirteen_get_key(VK_F);
    if cur_f && !g_prev_f { thirteen_set_fullscreen(!thirteen_get_fullscreen()); }
    g_prev_f = cur_f;

    bool cur_space = thirteen_get_key(VK_SPACE);
    if !g_initialized || (cur_space && !g_prev_space) {
        // Seed from the frame counter so successive resets differ.
        board_initialize(g_frame + 1);
        g_dirty = true;
    }
    g_prev_space = cur_space;

    i32 gs = game_result();
    if gs == GS_UNDECIDED {
        bool cur_left = thirteen_get_mouse_button(THIRTEEN_MOUSE_LEFT);
        if cur_left && !g_prev_left {
            i32 mx = 0; i32 my = 0;
            thirteen_get_mouse_position(&mx, &my);
            i32 cx = 0; i32 cy = 0;
            screen_to_board(mx, my, &cx, &cy);
            if in_bounds(cx, cy) { handle_left_click(cx, cy); g_dirty = true; }
        }
        g_prev_left = cur_left;

        bool cur_right = thirteen_get_mouse_button(THIRTEEN_MOUSE_RIGHT);
        if cur_right && !g_prev_right {
            i32 mx = 0; i32 my = 0;
            thirteen_get_mouse_position(&mx, &my);
            i32 cx = 0; i32 cy = 0;
            screen_to_board(mx, my, &cx, &cy);
            if in_bounds(cx, cy) { handle_right_click(cx, cy); g_dirty = true; }
        }
        g_prev_right = cur_right;
    }
    else {
        g_prev_left  = thirteen_get_mouse_button(THIRTEEN_MOUSE_LEFT);
        g_prev_right = thirteen_get_mouse_button(THIRTEEN_MOUSE_RIGHT);
    }

    if g_last_game_state != gs {
        g_last_game_state = gs;
        g_dirty = true;
    }

    if g_dirty {
        for i32 iy = 0; iy < c_height; iy++ {
            for i32 ix = 0; ix < c_width; ix++ {
                i32 i = (iy * c_width + ix) * 4;
                draw_pixel(ix, iy, &g_pixels[i], gs);
            }
        }
        g_dirty = false;
    }

    g_frame = g_frame + 1;
}

i32 main() {
    thirteen_set_application_name("Thirteen Demo - Minesweeper");
    g_pixels = thirteen_init(cast(u32, c_width), cast(u32, c_height), c_fullscreen);
    if g_pixels == null { return 1; }
    thirteen_run(on_frame);
    return 0;
}
