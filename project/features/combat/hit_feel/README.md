# features/combat/hit_feel — the shared hit feel

One module for every landed hit: guns (lane gunplay), melee and the claw combo (`rivet-motion`),
ghost powers (Hauler stomp, Gearbox ram). Tuning lives in `data/tables/hit_feel.json`
(`gtai.hit_feel/1`), one row per damage class: `light`, `medium`, `heavy`, `blast`, `burn`,
`shock`, `melee`. Add a class by adding a row; never hardcode a stop or a shake in a caller.

## API

```gdscript
var feel: HitFeel = HitFeel.shipped(camera_rig)   # rig may be null (tests, headless)
feel.reaction.connect(_on_reaction)               # enemy-ai: (target_id, kind, dir, ticks)

# on every landed hit (ProjectileSim.hit gives you target, amount, hit_class, dir):
var hold: int = feel.land(target.id, hit_class, dir, not target.alive(), tick)
if hold > 0:
    clock.hold(hold)                              # the caller owns the clock

sprite.modulate = base.lerp(FLASH, feel.flash(target.id, tick))  # the hit flash, 1 -> 0
knock = dir * weapon.knockback_mps * feel.knock_scale(hit_class)
```

- **Hit-stop** names a `camera.json` hit-stop id; a lethal hit uses `kill_hitstop` instead. The
  rig returns 0 under reduced motion and inside its cooldown, so rapid fire never stutters.
  Set `beat_mode = true` during a scripted kill beat: a lethal hit then uses `beat_kill_hitstop`
  (`boss_hit`, 8 ticks instead of 6; d5-combat REQUEST 3).
- **Shake** names a `camera.json` shake id; the rig keeps the stronger shake in progress and scales
  it to 0 under reduced motion (the shake budget).
- **Reaction** is `none|flinch|stagger|knockdown` with a length in sim ticks; not emitted for a
  lethal hit (the kill beat owns that). `enemy-ai` plays the animation; this module never does.
- **Flash** is per target id, fading linearly over `flash_ticks`.

## HitLink: the one-line hookup for a CombatArena

```gdscript
var link: HitLink = HitLink.make(arena, HitFeel.shipped(rig), WeaponTable.shipped())
view.cast_view.hit_link = link          # impact star (flash) + drawn flinch (lean)
# each sim tick, after arena.step():
link.step()                             # knockback slides the victims, decaying x0.82 a tick
if link.hold > 0:
    clock.hold(link.hold)               # the kill hit-stop the hit asked for
    link.hold = 0
```

`HitLink` listens to `CombatArena.struck` and `HitFeel.reaction`. In the D5 print the flash is an
inked impact star (cream, ink rim; Rivet's rim is vermilion = danger), not a tint. Reference
scene: `dev/gunplay/pistol_fight.tscn` (`-- --armored` for non-lethal hits).

## The camera side: FeelCam + FeelBudget (lane n7-ranged, 2026-11-05)

Until n7-ranged, the arena (`GunplayHook`) handed every hit to a detached `CameraRig.new()` and
dropped `link.hold`, so a landed round shook nothing and stopped nothing in the live paths (the pit,
the city block, quest 1). The camera side now lives in the view: `CollectCallView` owns one
`FeelCam` that listens to `CombatArena.struck` and asks `HitFeel.camera_row(weapon, class, lethal)`.

```gdscript
var cam: FeelCam = FeelCam.attach(arena, clock)       # connects arena.struck (Rivet's rounds)
# any other attack (melee lane, ghost powers, a boss slam) calls hit() itself:
var held: int = cam.hit(&"claw", &"melee", dir * strength, lethal, tick)   # |dir| = strength
camera.offset += cam.offset_px(tick, zoom)           # shake + kick, world px for that zoom
```

- **Row resolution**: the class row (`classes`), then the weapon's override on top
  (`weapons`: any of `hitstop`, `shake`, `kick_px`, `kick_ticks`), then a kill takes
  `kill_hitstop` (`beat_kill_hitstop` in a beat) and `kick_px * kill_kick_scale`.
- **Directional kick**: `kick_px` screen px along the hit (any zoom), full on the hit tick and
  easing back as (1 - t)^2 over `kick_ticks`; during a hit-stop the tick does not move, so the frame
  freezes displaced. A negative sense would be a one-line change; along the hit was chosen.
- **Strength**: the length of `dir` (unit = 1, capped at 2) scales the kick: splash falloff, chain
  hops, a combo finisher.
- **Caps** (`cap`, `FeelBudget`): `kicks_per_tick` kicks start per sim tick (the rest are refused,
  not summed), `shakes_per_second` shake starts and `hitstop_ticks_per_second` stop ticks in any
  60-tick window, the summed kick never past `kick_px_max` screen px. On top, the rig's own
  hit-stop cooldown (camera.json `hitstop_cooldown_ticks`) and strongest-shake-wins still apply.
- **Off**: `--feel=off` (HitFeel.enabled false) and reduced motion: no shake, kick or stop at all.
  The flash, reaction and knockback stay (the approved baseline, not camera feel). With
  `--feel=off` the live paths frame exactly as main `763f8fba` did.
- **View only**: FeelCam is made by the view (never in a headless replay), its state is never
  read by the sim, and hit-stop is `SimClock.hold` (wall time, every tick unchanged).
