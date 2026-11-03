# features/combat

Feature `combat`: its scene, script and local art together. Depends only on `core/` and WorldContext (LAY-05).

## Readable enemy fire (lane gunplay)

With a table gun wired, set `arena.guard_tell = GuardTell.from_table(WeaponTable.shipped())` next to
`arena.gun` and the contractors announce every burst: stop, a tell of `enemy_fire.tell_s` (FxView
draws a dashed vermilion aim line), a lock for the last `lock_frac` of it (the line goes solid, a
cream glint on the muzzle, the aim stops moving), then the burst down the locked line at
`speed_scale` with `lock_spread_scale` of the rifle cone. Left null, quest 1 keeps `GuardBrain`.

- Poses (enemy-ai): raise the rifle while `GuardTell.telling(f)`, hold still while
  `arena.guard_tell.locked(f)`.
- `guard_tell.one_slot = true`: one gunner tells or bursts at a time (A/B; attack slots are enemy-ai's).
- `guard_tell.track_through_lock = true` is the planted fault (no dodge window); tests catch it.
