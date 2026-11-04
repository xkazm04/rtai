#!/bin/bash
# bench_round.sh: under bench.lock, the drive bench at the tip and three bisect points
cd /c/Users/kazda/kiro/gtai-wt/n-showcase
LOCK=/c/Users/kazda/kiro/gtai-n4/bench.lock
(set -o noclobber; echo showcase > $LOCK) || { echo "bench.lock held"; exit 1; }
./evidence/bisect_drive.sh 9ebc5918 tip
./evidence/bisect_drive.sh 8f988db6 pre-fixes
./evidence/bisect_drive.sh 50e093bf fixes
./evidence/bisect_drive.sh a472e1ed pre-powers
rm -f "$LOCK"
