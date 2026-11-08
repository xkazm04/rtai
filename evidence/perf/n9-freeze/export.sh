#!/bin/bash
# n9 perf freeze (10:30): the owner's exe from this worktree's HEAD, plus its size / hash for REPORT.
# Run from the lane root: bash evidence/perf/n9-freeze/export.sh
set -u
export APPDATA=C:/Users/kazda/kiro/gtai-n9/appdata/perf TMP=C:/Users/kazda/kiro/gtai-n9/tmp/perf TEMP=C:/Users/kazda/kiro/gtai-n9/tmp/perf
G="C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe"
O=evidence/perf/n9-freeze
mkdir -p build/export/windows
git rev-parse --short HEAD > $O/commit.txt
git status --short -- project native >> $O/commit.txt
"$G" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe > $O/export.log 2>&1
echo "export exit $? errors $(grep -c -E 'ERROR|SCRIPT ERROR' $O/export.log)" | tee -a $O/commit.txt
ls -la build/export/windows/ | tee -a $O/commit.txt
sha256sum build/export/windows/RTAI.exe | tee -a $O/commit.txt
