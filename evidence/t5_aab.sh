#!/usr/bin/env bash
# t-5 cost, paired with an A/A twin: per round run A (HW 80, scratch-tools-before d720e22da), A2 (same tree again)
# and B (HW 132, n15-tools HEAD) in a rotated order; each is one parity run (1200 steps, both sims).
# Prints round arm gd_ms native_ms final_sha godot_others. Usage: t5_aab.sh <rounds> > out.tsv
set -u
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/tools
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
A=C:/Users/kazda/kiro/gtai-n15/scratch-tools-before/project
B=C:/Users/kazda/kiro/gtai-wt/n15-tools/project
OUT=C:/Users/kazda/kiro/gtai-n15/flake/t5
mkdir -p "$OUT"
others() { tasklist //FI "IMAGENAME eq Godot*" 2>/dev/null | grep -c Godot; }
one() { # arm path round
  local f="$OUT/$1_$3.json"; rm -f "$f"
  local n; n=$(others)
  "$G" --headless --path "$2" -s res://tests/parity/run_parity.gd -- --steps=1200 --out="$f" > "$OUT/$1_$3.log" 2>&1
  node -e "const r=require('$f');console.log(['$3','$1',r.step_ms_a,r.step_ms_b,(r.final_sha_a||r.final_digest||'-'),'$n'].join('\t'))"
}
echo -e "round\tarm\tgd_ms\tnative_ms\tsha\tgodot_procs_at_start"
for r in $(seq 1 "$1"); do
  case $((r % 3)) in
    0) one A $A $r; one A2 $A $r; one B $B $r ;;
    1) one B $B $r; one A $A $r; one A2 $A $r ;;
    2) one A2 $A $r; one B $B $r; one A $A $r ;;
  esac
done
