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
