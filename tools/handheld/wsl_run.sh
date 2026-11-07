#!/bin/bash
# SteamOS stand-in (docs/handheld/LEDGER.md): runs the linux-showcase export inside WSL2/WSLg.
# WSLg has Mesa's d3d12 Gallium driver (OpenGL over D3D12, the adapter picked by name) and no
# Vulkan-on-D3D12 ICD, so the renderer is Compatibility (opengl3) on the named adapter, or
# Forward+ on lavapipe (CPU) only as a boot check.
# Usage (from Windows): wsl.exe -d Ubuntu -- bash tools/handheld/wsl_run.sh <exe> <adapter: AMD|NVIDIA> <renderer: opengl3|vulkan> <frames.json> [arena args...]
set -u
exe="$1"; adapter="$2"; driver="$3"; frames="$4"; shift 4
export MESA_D3D12_DEFAULT_ADAPTER_NAME="$adapter"
export GALLIUM_DRIVER=d3d12
export LD_LIBRARY_PATH=/usr/lib/wsl/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export XDG_DATA_HOME="${XDG_DATA_HOME:-/tmp/gtai-handheld-xdg}"
mkdir -p "$XDG_DATA_HOME"
method=gl_compatibility; [ "$driver" = vulkan ] && method=forward_plus
"$exe" --rendering-driver "$driver" --rendering-method "$method" -- --frames="$frames" --frames-ticks=1200 "$@" 2>&1 \
  | grep -E "Using Device|OpenGL API|Vulkan|device:|SCRIPT ERROR|fight frames|CitySim|native|ERROR" | head -40
