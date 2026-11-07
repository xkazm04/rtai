# Gates it10 (d9 rivet, 2026-11-07)

On `61fbbdf8` (the flamer's one flame 5f3c583d + the shadow from the drawing 61fbbdf8):
- Unit, full no-arg run on 5f3c583d: 1700 passed / 0 failed. `--changed` on 61fbbdf8's tree: 1684 / 0.
- Lint: 15/15 (pre-commit hook on each commit).
- Director reel `--bot=reel --reel=director --loadout=pistol --rigs --quit-after 20000`, headless, the three views
  in parallel: 19/19 chapters fully down in tilt70, combo and top; 0 SCRIPT ERROR each
  (`reel-director-it10-<view>.log`; counted as `director chapter <id>: n/n down` lines with n == n).
- `node tools/evidence/run.mjs --no-bench` (lane-private TEMP): see below.
