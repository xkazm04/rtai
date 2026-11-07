#!/bin/sh
# Builds the CitySim GDExtension for Linux x86_64 (template_release + template_debug) inside Valve's
# Steam Linux Runtime 3.0 "sniper" SDK image (glibc 2.31: what a Steam build for the Deck runs on),
# from a throwaway copy of native/ (nothing is written to the checkout but the git-ignored .so files
# in project/native/bin/). Needs Docker. GODOT_CPP=<dir> when this checkout's godot-cpp submodule is
# not checked out (e.g. a worktree: the main checkout's native/godot-cpp at the same pinned commit).
# Usage: sh tools/handheld/build_linux_so.sh   (from the repo root, Git Bash)
set -eu
ROOT=$(pwd -W 2>/dev/null || pwd)
GCPP=${GODOT_CPP:-$ROOT/native/godot-cpp}
IMAGE=registry.gitlab.steamos.cloud/steamrt/sniper/sdk:latest
mkdir -p build/linux-so
MSYS_NO_PATHCONV=1 docker run --rm -v "$ROOT/native:/src:ro" -v "$GCPP:/gcpp:ro" -v "$ROOT/build/linux-so:/out" "$IMAGE" bash -c '
set -e; mkdir -p /tmp/b/native /tmp/b/project/native/bin; cp -r /src/. /tmp/b/native/
rm -rf /tmp/b/native/godot-cpp; cp -r /gcpp /tmp/b/native/godot-cpp; cd /tmp/b/native; rm -rf build godot-cpp/bin
for t in template_release template_debug; do
  scons -j"$(nproc)" platform=linux arch=x86_64 target=$t > /out/scons-$t.log 2>&1 || { tail -20 /out/scons-$t.log; exit 1; }
done
cp /tmp/b/project/native/bin/*.so /out/'
cp build/linux-so/*.so project/native/bin/
ls -la project/native/bin/*.so
