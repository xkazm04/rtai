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
- Not run this iteration: `node tools/evidence/run.mjs --no-bench` (last PASS on cc7f418b, it13). The changes since are
  view-only under card views (RivetFrames, strips, the muzzle table, the portrait row); `top` draws none of them.
- Unit, the full no-arg run on 90c46dfc's tree: 1705 passed / 0 failed / 0 skipped (no FLAKY).
