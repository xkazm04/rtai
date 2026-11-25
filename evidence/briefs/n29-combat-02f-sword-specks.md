# Brief n29-combat-02f-sword-specks: the last red specks on the plasma sword hilt -> amber

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" (binding). At the hard stop report and END, committed.** Never ask; at a
fork pick what serves the owner's words, say so in the report. Fix lint/format findings in your own edit and go on.

## Why
Owner: "repaint all the red the audit found ... the plasma sword's hilt rings to steel". 85c6b0c53 repainted the rings by a
masked recolour (parts >= 25 px), leaving reddish px 15 / 3 / 16 / 13 in `project/features/combat/weapons/art/plasma_sword/held_long.png`,
`held.png`, `pickup.png`, `held_55/plasma_sword.png`. In game at 64 px/m (`C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/red_sword_pair_64.png`,
right half) three single red dots still sit on the hilt: (829,475), (820,478), (805,494) in the full still; `evidence/n29/red/sword.md`
calls them the emitter prongs' lights. Red is blood only; a lit emitter is heat/power = amber.

## What
1. In `evidence/n29/red/recolour.py`, add a mode `--sword-specks [--dry]` (leave every other mode's result unchanged): for the
   four files above, every pixel still reddish by the audit counter (R>170, G<110, B<90, alpha>0, i.e. what `count_red.py`
   counts) plus its 1 px reddish-orange fringe gets the fire remap's amber hue (the same per-pixel remap the fire group used:
   hue to amber #edab42's hue, alpha/max/min-channel kept). Print per file: px moved and the bounding boxes. Nothing outside
   reddish/fringe moves (verify: per file, pixels changed == pixels listed).
2. Run it. Import through the kit: `node tools/tests/run_unit.mjs --select=<basenames>` runs the headless import first
   (through runGodot); pick the basenames with `node tools/tests/test_map.mjs <the 4 pngs>`.
   Count with `python -I evidence/n29/red/count_red.py` (or audit_count's counter) before -> after per file: target 0.
3. Re-render the after still exactly as `sword.md` says (`node build/dev/n28-deflect.mjs blade6 1 62`, seed 1, tick 62, 64 px/m,
   d3d12) as `stills/red_sword_after2_64.png` + crop (box 795,420,895,500, 6x nearest) and a pair `red_sword_pair2_64.png`
   (the before still left, after2 right). LOOK: no red dot on the hilt; amber specks read as lights. Reddish in the sword box
   (805,440,895,500): 3 -> target 0.
4. Commit 1 (by 05:35): the four PNGs (+ their `.import` if changed), recolour.py, `evidence/n29/red/sword.md` (an "After2" section
   with the numbers), `evidence/n29/red/audit.md` row 15 (one cell: numbers). Pre-commit hook may take ~12 min; if a
   `tools/film/kill_reel_*.break.test.mjs` fails, the class cache is stale: Godot `--import`, commit again; never skip the hook.
   `frames.json` in the masters dir: add one entry for the pair2 (re-read the file right before writing; keep all others).

## Repo law, allowlist
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat` before every Godot run; `GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
`--rendering-driver d3d12` for renders; any windowed run `--position 0,1440`. One Godot for the lane: another builder (c4,
mutate in a Temp `gtai-mutate-*` worktree) runs in parallel; before each Godot launch check
`wmic process where "name like 'Godot%'" get processid,commandline` for one naming `n23-street` or `gtai-mutate` that you did not
start and wait (poll 30 s, max 8 min, then go on and say so). Stage per path, `git commit -- <paths>`; banned: git stash,
add -A/./-u, commit -a, reset --hard, amend, rebase, push. Trailer `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.
Allowlist: the four sword PNGs (+ `.import`), `evidence/n29/red/**`, `build/**`, the masters `n29/combat/` dir. Forbidden: every
other PNG (showcase/small swords, `rivet_*` sheets = keys), code, tables, `docs/decisions.md` (the 85c6b0c53 line covers it),
root JOURNAL.md / REPORT.md, other worktrees.

## Wall clock (binding)
Launched about 05:00. Commit 1 by **05:35**. HARD STOP **05:45**: report (commit, px per file before -> after, sword box
before -> after, what the pair shows) and END.
