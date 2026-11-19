class_name GuardBrain
extends RefCounted
## A dock contractor with an assault rifle (mechanic assault-rifle): walk at Rivet until inside
## engage_m, then spray bursts of weak rounds (burst, burst_gap, cooldown) with a seeded spread.
## Sense, decide and apply in one small step per tick; the arena owns the shots it returns.


static func step(
	g: Fighter, target: Vector2, tuning: CombatTuning, rng: RandomNumberGenerator
) -> Shot:
	if approach(g, target, tuning):
		return null
	return trigger(g, tuning, rng)


## Resolve body penetration on the moving partner. Wave guards keep their own movement.
static func space_partner(g: Fighter, hostiles: Array[Fighter]) -> void:
	for other: Fighter in hostiles:
		if other == g or not other.alive():
			continue
		var side: float = 1.0 if g.id > other.id else -1.0
		g.pos += EnemyMotor.repel(g.pos, other.pos, g.station_spacing_m, side)


static func trigger(g: Fighter, tuning: CombatTuning, rng: RandomNumberGenerator) -> Shot:
	var w: CombatTuning.Weapon = tuning.weapon(g.weapon)
	if g.burst_left > 0:
		if g.burst_gap > 0:
			g.burst_gap -= 1
			return null
		g.burst_left -= 1
		g.burst_gap = w.burst_gap_ticks
		var spread: float = rng.randf_range(-w.spread_rad, w.spread_rad)
		return Shot.fire(g, g.facing.rotated(spread), w)
	if g.cooldown > 0:
		g.cooldown -= 1
		return null
	g.burst_left = w.burst
	g.cooldown = w.cooldown_ticks
	return null


## Both rifle brains share the approach. On open ground the original speed and range apply.
static func approach(g: Fighter, target: Vector2, tuning: CombatTuning) -> bool:
	var speed: float = tuning.human["walk_mps"]
	if g.pursuit != null and g.pursuit.advance(g, target, speed):
		return true
	var to: Vector2 = target - g.pos
	if to.length() > 0.01:
		g.facing = to.normalized()
	if to.length() <= tuning.human["engage_m"]:
		return false
	g.pos += g.facing * speed * SimClock.TICK_DT
	return true
