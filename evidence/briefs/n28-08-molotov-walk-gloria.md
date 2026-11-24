# Brief n28-08-molotov-walk-gloria: molotov walk-only commit, then Gloria in brass (concept + p70 held strips + held art)

Same header rules as `evidence/briefs/n28-07-ray-molotov.md` (read its header: in-session builder, `cd` to
`C:\Users\kazda\kiro\gtai-wt\n23-controls` in every shell command, APPDATA/GODOT_BIN exports, d3d12, `--position 0,1440`,
one Godot at a time, never raw Godot, image tool hand-copy rule, no subagents). Check `date` first and often.

**HARD STOPS: part A committed by 21:10. Part B concept + p70 strips committed by 21:42 (start that commit by 21:30: the
pre-commit hook takes ~12 min). Report and END by 21:53 whatever the state** (write STATE.md first). Small commits staged per
path with `git commit -- <paths>`. No amend, rebase, stash, `add -A/./-u`, `commit -a`, `reset --hard`, push. Fix lint and
format findings in your own edit and go on. If the hook fails on `tools/film/kill_reel_*.break.test.mjs`: `--import`, commit
again. Never commit `hs_err_pid*.log` (leave those files alone).

## Part A: molotov ships its WALK sheet only (director's decision; the run stays on the stop-gap)
The tree holds UNCOMMITTED molotov files (see `C:/Users/kazda/kiro/gtai-art/rivet-n28/molotov/STATE.md`). The director
looked at the walk column at 64 px/m (`gtai-masters/n28/keys/grid_molotov_64.png`): it passes. The run (final4) is rejected.
1. Move `project/features/characters/art/view/p70/rivet_run8_eq_molotov.png` and its `.png.import` out of the tree into
   `C:/Users/kazda/kiro/gtai-art/rivet-n28/molotov/unshipped_run8_final4/` (they are untracked; `mv`, do not delete).
2. Remove the run8 molotov line from `steam/ai-provenance/2026-11.jsonl` (the last line; keep the walk line). Keep the
   `rivet_motion.json` and `test_rivet_grid_stride.gd` edits (they are the walk's: cycle 81, walk travel 27.5/34.5).
3. Verify the run with no own run8 sheet falls back to the stop-gap for the molotov (read how the grid loader picks a sheet:
   `project/features/player/**` RivetWalk / grid code, `walk_grid` in `rivet_motion.json`; if a walk sheet without a run8
   sheet breaks or picks the plasma rifle's run, STOP part A and report exactly what it does). `--import`.
4. `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`.
5. Recapture with `scripts/capture28.py molotov candidate` (as STATE.md says; `--import` before it) and confirm in the 64 px/m
   candidate frames: walk = the new sheet, sprint = the stop-gap. Re-render `grid_molotov_64.png` / `_32.png` if the
   capture tool makes them. Measure foot_slide walk (expected 0.43/1.56 cm) and run (the stop-gap's number).
6. Commit: "Molotov walks on its own p70 grid edited from the plasma rifle's; its run stays the stop-gap" with the walk png,
   its `.import`, `rivet_motion.json`, the test, the provenance file. Then `evidence/n28-keys/grid_molotov.md` (walk numbers,
   why the run is not shipped: run row 1 soles drift 14 px, the donor-leg seam and the shift both fail the look, numbers from
   STATE.md) + frames.json entry, committed separately.

## Part B: Gloria in brass (start the concept image in the background DURING part A's Godot/hook waits)
Follow `evidence/briefs/n28-04-gloria-brass.md` (why, what exists, colour law, allowlist, evidence paths), trimmed to fit:
- **Images: at most 5 in this call** (concept <= 2, p70 held strips <= 3). No p55 strips this call (they are next).
- Concept first (image 1 = take A row of `C:/Users/kazda/kiro/gtai-masters/n27/keys/gloria_concepts_ab.png`, image 2 = the
  shipped pistol row). Bar: gun bbox length 1.3-1.5x the pistol's and mean gun hue measurably apart (write both numbers);
  brass = warm yellow metal (hue about 40-50 deg, not orange/amber 20-35 deg, no glow). Save the comparison sheet
  `gtai-masters/n28/keys/gloria_concept_n28.png`. Commit nothing from the concept but the round's STATE.md in gtai-art.
- p70 held strips: the n27 pipeline in `C:/Users/kazda/kiro/gtai-art/rivet-n27/gloria-p70/` (`mkrefs.py`, `cut2.py`,
  `install.py`, `weapon_art.py`, `rivet_muzzle_n27.py`): image edits of the shipped pistol strips (image 1) with the n28
  concept (image 2). Register, tone, flash from the pistol's drawn flash at her new muzzle, re-measure `rivet_muzzle.json`
  gloria p70. Held art (`held.png`, `held_small.png`, `icon.png`, `pickup.png`) cut from the strips, no extra images; full
  size like the pistol's (bbox fill %). The p55 strips keep the n27 compact gun this call (say so in STATE.md).
- Look in the game at tilt 70, 8 aim directions, firing, at 64 px/m: save `gtai-masters/n28/keys/gloria_n28_fire_64.png`.
  Colour law: no red, no teal, brass not amber.
- `--import`, provenance lines, `run_unit.mjs --changed`, `quick.mjs`, commit "Gloria in brass with a longer nail strip:
  p70 held strips and held art".
- Round `C:/Users/kazda/kiro/gtai-art/rivet-n28/gloria-brass/STATE.md` updated after every step, resumable; its "Next" names
  the p55 strips, the old/n27/n28/pistol comparison, the 32 px/m clip and her own walk grid.

## Allowlist
Part A: the files named in part A, `evidence/n28-keys/**`, `gtai-art/rivet-n28/molotov/**`, `gtai-masters/n28/keys/**`,
`build/**`. Part B: the allowlist of `n28-04-gloria-brass.md`. Anything else: stop and report a `NEED` line. Forbidden:
`project/features/combat/**` code, `ghost_forms.json`, `weapons.json`, `enemies.json`, `fx_atlas.png`,
`project/boot/prologue/**`, `cast_cards.json`, `native/`, other worktrees, `main`.

## Report (final message, short)
`IMAGES n`, commit shas, part A numbers (walk/run foot_slide, fallback confirmed), concept numbers (length ratio, hue),
what is committed for Gloria, still paths, STATE.md "Next".
