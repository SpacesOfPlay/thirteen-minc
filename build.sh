#!/usr/bin/env bash
# build.sh — build (and run) a thirteen-minc example.
#
# Usage:
#   ./build.sh                          # build + run examples/simple
#   ./build.sh examples/simple
#   ./build.sh examples/simple --no-run
#   ./build.sh wasm examples/simple     # wasm: build + serve + open browser
#   ./build.sh wasm examples/simple --no-run
#   ./build.sh linux examples/simple    # cross-compile
#
# The first positional arg is either a target (native/windows/linux/
# macos/wasm) or the source. If a target, the next positional arg is
# the source.

set -euo pipefail
root="$(cd "$(dirname "$0")" && pwd)"

src=""
target="native"
no_run=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-run) no_run=1; shift ;;
        native|windows|linux|macos|wasm)
            target="$1"; shift ;;
        *)
            if [[ -z "$src" ]]; then src="$1"
            else echo "unknown arg: $1" >&2; exit 1; fi
            shift ;;
    esac
done

# minc: $MINC override (install dir, or a direct binary path), else
# PATH (installed toolchain), else next
# to this script (manual zip layout). Install from https://minc.dev.
if [[ -n "${MINC:-}" ]]; then
    if [[ -d "$MINC" ]]; then minc="$MINC/minc"; else minc="$MINC"; fi
elif command -v minc >/dev/null 2>&1; then
    minc="$(command -v minc)"
else
    minc="$root/minc"
fi
if [[ ! -x "$minc" ]]; then
    echo "minc compiler not found. Install it:" >&2
    echo "  curl -fsSL https://minc.dev/install | bash" >&2
    echo "or set MINC (see install_minc.md)." >&2
    exit 1
fi

default_example="examples/simple"
if [[ -z "$src" ]]; then
    src="$default_example"
    echo "no source given — running default example: $src"
    echo "  other examples:"
    find "$root/examples" -name '*.mc' -type f | sort | while read -r f; do
        rel="${f#$root/}"
        if [[ "$rel" != "$default_example.mc" ]]; then
            echo "    ./build.sh $rel"
        fi
    done
    echo
fi

[[ "$src" != /* ]] && src="$root/$src"
# Accept either examples/<name> (no extension), examples/<name>.mc, or
# a direct path to any .mc file.
if [[ -f "$src" ]]; then
    :
elif [[ -f "$src.mc" ]]; then
    src="$src.mc"
else
    echo "source not found: $src (also tried $src.mc)" >&2; exit 1
fi
name="$(basename "${src%.*}")"

[[ -f "$root/lib/thirteen.mc" ]] || { echo "missing $root/lib/thirteen.mc — dist is corrupt" >&2; exit 1; }

build="$root/build/$name"
mkdir -p "$build"

if [[ "$target" == "wasm" ]]; then
    # Delegate to `minc run` — stages files declared via @wasm_host in
    # lib/thirteen.mc, generates the index.html, fires up http server,
    # (without --no-browser) opens the browser. Ctrl+C stops the server.
    out="$build/main.wasm"
    args=("run" "$src" "--target" "wasm" "-o" "$out")
    [[ $no_run -eq 1 ]] && args+=("--no-browser")
    echo "compiling $name (wasm)..."
    exec "$minc" "${args[@]}"
fi

out="$build/$name"
minc_args=("$src" "-o" "$out")
[[ "$target" != "native" ]] && minc_args+=("--target" "$target")

echo "compiling $name ($target)..."
(cd "$root" && "$minc" "${minc_args[@]}")
echo "built $out"

if [[ $no_run -eq 0 ]]; then
    echo "running..."
    (cd "$build" && "$out")
fi
