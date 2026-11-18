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
## The hiding spot a token holder left, retained through its timed peek and return.
var _hide: Vector2 = Vector2.INF
var _peek: int = -1
var _return_until: int = -1
var _blind: int = 0
var _route: PackedVector2Array = PackedVector2Array()
var _next: int = 0
var _destination: Vector2 = Vector2.INF
var _strafe: bool = false


func _init(h: Fighter, arch: EnemyRoster.Archetype) -> void:
	agent = EnemyAgent.make(h.id, arch, h.pos)
	agent.facing = h.facing
	agent.enter(S.ENGAGE)


func available(h: Fighter, arena: CombatArena) -> bool:
	var w: CombatTuning.Weapon = arena.tuning.weapon(agent.arch.production_weapon)
	return arena.tick >= _return_until and h.cooldown <= w.cooldown_ticks and agent.cooldown == 0


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
	_update_peek(pit.tick)
	if (pit.tick + e.id) % PLAN_TICKS == 0:
		_plan(pit, map)
	e.state = motion
	if _strafe:
		var ring: float = (
			e.arch.preferred_m
			if e.token
			else lerpf(e.arch.attack_m, e.arch.preferred_m, e.arch.aggression)
		)
		return EnemyBrain.strafe(e, pit.rivet_pos, ring)
	return _walk()


## Count exposed ticks only after a cover holder has sight. Release its token on retreat.
func _update_peek(tick: int) -> void:
	if tick < _return_until:
		if agent.pos.distance_to(_hide) < 0.45:
			_return_until = mini(_return_until, tick + PLAN_TICKS)
		return
	if not agent.token:
		_peek = -1
		return
	if _peek < 0 and motion == S.COVER:
		_peek = agent.arch.peek_ticks
	if _peek < 0 or not agent.sees:
		return
	_peek -= 1
	if _peek <= 0:
		agent.token = false
		_return_until = tick + BLIND_LIMIT
		_peek = -1


func _plan(pit: EnemyPit, map: GuardRouteMap) -> void:
	var e: EnemyAgent = agent
	var target: Vector2 = pit.rivet_pos
	_strafe = false
	motion = S.ENGAGE
	if pit.tick < _return_until:
		motion = S.COVER
		_set_goal(_hide, map)
		return
	var slot: int = (pit.tick + e.id) / PLAN_TICKS
	var draw: float = float(hash(Vector2i(e.id, slot)) & 0xffff) / 65536.0
	var blind_limit: float = BLIND_LIMIT * lerpf(1.0, 0.25, e.arch.aggression)
	if not e.token and _blind <= blind_limit and draw < e.arch.cover_bias:
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


## Plant for the row's tell, then resolve the locked arc against Rivet's current position.
func swing(h: Fighter, arena: CombatArena, map: GuardRouteMap) -> void:
	var e: EnemyAgent = agent
	e.cooldown = maxi(0, e.cooldown - 1)
	if not e.token or motion == S.PANIC:
		h.swing_left = 0
		return
	var to: Vector2 = arena.rivet.pos - h.pos
	var reach: float = e.arch.weapon.reach_m + arena.rivet.radius_m
	if h.swing_left == 0:
		if not e.sees or to.length() > reach or e.cooldown > 0:
			return
		h.swing_tick = arena.tick
		h.swing_left = e.arch.telegraph_ticks
		e.aim = to.normalized()
		arena.announce_tell(e.arch.weapon.id)
	else:
		h.swing_left -= 1
	e.state = S.WINDUP
	h.facing = e.aim
	if h.swing_left > 0:
		return
	e.state = S.FIRE
	e.cooldown = e.arch.weapon.cooldown_ticks
	e.token = false
	if to.length() <= reach and e.aim.dot(to.normalized()) >= EnemyPit.MELEE_ARC_COS:
		if map.clear_line(h.pos, arena.rivet.pos):
			arena.hit_dir = e.aim
			arena.hit_at = arena.rivet.pos
			arena.damage(arena.rivet, e.arch.production_damage, h.id, e.arch.weapon.id, &"melee")
