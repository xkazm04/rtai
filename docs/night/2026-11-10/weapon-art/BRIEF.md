# n13 weapon art - builder brief (2026-11-10)

Branch `n13-weapon-art`, worktree `C:\Users\kazda\kiro\gtai-wt\n13-weapon-art`, cut from main
`0e5e1e19d` (n12-visual merged). Native DLLs in `project/native/bin/` are the newer int-day build
copied from n12 (main checkout's are stale): do not rebuild or replace them.

These are the owner's verdicts on the n12 night report. Background for every item:
`docs/night/2026-11-09/visual/JOURNAL.md` (Group B and D sections) and `REPORT.md`; the films and
stills it cites are in `C:\Users\kazda\kiro\gtai-masters\n12\visual\` (`frames.json` indexes them).
Write new films and stills to `C:\Users\kazda\kiro\gtai-masters\n13\weapon-art\` with a
`frames.json` of the same shape.

## Repo law (from AGENTS.md / STANDARDS.md - read both first)
- Stage per path. No `git add -A`/`.`/`-u`, no stash, no `reset --hard`. Commit each item as it lands.
- Typed GDScript, files about 200 LOC (hard 300), functions 40 lines or fewer, 5 params max. `Log`, not `print`.
- Data is JSON with a schema; commit `.import`/`.uid` with every new or changed asset.
- No global RNG, no frame delta outside `World._process`. Red is for blood only, teal for souls only.
- Godot windows open on the secondary screen: launch with `--position 0,1440`.
- Never touch the sim: parity must stay bit-exact.

## Lane rules (as n12)
1. Audit before building: film the current state of each item at 32 px/m first.
2. Every change has a before: a flag or data value that restores the shipped look, named in the journal.
3. Look goldens at rest stay at 0.00 drift unless an item intentionally changes a frame they show;
   then name the golden, show before/after, and re-bless only that one with the reason in the commit.
4. New art is warmed behind the load screen (extend `WeaponFxWarm` / `RivetStripWarm`, n12 A1), and
   checked with `node tools/perf/fight_gate.mjs` against its A/A twin (the machine is contended:
   judge by the paired CI, span cost and frames over 25 ms, not absolute p50).
5. Asset changes go through the repo's art tools (`tools/art/`, e.g. `plasma_blade_fit.py`) or a new
   committed, re-runnable script there; never hand-edited pixels with no script to regenerate them.
6. Return questions instead of guessing. If an item cannot be done to the bar, stop it, film why,
   and write it up as an owner call; do not ship a weak version on.

## Items (in this order)

### 1. Plasma sword: treatment B, heavier ink rim
The owner picked B from `plasma_sword_treatments-candidates-3x.png` (shipped, A cream core,
B ink rim, C both). Re-cut the shipped strip with B's heavier ink rim, from the blade's own plate
only (no new colour), as a committed script so it regenerates. Every cell of the strip (5 facings,
side and camera strike cells, rest), held and swung. Acceptance: game-scale stills match the B
candidate; before/after film of a plasma sword combo at 32 px/m; the shipped strip restorable by
a data value or the script's flag.

### 2. Dropped pistol: a drawn gun cell
`ShockArcsView` draws a stunned cop's dropped pistol as a placeholder polygon (reads as a cream
bracket at 32 px/m). Replace it with a proper gun cell, preferably from the existing pistol art
(`weapon_art.json`, the held pistol strips) lying flat on the ground band, rotated to its drop
angle. Keep `GUN_ON_FLOOR` depth. Acceptance: frames 70/85/130 of the D1 shot re-filmed
before/after; reads as a pistol at 32 px/m; the polygon restorable by a flag.

### 3. Plasma impact disc: smaller, or a ring
The plasma rifle's approved impact art is a cream disc that covers the human at 32 px/m through the
held frames, hiding the n12 wound snap (`plasma_wound_snap-ab-32ppm*`). Make it smaller or a ring
so the body and its 2-tick throw read through it. Try both if cheap and pick on film; say which and
why. Acceptance: re-film of ticks 333-341 before/after; the struck body visible in every held
frame; the old disc restorable by data.

### 4. Wind-up cells: plasma sword, katana, electro baton
Their drawn strips have no wind-up cell (anticipation 2/5 for the plasma sword, baton 2, katana 4).
n12 tried showing the overhead strike cell during the wind-up and dropped it (a flicker of a second
swing, `d2_plasma_sword_windup_trial-dropped-32ppm.png`). The repo has no offline image generator.
Do this:
a. Try to compose a wind-up cell from each strip's own parts (blade plate raised back behind the
   shoulder, body from the nearest facing cell) with a committed script, shown during the existing
   wind-up ticks (view only; the sim's timings untouched). Judge on film with the melee.md 1-5
   scale. Ship it on only if anticipation rises by at least 1 with no pop or flicker.
b. For any blade where (a) fails the bar, write a commission request at
   `docs/art/requests/windup-cells.md`: per weapon, the cell size, facing, palette (plate list),
   pose description, the strip slot it fills, and reference stills; good enough to hand to an
   artist or an image generator. Also do (b) for the ones that pass, marked "interim cell shipped".

## Gates before your final report
lint 15/15, `node tools/tests/run_unit.mjs` all, scenarios, parity bit-exact, look goldens, debt,
and the fight gate for any item that adds art. Add unit tests for any new logic and run
`tools/mutate/mutate.mjs` on changed .gd files; quote scores.

## Report
Keep `docs/night/2026-11-10/weapon-art/JOURNAL.md` as you go (per item: audit, change, before,
measured, commits). End with a `## Report` section: per item on/off/not done, the stills and films,
gates with figures, perf, and owner calls. Do not merge, do not push.
