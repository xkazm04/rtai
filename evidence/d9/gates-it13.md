# Gates it13 (d9 rivet, 2026-11-07)

On `cc7f418b` (RigInput.revive 988c0329 + the first pose under cards 6438394e):
- `node tools/evidence/run.mjs --no-bench` (lane-private TEMP, no worktree writes during the run): lint 15/15 PASS,
  unit 1704 / 0 PASS, scenarios 52 PASS (incl. the replay), parity bit-exact over 1200 steps + planted mutation caught
  at step 629 PASS, selftest look goldens 11/11 + block goldens 5/5 PASS (top did not move), release-compile 600 / 0 PASS.
- Director reel `res://dev/arena/arena.tscn --quit-after 20000 -- --bot=reel --reel=director --loadout=pistol --rigs
  --view=<v>`, headless, the three views in parallel: 19/19 chapters fully down in tilt70, combo and top; 0 SCRIPT
  ERROR; 0 `p_frame`; 2 `^ERROR` lines each, both known and not this lane's (the shader compiler's custom_samplers
  note, the resources-in-use exit leak) (`reel-director-it13-<view>.log`).
