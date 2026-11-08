#!/bin/bash
# ABAB riot + drive_dense, scratch timers: CityOccluders L20b vs L20c (column index)
cd /c/Users/kazda/kiro/gtai-n9/tmp/perf/cvprof
export APPDATA=C:/Users/kazda/kiro/gtai-n9/appdata/perf
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
for round in 1 2 3; do for arm in l20b l20c; do
  cp arms/$arm/city_occluders.gd project/features/city/view/city_occluders.gd
  cp arms/$arm/city_occlusion.gd project/features/city/view/city_occlusion.gd
  for sc in riot drive_dense; do
    z=1.0; [ $sc = drive_dense ] && z=1.5
    n=$(tasklist | grep -ci godot)
    o=out/c-$sc-$arm-$round
    timeout 120 "$G" --screen 0 --rendering-driver d3d12 --disable-vsync --fixed-fps 60 --resolution 1920x1080 --path project res://dev/bench/city_bench.tscn -- --scenario=$sc --zoom=$z --view=tilt70 --secs=30 --out=$(pwd -W)/$o.json > $o.log 2>&1
    echo "$sc $arm r$round godots_before=$n $(grep -h 'OCCPROF\|occlusion:' $o.log | tr '\n' ' ') err=$(grep -c 'SCRIPT ERROR' $o.log)"
  done
done; done
cp arms/l20c/city_occluders.gd project/features/city/view/city_occluders.gd
cp arms/l20b/city_occlusion.gd project/features/city/view/city_occlusion.gd
