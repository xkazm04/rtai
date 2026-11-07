# Gates it22 (d9 rivet, 2026-11-07 17:35-, code c36631bc + the p55 walk grid)

- Director reel `res://dev/arena/arena.tscn --quit-after 20000 -- --bot=reel --reel=director --loadout=pistol --rigs
  --view=<top|tilt70|combo>` (headless): 19/19 chapters fully down in each view; 0 SCRIPT ERROR; 0 `p_frame`;
  the 2 known `^ERROR` lines each (`reel-director-it22-<view>.log`). (The reel arms Rivet: the bare-claw walk
  path is not exercised there; quest 1 is where it shows.)
- Unit, full no-arg run (with both walk grids imported): 1712 passed, 0 failed (41.8 s).
- Lint: 15/15 (pre-commit on c36631bc).
