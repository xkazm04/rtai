# Brief b4-guard-pose: Rivet's held guard reads without the spark

Lane `controls`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, branch `n23-controls`. Owner: "Redraw the guard pose so it reads without the spark."
**Hard stop: 06:35 wall clock (check `date`). Commit deadline: 06:30.**
Read `evidence/briefs/n23-controls-common.md` first: environment and repo law bind this brief.

## Today
`project/features/player/player_guard_pose.gd` hides Rivet's pitched head card while the guard is up and redraws the standing cell of `RivetStrips.DIR + art + "/" + RivetStrips.BASE` with each painted forearm rotated about its elbow (`BEND`), five cells (front to back) mirrored to eight facings (`RigHeadCard.OCT_FRAME/OCT_FLIP`), for `p70` and `p55`. `PlayerGuardView.pose()` / `_pitched()` drives it; the flat rig uses arm IK (`c_hands_up`). At 32 px/m tilt 70 the rotated forearms are a few pixels and the guard reads only through the amber deflect spark.

## Goal
At 32 px/m, tilt 70, the silhouette alone says "blocking": forearms / claw raised and crossed in front of the chest on the aim side, body lowered (knees bent, head drawn in), the collar still visible (a rigid striped hazard collar, never cloth; see `memory`: never a scarf). Raise and lower through 2 or 3 in-betweens (about 3 ticks each; consts from `SimClock.TICK_RATE`), and a distinct **stagger** pose when the guard meter breaks (`PlayerGuard.broken()`), held while broken.

## How (the way the other poses ship)
- Painted strips, like the gun, reload and form strips: generate with image_gen from Rivet's own shipped p70/p55 base strip cells as the reference (own-art references only), your prompts under `docs/art/prompts/n23/controls/`, masters to `C:/Users/kazda/kiro/gtai-masters/n23/controls/masters/`, an `art_src/n23-controls.manifest.json` entry per master, one provenance line per shipped PNG in `steam/ai-provenance/2026-11.jsonl` (append only), cut by a script under `tools/art/` (reuse the script that cut the existing Rivet strips; never by hand). Same figure density, ink line and foot pad as `rivet` base strips (`RivetRes`, `RivetStrips.foot_px`). Shipped strips: `rivet_guard.png` per pitch under the Rivet strip dir, cells = 5 facings x (in-between 1, in-between 2, held, stagger) or the layout you justify.
- `PlayerGuardPose` draws the right cell for facing x phase (keep the mirror logic). Keep the old forearm-rotation path behind a const or a view flag only if needed for the before/after stills; otherwise delete it. Flat rig: keep IK but also lower the body if the rig supports it; skip if it does not.
- The pose is view only: no replay/sim digest may move (check `replay_60s` and the guard scenarios).
- Look at every sheet yourself before it ships. If a facing comes out wrong after two rerolls, report which.

## Evidence (to `C:\Users\kazda\kiro\gtai-masters\n23\controls\`)
- `guard_pose_32.png` and `guard_pose_64.png`: contact sheets, old pose (base commit `76111adec`) beside new held pose, all eight facings, **no spark** (suppress the deflect flash for the sheet), p70 tilt 70; plus a p55 row if p55 is shipped.
- `guard_phases_64.png`: one facing, rest -> in-between 1 -> in-between 2 -> held -> stagger.
- A 32 px/m clip 10 to 20 s: Rivet raising, holding while turning, lowering, and a meter break into stagger (`guard_pose.mp4`). Use `tools/film/` (`sheet.mjs`, `compare.mjs`) where it fits; a dev driver under `project/dev/controls/` otherwise.
- Update `C:\Users\kazda\kiro\gtai-masters\n23\controls\frames.json` (create if missing; 8-15 entries, best first: `{file, title, ppm, before, note}`).

## Tests
Update `project/tests/unit/test_guard_view.gd` (cell chosen per facing and phase; stagger while broken; hidden when lowered; mirror for the back facings). `node tools/tests/run_unit.mjs --changed` green. Mutate `player_guard_pose.gd` (cap 20).

## Allowlist
`project/features/player/**`, the Rivet strip dir for the new `rivet_guard*.png` (+ `.import`), the Rivet strip tables if a row is needed (list lines), `tools/art/**` (new script or guard rows in the shared cut config, list lines), `docs/art/prompts/n23/controls/**`, `art_src/n23-controls.manifest.json`, `steam/ai-provenance/2026-11.jsonl` (append), `project/tests/unit/test_guard_view.gd`, `project/dev/controls/**`. Do not draw or change any enemy art.

## Report
Commits, the sheets' paths, which facings were rerolled, digests unchanged (quote), mutate score, what is left.
