#!/bin/bash
set -e
w=$1; cell=$2; note=$3
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
cp evidence/it4/rivet_x15_${w}_before_after_x2_64ppm.png /c/Users/kazda/kiro/gtai-masters/n15/hero/
git add project/features/characters/art/view/p70/rivet_eq_${w}.png project/features/characters/rivet_res.gd tools/art/rivet_frames.json evidence/it4/rivet_x15_${w}_before_after_x2_64ppm.png
git commit -q -m "n15 hero: Rivet's p70 ${w} strip at x1.5 (RivetRes.X15)

110 cut reproduced byte-exactly first; fig_h 165 (cell ${cell}). Filmed in cursor_sweep
--loadout=${w} (the STAND leg draws the strip): ${note}; same size and stance, sharper ink.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" 2>&1 | tail -1
git log --oneline -1
