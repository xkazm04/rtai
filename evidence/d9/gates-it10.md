# Gates it10 (d9 rivet, 2026-11-07)

On `61fbbdf8` (the flamer's one flame 5f3c583d + the shadow from the drawing 61fbbdf8):
- Unit, full no-arg run on 5f3c583d: 1700 passed / 0 failed. `--changed` on 61fbbdf8's tree: 1684 / 0.
- Lint: 15/15 (pre-commit hook on each commit).
- Director reel `--bot=reel --reel=director --loadout=pistol --rigs --quit-after 20000`, headless, the three views
  in parallel: 19/19 chapters fully down in tilt70, combo and top; 0 SCRIPT ERROR each
  (`reel-director-it10-<view>.log`; counted as `director chapter <id>: n/n down` lines with n == n).
- `node tools/evidence/run.mjs --no-bench` (lane-private TEMP): see below.
- Evidence run on dfb7a4de (`--no-bench`, lane-private TEMP): lint PASS; scenarios 52 PASS; parity exact + planted
  caught PASS; look goldens 11/11 + block 5/5 PASS (top did not move); release-compile 600 loaded / 0 failed PASS;
  unit 1700 / 0 but the stage reads FAIL "tree changed during run (tools/art/rivet_portrait.py)": a file this lane
  wrote mid-run, not a test failure.
- On cfe5eea4 (RigHeadCard leaves the card to RivetFrames): director reel 19/19 fully down in tilt70, combo, top;
  0 SCRIPT ERROR; 2 `^ERROR` lines each (as on 61fbbdf8: the kill_char_fx shader note and the exit leak);
  0 `p_frame` lines (`reel-director-it10b-<view>.log`). Unit rivet + head card + rigs 33/0; hud dialogue 10/0.
