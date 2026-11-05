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
| Tonnage press slam | 5 | 3 | 4 | 4 | 1 | a dashed teal ring grows for ~40 ticks, then the press disc fills (a clear, dodgeable tell); the impact prints ink cracks and blood and flattens the car, but no hold, shake or debris marks the frame |
| Dent seize + blast | 4 | 3 | 3 | | 1 | the tether and the seized car read; the blast (cream starburst, dark ring) lands at the right edge of the 32 px/m frame (camera on Dent, the owner's open call) |

## Ranked, weakest first (the work order)
Pending the Kerf, Ohm, Tonnage ram/plates and 48 px/m strips (this iteration).
