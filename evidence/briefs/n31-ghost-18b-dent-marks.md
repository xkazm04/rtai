# n31 ghost 18b - Dent's drop drawn in beats on the ground: skid telegraph, dust wake, scuff that stays; beat strip

Builder tag: `g18b-dent-marks`. **First commit within 25 minutes; hard stop 55 minutes after launch** (last commit START 15 min before it; hook ~12 min). Report and END. Launch time and stops: see the addendum at the end.
Worktree (cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md`, `git log --oneline -15`, `C:\Users\kazda\kiro\gtai-art\ghost-n31\dent-beats\state.md` (sections 2 and 4g: the beat plan and the record), Ohm's finished pass as the pattern: `project/features/souls/ohm_drop_marks.gd`, `ghost_deploy_effects.gd` (`lingers()`, `_draw_ground`), `git show --stat 8ab450ec9`, and g17's view commits (`git log --grep="ghost 17"`: `DentDropBeats` gives the ram tick R and the body path).

## Why
Owner: "The animation of ghost deployment and effect needs more detailed work - expecting the same issue will be for other ghosts". Dent is now one press: a lane from Rivet's side along the aim, a 15-tick wind-up, a ram that shoves everyone within ram_half_m (1.3 m after g17) + body radius. Nothing on the ground tells a player where the lane runs during the wind-up (the counterplay: foes may step out), nor where the ram went afterwards.

## Director decisions (do not reopen)
Ground colours only tan dust, soot, ink (never teal, red, vermilion). Lane drawn 2 x ram_half_m wide (read the row, do not hard-code 2.6). Scuff holds 2 s + 1 s fade from a record that outlives the ghost (Ohm's scorch pattern). P = press, R = P + 15.

## Beats
- arrival P..P+3: `dent_launch_puff` small (~1 m) at the lane origin.
- wind-up P+4..R-1: `dent_lane_skid` revealed from the origin to the spot (ease-out, full length by R-4) + `dent_lane_cap` at the spot end; the telegraph.
- ram R..R+7: `dent_wake` from the launch point to the body (its head follows `DentDropBeats.at`), `dent_launch_puff` again on R at the origin; existing `RamMarks` unchanged.
- stop R+8..: `dent_stop_scuff` under the spot.
- aftermath R..R+180: `dent_lane_scuff` replaces the skid on R, held 120 ticks, faded over 60.

## Art
Packed already by g18a in `build/n31/dent_pack/` (strips 1024x320 lying along +x, origin end left; squares 512): `dent_lane_skid.png`, `dent_lane_scuff.png`, `dent_wake.png`, `dent_lane_cap.png`, `dent_stop_scuff.png`, `dent_launch_puff.png`, and `contact.png` (Read it). Copy them to `project/features/souls/art/`, `--import` through runGodot, commit the `.import` files with them. Strips: rotate by the lane angle, scale x to the lane length, y to 2 x ram_half_m. If a packed file is missing, draw that beat in code (lines/ellipses in tan + ink) and say so. One provenance line per shipped image in `steam/ai-provenance/2026-11.jsonl` (copy g12's lines' format).

## Code
A new `DentDropMarks` (copy `OhmDropMarks`: press/ram ticks, origin, spot, half_m; `ground_alpha` 120 + 60), its branches in `ghost_deploy_effects.gd` `_draw_ground` and `lingers()`. If `ghost_deploy_effects.gd` passes ~200 lines, move the three records into one small holder. Unit tests `project/tests/unit/test_dent_drop_marks.gd`: the skid front reaches the spot by R-4 and not before P+4; the scuff alpha is 1 at R+119, about 0.5 at R+150, 0 at R+180; the record outlives the ghost (lingers true after the ghost is gone, false after R+180).

## Evidence (in this call)
A 64 px/m still strip of the beats (P+2, R-4, R+3, R+10, R+90) through g17's dev probe (`project/dev/ghost_n31/ghost_n31_dent_beats*`; add a `--strip` mode or a new file there) and the drawn lane width measured in the R-4 frame (bar: within 0.25 m of 2 x ram_half_m) and the skid's far end within 0.25 m of the spot. Read every still before its commit. Strip to `C:\Users\kazda\kiro\gtai-masters\n31\ghost\dent-beats-64ppm.png` + a frames.json entry. One `docs/decisions.md` line (`- [2026-11-26] DECISION ghost n31 Dent drop look: ...` with the beats, colours and measured width).

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`. Lane Godot lock `build/n31/godot.lock` per run (`g18b-dent-marks <pid>`; never delete another's). Godot only through the repo tools. Windowed runs `--position 0,1440`.
- Allowlist: `project/features/souls/{ghost_deploy_effects.gd, dent_drop_marks.gd (new), dent_drop_beats.gd, a small new records holder}`, `project/features/souls/art/dent_*.png(+.import)`, `project/tests/unit/test_dent_*.gd`, `test_ghost_deploy_effects*.gd`, `project/dev/ghost_n31/ghost_n31_dent_beats*`, `tools/ghost/**`, `steam/ai-provenance/2026-11.jsonl` (append), `docs/decisions.md` (one line), `tools/debt/baseline.json` via the debt tool, `evidence/n31/ghost/**`, `build/n31/**`, masters ghost folder. NOT `project/features/combat/**`, `project/dev/gauntlet/**`, other lanes' files. Any other path: STOP, report a NEED.
- Typed GDScript, ~200 lines/file (hard 300), <= 40 lines/function, <= 5 params, `Log` not `print`. New files -> `--import`, commit `.uid`/`.import`. Before each commit `node tools/tests/run_unit.mjs --select=<dent/ghost tests touched>`. Fix lint and format findings in your own edit and go on. Stage per path, `git commit -m "..." -- <paths>`; no add -A/./-u, stash, amend, rebase, reset --hard, --no-verify. Commit messages end with a blank line then `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Order if time is short: skid telegraph + scuff (the two a player needs) > wake + puffs + stop scuff > strip + width measure > decisions line.

## Report
Commits, the strip path and what you saw, measured width and far end, tests, NEED lines, what was not done.

## Added 01:43 (director, after g18a: commit 36ecbb799, contact sheet looked at, ACCEPT)
- All six packed, all along +x with the origin end left; no rotation needed. Director look at `build/n31/dent_pack/contact.png`: tan/soot/ink, no teal, no red.
- Skid: the two lines sit at y 117 and 206 of 320 (37 % / 64 %), not at the edges. Map them to the lane edges in code: draw the strip so its y band 117..206 spans exactly 2 x ram_half_m (i.e. scale y by (2 x half_m x px_per_m) / 89 and centre the band on the lane line), or crop the strip to y 105..218 before copying it into `art/` (then the lines sit ~11 px inside each edge). Measure the drawn line spacing in the R-4 still: bar = 2 x ram_half_m +- 0.25 m.
- Cap: three arcs converging on the RIGHT = the spot end (place the right edge at the spot). Stop scuff: gouges fan back LEFT from a heel point on the right = the spot (place the heel point at the spot, the fan trailing toward the origin). Launch puff: the big cloud left, so at the origin it billows backward. Wake: thick at the left, tapering right: the tip follows the body.

## Added 02:26 (director) - launch times and neighbours
Launched 02:26. **First commit by 02:51, last commit START by 03:06, hard stop 03:21: report and END.**
- g17 landed (5cef2a3d8 view, 24b12bc99 ram_half_m 1.3). Its scenarios run (`build/n31/g17lock.sh node tools/tests/run_scenarios.mjs`, holder of `build/n31/godot.lock` as `g17-dent-view <pid>`) may still be running when you start: WAIT for the lock, never delete it. It removes itself.
- A parallel builder `g21-kerf-drop` works on Kerf (`ghost_attacks.json`, deploy strike/spot/body, `test_kerf_*`, `ghost_n31_kerf_beats*`). It does NOT touch `ghost_deploy_effects.gd`, `dent_*`: those are yours. Never stage its paths. Both of you take turns on the lane Godot through the lock file (`g18b-dent-marks <pid>`; copy `build/n31/g17lock.sh` to `build/n31/g18block.sh` with your tag).
- `docs/decisions.md`: before appending, `git diff --quiet docs/decisions.md` must be clean (else wait 1 min and retry); append, then commit it alone at once (`git commit -m ... -- docs/decisions.md`).
- Mutate: skip (the director runs it later).
