#!/usr/bin/env bash
# it6: the zoom before/after (32 vs 40 px/m) on the Deck row's HUD, tick-exact (arena --shot), the iGPU.
# deck_bench_z1 = zoom_k 1.0 (32 px/m, the before), deck_bench = zoom_k 1.25 (40 px/m, shipped tonight).
set -u
cd "$(dirname "$0")/../../../.."
export APPDATA=C:/Users/kazda/kiro/gtai-n9/appdata/handheld TMP=C:/Users/kazda/kiro/gtai-n9/tmp/handheld TEMP=C:/Users/kazda/kiro/gtai-n9/tmp/handheld
OUT=$(cd evidence/n9h/it6/zoom && pwd -W)
shot() { # row scene tick
  node tools/handheld/sim.mjs --device=$1 --scene=$2 --ticks=$(( $3 + 120 )) --out="$OUT" --label=$2-$1 -- \
    --shot="$OUT/$2-$1-t$3.png" --shot-tick=$3 | head -1 | cut -c1-140
}
shot deck_bench_z1 king 900; shot deck_bench king 900
shot deck_bench_z1 city_combo 600; shot deck_bench city_combo 600
shot deck_bench servo 900
