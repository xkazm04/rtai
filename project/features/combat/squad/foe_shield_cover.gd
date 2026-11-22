class_name FoeShieldCover
extends RefCounted
## A shoulder on either side of the carrier's back. Both places are inside the
## width of the actual plate. A shot from the side can still catch either rifleman.

const SHADOW_M: float = 1.5
const HALF_WIDTH_M: float = 0.72
const FOLLOW_M: float = 1.1
const SHOULDER_M: float = 0.44

var carriers: Array[Fighter] = []


func velocity(mind: SquadMind, squad: ArenaSquad, map: GuardRouteMap, fallen: float) -> Vector2:
	var pit: EnemyPit = squad.pit
	var e: EnemyAgent = mind.agent
	if not carriers.is_empty() and e.arch.uses_cover and mind.motion != EnemyAgent.State.PANIC:
		var at: Vector2 = spot(e, squad, map)
		if at.is_finite():
			mind.mobile_goal = at
			e.goal = at
			mind.motion = EnemyAgent.State.COVER
			e.state = mind.motion
			return (at - e.pos) * 8.0
	if mind.mobile_goal.is_finite():
		mind.forget_route()
		mind.motion = EnemyAgent.State.ENGAGE
	return mind.velocity(pit, map, fallen)


func spot(e: EnemyAgent, squad: ArenaSquad, map: GuardRouteMap) -> Vector2:
	var best: Vector2 = Vector2.INF
	var nearest: float = SquadMind.COVER_RADIUS_M
	for carrier: Fighter in carriers:
		if not _raised(carrier, squad):
			continue
		var away: Vector2 = squad.pit.rivet_pos.direction_to(carrier.pos)
		if carrier.facing.dot(-away) < 0.1:
			continue
		var at: Vector2 = (
			carrier.pos + away * FOLLOW_M + away.orthogonal() * e.strafe_sign * SHOULDER_M
		)
		var distance: float = e.pos.distance_to(at)
		if distance < nearest and map.clear_line(e.pos, at):
			best = at
			nearest = distance
	return best


func multiplier(h: Fighter, ray: Vector2, arena: CombatArena, row: EnemyRoster.Archetype) -> float:
	for carrier: Fighter in carriers:
		if carrier == h or not _raised(carrier, arena.squad_ai):
			continue
		var behind: Vector2 = h.pos - carrier.pos
		if behind.length_squared() > SHADOW_M * SHADOW_M or behind.dot(ray) <= 0.0:
			continue
		if absf(behind.cross(ray)) > HALF_WIDTH_M or carrier.facing.dot(-ray) < row.shield_cos:
			continue
		if (carrier.pos - arena.rivet.pos).dot(ray) > 0.0:
			return row.shield_front_mult
	return 1.0


func _raised(carrier: Fighter, squad: ArenaSquad) -> bool:
	return carrier.alive() and carrier.exposed and not OhmShortCircuit.held(squad, carrier)
