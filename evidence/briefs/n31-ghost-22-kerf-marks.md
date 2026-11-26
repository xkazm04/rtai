# n31 ghost 22 - Kerf's drop drawn in beats on the ground: cut scorch, spatter, rear scorch; beat strip

Builder tag: `g22-kerf-marks`. **First commit within 25 minutes; hard stop 55 minutes after launch** (last commit START 15 min before it; hook ~12 min). Report and END. Launch time: see the addendum.
Worktree (cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md`, `git log --oneline -20`, `C:\Users\kazda\kiro\gtai-art\ghost-n31\kerf-beats\state.md` (sections 3, 4f, 5), the Kerf drop commits (`git log --grep="ghost 21"`) and the two finished ground passes as the pattern: `project/features/souls/ohm_drop_marks.gd`, `dent_drop_marks.gd`, `ghost_deploy_effects.gd` (`lingers()`, `_draw_ground`, and the records holder if g18b made one) and `git log --grep="ghost 18b"`.

## Why
Owner: "The animation of ghost deployment and effect needs more detailed work - expecting the same issue will be for other ghosts". Kerf is one press now (g21): lock, 12-tick wind-up with a sighting line, blink + cut on C = P + 12. The cut leaves nothing on the ground; nothing says where the blade went afterwards.

## Director decisions (do not reopen)
Ground colours: ink, soot, charcoal, tan + flat amber heat (#FFB000 family; heat is allowed amber). Never teal, red or vermilion on the ground. Sizes from state.md section 5: cut scorch 2.6 m x 0.8 m along the cut line (the line `KerfView.draw_cut` draws, 55 degrees across the target's facing), centred on the target's position at C; spatter 1.8 m across for 12 ticks at C along the cut line; rear scorch 1.4 m at the rear spot. Hold 120 ticks + fade 60 from C; the record outlives the ghost (Ohm's scorch pattern).

## Art
Raw images: `C:\Users\kazda\kiro\gtai-art\ghost-n31\kerf-beats\out\{fx-cut-scorch,fx-cut-spatter,fx-rear-scorch}.png` (chroma green #00B140, accepted by the director). Pack with `tools/ghost/drop_pack.py` (strip mode for the scorch: 1024x320; squares 512 for the others) into `build/n31/kerf_pack/`, make a contact sheet and Read it; copy to `project/features/souls/art/kerf_{cut_scorch,cut_spatter,rear_scorch}.png`, `--import` through runGodot, commit the `.import` files with them. One provenance line per shipped image in `steam/ai-provenance/2026-11.jsonl` (copy g18b's lines' format).

## Code
A new `KerfDropMarks` (copy `DentDropMarks`/`OhmDropMarks`: cut tick, target pos at C, cut angle, rear spot; `ground_alpha` 120 + 60), its branches in `ghost_deploy_effects.gd` (or the records holder) `_draw_ground` and `lingers()`. A whiffed cut (dead/left target) draws no scorch. Unit tests `project/tests/unit/test_kerf_drop_marks.gd`: nothing before C; spatter visible C..C+11, gone at C+12; scorch alpha 1 at C+119, ~0.5 at C+150, 0 at C+180; lingers after the ghost is gone, false after C+180; whiff -> no record.

## Evidence (in this call)
A 64 px/m still strip (C-4 wind-up with the sighting line, C+2 cut + spatter, C+20 recover, C+90 scorch) through g21's dev probe `project/dev/ghost_n31/ghost_n31_kerf_beats*` (add a `--strip` mode if missing). Measure in the C+90 frame: the scorch length within 0.3 m of 2.6 m and centred within 0.25 m of the target's C position. Read every still before its commit. Strip to `C:\Users\kazda\kiro\gtai-masters\n31\ghost\kerf-beats-64ppm.png` + a frames.json entry (keep existing entries). One `docs/decisions.md` line (`- [2026-11-26] DECISION ghost n31 Kerf drop look: ...` beats, colours, measured length) appended only when `git diff --quiet docs/decisions.md` is clean, committed alone at once.

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`. Lane Godot lock `build/n31/godot.lock` per run (`g22-kerf-marks <pid>`, helper: copy `build/n31/g17lock.sh` with your tag; never delete another's; wait). Godot only through the repo tools. Windowed runs `--position 0,1440`.
- Allowlist: `project/features/souls/{ghost_deploy_effects.gd, kerf_drop_marks.gd (new), the records holder, kerf_drop_beats.gd for a read-only getter}`, `project/features/souls/art/kerf_*.png(+.import)`, `project/tests/unit/test_kerf_*.gd`, `test_ghost_deploy_effects*.gd`, `project/dev/ghost_n31/ghost_n31_kerf_beats*`, `tools/ghost/**`, `steam/ai-provenance/2026-11.jsonl` (append), `docs/decisions.md` (one line), `tools/debt/baseline.json` via the debt tool, `evidence/n31/ghost/**`, `build/n31/**`, masters ghost folder. NOT `project/features/combat/**`, `project/dev/gauntlet/**`, other lanes' files. Any other path: STOP, report a NEED.
- Typed GDScript, ~200 lines/file (hard 300), <= 40 lines/function, <= 5 params, `Log` not `print`. New files -> `--import`, commit `.uid`/`.import`. Before each commit `node tools/tests/run_unit.mjs --select=<kerf/ghost tests touched>`. Fix lint and format findings in your own edit and go on. Stage per path, `git commit -m "..." -- <paths>`; no add -A/./-u, stash, amend, rebase, reset --hard, --no-verify. Commit messages end with a blank line then `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Mutate: skip.
- Order if time is short: cut scorch + its hold (the one a player needs) > spatter + rear scorch > strip + measure > decisions line.

## Report
Commits, the strip path and what you saw, measured length/centre, tests, NEED lines, what was not done.

## Added 02:52 (director) - launch times and neighbours
Launched 02:52. **First commit by 03:15, last commit START by 03:28, hard stop 03:42: report and END.** Order if short (above) binds: the cut scorch + its hold first.
- g18b finished: `ghost_deploy_effects.gd` now has a public `track()` laying the Ohm and Dent records (165 lines): add Kerf's record there the same way (`git show cc2bf7da3`).
- A parallel builder `g19-dent-take` films Dent (only `project/dev/ghost_n31/ghost_n31_take*`, `evidence/n31/ghost/take-dent*`, temp worktrees). It uses the lane Godot through `build/n31/godot.lock` for long film runs: wait your turn, never delete its lock. Never stage its paths.
- Where the cut's target position at C lives: g21's `KerfDrop` (on `TonnageDump`) and `ghost_deploy_strike.gd` `_kerf` (`git show 3211dfd49`); a whiff sets no target hit.
