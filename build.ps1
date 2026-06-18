# build.ps1 — build (and run) a thirteen-minc example.
#
# Usage:
#   ./build.ps1                              # build + run examples/simple
#   ./build.ps1 examples/simple              # build + run a named example
#   ./build.ps1 examples/simple -NoRun       # compile only, don't launch
#   ./build.ps1 wasm examples/simple         # wasm: build + serve + open browser
#   ./build.ps1 wasm examples/simple -NoRun  # wasm: build + serve, no browser
#   ./build.ps1 linux examples/simple        # cross-compile object
#
# Conventions:
#   - First positional arg is either a target (native/windows/linux/
#     macos/wasm) or the source. If a target, the next positional arg
#     is the source.
#   - Each example is a single file examples/<name>.mc. You may pass
#     just `examples/<name>` (no extension); the script adds .mc.
#   - You can also pass a direct path to any .mc file.
#   - Native output goes in build/<name>/<name>.exe. For wasm, output
#     is build/<name>/main.wasm and lib/thirteen.js is auto-staged
#     next to it (driven by `@wasm_host "thirteen.js"` in lib/thirteen.mc).

param(
    [Parameter(Position=0)]
    [string]$Arg0,
    [Parameter(Position=1)]
    [string]$Arg1,
    [switch]$NoRun
)

# Resolve: arg0 may be a target ("wasm", "linux", …) or the source.
$Target = "native"
$Source = $null
$validTargets = @("native", "windows", "linux", "macos", "wasm")
if ($validTargets -contains $Arg0) {
    $Target = $Arg0
    $Source = $Arg1
} else {
    $Source = $Arg0
    if ($Arg1) {
        Write-Error "unexpected second positional argument: $Arg1"
        exit 1
    }
}

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# Locate the minc compiler.
$minc = $null
$localMinc = Join-Path $root 'tools\minc\minc.exe'
if (Test-Path $localMinc) {
    $minc = (Resolve-Path $localMinc).Path
} else {
    $minc = (Get-Command minc.exe -ErrorAction SilentlyContinue).Source
}
if (-not $minc) {
    Write-Host ""
    Write-Host "minc compiler not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  1. Auto-fetch the pinned closed-source binary (~1.7 MB):"
    Write-Host "       .\tools\get_minc.ps1"
    Write-Host "  2. Install manually from"
    Write-Host "       https://github.com/SpacesOfPlay/minc-dev/releases"
    Write-Host "     and put minc.exe on PATH."
    Write-Host ""
    exit 1
}

$defaultExample = "examples\simple.mc"
if (-not $Source) {
    $Source = "examples\simple"
    Write-Host "no source given — running default example: $Source"
    Write-Host "  other examples:"
    Get-ChildItem (Join-Path $root 'examples') -Recurse -Filter *.mc |
        Where-Object { $_.FullName -ne (Join-Path $root $defaultExample) } |
        ForEach-Object {
            $rel = $_.FullName.Substring($root.Length + 1).Replace('\', '/')
            Write-Host "    ./build.ps1 $rel"
        }
    Write-Host ""
}

# Accept either examples/<name> (no extension), examples/<name>.mc, or
# a direct path to any .mc file.
if (-not [System.IO.Path]::IsPathRooted($Source)) {
    $Source = Join-Path $root $Source
}
if (Test-Path $Source -PathType Leaf) {
    $src = $Source
} elseif (Test-Path "$Source.mc" -PathType Leaf) {
    $src = "$Source.mc"
} else {
    Write-Error "source not found: $Source (also tried $Source.mc)"
    exit 1
}
$name = [System.IO.Path]::GetFileNameWithoutExtension($src)

$libMc = Join-Path $root 'lib\thirteen.mc'
if (-not (Test-Path $libMc)) {
    Write-Error "missing $libMc — dist is corrupt"; exit 1
}

$buildDir = Join-Path $root 'build' $name
if (-not (Test-Path $buildDir)) { New-Item -ItemType Directory -Path $buildDir -Force | Out-Null }

if ($Target -eq "wasm") {
    # Delegate to `minc run` — it stages files declared via @wasm_host
    # in lib/thirteen.mc, generates the index.html shell, fires up an
    # http server on 127.0.0.1:8080, and (without --no-browser) opens
    # the browser. Ctrl+C in the terminal stops the server.
    $out = Join-Path $buildDir 'main.wasm'
    $mincArgs = @('run', $src, '--target', 'wasm', '-o', $out)
    if ($NoRun) { $mincArgs += '--no-browser' }
    Write-Host "compiling $name (wasm)..."
    Push-Location $root
    try {
        & $minc @mincArgs
        exit $LASTEXITCODE
    } finally { Pop-Location }
}

# Native / cross-compile path: build + (optionally) run.
$out = Join-Path $buildDir "$name.exe"
$mincArgs = @($src, '-o', $out)
if ($Target -ne "native") { $mincArgs += @('--target', $Target) }

Write-Host "compiling $name ($Target)..."
Push-Location $root
try {
    & $minc @mincArgs
    if ($LASTEXITCODE -ne 0) { Write-Error "minc compile failed."; exit $LASTEXITCODE }
} finally { Pop-Location }
Write-Host "built $out"

if (-not $NoRun) {
    Write-Host "running..."
    Push-Location $buildDir
    try { & $out; exit $LASTEXITCODE } finally { Pop-Location }
}
