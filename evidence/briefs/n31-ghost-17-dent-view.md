# n31 ghost 17 - Dent's drop: the view follows the ram (faces the lane, waits at the origin, travels on the ram), width 1.3 m, suite + scenarios

Builder tag: `g17-dent-view`. **First commit within 25 minutes; hard stop 55 minutes after launch** (last commit START 15 min before; hook ~12 min). Report and END.
Worktree (cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md`, `git log --oneline -20`, `C:\Users\kazda\kiro\gtai-art\ghost-n31\dent-beats\state.md` (g16's prep: the chain and the exact view lines to change), `git show 87ac21445` (Dent's drop: `DentLane`, strike on the charge's last tick), `git show 8ab450ec9 -- project/features/souls/ghost_deploy_body.gd` (g12's generalised `_drops` + row-0 lock).

## Why
Dent shipped as a one-press drop (`87ac21445`) but the view still plays the hold animation: every drop row is locked to row 0 (Dent faces the camera) and his body slides along the lane during the wind-up instead of after the ram. A player would see Dent drift toward the foes and then the hits land late: it reads as lag, not a charge.

## Director decisions (do not reopen)
- Dent's view in drop mode: faces along the lane (his own facing, NOT the row-0 lock: keep row 0 for Tonnage and Ohm only), stands at the lane's origin (Rivet's side) through the wind-up in a crouch/pull-back pose (best shipped cell per state.md), travels origin -> spot over R..R+8 (ease-in, fast: it is a ram), stays at the spot to the fade.
- `ram_half_m` 0.9 -> **1.3** (g15's play table: zero-hit 11 % -> 6 %, mean 1.81 -> 2.04; no width under 2 m reaches mean 2.5 because the shipped bot fires Dent at 2 bodies: the owner's call lists it). One data value.

## Do
1. The view change in `ghost_deploy_body.gd` (+ `dent_body.gd` if state.md says so): as above. A unit test that a dropped Dent's drawn position is the lane origin during the charge and the spot from R+8 on, and that Tonnage/Ohm keep row 0. A 64 px/m still pair (wind-up R-5, ram R+3) through a dev probe (copy `project/dev/ghost_n31/ghost_n31_ohm_beats.gd` into a NEW `ghost_n31_dent_beats.gd` with `--form`-free Dent setup); Read both stills before the commit. Commit.
2. `ram_half_m` 1.3 in `ghost_attacks.json`; fix any test that pins 0.9 for the drop row. One `docs/decisions.md` line (`- [2026-11-26] DECISION ghost n31 Dent width: ram_half_m 0.9 -> 1.3 (play zero-hit 11 % -> 6 %, mean 1.81 -> 2.04; mean 2.5 not reached at <= 2 m because the bot fires at 2 bodies), view faces the lane and rams on the ram tick`). Commit.
3. Full unit suite (`node tools/tests/run_unit.mjs`) and the scenarios once (the documented runner). A moved digest: re-pin once with a dated decisions line naming "n31 ghost Dent drop". Commit if anything changed.
4. If time: mutate `project/features/souls/dent_lane.gd --max=10 --tests=test_dent_drop`; quote killed/(killed+survived).

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`. Lane Godot lock `build/n31/godot.lock` per run (`g17-dent-view <pid>`; delete only yours; wait for another builder's). Godot only through the repo tools.
- Allowlist: `project/features/souls/{ghost_deploy_body.gd,dent_body.gd,dent_lane.gd,ghost_deploy_effects.gd}` (+ a small new souls helper), `project/data/tables/ghost_attacks.json`, `project/tests/unit/test_dent_*.gd`, `test_ghost_deploy_view.gd`, `test_ghost_deploy_attacks.gd`, NEW `project/dev/ghost_n31/ghost_n31_dent_beats*`, scenario digest files the runner names, `evidence/n31/ghost/**`, `build/n31/**`, masters ghost folder (+ frames.json entries), `docs/decisions.md` (lines as above), `tools/debt/baseline.json` via the debt tool. NOT `project/features/combat/**`, `project/dev/gauntlet/**`, other lanes' files. Any other path: STOP, report a NEED.
- Typed GDScript, ~200 lines/file (hard 300), <= 40 lines/function, <= 5 params, `Log` not `print`. New `.gd` -> `--import` via runGodot, commit the `.uid`. Fix lint and format findings in your own edit and go on. Stage per path, `git commit -m "..." -- <paths>`; no add -A/./-u, stash, amend, rebase, reset --hard, --no-verify. Commit messages end with a blank line then `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Report
Commits, stills and what you saw, tests, suite + scenarios (digests moved?), mutate score, NEED lines.

## Added 01:28 (director) - g16's prep is done
Follow `state.md` section 4 for the code (`_faces_camera`, Ohm-only rise, `DentDropBeats.at/pose`, `DentBody.deploy_pose`). Director answers: no rise for Dent; shipped DIVE rows; ram 8 ticks; 0.3 m recoil. The 6 ground images (`dent-beats/out/`, round started 01:27) belong to the NEXT call (g18: `DentDropMarks` + strip packer mode + beat strip), not this one, unless parts 1-3 are committed with 20+ minutes left.

## Added 01:42 (director) - launch times
Launched 01:42. **First commit by 02:07, last commit START by 02:22, hard stop 02:37: report and END.** Parts 1 and 2 are the must; part 3 (full suite + scenarios) runs only if part 2 is committed by 02:12, else report "suite not run" (the director runs it). Part 4 mutate only if 15+ minutes remain.
A parallel builder `g18a-pack` works ONLY in `tools/ghost/**` and `build/n31/dent_pack/**` (no Godot, no souls files): ignore its commits; never stage its paths. You are the only one appending to `docs/decisions.md` this hour and the only one using Godot.
The stills: write them to `build/n31/g17/` and copy the two you Read into `C:\Users\kazda\kiro\gtai-masters\n31\ghost\` as `dent-view-windup-64ppm.png` and `dent-view-ram-64ppm.png` (frames.json entries appended, before=false).
