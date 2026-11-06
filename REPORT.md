# REPORT: lane n7-ranged (Rivet's guns + the shared feel layer), night 2026-11-05/06

DRAFT written in iteration 5 (22:30); the last iteration finishes it by 08:40. Branch `n7-ranged`,
cut from main `763f8fba`. Clips and stills: `C:\Users\kazda\kiro\gtai-masters\n7\ranged\` (index:
`frames.json`). Audit and per-weapon before/after: `docs/polish/ranged.md`. Running log: `JOURNAL.md`.

## What works (with its evidence)

| Change | Commit(s) | Before flag (same build) | Evidence (masters n7/ranged) |
|---|---|---|---|
| The shared feel layer reaches the live paths: FeelCam (shake, directional kick, hit-stop) + FeelBudget (caps per frame and per second), per-weapon rows on top of the damage class, a kill keeps the longer stop; view only (parity bit-exact) | `779cdd3d`, `e88ebcfe`, `5535aad2`, `eebc82f7` | `--feel=off` | `mini_nuke-ab-32ppm.mp4`, `heavy_feel-ab-48ppm.mp4` (rocket stop and shake) |
| The arena voices its guns (quest 1's StageAudio; the arena was digitally silent) | `0f8e4f5f` | `--silent` | `rocket_blast_sound-ab-32ppm.mp4` (with sound) |
| Recoil kick per round Rivet fires (Gatling 1.8 px, Gloria 1.5 px, hand cannon 2 px) | `2691917e`, `016966b2`, `078e83ab` | `--feel=off` | `gatling_spinup-ab-32ppm.mp4` (Gloria's 1.5 px kick measured; its clip dropped to keep frames.json at 15) |
| The Gatling's 0.5 s spin-up tremor (about 10/15 Hz, grows with the spin) | `b2af1801`, `eb1d4f1c` | `--feel=off` | `gatling_spinup-ab-32ppm.mp4` |
| The Gatling winds up visibly: a whirl of three ink-and-cream arcs turns at the barrel tip while the barrels spin up (and wind down), growing with the spin; the first round's flash takes the same spot (it7 audit: the spin-up showed nothing on the gun) | `d99106f4`, `ce923514` | `--feel=off` (or gatling `spin_whirl_m` 0) | `gatling_whirl-ab-32-48ppm.mp4` |
| Electro stun: the struck body is thrown 0.3 m along the bolt on the hit frame (owner note item 1) | `9c140ffb` | `--react-snap=off` | `electro_snap-ab-48ppm.mp4` |
| Rocket and mini-nuke boom on the blast frame | `da508e6b` | `--end-cue=off` | `rocket_blast_sound-ab-32ppm.mp4` |
| Flamethrower ignition: a 3 px kick plus a fireball flare at the nozzle on the round that lights the stream (reads at 32 px/m for about 4 frames) | `e32720c4`, `5ef1c584` | `--feel=off` | `flamer_ignite_flare-ab-32-48ppm.mp4` |
| Hit-stop cooldown 20 -> 16 ticks (every Kerf cut gets its stop; n7-melee call 7) | `0d4089f1` | - | n7-melee's clips |
| Quest 1 fires the table guns (Gloria as her weapons.json row; the rifle stays on combat.json) | `48679f03` | `--quest-guns=off` | `quest1_table_gloria_dock9-ab-48ppm.mp4` (the it6 32 px/m pair dropped to keep frames.json at 15) |
| Muzzle flash, smoke and shells leave along the shot's aim, not a facing the walk turned between shots (found by filming quest 1) | `1ce1b11e`, `ed60713e` | - (bug fix) | `quest1_gloria_muzzle_side-48ppm.png` |
| Molotov throw follow-through: the torso leans into the release and the gun shoulder whips through (modest but visible at 32 px/m for about 15 frames; the lean alone was 1-2 px); the arm-only version `41bb90e7` moved no pixel | `41bb90e7`, `7326b53b`, `9b351ab4` | - (THROW_LEAN and THROW_TWIST 0 in `rig_clips.gd`, or drop the molotov `rig_kick` row) | `molotov_windup-ab-32-48ppm.mp4` (the twist plays in its after; the it6 twist clip dropped to keep frames.json at 15) |
| Rivet's pistol flash reads at 32 px/m: his flash cell 1.6x (an ink-edged cream star, vermilion core, about one body wide; before it was a 15 px speck, smaller than the cop's own flash) | `d79c5278` | `--feel=off` (or hit_feel.json pistol `muzzle_k` 1) | `pistol_muzzle-ab-32-48ppm.mp4` |
| Gloria's flash (quest 1's sidearm, the same cell): 1.8x, one notch over the pistol | `50c0883b` | `--feel=off` (or gloria `muzzle_k` 1) | `gloria_muzzle-ab-32ppm.mp4` |
| Machine pistol flash: 1.3x (at 14 rounds a second the flash_smg cell is up 3 ticks of 4, a 6-8 px flicker before; now a cream star about the gun's size, under the pistol's single shot) | `193bc529` | `--feel=off` (or machine_pistol `muzzle_k` 1) | `machine_pistol_muzzle-ab-32-48ppm.mp4` |
| The muzzle flash (and the Gatling's whirl, the flamer's lick) prints on the drawn barrel tip of whatever hold is shown: RivetHeldView publishes the bore tip each frame (before: a fixed spot a claw width beside the aim line, off the rocket tube, the Gatling and the long guns) | `9054e346` | `--flash-at=side` | `muzzle_on_drawn_tip-ab-48-32ppm.mp4` |
| Molotov wind-up: a ready bottle is held cocked behind the gun shoulder (lit, by the helmet), and the throw whips the claw out to the aim from there; the next bottle cocks back in the reload's last phase (before: held out at the aim, no wind-up; audit anticipation 1 -> 3). The release tick is unchanged (render only) | `8766508f`, `cb98ccd4` | `--throw-windup=off` (or held_classes.json thrown `windup_px` 0) | `molotov_windup-ab-32-48ppm.mp4` |
| Molotov first aim: the lit bottle lifts from the ready claw to cocked over 0.22 s (smoothstep, about 13 frames) instead of jumping behind the helmet in one frame; straight out of a reload it is already cocked (no second rise). Render only | `9df494f6` | held_classes.json thrown `windup_rise_s` 0 (the snap) | `molotov_draw_rise-ab-32-48ppm.mp4` |
| Mini-nuke launch weight: a 4 px camera kick against the aim on the launch, easing out over 7-9 frames (measured at 32 and 48 px/m; the rocket's is 3 px, the nuke had none). Restrained on purpose: the blast keeps its own stop, kick and shake. A harder rig kick (arena.json rig_kick 2.0) was filmed and dropped: it did not separate at 32 px/m (the tube swings into its reload pose on the next frame) and the schema caps it at 1.6 | `5c171ed8` | hit_feel.json mini_nuke `fire_kick_px` 0, or `--feel=off` | `mini_nuke_launch-ab-32-48ppm.mp4` |
| Rocket and mini-nuke tube stays on the gun shoulder: on every launch the tube jumped to Rivet's left for a frame, and the nuke sat on the left again for about 9 frames of its reload (present on main: the reload poses the claw on the centre line, so the tube's axis passed within 0.2 px of the head's centre and the helmet clearance took the nearer side, flipping 19 times over a rocket reload and 21 over a nuke's). Aimed, it now keeps the gun shoulder's side. View only (lone kill ticks unchanged) | `5586a80e` | - (bug fix; before = main) | `tube_side-ab-32-48ppm.mp4` |
| Mini-nuke framing: the camera follows the shell in flight (0.8 of the way, at most 10 m and 300 screen px) and holds 60 ticks on the landing while the ring plays, then eases back. Its ring is 12 m in radius, 384 px at 32 px/m on an 800 px screen, so on Rivet it was always cut: at 32 px/m only its top arc showed, at 48 nothing. Now the whole ring at 32 (Rivet at the top edge), the upper half at 48 and the top arc at 64, Rivet always in frame. View only (kill ticks unchanged, outside the kick cap) | `8efe76ca`, `a63bd8e0` | hit_feel.json mini_nuke `blast_lead_k` 0, or `--feel=off` | `nuke_blast_lead-ab-32-48ppm.mp4` |
| The rocket, mini-nuke, hand cannon and homing shard voice a shot of their own (no new asset: three cue rows re-pitch the rifle shot and the nail-gun pop). Before: the rocket played the pistol shot, the nuke Rivet's joint whine at -19 dBFS (nearly silent under the bed), the hand cannon Gloria's nail-gun pop, the shard the generic pistol shot. Measured, not listened to: tube 1.2 kHz centroid at -5 dBFS, hand cannon 1.7 kHz, shard 10.2 kHz and 0.32 s (pistol 3.1 kHz, nail gun 6.0 kHz) | `d4559823` | the old `shot_cue` in each weapons.json row | `shot_cues-ab-32ppm.mp4` (with sound, each gun before then after) |
| Combined clip of the polished set in the city block, 32 px/m, fight camera, with sound (72 s, retaken on `13e0e050`: every ranged chapter plus the whole nuke ring, with the tube fix and the nuke's camera lead) | `13e0e050` | - | `city_block_polished_set-32ppm.mp4` |

Gates (iteration 5): evidence run on `41bb90e7`: lint 13/13, scenarios 52/52, parity bit-exact
(planted mutation caught at 629), selftest pass; unit 1138/0 (flagged by the tree-change guard
because I edited docs during the run). City-block director reel with `--loadout=pistol` on
`ed60713e` 19/19, 0 SCRIPT ERROR. On `7326b53b`: unit 1138/0, lint 13/13, pit director reel with the loadout 19/19, 0 SCRIPT ERROR.

## What does not work / not done
- Molotov throw: the wind-up landed in iteration 11 as a cocked ready pose (`8766508f`), not as a
  timed wind-up before each release: the throw fires on the button press (semi, 50-tick interval
  over a 42-tick reload), so nothing in the sim announces the release; a wind-up that plays
  between press and release would need the release to wait in the sim (a gameplay timing change,
  not done).
- Quest 1's assault rifle (combat.json, not a table gun): filmed in it15 (Dock 9, ticks 14363-14721) and it reads weakly: thin dark dashes, no muzzle flash, no rifle drawn in Rivet's claw (`evidence/ranged/it15-quest1-rifle-32ppm-2x.png`). It fires on the quest's combat.json path (`arena.gun` null), so GunFx, not the table guns' WeaponFxArt, draws its flash, and that flash does not show in the frames (taken every 2 ticks). Not fixed.
- Quest 1's table-gun change is small at 32 px/m in the windows filmed so far (Rivet fires few
  nails in Dock 9).
- No performance claim: no bench was run under the bench lock.

## Calls for the owner
1. **Homing shard pop timing (combat note item 4).** Options: the default 36 grind ticks (the
   approved brutality freeze on the shards, pop at hit + 39 ticks) or `--shard-pop=12` (pop at
   hit + 15). Built default: 36. See `homing_shard_pop-call-32ppm.mp4`, or
   `RTAI.exe -- --weapon=homing_shard` vs `RTAI.exe -- --weapon=homing_shard --shard-pop=12`.
2. **Rivet's muzzle flash sizes.** Options: the weapon-art cell size (1, the before) or the scales
   built tonight (pistol 1.6, Gloria 1.8, machine pistol 1.3; one `muzzle_k` per hit_feel.json
   `weapons` row). Built default: the scales. See `pistol_muzzle-ab-32-48ppm.mp4`,
   `gloria_muzzle-ab-32ppm.mp4`, `machine_pistol_muzzle-ab-32-48ppm.mp4`, or
   `RTAI.exe -- --weapon=pistol` vs `RTAI.exe -- --weapon=pistol --feel=off` (off also drops the
   camera feel).
3. **The Gatling's spin-up whirl.** Options: the whirl at 0.8 m (built), 0.6 m (quieter, faint at
   32 px/m), or none (`spin_whirl_m` 0: the camera tremor alone). Built default: 0.8. See
   `gatling_whirl-ab-32-48ppm.mp4`, or `RTAI.exe -- --weapon=gatling` vs
   `RTAI.exe -- --weapon=gatling --feel=off`. Since `9054e346` the whirl and every muzzle flash
   print on the drawn barrel tip of whatever hold you pick (before: a fixed spot a claw width to the
   aim side, beside the heavy guns' barrels; `--flash-at=side` shows it).
4. **Where the muzzle flash prints.** Options: on the drawn barrel tip (built, follows any hold
   verdict) or the fixed spot beside the aim line (`--flash-at=side`, the before). Built default:
   the drawn tip. See `muzzle_on_drawn_tip-ab-48-32ppm.mp4` (pistol, plasma rifle, rocket, flamer,
   Gatling whirl at 48 and 32 px/m), or `RTAI.exe -- --weapon=rocket_launcher` vs
   `RTAI.exe -- --weapon=rocket_launcher --flash-at=side`.

5. **The molotov held cocked.** Options: a ready bottle held cocked behind the gun shoulder by the
   helmet, the throw whipping out from there (built, `windup_px` 110 part px), or held out at the
   aim (`--throw-windup=off` / `windup_px` 0, the before). It changes how the ready molotov is held
   (the thrown class is not among tonight's open hold calls, but it is a hold). Built default: cocked.
   See `molotov_windup-ab-32-48ppm.mp4`, or `RTAI.exe -- --weapon=molotov --bot=gunplay --lone
   --cam=fight` vs the same with `--throw-windup=off`.

6. **The camera follows the mini-nuke.** Options: the view leads toward the shell and holds on
   its ring (built: `blast_lead_k` 0.8, at most 10 m and 300 screen px, held 60 ticks), a gentler
   lead (`blast_lead_k` 0.5: about the ring's upper two thirds, Rivet well inside the frame), or the camera stays on Rivet
   (`blast_lead_k` 0, the before: the ring runs off the screen). It moves the camera away from
   Rivet for about 2 s per nuke. Built default: 0.8 (the whole ring at 32 px/m, Rivet at the top edge). See
   `nuke_blast_lead-call-3way-32ppm.mp4` (0 / 0.5 / 0.8 side by side), `nuke_blast_lead-ab-32-48ppm.mp4`, or
   `RTAI.exe -- --weapon=mini_nuke --bot=gunplay --lone` vs the same with `--feel=off` (off also
   drops the kicks and the stop).

7. **The re-voiced shots.** Options: the shots built tonight from existing samples (`shot_tube`:
   the rifle shot an octave down for the rocket and nuke launch; `shot_hand_cannon`: the rifle shot
   at 0.72; `shot_shard`: the nail-gun pop at 1.7, quieter), or main's borrowed cues (pistol shot,
   joint whine, Gloria's pop), or a per-weapon sound asset pass (not built: new audio). Built
   default: the re-pitched cues. Nobody has listened to them yet (no audio device on the build
   machine; measured only): listen to `shot_cues-ab-32ppm.mp4` (each gun before, then after), or
   `RTAI.exe -- --weapon=mini_nuke --bot=gunplay --lone` (and `--weapon=hand_cannon`,
   `--weapon=homing_shard`). The before is one data value per gun (weapons.json `shot_cue`).

(More calls may be added by later iterations.)

## What blocked or slowed me
- Four lanes on one machine: Godot runs and Movie Maker takes ran slowly (hitches of 35 ms in
  the capture logs, from contention).
- `--arena=city` without the arena scene argument boots the main scene and ignores every arena
  flag (7 min lost, JOURNAL 21:35).
- gdformat and Python text mode write CRLF on Windows; strip it after.

## Next steps
See the last `NEXT:` entry in JOURNAL.md.
