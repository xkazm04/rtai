# n-d4 iteration 6 evidence (night lane d4-production, 2026-11-03)

- `night_iter6_summary.png`: before | after, in-engine, for every iteration-6 item. City frames come from
  `dev/showcase/city_frame.tscn` (32 / 48 px/m) and the props board from `asset_board.gd --page=props`. Quest 1 frames
  come from main's own `dev/frames/collect_call_frames.gd`: before = main 721fbbb as is, after = main + n-d4 art +
  `q1_view_art.patch`. The quest art through look_d4 is `asset_board.gd --page=quest`.
- `q1_view_art.patch`: quest 1 view (stage / cast / fx / hud) drawing the D4 art, +156 / -82. `git apply --check` is
  clean on main 721fbbb. It needs the n-d4 art merged first. Not applied on this branch: the view code is the quest
  owner's.
- `gates-cc3b37c.txt`: `node tools/evidence/run.mjs --no-bench` at cc3b37c, rc 0. Only docs changed after it.
- Full frame sets, every probe (kept and reverted) and the running ladder: `gtai-masters/night/d4-production/`
  (`ladder.png`, `before_*` / `after_*`, `work/`). See `JOURNAL.md` 00:50-01:44.
