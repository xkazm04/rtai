class_name SquadMind
extends RefCounted

const S := EnemyAgent.State
const PLAN_TICKS: int = 12
const BLIND_LIMIT: int = 6 * SimClock.TICK_RATE
const COVER_RADIUS_M: float = 8.0
const SPACING_GAP_M: float = 1.5

var walker: FoeWalker
var turret: FoeTurret
var shield: FoeShield
var mobile_goal: Vector2 = Vector2.INF
var rocket: FoeRocket
var agent: EnemyAgent
## Rounds remaining when a token, range or sight interrupted the production trigger.
var paused_rounds: int = 0
var cover_ceiling: int = 0
var plan_pending: bool = false
var route_pending: bool = false
var search_ceiling: int = 0
var motion: EnemyAgent.State = S.ENGAGE
## The hiding spot a token holder left, retained through its timed peek and return.
var _hide: Vector2 = Vector2.INF
var _peek: int = -1
var _return_until: int = -1
var _blind: int = 0
var _route: PackedVector2Array = PackedVector2Array()
var _next: int = 0
var _destination: Vector2 = Vector2.INF
var _strafe: bool = false
var _plan_offset: int = 0


func _init(h: Fighter, arch: EnemyRoster.Archetype) -> void:
	walker = FoeWalker.new() if arch.id == &"war_machine" else null
	shield = FoeShield.new() if arch.id == &"shield_robot" else null
	turret = FoeTurret.new() if arch.weapon.id == &"turret_gun" else null
	rocket = FoeRocket.new() if arch.weapon.id == &"rocket" else null
	agent = EnemyAgent.make(h.id, arch, h.pos)
	agent.facing = h.facing
	agent.enter(S.ENGAGE)


func available(h: Fighter, arena: CombatArena) -> bool:
	if agent.arch.explicit_spawn and not agent.melee():
		return h.cooldown <= 1
	var w: CombatTuning.Weapon = arena.tuning.weapon(agent.arch.production_weapon)
	return arena.tick >= _return_until and h.cooldown <= w.cooldown_ticks and agent.cooldown == 0


func destination() -> Vector2:
	if mobile_goal.is_finite():
		return mobile_goal
	return agent.goal if _destination.is_finite() else Vector2.INF


func velocity(pit: EnemyPit, map: GuardRouteMap, fallen: float) -> Vector2:
	var e: EnemyAgent = agent
	_blind = 0 if e.sees else _blind + 1
	if fallen > e.arch.morale and EnemyBrain.break_morale(e, fallen, pit.roster.panic_ticks):
		motion = S.PANIC
	if motion == S.PANIC:
		e.timer -= 1
		if e.timer > 0:
			if e.timer == pit.roster.panic_ticks - 1 or (pit.tick + e.id) % PLAN_TICKS == 0:
				_set_goal(e.pos + pit.rivet_pos.direction_to(e.pos) * 4.0, map)
			return _walk()
		motion = S.ENGAGE
		_destination = Vector2.INF
	_update_peek(pit.tick, pit.rivet_pos)
	if plan_pending or (pit.tick + e.id - _plan_offset) % PLAN_TICKS == 0:
		var overdue: bool = plan_pending
		_plan(pit, map)
		# Keep a granted slot so the same pair does not collide every twelve ticks.
		if overdue and not plan_pending:
			_plan_offset = (pit.tick + e.id) % PLAN_TICKS
	e.state = motion
	if _strafe:
		var ring: float = (
			e.arch.preferred_m
			if e.token
			else lerpf(e.arch.attack_m, e.arch.preferred_m, e.arch.aggression)
		)
		return EnemyBrain.strafe(e, pit.rivet_pos, ring)
	return _walk()


## Count the peek while the holder can engage. Distant sight alone can spend the entire peek
## walking into range, leaving the guard cycling between the same cover and approach.
func _update_peek(tick: int, target: Vector2) -> void:
	if tick < _return_until:
		if agent.pos.distance_to(_hide) < 0.45:
			_return_until = mini(_return_until, tick + PLAN_TICKS)
		return
	if not agent.token:
		_peek = -1
		return
	if _peek < 0 and motion == S.COVER:
		_peek = agent.arch.peek_ticks
	if _peek < 0 or not agent.has_shot_at(target):
		return
	_peek -= 1
	if _peek <= 0:
		agent.token = false
		_return_until = tick + BLIND_LIMIT
		_peek = -1


func _plan(pit: EnemyPit, map: GuardRouteMap) -> void:
	var e: EnemyAgent = agent
	var target: Vector2 = pit.rivet_pos
	var slot: int = (pit.tick + e.id) / PLAN_TICKS
	var draw: float = float(hash(Vector2i(e.id, slot)) & 0xffff) / 65536.0
	var blind_limit: float = BLIND_LIMIT * lerpf(1.0, 0.25, e.arch.aggression)
	var seek_cover: bool = not e.token and _blind <= blind_limit and draw < e.arch.cover_bias
	plan_pending = pit.tick >= _return_until and seek_cover and map.cover_searches >= cover_ceiling
	if plan_pending:
		return
	_strafe = false
	motion = S.ENGAGE
	if pit.tick < _return_until:
		motion = S.COVER
		_set_goal(_hide, map)
		return
	if seek_cover:
		var boxes: Array[Rect2] = map.boxes_near(e.pos, COVER_RADIUS_M)
		var spot: Vector2 = EnemySenses.best_cover(e, target, boxes, pit.claims(e))
		if spot != Vector2.INF:
			motion = S.COVER
			_hide = spot
			_set_goal(spot, map)
			return
	if (
		not e.melee()
		and not e.token
		and e.arch.flanks
		and pit.holder_centroid() != Vector2.INF
		and _blind <= blind_limit
	):
		motion = S.FLANK
		_set_goal(EnemyBrain.flank_spot(e, pit), map)
	elif e.sees:
		_strafe = true
		_destination = Vector2.INF
		route_pending = false
	else:
		_set_goal(target, map, true)


func _set_goal(goal: Vector2, map: GuardRouteMap, known_blocked: bool = false) -> void:
	var bounds: Rect2 = map.region()
	agent.goal = goal.clamp(bounds.position, bounds.end)
	if agent.goal.floor() == _destination.floor():
		return
	_destination = agent.goal
	route_pending = (
		(known_blocked and agent.goal == goal) or not map.clear_line(agent.pos, agent.goal)
	)
	if not route_pending:
		_route.clear()
	retry_route(map)


func retry_route(map: GuardRouteMap) -> void:
	if route_pending and map.searches < search_ceiling:
		_next = 0
		_route = map.route(agent.pos, agent.goal)
		route_pending = false


func _walk() -> Vector2:
	if _next < _route.size() and agent.pos.distance_to(_route[_next]) < 0.4:
		_next += 1
	if _next < _route.size():
		return agent.pos.direction_to(_route[_next]) * agent.arch.speed_mps
	return EnemyMotor.arrive(agent, agent.goal, agent.arch.speed_mps)


func swing(h: Fighter, arena: CombatArena, map: GuardRouteMap) -> void:
	FoeAttacks.swing(self, h, arena, map)


func forget_route() -> void:
	if rocket != null:
		rocket.forget_site()
	mobile_goal = Vector2.INF
	_route.clear()
	_next = 0
	_destination = Vector2.INF
	_hide = Vector2.INF
	_return_until = -1
	_peek = -1
	_strafe = false
	_blind = 0
	agent.goal = agent.pos
	route_pending = false
	plan_pending = true
