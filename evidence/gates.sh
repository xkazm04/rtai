#!/bin/bash
# Runs the four gates under the showcase's private APPDATA; logs to evidence/<round>/
set -u
R=${1:-r1}
cd /c/Users/kazda/kiro/gtai-wt/n-showcase
export APPDATA=C:/Users/kazda/kiro/gtai-n4/appdata/showcase
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
mkdir -p evidence/$R
node tools/lint/lint.mjs > evidence/$R/lint.log 2>&1; echo "lint exit $?" >> evidence/$R/summary.txt
node tools/tests/run_unit.mjs > evidence/$R/unit.log 2>&1; echo "unit exit $?" >> evidence/$R/summary.txt
"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd > evidence/$R/scenarios.log 2>&1; echo "scen exit $?" >> evidence/$R/summary.txt
node tools/evidence/run.mjs --no-bench > evidence/$R/evidence.log 2>&1; echo "evidence exit $?" >> evidence/$R/summary.txt
