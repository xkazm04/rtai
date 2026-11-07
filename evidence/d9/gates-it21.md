# Gates it21 (d9 rivet, 2026-11-07 16:33-, code 613490f1: the p70 electro baton v5 strip, p70 out of NO_ARC)

- Director reel `res://dev/arena/arena.tscn --quit-after 20000 -- --bot=reel --reel=director --loadout=pistol --rigs
  --view=<top|tilt70|combo>` (headless): 19/19 chapters fully down in each view (electro_baton 1/1); 0 SCRIPT
  ERROR; 0 `p_frame`; the 2 known `^ERROR` lines each (`reel-director-it21-<view>.log`).
- Unit, full no-arg run: 1708 passed, 0 failed (51.5 s).
- Lint: 15/15.
- Evidence run 1 on 5af5db29 (code 613490f1), lane-private TEMP: lint, scenarios 52, parity exact + planted caught
  (step 629), look goldens 11/11 (top did not move), release-compile 600/0 PASS; unit-tests 1708/0 but marked FAIL
  by the tree-changed guard: I appended to JOURNAL.md during the run (my error, not a test).
- Evidence run 2 on 64953f9b (code 129e3745: + `--rivet-height`), hands off: ALL PASS: lint 15/15, unit 1709/0,
  scenarios 52, parity exact + planted caught (step 629), selftest look goldens 11/11 within mean 4 (worst 0.27),
  release-compile 600/0.
