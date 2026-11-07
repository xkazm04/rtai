# Gates it16 (d9 rivet, 2026-11-07)

On `90c46dfc` (portrait v2 e978f01f, plasma sword 55 v4 a2f9c77e, left strips by component ebacd1ab, the flamer's
drawn flame needs the aim 90c46dfc):
- Lint: 15/15 (pre-commit hook on each commit).
- Director reel `res://dev/arena/arena.tscn --quit-after 20000 -- --bot=reel --reel=director --loadout=pistol --rigs
  --view=<v>`, headless, the three views in parallel: 19/19 chapters fully down in tilt70, combo and top; 0 SCRIPT
  ERROR; 0 `p_frame`; 2 `^ERROR` lines each, both known and not this lane's (the shader compiler's custom_samplers
  note, the resources-in-use exit leak) (`reel-director-it16-<view>.log`).
- Unit: `--select` runs while iterating (hud dialogue 10/0; rivet frames + muzzle + revive 13/0; `--changed` 1688/0
  on the left-strip tree); the full no-arg run: see below.
- `node tools/evidence/run.mjs --no-bench` on 0ee23a95 (code = 90c46dfc; lane-private TEMP, no worktree writes while it
  ran, 14:29-14:36): lint 15/15, unit 1705/0, scenarios 52, parity exact + planted mutation caught at step 629, look
  goldens 11/11 (worst 0.27) + block 5/5 (worst 0.22): `top` did not move; release-compile 600 loaded / 0 failed:
  all PASS.
- Unit, the full no-arg run on 90c46dfc's tree: 1705 passed / 0 failed / 0 skipped (no FLAKY).
- it16b on e6a74d74 (the flamer burst latch): director reel 19/19 fully down in tilt70, combo, top; 0 SCRIPT ERROR;
  0 `p_frame`; the 2 known `^ERROR` lines each (`reel-director-it16b-<view>.log`). Unit `--changed` 1690/0; lint 15/15.
  The evidence run above was on 90c46dfc's code (view-only change since, under card views; `top` draws none of it).
