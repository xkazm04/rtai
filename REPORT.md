# REPORT: lane n7-ranged (Rivet's guns + the shared feel layer), night 2026-11-05/06

DRAFT written in iteration 5 (22:30); the last iteration finishes it by 08:40. Branch `n7-ranged`,
cut from main `763f8fba`. Clips and stills: `C:\Users\kazda\kiro\gtai-masters\n7\ranged\` (index:
`frames.json`). Audit and per-weapon before/after: `docs/polish/ranged.md`. Running log: `JOURNAL.md`.

## What works (with its evidence)

| Change | Commit(s) | Before flag (same build) | Evidence (masters n7/ranged) |
|---|---|---|---|
| The shared feel layer reaches the live paths: FeelCam (shake, directional kick, hit-stop) + FeelBudget (caps per frame and per second), per-weapon rows on top of the damage class, a kill keeps the longer stop; view only (parity bit-exact) | `779cdd3d`, `e88ebcfe`, `5535aad2`, `eebc82f7` | `--feel=off` | `hand_cannon-ab-32ppm.mp4`, `rocket_launcher-ab-32ppm.mp4`, `mini_nuke-ab-32ppm.mp4`, `heavy_feel-ab-48ppm.mp4` |
| The arena voices its guns (quest 1's StageAudio; the arena was digitally silent) | `0f8e4f5f` | `--silent` | `rocket_blast_sound-ab-32ppm.mp4` (with sound) |
| Recoil kick per round Rivet fires (Gatling 1.8 px, Gloria 1.5 px, hand cannon 2 px) | `2691917e`, `016966b2`, `078e83ab` | `--feel=off` | `gatling-ab-32ppm.mp4`, `gloria_kick-ab-32ppm.mp4` |
| The Gatling's 0.5 s spin-up tremor (about 10/15 Hz, grows with the spin) | `b2af1801`, `eb1d4f1c` | `--feel=off` | `gatling_spinup-ab-32ppm.mp4` |
| Electro stun: the struck body is thrown 0.3 m along the bolt on the hit frame (owner note item 1) | `9c140ffb` | `--react-snap=off` | `electro_snap-ab-48ppm.mp4` |
| Rocket and mini-nuke boom on the blast frame | `da508e6b` | `--end-cue=off` | `rocket_blast_sound-ab-32ppm.mp4` |
| Flamethrower ignition kick (3 px on the first puff after a rest) | `e32720c4` | `--feel=off` | `flamer_ignite-ab-32ppm.mp4` |
| Hit-stop cooldown 20 -> 16 ticks (every Kerf cut gets its stop; n7-melee call 7) | `0d4089f1` | - | n7-melee's clips |
| Quest 1 fires the table guns (Gloria as her weapons.json row; the rifle stays on combat.json) | `48679f03` | `--quest-guns=off` | `quest1_table_gloria-ab-32ppm.mp4`, `quest1_table_gloria_dock9-ab-48ppm.mp4` |
| Muzzle flash, smoke and shells leave along the shot's aim, not a facing the walk turned between shots (found by filming quest 1) | `1ce1b11e`, `ed60713e` | - (bug fix) | `quest1_gloria_muzzle_side-48ppm.png` |
| Combined clip of the polished set in the city block, 32 px/m, with sound | - | - | `city_block_polished_set-32ppm.mp4` |

Gates on `ed60713e`/`03df7e8c` (iteration 5): lint 13/13 over 940 files; unit 1137/0; city-block
director reel with `--loadout=pistol` 19/19 down, 0 SCRIPT ERROR
(`evidence/ranged/it5-reel-city-loadout.log`); evidence run: see JOURNAL iteration 5.

## What does not work / not done
- Molotov throw anticipation: not scored. In the 48 px/m take I could not pick the spinning bottle
  out in flight (JOURNAL FINDING 22:20).
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
