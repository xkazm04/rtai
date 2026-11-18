class_name SquadMind
extends RefCounted
## One local cover/flank search per 12 ticks, offset by fighter ID. A blocked goal gets one
## A* path when it changes cell. Between plans the motor follows the cached bends.

const S := EnemyAgent.State
const PLAN_TICKS: int = 12
const BLIND_LIMIT: int = 6 * SimClock.TICK_RATE
const COVER_RADIUS_M: float = 8.0
const SPACING_GAP_M: float = 1.5

var agent: EnemyAgent
## Rounds remaining when a token, range or sight interrupted the production trigger.
var paused_rounds: int = 0
var motion: EnemyAgent.State = S.ENGAGE
var _blind: int = 0
var _route: PackedVector2Array = PackedVector2Array()
var _next: int = 0
var _destination: Vector2 = Vector2.INF
var _strafe: bool = false


func _init(h: Fighter, arch: EnemyRoster.Archetype) -> void:
	agent = EnemyAgent.make(h.id, arch, h.pos)
	agent.facing = h.facing
	agent.enter(S.ENGAGE)


func velocity(pit: EnemyPit, map: GuardRouteMap, fallen: float) -> Vector2:
	var e: EnemyAgent = agent
	_blind = 0 if e.sees else _blind + 1
	if EnemyBrain.break_morale(e, fallen, pit.roster.panic_ticks):
		motion = S.PANIC
	if motion == S.PANIC:
		e.timer -= 1
		if e.timer > 0:
			if e.timer == pit.roster.panic_ticks - 1 or (pit.tick + e.id) % PLAN_TICKS == 0:
				_set_goal(e.pos + pit.rivet_pos.direction_to(e.pos) * 4.0, map)
			return _walk()
		motion = S.ENGAGE
		_destination = Vector2.INF
	if (pit.tick + e.id) % PLAN_TICKS == 0:
		_plan(pit, map)
	e.state = motion
	if _strafe:
		return EnemyBrain.strafe(e, pit.rivet_pos, e.arch.preferred_m)
	return _walk()


func _plan(pit: EnemyPit, map: GuardRouteMap) -> void:
	var e: EnemyAgent = agent
	var target: Vector2 = pit.rivet_pos
	_strafe = false
	motion = S.ENGAGE
	if _blind <= BLIND_LIMIT and e.arch.uses_cover and not e.token:
		var boxes: Array[Rect2] = map.boxes_near(e.pos, COVER_RADIUS_M)
		var spot: Vector2 = EnemySenses.best_cover(e, target, boxes, pit.claims(e))
		if spot != Vector2.INF:
			motion = S.COVER
			_set_goal(spot, map)
			return
	if e.sees and not e.token and e.arch.flanks:
		motion = S.FLANK
		_set_goal(EnemyBrain.flank_spot(e, pit), map)
	elif e.sees:
		_strafe = true
		_destination = Vector2.INF
	else:
		_set_goal(target, map)


func _set_goal(goal: Vector2, map: GuardRouteMap) -> void:
	agent.goal = goal.clamp(map.region().position, map.region().end)
	if agent.goal.floor() == _destination.floor():
		return
	_destination = agent.goal
	_next = 0
	_route.clear()
	if not map.clear_line(agent.pos, agent.goal):
		_route = map.route(agent.pos, agent.goal)


func _walk() -> Vector2:
	if _next < _route.size() and agent.pos.distance_to(_route[_next]) < 0.4:
		_next += 1
	if _next < _route.size():
		return agent.pos.direction_to(_route[_next]) * agent.arch.speed_mps
	return EnemyMotor.arrive(agent, agent.goal, agent.arch.speed_mps)
