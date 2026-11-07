# Gates it22 (d9 rivet, 2026-11-07 17:35-, code c36631bc + the p55 walk grid)

- Director reel `res://dev/arena/arena.tscn --quit-after 20000 -- --bot=reel --reel=director --loadout=pistol --rigs
  --view=<top|tilt70|combo>` (headless): 19/19 chapters fully down in each view; 0 SCRIPT ERROR; 0 `p_frame`;
  the 2 known `^ERROR` lines each (`reel-director-it22-<view>.log`). (The reel arms Rivet: the bare-claw walk
  path is not exercised there; quest 1 is where it shows.)
- Unit, full no-arg run (with both walk grids imported): 1712 passed, 0 failed (41.8 s).
- Lint: 15/15 (pre-commit on c36631bc).
- Evidence run on e2400dc4 (`node tools/evidence/run.mjs --no-bench`, lane-private TEMP, hands off): ALL PASS:
  lint 15/15, unit 1712/0, scenarios 52, parity exact + planted caught (step 629), selftest look goldens 11/11
  within mean 4 (worst 0.27; `top` did not move), block goldens 5/5, release-compile 601/0.
