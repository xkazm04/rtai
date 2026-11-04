class_name FightReach
extends RefCounted
## Lane gunplay: who or what a table round reaches in the real fight (split out of FightAreas):
## where a thrown bottle lands (the living hostile closest to the aim line), and the electro
## chain's next hop (the nearest exposed living hostile, else the nearest unused metal).
## Pure functions of the fight's state: no RNG, no writes.

## TickInput carries the aim as a direction only, so a thrown bottle lands on the living hostile
## closest to the aim line within this angle (and its range), else at the aim point.
const LOB_CONE_RAD: float = 0.2
## A homing round looks for the nearest living hostile this far ahead, within this half-angle.
const HOME_RANGE_M: float = 12.0
const HOME_CONE_COS: float = 0.5
const TRAIL_POINTS: int = 10


## Turns a homing round `s` toward the nearest living hostile ahead by at most its turn rate.
static func home(arena: CombatArena, s: Shot) -> void:
	@warning_ignore("return_value_discarded")
	s.trail.append(s.pos)
	if s.trail.size() > TRAIL_POINTS:
		s.trail.remove_at(0)
	var dir: Vector2 = s.vel.normalized()
	var best: Fighter = null
	var best_d: float = HOME_RANGE_M
	for h: Fighter in arena.hostiles:
		var to: Vector2 = h.pos - s.pos
		var d: float = to.length()
		if h.alive() and h.exposed and d < best_d and d > 0.01 and dir.dot(to / d) >= HOME_CONE_COS:
			best_d = d
			best = h
	if best == null:
		return
	var turn: float = dir.angle_to(best.pos - s.pos)
	s.vel = s.vel.rotated(clampf(turn, -s.spec.homing_rad_per_tick, s.spec.homing_rad_per_tick))


## Where a bottle thrown from `from` toward `at` lands (see LOB_CONE_RAD). A shell with a
## `min_m` (weapons.json min_lob_m: the mini-nuke) never lands closer than that along the aim, so
## its blast circle stays off the thrower (showcase REQUEST 16).
static func lob_target(arena: CombatArena, from: Vector2, at: Vector2, w: WeaponSpec) -> Vector2:
	var lands: Vector2 = _lob_pick(arena, from, at, w.range_m)
	if from.distance_to(lands) >= w.min_lob_m:
		return lands
	return from + (lands - from).normalized() * w.min_lob_m


static func _lob_pick(arena: CombatArena, from: Vector2, at: Vector2, range_m: float) -> Vector2:
	var aim: Vector2 = (at - from).normalized()
	var best: Vector2 = at
	var best_off: float = INF
	for h: Fighter in arena.hostiles:
		var to: Vector2 = h.pos - from
		var off: float = absf(aim.cross(to))
		var in_cone: bool = absf(aim.angle_to(to)) <= LOB_CONE_RAD
		if h.alive() and to.length() <= range_m and in_cone and off < best_off:
			best_off = off
			best = h.pos
	return best


static func nearest(arena: CombatArena, from: Vector2, r: float, skip: Array[Fighter]) -> Fighter:
	var best: Fighter = null
	var best_d: float = r
	for h: Fighter in arena.hostiles:
		if h.alive() and h.exposed and not skip.has(h):
			var d: float = h.pos.distance_to(from)
			if d <= best_d:
				best_d = d
				best = h
	return best


static func metal(
	arena: CombatArena, from: Vector2, radius: float, used: PackedVector2Array
) -> Vector2:
	var best: Vector2 = from
	var best_d: float = radius
	for m: Vector2 in arena.metal:
		var d: float = m.distance_to(from)
		if d <= best_d and d > 0.01 and not used.has(m):
			best_d = d
			best = m
	return best
