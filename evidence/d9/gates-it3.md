# d9 rivet gates, iteration 3 (code at 19ddf549)
- lint: all 15 checks pass (pre-commit, every commit).
- unit: `node tools/tests/run_unit.mjs`: 1691 passed, 0 failed (10:10).
- director reel `--bot=reel --reel=director --loadout=pistol --rigs --view=<v> --quit-after 14000`, headless:
  tilt70 / combo / top: 19/19 chapters down, 0 SCRIPT ERROR (reel-director-it3-*.log).
- `node tools/evidence/run.mjs --no-bench` (10:21-10:28): scenarios 52 ran, 0 failed (replay_60s incl.),
  look goldens 11/11 ok, parity exact (planted mutation caught at step 629). It then stopped at
  release-compile: `%TEMP%\gtai-release-compile exists but was not created by release_compile` (a dir
  this lane did not make; left alone). Release-compile owed.
