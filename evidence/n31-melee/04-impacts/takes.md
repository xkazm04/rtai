# n31 melee 04f: item 4's impacts in play, main | n31 impacts

Films (owner, `gtai-masters/n31/melee/`): `beside_impacts_<weapon>.mp4`, 1920x1080, 35.0 s, H.264. Each half is
the middle half of a 1080p60 take cropped round Rivet (03p5's composite): left "main" = a temp worktree at
`0f1e1ce95` (the audit commit; its play_take.mjs has no `--game-flags`, its defaults are the old rules: melee
sweep off, kill feed off), right "n31 impacts" = HEAD with `--game-flags=--melee-sweep=off,--kill-feed=off`.
Same seed 7, 2100 frames, 32 px/m, tilt 70, the average bot holding the weapon: the two halves are the same
fight frame for frame, only the view-only marks differ. Built by `tools/melee/impact_takes.sh`; the seconds
where the halves differ were found with `tools/melee/take_diff.py` on the two source takes (20 fps), then
looked at as stills.

Most bot strikes kill (the kill is generic on both sides: the feed is off), so a wound mark shows only on the
non-lethal hits listed here.

## katana

- 15.2 s: Rivet cuts a cop inside a black blast cloud: the right half draws cream-and-ink cut strokes across
  him; the left half shows only the cloud and the body.
- 16.8 s: two crossed cuts on the cop at the kerb above Rivet (right); left: the cop, no mark.
- 30.6 s: a cut stroke left of Rivet on the cop he swings at (right); left: the swing arc only.
- Hits in this take: 13.1, 15.15-15.35, 16.75-16.95, 29.95-30.15, 30.55-30.75 s (each about 0.3 s, the mark's
  21 ticks).

## plasma_sword

- 15.2 s: two ember-and-ink sear strokes on the cop Rivet swings into inside the black cloud (right); left: the
  white swing arc and the cloud, nothing on the cop.
- 17.55 s: three sears on the cops at the kerb above Rivet, the strongest difference in the take (253 px at
  960x540); left: the bodies and the cloud only.
- 27.6 s: sears on the two cops right of Rivet, one above and one below the kerb line; left: nothing on them.
- Hits in this take: 13.0, 13.8, 15.15, 15.85, 17.5, 18.15, 24.5, 27.5, 29.4, 30.15, 31.35, 32.95 s; each
  sear lives about 0.5 s (30 ticks) and thins to its char.

## chainsaw

- 15.4 s: a small white bite starburst on the cop in the black cloud above Rivet (right); left: the cloud only.
- 16.9 s: the bite burst on the cop Rivet grinds at his left; left: the cop and the blood, no burst.
- 18.65 s: a burst on the cop right of Rivet; left: nothing there.
- Every bite also shakes the after half once (the whole frame shifts: take_diff counts 20-32 k px on those
  frames): 13.35, 15.0, 15.35, 16.5, 16.85, 18.25, 18.6, 20.05, 20.35, 21.75, 22.05 s and on. The jagged kerf
  is hard to see at 32 px/m in play: the burst and the shake carry the bite.

## The audit sheet, before | after (`sheet_before_after.png`)

`python tools/melee/impact_sheet.py build/n31/04f/still_before build/n31/04f/still_after <png>`: marks_still at
64 px/m, before from the temp tree at `0f1e1ce95` (marks_still copied in: its `_life` reads fixed mark lives
and its gun path has no GunFxWound flick, neither exists there), after from HEAD. Both runs re-pin the victim
after every sim step (04f part C, `marks_still.gd _pin`): the 04d/04e stills lost him.

| weapon | hit human | hit robot | hit shield | what the after shows |
|---|---|---|---|---|
| claw | 3 -> 3 | 2 -> 2 | 2 -> 2 | unchanged rakes |
| katana | 1 -> 2 | 1 -> 2 | 2 -> 2 | cut with red beads on the cop; cut + oil specks on the robot; cut on the slab |
| plasma_sword | 1 -> 2 | 1 -> 2 | 1 -> 2 | ember sear; on the slab the sear + an ember spit |
| chainsaw | 1 -> 2 | 0 -> 2 | 1 -> 2 | the bite starburst on all three (main: nothing); white sparks and oil off the robot; spray off the slab |
| electro_baton | 2 -> 2 | 2 -> 2 | 1 -> 2 | amber arc on the slab; robot specks; the human's stun arcs are not in a still |
| pistol | 1 -> 2 | 1 -> 1 | 2 -> 2 | red flick drops + cream hot point on a human; one faint dark speck on a robot |
| gatling | 1 -> 2 | 1 -> 1 | 2 -> 2 | as the pistol |

Caveats: the "human" victim is the arena's first guard, who carries a riot shield (the human and shield columns
show the same man); the gun rows stop one probe round on a body, and the victim is not drawn at the stop
(the crops centre on the stop); gun "shield" cells are that body stop, not a slab hit.
