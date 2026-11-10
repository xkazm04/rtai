# n15-combat JOURNAL

Lane combat, night n15 (2026-11-10 22:00 to 2026-11-11 08:00). Branch `n15-combat`, cut from main `5c5c03611`.
APPDATA for every Godot run: `C:/Users/kazda/kiro/gtai-n15/appdata/combat`.

## Session 1 (iteration 1, 21:58-23:28)

- 21:58 read: brief, common rules, AGENTS.md, tools/README.md, n11 combat REPORT "What does not work",
  last 30 decisions lines. Reply file `gtai-assets/replies/n15-combat.md` is empty (c-2 redraw not yet in).
  No other lane's journal names combat yet.
- FRICTION 22:05: ran the look goldens through `tools/dev/run.mjs` (headless): wrong, headless renders
  nothing. Killed my tree by PID (94744). Re-ran as `node tools/selftest/run.mjs` (windowed, the evidence
  path) for the baseline.
- Registry rules applied: (filled per decision below)
- BASELINE 22:30 (look goldens on the fresh worktree, main 5c5c03611 code with int-day's DLLs, `node tools/selftest/run.mjs`,
  log `build/selftest-baseline.log`): look goldens 11/11 within mean 4 (worst 0.00); block goldens 5/5 (worst 0.69);
  world lock holds; accents on doctrine. So the n14 "worst 0.69" is the BLOCK site and is present on main's code here.
- MILESTONE 22:40 `13a74d4dd` item 2: SWAT hit v4 + elder hit v3 packed (`street_hit.py VERSIONS`, one scale per kind,
  boot-bottom alignment, shift-in instead of bleed). FILL re-measured (swat 1.36, elder 1.20). Both filmed
  before/after at t341-348, 64 px/m: SWAT's carbine now continuous into the fall; elder thrown hard. Shipped.
- FRICTION: re-running `street_hit.py` re-packs 4 shipped burn sheets differently (hood, punk, swat, thug): the
  library's `burn/1_*` cells were re-keyed at 07:02, after n11's 06:58 pack. Restored them with `git checkout`; the
  flail item (next) has to pack frame 1 and 1b from the same (07:02) cells anyway.
- FRICTION / REQUEST tools: `node tools/film/compare.mjs` refuses `--victim=<kind>` ("bad argument"), and
  `film.mjs` refuses it after `--` ("give --victim before the --"), so a lone-victim before/after cannot go through
  compare. I filmed the before by putting the parent's sheet (via `git lfs smudge`) and FILL back for one film, then
  `git checkout --`. REQUEST tools: compare.mjs passes `--victim` through to both sides.
- Registry: no design fork taken yet beyond "ship only what reads better" (brief); judged on film.
