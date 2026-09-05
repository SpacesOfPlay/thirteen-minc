// build.mc - build (and run) a thirteen-minc example.
//
// Usage, from this folder:
//   minc run                       build + run examples/simple
//   minc run examples/simple       build + run a named example
//   minc run <x> --no-run          compile only
//   minc build [<example>]         compile only
//   minc build linux <example>     cross-compile (windows/linux/macos)
//   minc wasm [<example>]          build + serve + open browser
//   minc wasm <x> --no-run         build + serve, no browser
//   minc clean
//
// Each example is a single file examples/<name>.mc; pass
// `examples/<name>` (no extension) or a path to any .mc file.
//
// Native output goes in build/<name>/ and runs with that directory as
// the working directory. Wasm output is build/<name>/main.wasm, with
// lib/thirteen.js staged next to it. An OS word before the source
// cross-compiles, build only.
//
// The compiler is taken from MINC, then PATH, then this folder
// (install: https://minc.dev).

@minc_min_version "0.9.14"

// Older minc ignores the tag above; this forces an error instead.
when !defined(MINC_VERSION) || MINC_VERSION < 9014 {
    minc_0_9_14_or_newer_required please_update_minc;
}

import process;
import file;
import str;

when os(windows) { str HOST_EXE_SUFFIX = ".exe"; }
when os(linux) || os(macos) { str HOST_EXE_SUFFIX = ""; }

str DEFAULT_EXAMPLE = "examples/simple";

string join_named(str dir, str name, str ext) {
    string base = str_concat(name, ext);
    defer free(base);
    return path_join(dir, base);
}

void die(str s) {
    eprint("{}\n", s);
    exit(1);
    return;
}

// MINC (install dir or binary), then PATH, then this folder.
string find_minc() {
    string env = env_get("MINC");
    if env.len > 0 {
        if path_is_dir(env) {
            string cand = join_named(env, "minc", HOST_EXE_SUFFIX);
            free(env);
            return cand;
        }
        return env;
    }
    free(env);

    string onpath = path_which("minc");
    if onpath.len > 0 { return onpath; }
    free(onpath);

    string local = str_concat("./minc", HOST_EXE_SUFFIX);
    if path_exists(local) { return local; }
    free(local);

    string none = { .data = null, .len = 0 };
    return none;
}

void list_other_examples() {
    DirList files = dir_list("examples", ".mc", false);
    defer dir_list_free(&files);
    for i32 i = 0; i < files.count; i++ {
        string rel = path_join("examples", files.items[i]);
        defer free(rel);
        if str_equal(rel, "examples/simple.mc") { continue; }
        print("    minc run {}\n", rel);
    }
    return;
}

// examples/<name>, examples/<name>.mc, or any .mc path. Caller frees.
string resolve_source(str arg) {
    if path_exists(arg) && !path_is_dir(arg) { return string(arg); }
    string with_ext = str_concat(arg, ".mc");
    if path_exists(with_ext) { return with_ext; }
    free(with_ext);
    eprint("source not found: {} (also tried with .mc)\n", arg);
    exit(1);
    string none = { .data = null, .len = 0 };
    return none;
}

// Run build/<name>/<name> with its own directory as cwd. Windows
// resolves a relative program path against the parent's directory,
// POSIX against the child's.
i32 run_built(str dir, str name) {
    string from_root = join_named(dir, name, HOST_EXE_SUFFIX);
    defer free(from_root);
    string from_dir = str_concat("./", name);
    defer free(from_dir);
    ProcCmd c = { .cwd = dir };
    when os(windows) { c.args[0] = from_root; }
    when os(linux) || os(macos) { c.args[0] = from_dir; }
    ProcResult r = proc_run(&c);
    i32 rc = r.exit_code;
    proc_result_free(&r);
    return rc;
}

void usage() {
    print("usage: minc <run|build|wasm|clean> [<os>] [<example>] [--no-run]\n"
          "  minc run [examples/<name>]      build + run (default: examples/simple)\n"
          "  minc build [examples/<name>]    compile only\n"
          "  minc build linux <example>      cross-compile (windows/linux/macos)\n"
          "  minc wasm [examples/<name>]     build + serve + open browser\n"
          "  minc clean                      remove build/\n");
    return;
}

i32 main() {
    i32 argc = get_argc();
    str verb = "run";
    str os_target = "";
    str target = "";
    bool no_run = false;

    for i32 i = 1; i < argc; i++ {
        str a = str_from_cstr(get_arg(i));
        if str_equal(a, "--no-run") { no_run = true; }
        else if i == 1 {
            // A .mc path in the verb slot means "run this".
            if str_ends_with(a, ".mc") { target = a; }
            else { verb = a; }
        } else if str_equal(a, "windows") || str_equal(a, "linux")
               || str_equal(a, "macos") || str_equal(a, "native") {
            if !str_equal(a, "native") { os_target = a; }
        } else if target.len == 0 { target = a; }
    }

    if str_equal(verb, "clean") {
        ignore dir_remove("build");
        print("clean.\n");
        return 0;
    }
    if !str_equal(verb, "run") && !str_equal(verb, "build") && !str_equal(verb, "wasm") {
        usage();
        return 1;
    }

    string minc = find_minc();
    defer free(minc);
    if minc.len == 0 {
        print("\nminc compiler not found.\n"
              "Install it:  powershell -c \"irm minc.dev/install.ps1 | iex\"\n"
              "or set MINC (see install_minc.md).\n");
        die("See README.md (Quickstart) and LICENSE.md.");
    }

    if !path_exists("lib/thirteen.mc") {
        die("missing lib/thirteen.mc - dist is incomplete");
    }

    if target.len == 0 {
        target = DEFAULT_EXAMPLE;
        print("no source given - using default example: {}\n  other examples:\n", target);
        list_other_examples();
        print("\n");
    }

    string src = resolve_source(target);
    defer free(src);
    str name = path_stem(src);

    string out_dir = path_join("build", name);
    defer free(out_dir);
    ignore dir_create(out_dir);

    if str_equal(verb, "wasm") {
        // Delegate to `minc run`: it stages the @wasm_host files,
        // generates the index.html shell, serves on 127.0.0.1:8080 and
        // opens the browser. Ctrl+C stops the server.
        string wasm_out = path_join(out_dir, "main.wasm");
        defer free(wasm_out);
        print("compiling {} (wasm)...\n", name);
        ProcCmd c = { .args = {
            minc, "run", src, "--target", "wasm",
            "-o", wasm_out
        } };
        if no_run { proc_arg(&c, "--no-browser"); }
        ProcResult r = proc_run(&c);
        i32 rc = r.exit_code;
        proc_result_free(&r);
        return rc;
    }

    // Native or cross build. The suffix follows the target platform.
    str exe_suffix = HOST_EXE_SUFFIX;
    if os_target.len > 0 {
        exe_suffix = "";
        if str_equal(os_target, "windows") { exe_suffix = ".exe"; }
    }
    string exe = join_named(out_dir, name, exe_suffix);
    defer free(exe);

    print("compiling {}", name);
    if os_target.len > 0 {
        print(" ({})...\n", os_target);
    } else {
        print("...\n");
    }
    ProcCmd c = { .args = { minc, src, "-o", exe } };
    if os_target.len > 0 {
        proc_arg(&c, "--target");
        proc_arg(&c, os_target);
    }
    ProcResult r = proc_run(&c);
    i32 rc = r.exit_code;
    proc_result_free(&r);
    if rc != 0 || !path_exists(exe) { die("minc compile failed"); }
    print("built {}\n", exe);

    if os_target.len > 0 {
        print("cross-compiled - not running.\n");
        return 0;
    }
    if str_equal(verb, "run") && !no_run {
        print("running...\n");
        rc = run_built(out_dir, name);
    }
    return rc;
}
