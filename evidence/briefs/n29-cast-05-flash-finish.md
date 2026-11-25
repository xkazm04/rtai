# Brief n29-cast-05: land the staged flash harness, then the flash at 32 px/m, the hue count and mutate

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent.
**Hard stop 03:40 local** (check `date +%H:%M` often). **Commit part 1 by 03:05, part 2 by 03:35.** Never end with finished
work uncommitted. Then report and END.

## Part 1: commit the three left paths (by 03:05)
Staged already: `project/dev/cast/cast_impact_edge.gd`, `evidence/n29-cast/flash/README.md`; modified (not staged):
`tools/debt/baseline.json` (an `--accept-regression` for dev_loc 3053 -> 3058, already applied). The last commit attempt failed
in the pre-commit lint's `tool-tests` step: `build/lint/tool-tests.txt` shows 604 of 605 pass, the one failure is
`tools\merge\step_guard.break.test.mjs` (18.9 s, under machine load). Run that file alone
(`node --test tools/merge/step_guard.break.test.mjs`); if it passes alone it is a load flake: commit again
(`git add tools/debt/baseline.json` then
`git commit -m "dev(cast n29): flash harness pitch flag + measured table" -- project/dev/cast/cast_impact_edge.gd evidence/n29-cast/flash/README.md tools/debt/baseline.json`).
If it fails alone, read why and report it (it is not ours to fix: `tools/merge/**` is outside the allowlist); then try once more,
and if the hook still refuses, write `FLAKY tools/merge/step_guard.break.test.mjs` with the failing output in your report.
Never skip the hook, never `--no-verify`. If the debt-ratchet says `tighten:` run `node tools/debt/debt.mjs --update`.

## Part 2: the flash judged on the street (by 03:35)
The code is `CastFarCard.sync_tint(on)` (commit `7ca036a93`), harness `project/dev/cast/cast_impact_edge.gd` (64 px/m via
`_ppm = 64` at line ~22, pitch via `GTAI_CAST_PITCH`) + `tools/art/cast_impact_edge.py`.
1. A 32 px/m still: same harness at 32 px/m (add an env/flag the way `GTAI_CAST_PITCH` was added, smallest change), tilt 70,
   door carrier and gunner, flash on and calm, the lancer column as reference; compose one 1920x1080-or-smaller contact PNG
   `C:\Users\kazda\kiro\gtai-masters\n29\cast\flash_door_gunner_32ppm_tilt70.png`. Look at it yourself (Read tool) and say
   whether the flash reads at 32.
2. Hue count, in the flashed cells of the 64 and 32 stills, inside each figure's silhouette: px with hue in 345-15 deg and
   S >= 0.45, V >= 0.35 (red/vermilion) and px with hue 160-200 deg, S >= 0.35 (teal), before vs after. Bar: after adds 0 of
   either compared with the calm cell of the same figure (+-5 px). Add the counts as columns to `evidence/n29-cast/flash/README.md`.
3. Mutate: `node tools/mutate/mutate.mjs --file=project/features/characters/cast_far_card.gd --lines=<the sync_tint lines> --max=20 --tests=test_cast_door`
   (find the right lines with `grep -n sync_tint`; if `cast_far_card.gd` is elsewhere, `git show --stat 7ca036a93`). Give it
   at most 20 min. Quote killed/(killed+survived) in the README.
4. Commit the harness change, the README, the contact still path in the README, in one commit (pathspec). Add the 32 still
   to `C:\Users\kazda\kiro\gtai-masters\n29\cast\frames.json` (valid JSON array; one entry `{file,title,ppm:32,before:"",note}`
   after the two flash 64 entries). Run `node tools/tests/run_unit.mjs --changed` and quote its summary line.

## Repo law (binding)
- Every Godot launch goes through `runGodot` (`tools/dev/run.mjs` or the harness's own launcher); before it:
  `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/cast` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; anything that renders
  gets `--rendering-driver d3d12`; windowed runs `--position 0,1440` (never the main display).
- **Lane Godot lock**: another sub-agent works in this worktree. Before any Godot launch take
  `until mkdir build/lane-godot.lock 2>/dev/null; do sleep 15; done` (inside one bash command), and `rmdir build/lane-godot.lock`
  right after the run ends (also on failure). Never hold it while you think or edit. Older than 25 min = stale: remove it.
  mutate runs Godot too: hold the lock for it.
- A `mem-budget: waiting` line means the machine is full: wait, do not kill.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, `Log` not `print`. Fix lint and format findings in your
  own edit and go on. A dev_loc rise: `node tools/debt/debt.mjs --update --accept-regression="cast_impact_edge 32ppm for n29 cast"`.
- Stage per path, commit with a pathspec. Banned: `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend, rebase,
  branch switches, push. The hook can take ~12 min; never skip it.
- Commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
`project/dev/cast/cast_impact_edge.gd`, `tools/art/cast_impact_edge.py`, `evidence/n29-cast/flash/**`, `tools/debt/baseline.json`
(through the debt tool only), `C:\Users\kazda\kiro\gtai-masters\n29\cast\` (the flash still + frames.json), scratch `build/look/n29-flash/`.
Forbidden: `cast_cards.json`, every file under `project/features/**` (another builder is changing card scale there right now),
`docs/**`, other lanes' files.

## Report (then END)
Commit shas, the step_guard verdict, the 32 still path and what you saw, the hue table, mutate score, `run_unit --changed` line,
what you could not do.
