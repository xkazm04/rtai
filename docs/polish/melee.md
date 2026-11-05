# Polish audit: Rivet's melee and the four ghosts' attacks (lane n7-melee, 2026-11-05/06)

Filmed on `n7-melee` at `a1716c1d` (main `763f8fba` + the non-lethal melee wound), arena
`res://dev/arena/arena.tscn`, `--fixed-fps 60`, 1280x720, `--rigs`. Films: `evidence/n7-melee/audit.sh`
(raw AVIs in the lane scratch, not kept). Melee: director chapters (`--bot=reel --reel=director
--chapter=<id> --loadout=pistol --clean`, patrol cops). Ghosts: `--bot=ghosts --ghost=<id>` (the
ghost-powers beats, telemetry overlay on).

## The instrument (motion-quality-gating)
- **Sampling.** Per attack one strip: frames 40-157 every 3rd (40 frames, 10x4) for melee, a crop
  of 240x140 px around Rivet at 32 px/m; ghosts: a 16-frame overview (every 50-56 frames, full frame)
  and a strip over the attack window (every 4th frame, 30 frames). Scores at 32 px/m, the judging scale.
- **Scale.** 1-5, absolute (what ships in a top-down action game today), never graded against this batch.
  Correctness is the floor: "it plays and nothing pops" is a 2, not a 3.
- **Each dimension is a visible contrast**:
  - *Anticipation*: a pose that loads before the active frame (the blade cocks, a tell grows) vs the hit
    arriving from the idle pose.
  - *Impact*: the hit frame differs from its neighbours (hold, flash, kick, debris, a shape change) vs
    the hit frame looking like the frame before it.
  - *Read at 32*: at 32 px/m, without slowing down, you can say what hit whom and what happened to them.
  - *Victim sync*: the victim's body changes on the hit frame vs a frame or more later, or never.
  - *Sound*: a cue of the attack's own fires on the hit frame. From data (`audio_cues.json`), not by ear:
    the lane cannot listen. 1 = no cue of its own (only the generic kill/death cues).
- Craft (the first four) and sound are reported side by side, never averaged. Unmeasured = blank.

## Systemic findings (they cap every Impact score below)
1. **No camera feel reaches the arena, the city block or quest 1.** n7-ranged FINDING 19:25: the arena's
   rig is null and GunplayHook's HitFeel rig is detached; only free roam (`boot/world.gd`) and the
   Hauler's private rig shake. So no melee hit and no ghost impact has a hit-stop, a shake or a kick in
   the live paths. n7-ranged's FeelCam fixes the camera side; melee needs its own `cam.hit` calls
   (no `struck`). Item 3 of the brief.
2. **Sound: no attack in this lane has a cue of its own.** `audio_cues.json` has 34 cues; none for a
   swing, a cut, a grind, a jab, a slam, a blink, a bolt or a seize. Melee kills get `rivet_kill`/
   `death`/`body_fall`; a non-lethal melee hit gets nothing. New cues need sound assets (no generator in
   this lane's tools): a call, not a build tonight.
   **Partly done 00:07 (`f593aac4`)**: each family now has a hit sound of its own from the shipped bank,
   pitched per family (audio_cues.json `hits`: claw knock, blade cut, chainsaw bite, baton zap, ghost
   slam, Ohm bolt; Dent's blast -> `blast`), on the hit tick (measured: within 1 frame of the visual hit
   on the claw kills and the ram contact). Re-scored sound 1 -> 3 for every attack: on the frame and
   distinct per family, but reused recordings, and no swing whoosh or telegraph sound (still a call:
   real recordings). `M/hit_cues_ab_32ppm.mp4` (`--hit-cues=off` = the before).
3. **A non-lethal melee hit showed nothing** (riot cop, SWAT): fixed in `1e32a7fd` + `a1716c1d`
   (`M/melee_wound_riot_ab_48ppm_64slow.mp4`).

## Scores (32 px/m)

| Attack | Antic. | Impact | Read 32 | Victim sync | Sound | What I saw |
|---|---|---|---|---|---|---|
| Plasma sword (deflect) | 4 | 2 | 2 | 3 | 1 | big cream smear sectors read; the deflect is a tiny spark on the blade, the returned round is a thin line and the shooter's death 7 m away is not tied to the swing; the blade is the cream placeholder |
| Chainsaw | 3 | 3 | 2 | 4 | 1 | the grind's white-ink judder is distinct, but the kill ends as a red blob under Rivet's feet: at 32 the body is not separable from the blood and Rivet |
| Claw combo | 3 | 2 | 3 | 4 | 1 | the jab is small at 32 (the arm over the cop); no hold on the hit frame; the kill reads through a large blood spray and the fold (combat-notes) |
| Electro baton | 3 | 4 | 4 | 4 | 1 | the shock star and arcs mark the hit frame; the victim is thrown with a smear |
| Katana | 4 | 4 | 5 | 5 | 1 | the blade lifts, the cut bisects, halves fly apart on the cut frame: the best-reading melee |
| Kerf blink-slice chain | 2 | 2 | 3 | 4 | 1 | each target splits into two halves on its cut frame (sync holds), teal afterimages trace the blink; but three cops in a column split inside ~12 frames with no hold or mark between cuts, so at 32 the chain reads as one event; the camera jumps with each blink |
| Ohm forked bolt | 2 | 3 | 3 | 4 | 1 | no tell: the bolt is instant; a thin teal line at 32; the victim flashes to an ink x-ray with sparks on the hit frame, the struck car goes dark (wreck); the mass arc (upgrade_tier 1) is not in the beat |
| Tonnage press slam | 5 | 3 | 4 | 4 | 1 | a dashed teal ring grows for ~40 ticks, then the press disc fills (a clear, dodgeable tell); the impact prints ink cracks and blood and flattens the car, but no hold, shake or debris marks the frame |
| Dent seize + blast | 4 | 3 | 3 | 4 | 1 | the tether and the seized car read; the blast (cream starburst, dark ring) lands at the right edge of the 32 px/m frame (camera on Dent, the owner's open call) |

## Ranked, weakest first (the work order)
By the craft columns (impact and read at 32 weigh most: they are what the owner judges), weakest first:
1. **Kerf's chain**: one blur at 32 (the brief's own warning). View-only fix candidates: a cut mark held
   on each victim from its cut frame, and a short hold per cut through FeelCam (`slice` row, no shake).
   **Done 20:18 (`cb3e5caa`)**: kerf_slice rides FeelCam (class `slice`; a kill takes the 6-tick kill stop)
   and KerfView draws a 0.15 s cream-and-ink cut flare per cut (`cut_flare_s`). Limit: the camera's
   20-tick stop cooldown is longer than the 18-tick `gap_s`, so at full player cadence only every other
   cut can hold (the reel presses every 20 ticks: every cut holds); the kick and the flare mark all.
   `M/kerf_chain_ab_32ppm_64slow.mp4`.
2. **Plasma sword deflect**: the deflect spark is tiny and the return is not tied to the swing; the
   placeholder blade (asset only after every item, backlog 3).
   **Done 20:30 (`2502aaa7`)**: a parry beat (row `plasma_deflect`: 4-tick stop, kick toward the shooter)
   and DeflectMarks (`melee_marks.json`): a cream starburst edged in ink on the bat frame and a streak
   along the return. `M/plasma_deflect_ab_32ppm_48slow.mp4`.
3. **Claw combo**: no hold on the hit frame (systemic 1), small jab at 32; melee weight (brief item 3).
   **Done 19:55 (`65dd07e1`)**: every melee hit now reaches FeelCam (MeleeFeel); measured holds on the
   claw's hit frames (6 frames at the kill, 5 at the second cop; none in the `--feel=off` before);
   `M/melee_feel_claw_ab_32ppm_48slow.mp4`.
   **Small jab done 00:40 (`f45ad8e6`)**: ClawMarks (`melee_marks.json claw`): three cream rakes edged
   in ink across the struck cop, square to the blow, printed whole on the hit frame (74, one frame
   before first blood; 106) and fading over 10 ticks. Looked at in 2x crops of frames 72-79 and
   104-111, before (flash_ticks 0) over after: the before shows only the arm over a blue cop. Re-scored
   impact 2 -> 3, read 3 -> 4. `M/claw_rake_ab_32ppm.mp4`, `M/claw_rake_48ppm_04x.mp4`.
4. **Ohm's bolt**: no tell; thin at 32.
   **Tried 20:38, not landed**: a fingertip charge glow over bolt_gap_s does not separate from the form's
   own teal aura at 32 px/m (the form is ~20 px). Next: a tell outside the aura (an ink/cream spark arc
   reaching toward the aim) or a bigger white ready glint.
   **Done 20:53 (`0555878c`)**, pass 2: white sparks edged in ink reach from the tips toward the aim as
   the charge refills; gone on the fire frame. `M/ohm_tell_ab_32ppm_crop.mp4`.
5. **Chainsaw**: the kill is a red blob under Rivet at 32.
   **Done 21:12 (`49cc45d1`)**: SawMarks (`melee_marks.json saw`): a cream starburst edged in ink on the
   tick the halves part (a slash along the cut hid on the saw bar), the grind's drops hidden until
   0.45 m clear of the held body, a firmer judder (0.06 m). `M/chainsaw_kill_ab_32ppm_48slow.mp4`.
6. **Tonnage slam**: a clear tell, but the impact frame has no hold, shake or debris.
   **Correction 20:30**: measured, the slam does shake and stop (HaulerKick: `crash` + `boss_hit`, outside
   FeelCam, so `--feel=off` films are identical); what is missing is debris on the landing.
   **Done 20:37 (`4c6c6bf5`)**: SlamDebris (landing flash, paper chips, dust) in HaulerMarks for every
   caller. `M/tonnage_slam_ab_32ppm_48slow.mp4`.
7. **Dent's blast**: lands at the frame edge at 32 (camera call open: polish only the impact).
   **Impact done 20:21 (`cb3e5caa`)**: dent_blast row (class blast, crash shake), kick outward from the
   car; measured 0.0 px -> 17.9 px first-frame jolt settling in 12 frames. `M/dent_blast_ab_32ppm.mp4`.
7b. **Tonnage ram** (scored 21:15 from the 48 px/m audit film; 32 px/m read): antic. 2, impact 2,
   read 2, victim sync 3, sound 1: the press drives cops into a heap against the car; HaulerKick's stop
   and shake run per hit, but nothing prints on the contact.
   **Done 21:27 (`0c4161d8`)**: RamMarks: a cream burst edged in ink just past each rammed body (the
   press hides the near side) and paper chips along the shove. Small at 32 px/m (~20 px); the heap is
   unchanged. `M/tonnage_ram_ab_32ppm_48slow.mp4`.
8. **Electro baton**, 9. **Katana**: read well; they get the shared hit-stop with item 3 only.

## Quest 1 shows melee (brief item 5)
**Done 21:47-22:05 (`fbc5a982`, `8237d411`)**: quest 1's pilot carries the katana on key 2
(RivetCarry.sheathe: a press draws it over the story's gun, a second press puts it away; a story swap
counts as put away). The shipped quest draws Rivet as a sprite, where no held weapon or swing existed
(the rigs are dev `--rigs` only), so CastBladeView draws the blade on the sprite's hand point with the
combo's sweep and a smear. Seen at Dock 9 (quest1_clip `--blade=13570-13880`, the pad closes on the
bot's target): the blade lifts, cuts down and settles at 32 px/m; contractors split on the cut frame
with the katana's halves and blood, the shared melee hit-stop holds. Limits: the hand point is a
guess on a sprite that does not turn with his arm (the blade starts at his shoulder side); the bot
does not draw the blade, so only a player (or the dev pad) sees it.
`M/quest1_katana_ab_32ppm.mp4` (before `--quest-blade=off` | after).

7c. **Dent's blow** (the seized car striking a body, weapon `dent_car`; scored 22:00 from the
48 px/m audit film and an arena ghost reel at 32): antic. 4 (the tether, the car swinging round),
impact 1, read 3, victim sync 4 (thrown off the bonnet with blood on the strike tick), sound 1.
Measured: the strike frame was identical to `--feel=off` (0 px differ): the blow had no feel row.
In the 48 px/m audit film the car leaves the frame before it strikes (camera on Dent, owner call).
**Done 22:03 (`4a522dfe`)**: hit_feel.json `dent_car` row, class `ram` (the melee stop, the crash
shake, a kick along the car's nose). Measured at 32 px/m (arena ghost reel, tick 117): a 13 px
jolt held through a 7-frame stop, the shake settling by frame 130; before 0 px.
`M/dent_car_blow_ab_32ppm_04x.mp4`.

7d. **Tonnage plates** (scored 22:27 frame by frame at 48 px/m, frames 84-113): antic. n/a,
   impact 1, read 1, victim sync n/a, sound 1. The cops' rounds drew on inside the press body with
   no mark: the armour read as rounds passing through him. **Done 22:39 (`8375c763`)**: PlateSparks
   (view only, FxView): an enemy round's tracer ends at the plate face (plate_r_m 1.35 from Rivet's
   spot) and its first contact prints a cream star edged in ink with a short bounce streak for
   plate_spark_ticks 6; at most plate_sparks_per_tick 2 new a tick (a capped round still stops).
   Looked at (48 px/m frames 86-109 every 2nd, 32 px/m x2 crops 90-105): the rounds stop at the
   hazard-striped plate, the stars read on it. Re-scored: impact 3, read 3 (small at 32 px/m, on
   purpose: small arms are a light hit). `M/tonnage_plates_ab_32ppm.mp4`,
   `M/tonnage_plates_48ppm_04x.mp4`. Fixed 22:57-23:04 (`330779ff`, `d97a976d`): the city film
   printed the first sparks round the teal morph disc before any press was drawn; the plates now
   wait until the transformation into Tonnage is 0.8 through (the press leaves the morph ring).

7e. **Ohm mass arc** (scored 22:45 from the 32 px/m film, `--tier=1` (OhmBeat already takes it),
   frames 94-117 every 2nd, and the 48 px/m pair at tick 92): antic. 4 (the tell), impact 3,
   read 2, victim sync 4 (every body stuns on the bolt tick), sound 1. The fan out of the first body
   drew five ropes as wide as the bolt over a six-body cluster, and each body wears cream stun
   squiggles: the cluster drowns. **Done 22:44 (`454490ce`)**: ghost_attacks.json ohm branch_k
   0.55 (view only): a hop from a struck body draws at 0.55 of the bolt with a smaller flash; 1 or
   `--feel=off` = the old look. Looked at: the bolt keeps its weight, the branches thin, the cops'
   blue shows through. Read 2 -> 3. Still open: the stun squiggles (the reaction view, not the arc)
   are most of the clutter. `M/ohm_mass_arc_ab_32ppm_04x.mp4`, `M/ohm_mass_arc_48ppm_04x.mp4`.
   **Done 23:25 (`7ce7b33d`, the squiggles)**: human_reactions.json stun_crowd (StunCrowd, view only):
   past the 2 newest stunned bodies the rest draw 1 spit and 1 head spark, no crawling arc (from 3
   arcs, 3 spits, 2 sparks each). full 0 or `--feel=off` = the before. A 1-arc pass was still busy.
   Looked at: the six cops read blue, each still visibly stunned (the spark circling, the spit).
   Read 3 -> 4. `M/ohm_stun_crowd_ab_32ppm_04x.mp4`.
