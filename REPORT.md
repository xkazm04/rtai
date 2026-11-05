# REPORT: lane n7-ranged (Rivet's guns + the shared feel layer), night 2026-11-05/06

DRAFT written in iteration 5 (22:30); the last iteration finishes it by 08:40. Branch `n7-ranged`,
cut from main `763f8fba`. Clips and stills: `C:\Users\kazda\kiro\gtai-masters\n7\ranged\` (index:
`frames.json`). Audit and per-weapon before/after: `docs/polish/ranged.md`. Running log: `JOURNAL.md`.

## What works (with its evidence)

| Change | Commit(s) | Before flag (same build) | Evidence (masters n7/ranged) |
|---|---|---|---|
| The shared feel layer reaches the live paths: FeelCam (shake, directional kick, hit-stop) + FeelBudget (caps per frame and per second), per-weapon rows on top of the damage class, a kill keeps the longer stop; view only (parity bit-exact) | `779cdd3d`, `e88ebcfe`, `5535aad2`, `eebc82f7` | `--feel=off` | `rocket_launcher-ab-32ppm.mp4`, `mini_nuke-ab-32ppm.mp4`, `heavy_feel-ab-48ppm.mp4` |
| The arena voices its guns (quest 1's StageAudio; the arena was digitally silent) | `0f8e4f5f` | `--silent` | `rocket_blast_sound-ab-32ppm.mp4` (with sound) |
| Recoil kick per round Rivet fires (Gatling 1.8 px, Gloria 1.5 px, hand cannon 2 px) | `2691917e`, `016966b2`, `078e83ab` | `--feel=off` | `gatling_spinup-ab-32ppm.mp4`, `gloria_kick-ab-32ppm.mp4` |
| The Gatling's 0.5 s spin-up tremor (about 10/15 Hz, grows with the spin) | `b2af1801`, `eb1d4f1c` | `--feel=off` | `gatling_spinup-ab-32ppm.mp4` |
| Electro stun: the struck body is thrown 0.3 m along the bolt on the hit frame (owner note item 1) | `9c140ffb` | `--react-snap=off` | `electro_snap-ab-48ppm.mp4` |
| Rocket and mini-nuke boom on the blast frame | `da508e6b` | `--end-cue=off` | `rocket_blast_sound-ab-32ppm.mp4` |
| Flamethrower ignition: a 3 px kick plus a fireball flare at the nozzle on the round that lights the stream (reads at 32 px/m for about 4 frames) | `e32720c4`, `5ef1c584` | `--feel=off` | `flamer_ignite_flare-ab-32-48ppm.mp4` |
| Hit-stop cooldown 20 -> 16 ticks (every Kerf cut gets its stop; n7-melee call 7) | `0d4089f1` | - | n7-melee's clips |
| Quest 1 fires the table guns (Gloria as her weapons.json row; the rifle stays on combat.json) | `48679f03` | `--quest-guns=off` | `quest1_table_gloria-ab-32ppm.mp4`, `quest1_table_gloria_dock9-ab-48ppm.mp4` |
| Muzzle flash, smoke and shells leave along the shot's aim, not a facing the walk turned between shots (found by filming quest 1) | `1ce1b11e`, `ed60713e` | - (bug fix) | `quest1_gloria_muzzle_side-48ppm.png` |
| Molotov throw follow-through: the torso leans into the release and the gun shoulder whips through (modest but visible at 32 px/m for about 15 frames; the lean alone was 1-2 px); the arm-only version `41bb90e7` moved no pixel | `41bb90e7`, `7326b53b`, `9b351ab4` | - (THROW_LEAN and THROW_TWIST 0 in `rig_clips.gd`, or drop the molotov `rig_kick` row) | `molotov_throw_twist-ab-32-48ppm.mp4` |
| Rivet's pistol flash reads at 32 px/m: his flash cell 1.6x (an ink-edged cream star, vermilion core, about one body wide; before it was a 15 px speck, smaller than the cop's own flash) | `d79c5278` | `--feel=off` (or hit_feel.json pistol `muzzle_k` 1) | `pistol_muzzle-ab-32-48ppm.mp4` |
| Gloria's flash (quest 1's sidearm, the same cell): 1.8x, one notch over the pistol | `50c0883b` | `--feel=off` (or gloria `muzzle_k` 1) | `gloria_muzzle-ab-32ppm.mp4` |
| Combined clip of the polished set in the city block, 32 px/m, with sound | - | - | `city_block_polished_set-32ppm.mp4` |

Gates (iteration 5): evidence run on `41bb90e7`: lint 13/13, scenarios 52/52, parity bit-exact
(planted mutation caught at 629), selftest pass; unit 1138/0 (flagged by the tree-change guard
because I edited docs during the run). City-block director reel with `--loadout=pistol` on
`ed60713e` 19/19, 0 SCRIPT ERROR. On `7326b53b`: unit 1138/0, lint 13/13, pit director reel with the loadout 19/19, 0 SCRIPT ERROR.

## What does not work / not done
- Molotov throw: scored 1/3/3/3/0 (no wind-up on Rivet; the bottle and the burst read). The arm-only
  follow-through `41bb90e7` moved no pixel (the aimed arm is already at 0.97 of its reach); the
  torso lean `7326b53b` shows, but only subtly. A real wind-up needs the release to wait in the sim
  (a gameplay timing change): not done.
- Quest 1's assault rifle (combat.json, not a table gun): not scored.
- Quest 1's table-gun change is small at 32 px/m in the windows filmed so far (Rivet fires few
  nails in Dock 9).
- No performance claim: no bench was run under the bench lock.

## Calls for the owner
1. **Homing shard pop timing (combat note item 4).** Options: the default 36 grind ticks (the
   approved brutality freeze on the shards, pop at hit + 39 ticks) or `--shard-pop=12` (pop at
   hit + 15). Built default: 36. See `homing_shard_pop-call-32ppm.mp4`, or
   `RTAI.exe -- --weapon=homing_shard` vs `RTAI.exe -- --weapon=homing_shard --shard-pop=12`.

(More calls may be added by later iterations.)

## What blocked or slowed me
- Four lanes on one machine: Godot runs and Movie Maker takes ran slowly (hitches of 35 ms in
  the capture logs, from contention).
- `--arena=city` without the arena scene argument boots the main scene and ignores every arena
  flag (7 min lost, JOURNAL 21:35).
- gdformat and Python text mode write CRLF on Windows; strip it after.

## Next steps
See the last `NEXT:` entry in JOURNAL.md.
