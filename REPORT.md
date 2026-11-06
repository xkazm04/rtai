# REPORT: lane n7-ranged (Rivet's guns + the shared feel layer), night 2026-11-05/06

Final, written at the freeze (iteration 25). Branch `n7-ranged`, cut from main `763f8fba`, code head
`5ed859c4` (gates, reels and the exe are all on it). Clips and stills: `C:\Users\kazda\kiro\gtai-masters\n7\ranged\` (index:
`frames.json`). Audit and per-weapon before/after: `docs/polish/ranged.md`. Running log: `JOURNAL.md`.

In one paragraph: the shared feel layer (hit-stop, a directional camera kick, shake, caps per frame and
per second, per-weapon rows, `--feel=off`) landed first, stays view only (parity bit-exact all night)
and n7-melee runs on it. Then, weakest first: the heavy guns got weight (the nuke's launch kick, the
camera following its shell and ring, the rocket and nuke tube kept on the gun shoulder, a boom on the
blast frame), the Gatling a visible and felt spin-up, the flamer an ignition beat, the molotov a
cocked wind-up and a release drawn on the sim's frame, the light guns flashes that read at 32 px/m, a
kill stop that freezes on the wound and a short shot trail from the gun to the wound. Eleven of Rivet's guns
got a shot cue of their own instead of a borrowed one (the last, at the freeze: quest 1's picked-up
rifle stopped playing the contractors' shot); none is listened to yet (call 7). Quest 1 fires the table guns, with the flash, tracer and trail. Every reel is
19/19 with 0 SCRIPT ERROR, and every change has a before flag or data value (calls 1-9).

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
| Molotov release in sync: the claw now carries the bottle over the head and out ahead on the sim's release frame. Before, the view saw the wind-up already 1 tick in and drew one frame behind, so the bottle vanished from behind the helmet and the claw swung out empty a frame later (frames 57-59 of the director chapter at 32 and 48 px/m; n7-melee's FYI, the same late feed as the claw strike). This is the shipped arsenal path (the wheel, the director reel and the city), not `--weapon=molotov`, which has no wind-up. View only; reels 19/19 x2 | `3243a483` | `--throw-sync=off` | `molotov_release_sync-ab-32-48ppm.mp4` (frames.json entry 0) |
| Molotov first aim: the lit bottle lifts from the ready claw to cocked over 0.22 s (smoothstep, about 13 frames) instead of jumping behind the helmet in one frame; straight out of a reload it is already cocked (no second rise). Render only | `9df494f6` | held_classes.json thrown `windup_rise_s` 0 (the snap) | `molotov_draw_rise-ab-32-48ppm.mp4` |
| Mini-nuke launch weight: a 4 px camera kick against the aim on the launch, easing out over 7-9 frames (measured at 32 and 48 px/m; the rocket's is 3 px, the nuke had none). Restrained on purpose: the blast keeps its own stop, kick and shake. A harder rig kick (arena.json rig_kick 2.0) was filmed and dropped: it did not separate at 32 px/m (the tube swings into its reload pose on the next frame) and the schema caps it at 1.6 | `5c171ed8` | hit_feel.json mini_nuke `fire_kick_px` 0, or `--feel=off` | `mini_nuke_launch-ab-32-48ppm.mp4` |
| Rocket and mini-nuke tube stays on the gun shoulder: on every launch the tube jumped to Rivet's left for a frame, and the nuke sat on the left again for about 9 frames of its reload (present on main: the reload poses the claw on the centre line, so the tube's axis passed within 0.2 px of the head's centre and the helmet clearance took the nearer side, flipping 19 times over a rocket reload and 21 over a nuke's). Aimed, it now keeps the gun shoulder's side. View only (lone kill ticks unchanged) | `5586a80e` | - (bug fix; before = main) | `tube_side-ab-32-48ppm.mp4` |
| Mini-nuke framing: the camera follows the shell in flight (0.8 of the way, at most 10 m and 300 screen px) and holds 60 ticks on the landing while the ring plays, then eases back. Its ring is 12 m in radius, 384 px at 32 px/m on an 800 px screen, so on Rivet it was always cut: at 32 px/m only its top arc showed, at 48 nothing. Now the whole ring at 32 (Rivet at the top edge), the upper half at 48 and the top arc at 64, Rivet always in frame. View only (kill ticks unchanged, outside the kick cap) | `8efe76ca`, `a63bd8e0` | hit_feel.json mini_nuke `blast_lead_k` 0, or `--feel=off` | `nuke_blast_lead-ab-32-48ppm.mp4` |
| The rocket, mini-nuke, hand cannon and homing shard voice a shot of their own (no new asset: three cue rows re-pitch the rifle shot and the nail-gun pop). Before: the rocket played the pistol shot, the nuke Rivet's joint whine at -19 dBFS (nearly silent under the bed), the hand cannon Gloria's nail-gun pop, the shard the generic pistol shot. Measured, not listened to: tube 1.2 kHz centroid at -5 dBFS, hand cannon 1.7 kHz, shard 10.2 kHz and 0.32 s (pistol 3.1 kHz, nail gun 6.0 kHz) | `d4559823` | the old `shot_cue` in each weapons.json row | `shot_cues-ab-32ppm.mp4` (with sound, each gun before then after) |
| Quest 1's picked-up assault rifle prints a muzzle flash and inked tracers. It has no weapons.json row, so it fired on the quest's combat.json path with no flash and hair-thin ink dashes; it now draws with its rivet_arsenal.json art stand-in (machine_pistol: flash_smg at muzzle_k 1.3, the cream-and-ink tracer converging from the gun side), view only, so quest 1's replay does not move. Judged at 32 and 48 px/m in Dock 9 (ticks 14340-14560): every round shows a star on the claw tip and a tracer you can follow to the target | `01a482d1` | `--weapon-fx=shapes` | `quest1_rifle_flash-ab-32ppm.mp4`, `quest1_rifle_flash-48ppm.mp4` |
| The Gatling voices a shot of its own, `shot_gatling` (the rifle shot at pitch 0.82, -3 dB, 6 voices; it shared the contractors' rifle shot with the machine pistol). Measured, not listened to: on the samples as played the onset centroid drops 2.35 -> 1.95 kHz and the tail grows 0.82 -> 1.00 s; in a 7 s sustained stream on the range (`--bot=range`), the mix's centroid over 2 s drops 3.8 -> 3.3 kHz at +1.1 dB rms. Picture and sim unchanged (lone kill tick 333 on both) | `6e50068c` | weapons.json gatling `shot_cue` = `shot_assault_rifle` | `gatling_shot_cue-ab-32ppm.mp4` (with sound, before then after) |
| The electro gun, plasma rifle and ray gun stop firing Rivet's own hurt cue: all three played `player_hit_robo_tazer` (Rivet hit by the tazer; non-positional, a 10-tick cooldown that voiced every other ray-gun round and could mute a real tazer hit right after Rivet fired). Own cues on the same crackle: `shot_plasma` (pitch 0.72, the heavier crack), `shot_electro` (1.0, sounds as before), `shot_ray` (1.35, cooldown 3, so each of its 10 rounds a second can voice). Measured on the range (`--bot=range`, 3 s of fire): centroid ray 8.0 -> 10.1 kHz, plasma 8.0 -> 6.4 kHz; not listened to (call 7) | `4e8860c3` | the three weapons.json `shot_cue` = `player_hit_robo_tazer` | `zap_cues-ab-32ppm.mp4` (with sound: ray before/after, then plasma before/after) |
| The molotov's fire burst lands with a sound: a small ignition whoomp, `bottle_burst` (the blast's car-wreck boom at pitch 1.45, -8 dB, as the molotov's end_cue). Before, the landing played only `projectile_end`, a concrete tick at -9 dB, under the biggest fire on screen. Measured on the lone film (kill tick 465 on both): over the 0.6 s from the landing, -34.2 -> -21.7 dB rms and the share under 250 Hz 8% -> 78%; not listened to (call 7) | `b66880c1` | `--end-cue=off` | `molotov_burst_cue-ab-32ppm.mp4` (with sound, before then after) |
| Rivet's machine pistol stops sounding like the enemy: it played `shot_assault_rifle`, the contractors' rifle shot; now `shot_smg` (the rifle shot at pitch 1.25, -6 dB, a lighter chatter). No gun of Rivet's plays the contractors' shot any more (unit test). Measured, not listened to: samples as played 2.35 -> 2.80 kHz onset centroid, 0.82 -> 0.65 s; on the range (2 s of fire) 3.8 -> 4.5 kHz, -3 dB rms | `51cb1194` | weapons.json machine_pistol `shot_cue` = `shot_assault_rifle` | `smg_shot_cue-ab-32ppm.mp4` (with sound, before then after) |
| The flamer's jet roars over the bed it borrowed: it played `fire_crackle`, the burning-wreck bed at -5 dB (continuous on film, but about 15 dB under a gun stream); now `shot_flame` (the crackle at pitch 0.9, +1 dB). On the range film (3 s of held jet): -28.4 -> -23.4 dB rms, still continuous (per-tick std 2.7 dB), centroid 5.9 -> 5.4 kHz. Still about 10 dB under a gun stream (one gain value if the owner wants it louder); not listened to (call 7) | `e63c186e` | weapons.json flamethrower `shot_cue` = `fire_crackle` | `flamer_jet_cue-ab-32ppm.mp4` (with sound, before then after) |
| Combined clip of the polished set in the city block, 32 px/m, fight camera, with sound (72 s, retaken on the freeze head `5ed859c4` at 07:44, 16 chapters down to the nuke, 0 SCRIPT ERROR, -22.3 dB mean as before; content as at 06:22 on `49cfe6c4`: every ranged chapter plus the whole nuke ring, with the tube fix, the nuke's camera lead, the re-voiced shots, the molotov release sync and the wound-hold) | `13e0e050` | - | `city_block_polished_set-32ppm.mp4` |

| Impact re-scored on film with the feel layer on vs off (same build, same kill tick): the pistol, machine pistol, Gloria and the Gatling kill now hold the struck body for about 6 frames before the blood and the fall (off: the blood is out 2 ticks after the hit and nothing answers it); audit I 2 -> 3 for all four. The homing shard's hit star holds the same way, but its blood waits for the pop (call 1) | `779cdd3d` (it1, the feel layer) | `--feel=off` | `evidence/ranged/it20-pistol-kill-feel-on-off-32ppm.jpg`, `it20-smg-gloria-kill-feel-on-off-32ppm.jpg`, `it20-gatling-shard-kill-feel-on-off-32ppm.jpg` (in the repo) |
| A light-class kill's hit-stop now freezes on the wound: the stop starts 2 ticks after the hit, so the held frame shows the blood spurt and the death pose (arms flung) instead of the darkened body still standing gun up, with the blood only after the hold. Pistol, machine pistol, Gloria (and quest 1's table-less rifle), and the Gatling by its own weapons row (`d85fb768`: blood 366 held to 372, before a bloodless hold 364-370); the plasma rifle's dissolve was already on its contact frame, so `medium` keeps 0; heavy, blast, melee and ghost stops unchanged. The fall lands on the same frame either way | `49cfe6c4`, `d85fb768` | `--wound-hold=off` (or hit_feel.json light / gatling `hold_delay_ticks` 0) | `pistol_wound_hold-ab-32-48ppm.mp4`; `evidence/ranged/it21-pistol-wound-hold-off-on-{32,48}ppm.jpg`, `it21-smg-wound-hold-off-on-32ppm.jpg`, `it21-gloria-wound-hold-off-on-32ppm.jpg`, `it21-gatling-wound-hold-off-on-32ppm.jpg` |
| Rivet's hit leaves its path a moment (shot trail): when his round stops in a body, a cream line in an ink casing joins the held gun to the wound and fades over the weapon's `trail_ticks` (pistol 8, Gloria 8, hand cannon 10, machine pistol 4; none on the Gatling, flamer, bolts or throws; misses none; at most 8 at once). Before: at a 5 m fight his pistol round was a pale needle on 2 frames while a cop's vermilion round read for 6. Audit pistol R 2 -> 3. View only (kill tick 332 on and off) | `1b1c8402` | `--shot-trail=off` (or hit_feel.json `trail_ticks` 0, or `--feel=off`) | `pistol_shot_trail-ab-32-48ppm.mp4` (frames.json entry 0); `evidence/ranged/it24-pistol-shot-trail-off-on-{32,48}ppm.jpg` |
| The shot trail in quest 1, the shipped path: Gloria's nails (on GunFx like the arena) draw it across Dock 9 to contractors about 15 m away, over the blood bloom; the picked-up assault rifle (no GunFx on its path) gets it through BareGunTrail at its art stand-in's value (machine_pistol, 4 ticks): on the 14438 kill a cream line runs into the contractor and fades to ink next frame. View only. In the city reel the pistol and SMG fights are point blank (under 2 m), so the trail barely shows there | `1b1c8402`, `2e8143a5` | `--shot-trail=off` (arena and exe; quest1_clip has no such flag) | `evidence/ranged/it24-quest1-gloria-shot-trail-32ppm.jpg`, `it24-quest1-rifle-shot-trail-32ppm.jpg` |
| Quest 1's rifle judged on its real hit ticks: a struck probe finds 10 rifle hits in Dock 9, every one a one-hit kill; at 32 px/m the tracer runs to the contractor, he is down on the next frame along the shot, and the blood sprays along the shot and stays (audit V ? -> 3, I ? -> 2) | - (judging only) | - | `evidence/ranged/it20-quest1-rifle-kills-32ppm.png` |
| Quest 1's picked-up assault rifle voices Rivet's own shot, `shot_rivet_rifle` (the contractors' rifle sample at pitch 0.9, 2 dB up): it played their exact `shot_assault_rifle`, so in Dock 9 his bursts were the enemy's sound. Now no gun of Rivet's shares the contractors' shot. Measured on the samples as played, not listened to: first 150 ms centroid 2.45 -> 2.17 kHz, peak -7 -> -5 dBFS, 0.82 -> 0.91 s. Render only (picture, sim and replay unchanged). No clip: quest1_clip records frames without sound | `5ed859c4` | audio_cues.json `shot_rivet_rifle` pitch 1, gain_db -4 (= the contractors' shot) | unit `test_rivet_rifle_cue` (3/3; planted fault caught) |

Gates on the latest code, `5ed859c4` (iteration 25, 07:39; `2e8143a5` green the same way at 07:23): `node tools/evidence/run.mjs --no-bench` on a clean tree: lint 13/13, unit 1194/0, scenarios 52/52, parity bit-exact over 1200 steps (planted mutation caught at 629), selftest (look goldens 11/11, block 5/5); director reels pit 19/19 and city 19/19 with `--loadout=pistol`, 0 SCRIPT ERROR (`evidence/ranged/it25-evidence-5ed859c4.log`). The city combined clip was retaken on `5ed859c4` at the freeze (see its row). The older lines below are history.

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
- Quest 1's assault rifle: the flash and tracer are fixed (it16, `01a482d1`, row above). Still open: no rifle of its own is drawn in Rivet's claw (the held art is an open owner call tonight). Its impact and victim reaction are judged since iteration 20 (row above); earlier note: they were not judged (the hits land off the clip's crops); its shot shared `shot_assault_rifle` with the contractors until `5ed859c4` (row above).
- Quest 1's table-gun change is small at 32 px/m in the windows filmed so far (Rivet fires few
  nails in Dock 9).
- No performance claim: no bench was run under the bench lock.

## The exe
`build/export/windows/RTAI.exe` (in this worktree, with `gtai_sim.windows.template_release.x86_64.dll`), exported on `5ed859c4` at 07:39: `"$GODOT_BIN" --headless --path project -s res://dev/bake_city.gd` (exit 0), then `"$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe` (exit 0, 0 ERROR lines, 245 MB). Booted on `5ed859c4`: `RTAI.exe --screen 0 --rendering-driver d3d12 --quit-after 600 -- --weapon=pistol --bot=gunplay --lone --cam=fight --ppm=32 --clean --reach=5` (exit 0, 0 SCRIPT ERROR, kill on tick 332 as before). Earlier boots: `RTAI.exe --screen 0 --rendering-driver d3d12 -- --weapon=pistol --bot=gunplay --lone --cam=fight --ppm=32 --clean --reach=5` (exit 0, 0 SCRIPT ERROR, kill on tick 332, the stop holds on the wound and the shot trail joins the gun to the wound 332-341, as in the editor take; on `2e8143a5` the hand cannon too, kill 331, trail 331-341; the Gatling's kill 364 on `d85fb768`). Every call below names its before and after flags on this exe. This is the freeze build.

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
   --cam=fight` vs the same with `--throw-windup=off`. That `--weapon=molotov` path is a table gun
   with no wind-up; the shipped arsenal path (the wheel, the director reel, the city) winds up 14
   ticks, and since `3243a483` its claw carries the bottle out on the release frame:
   `RTAI.exe -- --bot=reel --reel=director --loadout=pistol --chapter=molotov --ppm=48` vs the same
   with `--throw-sync=off` (the whip 2 frames late; `molotov_release_sync-ab-32-48ppm.mp4`).

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
   at 0.72; `shot_shard`: the nail-gun pop at 1.7, quieter; `shot_gatling`: the rifle shot at
   0.82, it16), or main's borrowed cues (pistol shot,
   joint whine, Gloria's pop), or a per-weapon sound asset pass (not built: new audio). Built
   default: the re-pitched cues. Nobody has listened to them yet (no audio device on the build
   machine; measured only): listen to `shot_cues-ab-32ppm.mp4` (each gun before, then after), or
   `RTAI.exe -- --weapon=mini_nuke --bot=gunplay --lone` (and `--weapon=hand_cannon`,
   `--weapon=homing_shard`); the Gatling's stream: `gatling_shot_cue-ab-32ppm.mp4` or
   `RTAI.exe -- --weapon=gatling --bot=range`; the zaps: `zap_cues-ab-32ppm.mp4` or
   `RTAI.exe -- --weapon=ray_gun --bot=range` (and `--weapon=plasma_rifle`); the molotov:
   `molotov_burst_cue-ab-32ppm.mp4` or `RTAI.exe -- --weapon=molotov --bot=gunplay --lone` vs the
   same with `--end-cue=off`; the SMG: `smg_shot_cue-ab-32ppm.mp4` or
   `RTAI.exe -- --weapon=machine_pistol --bot=range`; the flamer: `flamer_jet_cue-ab-32ppm.mp4` or
   `RTAI.exe -- --weapon=flamethrower --bot=range`; quest 1's picked-up rifle (`shot_rivet_rifle`, the
   contractors' rifle at pitch 0.9, 2 dB up): play quest 1 to Dock 9 and grab a contractor's rifle
   (no clip: the quest recorder writes frames only). The before is one data value per gun
   (weapons.json `shot_cue`; for the rifle, audio_cues.json `shot_rivet_rifle` pitch 1, gain_db -4).

8. **Where a light gun's kill stop freezes.** Options: on the wound, 2 ticks after the hit (built: the spurt and the flung arms hold for about 6 frames), or on the contact tick (the before: the body still standing, gun up, darkened; blood after). One value each: hit_feel.json `hold_delay_ticks` (0-4) on the light row and on the gatling weapons row. The Gatling: `RTAI.exe -- --weapon=gatling --bot=gunplay --lone --cam=fight` vs the same with `--wound-hold=off`. See `pistol_wound_hold-ab-32-48ppm.mp4`, or `RTAI.exe -- --weapon=pistol --bot=gunplay --lone --cam=fight` vs the same with `--wound-hold=off`.

9. **The shot trail.** Options: a fading ink-and-cream line from the gun to the wound on every hit (built: pistol and Gloria 8 ticks, hand cannon 10, machine pistol 4), a shorter flick (`trail_ticks` 4 on all four), or none (`--shot-trail=off` / `trail_ticks` 0, the before). It is the only thing tonight that draws a line where the round went after it is gone; if it reads as a laser to you, drop the value. Built default: the trail. See `pistol_shot_trail-ab-32-48ppm.mp4`, or `RTAI.exe -- --weapon=pistol --bot=gunplay --lone --cam=fight --ppm=32` vs the same with `--shot-trail=off` (and `--weapon=hand_cannon`, `--weapon=machine_pistol`). In quest 1 Gloria and the picked-up rifle draw it too (stills `evidence/ranged/it24-quest1-*-shot-trail-32ppm.jpg`).


## What blocked or slowed me
- Four lanes on one machine: Godot runs and Movie Maker takes ran slowly (hitches of 35 ms in
  the capture logs, from contention).
- `--arena=city` without the arena scene argument boots the main scene and ignores every arena
  flag (7 min lost, JOURNAL 21:35).
- gdformat and Python text mode write CRLF on Windows; strip it after.

## Next steps
1. Listen to every re-voiced cue on a machine with sound (call 7); each one is one data value.
2. The weak cells left (`docs/polish/ranged.md`): the homing shard's late blood and mark (call 1);
   the Gatling's read and victim sync on a single cop (it kills in 2 rounds, so a body held under
   sustained fire only shows on crowds and robots: film it on a boss); the machine pistol in a group
   at range (one take at 6 m read clean, R kept at 2); quest 1's rifle impact (no held rifle art: an
   open owner call).
3. A real wind-up before the molotov release needs the release to wait in the sim (a gameplay
   timing change: a decision and a replay re-bless, not polish).
4. The bench under the lock: no performance number was taken tonight.
Details: the last `NEXT:` entry in JOURNAL.md.
