#!/bin/bash
# A/B: city drive_dense at 32 px/m (zoom 1.0), --view=top vs --view=tilt, 2 passes alternating.
set -u
W=/c/Users/kazda/kiro/gtai-wt/n7x-view
O=/c/Users/kazda/kiro/gtai-n7x/scratch/view/it18/bench
mkdir -p "$O"
cd "$W/build/export/windows-bench" || exit 2
for pass in 1 2; do
  for v in top tilt; do
    ./RTAI-bench.exe --screen 0 -- --scenario=drive_dense --label=ab_$v --secs=30 --zoom=1.0 \
      --vsync=disabled --view=$v --out=C:/Users/kazda/kiro/gtai-n7x/scratch/view/it18/bench/ab_${v}_$pass.json \
      > "$O/ab_${v}_$pass.log" 2>&1
    echo "$v pass $pass exit $? $(date +%T)"
  done
done
