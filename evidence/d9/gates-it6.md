# d9 rivet gates, iteration 6 (code at 657a4b28; art and tests to the it6 HEAD)
- lint: all 15 checks pass (pre-commit, every commit).
- unit: `node tools/tests/run_unit.mjs`: 1695 passed, 0 failed (11:11).
- director reel `--bot=reel --reel=director --loadout=pistol --rigs --view=<v>`, headless:
  tilt70 / combo (`--quit-after 14000`) and top (`--quit-after 20000`): 19/19 chapters down, 0 SCRIPT ERROR
  (reel-director-it6-*.log). Top at 14000 frames ran out of ticks just before the last two chapters
  (17/17 down, electro_baton started at tick 6240): headless top runs uncapped, so ticks per frame drift with
  the machine's load; it6 top at 20000 frames: 19/19.
- Not re-run this session: `node tools/evidence/run.mjs --no-bench` (scenarios, look goldens, parity) and
  release-compile. `top` never reaches RivetFrames (RivetStrips.strip_of("") == ""), so the goldens are not
  expected to move; owed next session.
