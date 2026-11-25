# n30-cast-08: commit the evidence dev scenes (debt accept) + mutate re-run (tag `c08`, model sonnet)

Read `evidence/briefs/_common.md` first: it binds. Launched ~13:58. Commit by 14:20. Hard stop 14:35 (report and END).

## State
Three evidence dev scenes are on disk, untracked, cited by the lane's evidence:
- `project/dev/cast/cast_cop_jitter.gd` (+ `.gd.uid`, `.tscn`): rendered `gtai-masters/n30/cast/cop_jitter_64.png` (commit 89f23929d's table).
- `project/dev/cast/cast_warden_probe.gd` (+ `.gd.uid`, `.tscn`) and `project/dev/cast/cast_warden_hold.gd` (+ `.gd.uid`):
  rendered the warden size-at-death probe (`build/look/n30-c06b/RESULT.md`).
The debt ratchet (`node tools/debt/debt.mjs --check`) refuses them: `dev_loc` rises (39253 -> ~39550).

## Do
1. `gdformat` + `node tools/lint/lint.mjs` clean on those 5 .gd/.tscn files (fix findings in them only; `cast_warden_probe.gd`
   is 183 lines: fine under 200; functions <= 40 lines). `node tools/godot/check.mjs res://dev/cast/cast_cop_jitter.tscn
   res://dev/cast/cast_warden_probe.tscn res://dev/cast/cast_warden_hold.gd` (lane lock) must exit 0.
2. `node tools/debt/debt.mjs --update --accept-regression="cast_cop_jitter and cast_warden_probe dev scenes for n30 cast evidence"`.
   Check `git diff tools/debt/baseline.json` only moves `dev_loc` (+ its reason line); if any other metric moves, STOP and report.
3. `node tools/gate/quick.mjs`, then commit with a pathspec: the 8 dev files + `tools/debt/baseline.json`.
   Subject: `dev: cast evidence scenes (cop jitter still, warden size-at-death probe), debt dev_loc accepted`.
4. Mutate re-run: `node tools/mutate/mutate.mjs --file=project/features/characters/street_crowd_cards.gd --max=8 --lines=<the body_scale_of lines; read the file> --tests=test_street_crowd_cards`.
   Commit 89f23929d added a test for the 3 line-76 survivors: quote killed/(killed+survived) and list any survivor. No new
   test unless a survivor is a real behaviour (cop vs crowd spread); if so, add it to `project/tests/unit/test_street_crowd_cards.gd`, commit separately.

## Allowlist
The 8 dev files above, `tools/debt/baseline.json` (through the tool only), `project/tests/unit/test_street_crowd_cards.gd`,
`build/look/n30-c08/**`. Do NOT touch `tools/film/cast_war_films.mjs` or masters files (another builder c09 runs beside you).
Anything else: NEED.

## Report
Commit hashes + subjects, the debt diff lines, the mutate score line and survivors, every command's result line.
