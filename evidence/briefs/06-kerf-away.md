# Brief 06 (lane anim, tag kerf-away): Kerf's run straight away holds one drawing for four ticks

## Machine law (every Godot run, every gate)
- Before ANY Godot run or gate in a shell: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/anim` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Anything that renders: `--rendering-driver d3d12`. Windowed runs: `--position 0,1440` (secondary monitor, never the main display).
- Only ONE Godot process at a time from this worktree. Free your own processes by PID; never kill by name.
- Never touch `main`, other worktrees, `C:\Users\kazda\kiro\pof`. Never push.
- Repo law: AGENTS.md + STANDARDS.md. Typed GDScript, files <= ~200 lines (hard 300), functions <= 40 lines, <= 5 params,
  `Log` not `print`. Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`.
  Commit `.uid`/`.import` with new files. Quick gate: use `node tools/gate/quick.mjs --no-godot` (its Godot step
  fails on untouched characters/ and souls/ files: a known tool limit, autoloads invisible to --check-only); prove the
  parse with `node tools/tests/run_unit.mjs --changed`.
- Ownership: anim owns the ghosts' drawn art + render-only view code in `project/features/souls/` and `tools/art/**`.
  Render only: no sim timing, speed, hitbox or digest change. Owner's law: Kerf keeps run16 as built (n15 verdict);
  this brief only fixes a duplicated drawing inside it.

## What is known (your own previous session, commit 7ecf4047f, `evidence/ghost-cells/kerf_run_hold_ride_32ppm.txt`)
- Kerf run16 at 32 px/m, worst hold per octant (identical-artwork measure): right 9.0, toward-right 8.9, toward 16.7,
  toward-left 8.9, left 10.0, away-left 9.4, **away 25.3**, away-right 9.4. Bar: worst hold < 9 px.
- Straight away: row 5 columns 3 and 4 are one drawing (`gtai-masters/n19/anim/ghost-cells/kerf_away_hold_32ppm.png`),
  shown ticks 273-276. Toward (16.7) likely has the same kind of duplicate: check row 1 too.
- The assets lane drew run16 in-betweens for rows 1-4 (`gtai-art/library/keyed/ghosts/kerf_run16_70_row{N}_mid{ab}.png`,
  and `_left_` variants), none for row 5 (away). Kerf's run8 row 5's second half is its first half flipped (n11 reply:
  "he is symmetric from behind").

## Do
0. Bookkeeping your last session left out (one docs commit first): `LEVEL.md` rows with evidence paths for
   Ohm's cast wind-up (75143d50e: "Combat feel" / "Attack cells", Ohm column), Dent and Ohm hit from behind
   (19135b1b0: "Hit and death cells"), Kerf's 8-octant planted-feet numbers (7ecf4047f); and `docs/decisions.md` lines
   (`- [2026-11-19] DECISION anim/...`): Ohm wind-up drawn over cast ticks 0-2 with the bolt tick unchanged
   (`OHM_WINDUP_TICKS`; rejected: delaying the bolt, a gameplay change); hitback chosen when the blow is within 60 deg
   of the facing (`HIT_FROM_BEHIND`); Kerf row-4 alternates not taken (no hold improved). Raise a level only where the
   evidence meets that level's bar; say which you raised and why.
1. Find how the shipped run16 sheet's row 5 (and row 1) were built (the packer/script and its inputs; reproduce the
   committed sheet pixel-exactly first). Name every column pair in rows 1 and 5 that is the same drawing (or a pure
   mirror shown on adjacent ticks).
2. Fix each duplicate with the cheapest honest source, in this order: (a) a delivered library cell that is the right
   pose; (b) a script derivation from his own cells (e.g. the mirrored opposite-phase cell, since he is symmetric
   from behind and front, if it places the planted foot right); (c) only if neither works, `image_gen` an in-between from
   Kerf's own row-5 cells as references (common rules: master to `C:/Users/kazda/kiro/gtai-masters/n19/anim/masters/`,
   manifest entry in the `art_src/` format, prompt committed under `docs/art/prompts/n19/anim/`, provenance line in
   `steam/ai-provenance/2026-11.jsonl`; look at it before shipping). Pack by script, untouched cells byte-identical.
3. Re-measure all 8 octants exactly as in 7ecf4047f (same films, same ticks). Write before/after into
   `evidence/ghost-cells/kerf_run_hold_ride_32ppm.txt`. Same-tick 64 px/m before/after still of the fixed columns and a
   32 px/m tick strip to `gtai-masters/n19/anim/ghost-cells/`. Look at them; describe.
4. Update `LEVEL.md` Kerf "Planted feet" with the numbers only if they moved. Unit test if a code/data table changed.
   Commit (art + script + evidence).

## Then, if time remains (same session, separate commit): Tonnage's held walk frames
- Tonnage p70 walk16 profile, 110-tick film at 32 px/m: worst hold 18.39 px, mean 9.47 (bar < 9). Cause: step 5 is a
  44 cell px stance jump that one frame holds ~12 ticks (`evidence/tonnage-hold/cap_sweep_32ppm.md`; shipped caps p70 2.0,
  p55 off: do NOT change them). Level 4 needs a drawn in-between at that step. Check the library
  (`keyed/ghosts/tonnage_walk16_70_cells_req221/` and neighbours) for an unused in-between first; else the same (b)/(c)
  order as above, using Tonnage's own cells. Keep his size; his hit lean stays 4 deg. Re-measure with `hold_ride.py`.

End with: files, commits (sha + subject), commands and result lines, frame paths, the 8-octant before/after table.
