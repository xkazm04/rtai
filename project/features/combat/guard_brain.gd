class_name GuardBrain
extends RefCounted
## A dock contractor with an assault rifle (mechanic assault-rifle): walk at Rivet until inside
## engage_m, then spray bursts of weak rounds (burst, burst_gap, cooldown) with a seeded spread.
## Sense, decide and apply in one small step per tick; the arena owns the shots it returns.


static func step(
	g: Fighter, target: Vector2, tuning: CombatTuning, rng: RandomNumberGenerator
) -> Shot:
	var to: Vector2 = target - g.pos
	g.facing = to.normalized() if to.length() > 0.01 else g.facing
	if to.length() > tuning.human["engage_m"]:
		g.pos += g.facing * tuning.human["walk_mps"] * SimClock.TICK_DT
		return null
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
