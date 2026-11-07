#!/bin/sh
# it13: perf's L9 instrumented template (their head pck) on the iGPU at 1280x800, the riot, stock vs trim.
D=/c/Users/kazda/kiro/gtai-d9x/scratch/it13/tw
export APPDATA=C:/Users/kazda/kiro/gtai-d9x/appdata/handheld
export GTAI_TW_LOG=1
arm() { name=$1; mb=$2
  powershell -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w $D/sample_rtai.ps1)" -Tag "riot-$name" > $D/sample-$name.jsonl 2>&1 &
  GTAI_TW_TRIM_MB=$mb "$D/RTAI-bench.exe" --screen 0 --rendering-driver d3d12 --gpu-index 1 --resolution 1280x800 --max-fps 60 \
    -- --scenario=riot --zoom=1.0 --view=tilt70 --secs=30 --out=$(cygpath -w $D/riot-$name.json) > $D/riot-$name.log 2>&1
  wait
}
arm stock 0
arm trim 32
