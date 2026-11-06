# n7-melee REPORT (night 2026-11-05/06): Rivet's melee and the four ghosts' attacks

DRAFT written 23:40 (iteration 6), updated 03:22 (iteration 11). The final version lands at 08:40, after the freeze and the exe
export. Clips are under `C:\Users\kazda\kiro\gtai-masters\n7\melee\` (`M/` below); the shortlist is in
`M/frames.json`. Every change below is view only: no sim tick, replay or parity hash moved. Quest 1's
final hash moved once, deliberately, when quest 1 started carrying the katana (`fbc5a982`).

## What works (with its evidence)
| Item | Commit | What changed | Before / after |
|---|---|---|---|
| Non-lethal melee wound (brief 2) | `1e32a7fd`, `a1716c1d` | a riot cop or SWAT now twists on a jab or first cut (MeleeWound, view only; the chainsaw grind does not restart it) | `M/melee_wound_riot_ab_48ppm_64slow.mp4` (before `--soft-swing`) |
| Melee weight (brief 3) | `65dd07e1` + rows | every melee hit reaches FeelCam (n7-ranged's layer): a hold on the hit frame, a kick along the blow, the kill stop; per-weapon rows for the claw, katana, baton and chainsaw | `M/melee_feel_claw_ab_32ppm_48slow.mp4` (before `--feel=off`) |
| Kerf's chain | `cb3e5caa` | a hold and a cream-and-ink cut flare per cut: it reads cut by cut instead of one blur | `M/kerf_chain_ab_32ppm_64slow.mp4` |
| Kerf's sight (anticipation) | `96e1abe6` | a dashed teal sighting line from Kerf to the body the next press cuts, with a white lock (two brackets) on it; dim just after a blink, full when the next blink may fire, none without a charge. Each cut of a chain is called before it lands (the blink came from nowhere before) | `M/kerf_sight_ab_32ppm_48slow.mp4`, still `M/kerf_sight_ab_32_48ppm.png` (before `ghost_attacks.json` kerf `sight_k` 0, or `--feel=off`) |
| Kerf's camera after a blink | `3fd49218` | the camera whips from where Kerf stood to where he lands (0.18 s, eased out) instead of jumping with the one-tick blink; the cut's hit-stop holds the take-off framing, so he is seen landing across the frame, then the camera travels. A chain reads as one fight in one place. Quest 1 takes it too (`be78d440`: the objective ring now stays on its goal while the camera travels) | `M/kerf_cam_glide_ab_32ppm_48slow.mp4`, quest 1 `M/quest1_kerf_cam_glide_ab_32ppm.mp4` + still `M/quest1_kerf_cam_glide_ring_ab_32ppm.png` (before `--kerf-glide=off`) |
| Plasma sword deflect | `2502aaa7`, `a7ed5d4c` | a parry beat (a stop, a kick toward the shooter), a starburst on the bat frame and a streak along the return | `M/plasma_deflect_ab_32ppm_48slow.mp4` |
| Ohm's tell | `0555878c` | white sparks edged in ink reach from Ohm's fingertips toward the aim while the charge refills | `M/ohm_tell_ab_32ppm_crop.mp4` |
| Chainsaw kill | `49cc45d1` | a cream burst where the halves part, the grind's drops kept clear of the held body | `M/chainsaw_kill_ab_32ppm_48slow.mp4` |
| Chainsaw kill: where the halves fall | `85f3ffa9`, `c8be703d` | a melee kill now carries its own blow line (Rivet -> victim; before, the last round's line, often a cop shot flying back at Rivet), and the chainsaw throws its halves forward along the push (`signature_kills.json` chainsaw `split_follow` 0.8): they lie in a V 1-1.5 m in front of him instead of against his outline, and the grind's spray flies out past the victim. The katana and claw chapters looked at before/after: no regression (claw identical; katana halves now part on the far side) | `M/chainsaw_halves_ab_32ppm_48slow.mp4` (before `--saw-part=off --melee-dir=off`) |
| Tonnage press slam | `4c6c6bf5` | a landing flash, paper chips and dust on the slam | `M/tonnage_slam_ab_32ppm_48slow.mp4` |
| Dent's blast and blow | `cb3e5caa`, `4a522dfe` | felt: a kick outward from the car (blast), the melee stop plus a crash shake (blow) | `M/dent_blast_ab_32ppm.mp4`, `M/dent_car_blow_ab_32ppm_04x.mp4` |
| Dent's car bomb throws debris | `5c4219b2` | the blast flings the rocket blast's grey slabs in a bold ink edge and ink specks out past its ring (WeaponFxDebris, the arsenal's one debris drawer); before, the fireball and ring played over a car that just went dark. At 48 px/m, with the blast at the frame edge (camera on Dent, call open), the slabs fly back into frame | `M/dent_blast_debris_ab_32ppm_48slow.mp4`, still `M/dent_blast_debris_ab_32_48ppm.png` (before `ghost_attacks.json` dent `blast_debris` 0, `--blast-debris=off`, or `--feel=off`) |
| Tonnage ram | `0c4161d8` | a cream burst past each rammed body, paper chips along the shove | `M/tonnage_ram_ab_32ppm_48slow.mp4` |
| Tonnage's ram called before the contact | `bc788d09` | while the press moves at ram speed a bow wave (cream edged in ink) rides from its nose past its flanks, outside the drawn press, so the charge reads before anyone is hit (in quest 1 too) | `M/tonnage_ram_wake_ab_32ppm_48slow.mp4`, still `M/tonnage_ram_wake_ab_32_48ppm.png` (before `ghost_attacks.json` tonnage `ram_wake_k` 0, or `--feel=off`) |
| Tonnage plates | `8375c763`, `330779ff`, `d97a976d` | an enemy round now stops at the plate face with a small capped glance spark (it drew through his body before) | `M/tonnage_plates_ab_32ppm.mp4` |
| Ohm mass arc | `454490ce`, `7ce7b33d` | the branches draw at 0.55 of the bolt; a stunned crowd keeps full marks on the 2 newest bodies only, so the cops' blue reads through | `M/ohm_mass_arc_ab_32ppm_04x.mp4`, `M/ohm_stun_crowd_ab_32ppm_04x.mp4` |
| Ohm's bolt lands on the body it strikes | `a27fb59c` | the stroke stops 0.6 m out from each struck body and a crackling ink-and-white ring circles it (it ran into the body's chest under a solid white disc), so every link of the chain lands on a body you can see; a small gain, clearest on a robot | `M/ohm_bolt_rim_ab_32ppm_48slow.mp4`, still `M/ohm_bolt_rim_ab_32_48ppm.png` (before `ghost_attacks.json` ohm `rim_m` 0, or `--feel=off`) |
| Melee and ghost hit sounds | `f593aac4` | each attack family plays its own sound on the hit tick, built from the shipped bank (claw knock, blade cut, chainsaw bite, baton zap, ghost slam, Ohm bolt) | `M/hit_cues_ab_32ppm.mp4` (before `--hit-cues=off`) |
| Ghost wind-ups and whiffs make a sound | `690ec813`, `a6c2797b` | Tonnage's press slam whines from the tick its dashed ring appears (measured: the ring's first frame 126, the sound's 125, twice in the reel); a slam that hits no body lands with a heavy concrete thud (only a body hit played a sound before); Dent's seize clunks at the car on the tether's first frame (84; +3-5 dB over the car's own sounds, so a small gain); Ohm's bolt that burns a car, or reaches nothing, crackles where it ends (it was drawn in silence; onsets on the drawn bolts' frames). Built from the shipped bank, not listened to | `M/ghost_tell_cues_ab_32ppm.mp4` (before `--tell-cues=off`) |
| Claw jab reads at 32 | `f45ad8e6` | three cream rakes edged in ink across the struck cop on the hit frame, fading over 10 ticks | `M/claw_rake_ab_32ppm.mp4`, `M/claw_rake_48ppm_04x.mp4` (before `melee_marks.json` claw `flash_ticks` 0) |
| Claw jab: out on the held hit frame, a deeper cock | `791ea71a` | the view strike was fed 2 ticks late, so the hit-stop held the claw cocked on every claw hit; now it holds the claw in the cop, and the open claw draws back for 2 frames before the jab (blades unchanged) | `M/claw_strike_sync_ab_32ppm_48slow.mp4`, `M/claw_strike_sync_ab_64ppm_04x.mp4`, `M/claw_strike_sync_ab_still.png` (before `--strike-sync=off --pullback=off`) |
| Ghost hits move the victim | `91700e01` | a body Tonnage rams or throws with the slam, and that survives, now plays a knockdown on the hit (before: no reaction at all); a rammed riot cop goes down instead of standing braced | `M/ghost_wound_ram_ab_32ppm.mp4` (before `human_reactions.json` `ghost_wound` {}) |
| Quest 1 shows melee (brief 5) | `fbc5a982`, `8237d411`, `becfeb7f`, `806a657e`, `5f80e67c` | Rivet carries the katana on key 2 in quest 1; the shipped sprite cast draws the blade, the swing and the smear | `M/quest1_katana_ab_32ppm.mp4` (before `--quest-blade=off`) |
| The shipped quest 1 starts (found by the trial exe) | `87d7dc2b` | since `65dd07e1` the slice exe failed to compile quest1_game.gd (a dev-only class on the melee feel's path); fixed, and `test_slice_closure` now fails the unit gate on any dev class on quest 1's path | `evidence/n7-melee/it9-export-slice-fix.log`; the slice exe's title card loads, 0 SCRIPT ERROR |
| City Tonnage reel has no engine errors | `c48b2806` | the ram and slam chips draw in local space (6 triangulation ERRORs per city reel, 0 now; no visible change) | `evidence/n7-melee/city-tonnage-{before,after}-chipfix.log` |
| Plasma sword asset (backlog 3) | `4540d259`, `9a2d3137` | a new top-down held part from one image round: the blade tapers to a point from a pronged emitter collar, with ink arc strokes along a paper-white core (it was a square-ended cream plank); same hilt, same length and grip; the floor pickup and the HUD icon follow it. A shape gain at 48 px/m and up; at 32 px/m the two are close to identical | `M/plasma_sword_blade_ab_32ppm_48slow.mp4`, `M/plasma_sword_blade_ab_48ppm_3x.png` (before: the old `held_long.png`) |

The whole polished set in the city block at 32 px/m, with the game audio:
`M/melee_polished_set_city_32ppm.mp4` (44 s, re-cut on code `791ea71a`: the five melee segments refilmed for the strike sync; the ghost segments from `5c4219b2` with `evidence/n7-melee/set_clip.sh`: no dev
telemetry box, the ghost card whole; it is re-cut once more on the final head at the freeze).

Gates on the last build commit `a6c2797b` (05:21):
- lint 13/13; unit 1229/1229 (incl. `test_slice_closure`, `test_tell_cues`);
- scenarios 52/52 with 0 SCRIPT ERROR;
- director reel 19/19 in the arena and 19/19 in the city block (every chapter fully down), 0 SCRIPT ERROR.
The full `node tools/evidence/run.mjs --no-bench` (lint 13/13, unit 1229, scenarios 52, parity
bit-exact over 1200 steps with the planted mutation caught at 629, look goldens 11/11, block 5/5)
last ran green on `7da9f3d6` (code `a6c2797b`, 05:31); it re-runs on the final head at the freeze.
Bench not run: contended machine, no lock taken.

The logs are in `evidence/n7-melee/`.

## What does not (yet)
- The claw's second blow shows no wind-up of its own: its sim windup is 4 ticks and the view
  first sees it 2 ticks in, i.e. after the cock (before the strike sync it only seemed cocked
  because the rig ran late and then froze cocked on the hit). A visible cock there needs a longer
  sim windup, which is game timing, not polish. The first blow keeps its draw-back.
- The hit sounds reuse the shipped bank, pitched per family. Real recorded swings, cuts and slams
  are still missing (sound scores 3, not higher).
- The heap at the car under Tonnage's ram still reads as one blob at 32 px/m: the sim shoves the
  bodies into the car. Two view-only tries were reverted because they could not be seen in motion:
  a bigger burst on a ram kill (no ram kills in the beat), and ink speed lines over the shove (they
  lie under the press). The rammed bodies now react (`91700e01`): in the city the riot cop is
  thrown clear and reads, but a body that stays inside the press's footprint is hidden. The cause
  is draw order, not marks: the ghost form draws above every rig (ghost-forms' rule), so no view
  mark can show a body under it. That is call (h).
- Tonnage in quest 1: the dev recorder `res://dev/ghost-powers/quest_hauler_rec.tscn` (quest 1's real
  view, bound input) shows the ram's cream bursts on the dock guards Tonnage ploughs through, with
  the slam and the blood (`M/quest1_tonnage_ram_marks_32ppm.png`, frames 84-175 every 4th). The ring
  guards shoot, and his plates spark there as in the arena: a spark on screen in 274 of 330 ticks, at
  most 12 at once (the cap: 2 new a tick, 6 ticks each); small cream stars on the press's flank at
  2x (`M/quest1_tonnage_plates_32ppm_2x.png`, frames 60/64/100/104/200/204). The quest bot itself
  never takes Tonnage.

- Quest 1's objective ring places its goal from Rivet's spot. It now takes Kerf's camera glide
  (`be78d440`), but not the older view-only camera offsets (`forms_lift_m` under a ghost subtitle,
  the dev `--cam=fight` lean): with those the ring sits that far off its goal. Not changed this
  late, because the lift is a judged quest 1 look; it is one line (`cam_off_m` = all three).

## Calls for the owner
(a) Quest 1 carries the katana on key 2.
- Options: katana (built), electro baton, none.
- Clip: `M/quest1_katana_ab_32ppm.mp4`.
- Exe (quest 1 is the slice build): `build/export/windows-slice/RTAI.exe -- --quest-blade=off`
  (before), `-- --quest-blade=electro_baton` (the baton instead); no flag = the katana. The arena exe
  `build/export/windows/RTAI.exe` cannot open quest 1 (release templates take no scene path).

(b) Tonnage's stomp ignores `--feel=off`. The stomp's stop and shake come from HaulerKick, outside
the shared layer.
- Options: leave it, or route it through FeelCam.

(c) Dent's blow feel (`hit_feel.json` `dent_car`, class ram).
- Clip: `M/dent_car_blow_ab_32ppm_04x.mp4`.
- The off value is to delete the row.

(d) Tonnage's plates stop rounds in the view only; the sim radius is unchanged.
- Clip: `M/tonnage_plates_ab_32ppm.mp4`.
- Before: `--feel=off`.

(e) Ohm's branches draw at 0.55 of the bolt.
- Clip: `M/ohm_mass_arc_ab_32ppm_04x.mp4`.
- Before: `ghost_attacks.json` ohm `branch_k` 1.

(f) A stunned crowd draws full stun marks on its 2 newest bodies only; the rest get a spit and a
head spark.
- Clip: `M/ohm_stun_crowd_ab_32ppm_04x.mp4`.
- Before: `human_reactions.json` `stun_crowd.full` 0, or `--feel=off`.

(g) A ghost blow reaches past a riot shield like Rivet's melee (the rammed riot cop goes down).
- Options: past the slab (built), or the shield braces and shows its block sparks.
- Clip: `M/ghost_wound_ram_ab_32ppm.mp4`.
- Before: `human_reactions.json` `ghost_wound` {} (no ghost wounds at all), or `--feel=off`.

(h) The ram heap: a body the press shoves into a car sits inside the press's footprint, under it.
- Options: leave it (built); pop the struck body above the form for the shove's ~0.3 s (breaks the
  ghost-forms rule that no human draws over a ghost body); or let the sim keep rammed bodies out of
  the footprint (a sim change and a deliberate re-bless).
- Still: `M/ram_heap_under_press_32ppm_2x.png` (city, 32 px/m at 2x, frames 138/146/150: the star,
  the bonnet cop's head peeking from under the press arm, the riot cop thrown clear).
- See it: `RTAI.exe -- --arena=city --bot=ghosts --ghost=tonnage --rigs --ppm=32` (contact at
  about 2.3 s).

(i) The plasma sword's new blade art (backlog item 3; one Codex image round, provenance logged).
- Options: the new tapered blade with arc strokes (built); the old square-ended cream blade.
- Clip: `M/plasma_sword_blade_ab_32ppm_48slow.mp4`; still `M/plasma_sword_blade_ab_48ppm_3x.png`.
- The off value: restore the old `features/combat/weapons/art/plasma_sword/held_long.png` (git, one
  file) and its three weapon_art.json numbers (grip/muzzle row 48, size 539x100). No exe flag.
- See it: `RTAI.exe -- --bot=reel --reel=director --chapter=plasma_sword --loadout=pistol --rigs --ppm=48`
  (a dev-only chapter, run by name; the 19-chapter cut is unchanged).
- Note: at 32 px/m a held part of 46 px cannot show "plasma" through its drawing alone. If the owner
  wants the blade to read hot at 32, that is a view effect (a flicker or rim on the blade), not art.

(j) Kerf's sight: a dashed teal line to the next victim and a white lock on it.
- Options: line and lock (built); the lock only (no line); none.
- Clip: `M/kerf_sight_ab_32ppm_48slow.mp4`.
- Before: `ghost_attacks.json` kerf `sight_k` 0, or `--feel=off` (which also drops every other feel effect).
- See it: `RTAI.exe -- --bot=ghosts --ghost=kerf --rigs --ppm=32` (the first cut is called at about 1.5 s).
- Note: the line is teal because it is Kerf's own mark (a soul's), not an impact on the world.

(k) Tonnage's bow wave while he rams.
- Options: the bow wave (built); none (the ram reads only on contact).
- Clip: `M/tonnage_ram_wake_ab_32ppm_48slow.mp4`.
- Before: `ghost_attacks.json` tonnage `ram_wake_k` 0, or `--feel=off`.
- See it: `RTAI.exe -- --bot=ghosts --ghost=tonnage --rigs --ppm=32` (the press reaches the cops at
  the car at about 1.9 s).

(l) Ohm's bolt stops at the struck body's rim and rings it.
- Options: rim and ring (built); the old stroke into the body's centre under a white disc.
- Clip: `M/ohm_bolt_rim_ab_32ppm_48slow.mp4`.
- Before: `ghost_attacks.json` ohm `rim_m` 0, or `--feel=off`.
- See it: `RTAI.exe -- --bot=ghosts --ghost=ohm --rigs --ppm=48` (the first bolt hits the robot thug at
  about 1.5 s).

(m) Dent's car bomb flings the rocket's slabs.
- Options: the rocket's grey slabs and ink specks (built: one blast vocabulary for the arsenal and the
  ghosts); none (the fireball and ring alone). A cream car-panel variant was drafted and dropped to
  keep one debris drawer; it would be a second row in `blast_debris.json` if the owner wants it.
- Clip: `M/dent_blast_debris_ab_32ppm_48slow.mp4`.
- Before: `ghost_attacks.json` dent `blast_debris` 0, or `--blast-debris=off` (which also drops the
  rocket's slabs), or `--feel=off`.
- See it: `RTAI.exe -- --bot=ghosts --ghost=dent --rigs --ppm=32` (the car goes off at about 2.9 s).

(n) The claw cocks back deeper before the jab.
- Options: pullback 0.7 with the arm drawn back (built); the night's 0.35 torso twist only (the
  before); any depth 0-1 is one value (`melee_marks.json swing.pullback.claw`, `arm_back.claw`).
  The strike sync under it (the claw out on the held hit frame) is a fix, not a call; it also
  moves the katana and the baton: their sweep and smear now land on the held hit frame (before, the
  hit-stop held the blade lifted over the burst and the sweep came after the hold). Stills
  `M/katana_strike_sync_ab_48ppm_still.png`, `M/baton_strike_sync_ab_48ppm_still.png`, clip
  `M/katana_strike_sync_ab_48ppm_04x.mp4` (top/left before `--strike-sync=off`). If the owner
  prefers the lifted blade over the burst, `--strike-sync=off` is the whole before.
- Clip: `M/claw_strike_sync_ab_32ppm_48slow.mp4` (32 real time, then 48 at 0.4x), still
  `M/claw_strike_sync_ab_still.png` (rows: 32 before, 32 after, 48 before, 48 after).
- Before: `--pullback=off` (the depth only), `--strike-sync=off --pullback=off` (the whole before).
- See it: `RTAI.exe -- --bot=reel --reel=director --chapter=claw_combo --loadout=pistol --lone`.

(o) The ghosts' wind-up sounds.
- Options: the built picks (Tonnage's tell: the servo whine at pitch 1.4, about 1.0 s, so the slam's crash lands over its
  tail; the whiff: the concrete hit at 0.6; Dent's seize: the metal hit at 0.55); a lower, heavier press tell (servo at
  0.7-1.0 runs 1.4-2.0 s, well past the 0.5 s wind-up); none. Each is one `audio_cues.json` row (`ghost_press_tell`,
  `ghost_press_land`, `ghost_seize`: `sound`, `pitch`, `gain_db`). No one has listened to them; the measures are frame
  onsets and band energy, not taste. Kerf's sight and Ohm's charge stay silent (Ohm recharges after every bolt: a sound
  per refill would be noise). Ohm's bolt onto a car (or nothing) reuses HitCues' `ghost_bolt` row: once the crowd is down
  in the reel he burns a car every 0.4-0.5 s, so the crackle runs on there, one per drawn bolt, as on bodies.
- Clip: `M/ghost_tell_cues_ab_32ppm.mp4` (with sound and a waveform strip: Tonnage before, after; Dent before, after; Ohm
  on the car before, after).
- Before: `--tell-cues=off`.
- See it: `RTAI.exe -- --bot=ghosts --ghost=tonnage --rigs --ppm=32` (the ring at about 2.1 s), `--ghost=dent`
  (the seize at about 1.4 s), `--ghost=ohm` (the car bolts from about 5.8 s).

(p) Where the chainsaw's halves fall (and the line every melee kill carries).
- Options: forward V (built: `split_follow` 0.8, the halves ~51 deg off the push, 1-1.5 m in front of Rivet); sideways
  (0.25, the brutality night's value, but on the true line now: the halves either side of the victim, about 1 m); further
  forward (1.2+, a tighter V, the halves nearer one line). One value in `signature_kills.json` (chainsaw row). The blow line
  fix (`--melee-dir=off`) is a bug fix, not a taste call: before it a melee kill took the last round's direction, so the
  katana's and the saw's cuts threw their parts at random angles, often back onto Rivet.
- Clip: `M/chainsaw_halves_ab_32ppm_48slow.mp4` (32 px/m real time, then 48 px/m at 0.4x; before left).
- Before: `--saw-part=off` (sideways, on the true line), `--saw-part=off --melee-dir=off` (the whole before).
- See it: `RTAI.exe -- --arena=city --bot=reel --reel=director --chapter=chainsaw --loadout=pistol --clean`
  (the halves part at about 6.6 s).

(q) Kerf's camera after a blink.
- Options: the whip (built: `ghost_attacks.json` kerf `cam_glide_s` 0.18, cubic ease-out, held through the cut's
  hit-stop); the snap (0, the camera nailed to Rivet as before); a slower follow (0.3-0.4: the trail and the cut stay on
  screen longer, the camera lags further on a fast chain). One value. Kerf only: Dent's camera is call (d7) and untouched.
- Clip: `M/kerf_cam_glide_ab_32ppm_48slow.mp4` (city 32 px/m real time, then the arena at 48 px/m 0.4x; before left).
- Before: `--kerf-glide=off`.
- See it: `RTAI.exe -- --arena=city --bot=ghosts --ghost=kerf --rigs --ppm=32` (blinks from about 1.3 s).
  Quest 1 (dev recorder, bound input): `quest_ghost_rec.tscn -- --ghost=kerf --ppm=32 --out=<dir>` (blinks from frame 70).

## Next steps
See the last NEXT entry in `JOURNAL.md`.
