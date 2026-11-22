class_name FoeRocket
extends RefCounted
## Per-trooper firing cycle. Only the squad owns the rounds after launch.

const MIN_RANGE_M: float = 8.0
const NEW_SITE_M: float = 3.0
const SITE_ANGLES: Array[float] = [0.36, -0.36, 0.72, -0.72, 1.3, -1.3]

var locked_point: Vector2 = Vector2.INF
var last_launch: Vector2 = Vector2.INF
var _site: Vector2 = Vector2.INF
var _shots_here: int = 0
var _site_origin: Vector2 = Vector2.INF
var _observed_tick: int = -2
var _observed_target: Vector2


func forget_site() -> void:
	_site = Vector2.INF


## The bare arena's FX draws tells through GuardTell. Station guards keep their usual trigger.
class AimLines:
	extends GuardTell

	func step(
		g: Fighter, target: Vector2, tuning: CombatTuning, rng: RandomNumberGenerator
	) -> Shot:
		return GuardBrain.step(g, target, tuning, rng)


static func enable_lines(arena: CombatArena, roster: EnemyRoster) -> void:
	if arena.guard_tell == null:
		arena.guard_tell = AimLines.new()
		arena.guard_tell.lock_ticks = roster.aim_lock_ticks


func step(
	mind: SquadMind, h: Fighter, arena: CombatArena, squad: ArenaSquad, map: GuardRouteMap
) -> Shot:
	var e: EnemyAgent = mind.agent
	var pit: EnemyPit = squad.pit
	h.cooldown = maxi(0, h.cooldown - 1)
	if h.tell_left > 0:
		return _windup(e, h, arena, squad, map)
	if needs_relocation(e, pit.rivet_pos, e.sees):
		_reposition(e, pit, map)
	elif not e.has_shot_at(pit.rivet_pos):
		EnemyMotor.steer(e, mind.velocity(pit, map, 0.0), pit.rivet_pos, pit)
	elif e.token and h.cooldown == 0 and squad.rockets.count() < pit.roster.max_shooters:
		e.vel = Vector2.ZERO
		h.tell_left = e.arch.telegraph_ticks
		forget_site()
		_track(e, pit)
		e.aim = h.pos.direction_to(locked_point)
		e.facing = e.aim
		e.enter(EnemyAgent.State.WINDUP, h.tell_left)
		arena.announce_tell(e.arch.weapon.id)
	else:
		e.vel = Vector2.ZERO
		e.enter(EnemyAgent.State.ENGAGE)
	h.pos = e.pos
	h.facing = e.facing
	return null


func _windup(
	e: EnemyAgent, h: Fighter, arena: CombatArena, squad: ArenaSquad, map: GuardRouteMap
) -> Shot:
	var tracking: bool = not arena.guard_tell.locked(h)
	if (
		not e.token
		or (tracking and (not e.sees or e.pos.distance_to(arena.rivet.pos) < MIN_RANGE_M))
	):
		h.tell_left = 0
		e.enter(EnemyAgent.State.ENGAGE)
		return null
	if tracking:
		_track(e, squad.pit)
	e.aim = e.pos.direction_to(locked_point)
	h.facing = e.aim
	e.facing = e.aim
	h.tell_left -= 1
	e.timer = h.tell_left
	e.state_ticks += 1
	if h.tell_left > 0:
		return null
	e.token = false
	if squad.rockets.count() >= squad.pit.roster.max_shooters:
		e.enter(EnemyAgent.State.ENGAGE)
		return null
	e.enter(EnemyAgent.State.FIRE)
	e.shot_tick = arena.tick
	h.cooldown = e.arch.weapon.cooldown_ticks
	if h.pos.distance_to(_site_origin) >= NEW_SITE_M:
		_site_origin = h.pos
		_shots_here = 0
	_shots_here += 1
	last_launch = h.pos
	if _shots_here >= maxi(1, e.arch.weapon.relocate_after_shots):
		_site = _firing_site(e, squad.pit, map)
	return squad.rockets.launch(h, e.arch.weapon, locked_point, map)


func needs_relocation(e: EnemyAgent, target: Vector2, visible: bool) -> bool:
	if e.pos.distance_to(target) < MIN_RANGE_M:
		return true
	var limit: int = e.arch.weapon.relocate_after_shots
	if limit == 0:
		return e.pos.distance_to(last_launch) < NEW_SITE_M or _site.is_finite()
	return not visible or (_shots_here >= limit and e.pos.distance_to(_site_origin) < NEW_SITE_M)


## Only consecutive visible samples contribute velocity. The last tracking sample owns the lock.
func _track(e: EnemyAgent, pit: EnemyPit) -> void:
	var velocity: Vector2 = Vector2.ZERO
	if pit.tick == _observed_tick + 1:
		velocity = (pit.rivet_pos - _observed_target) * SimClock.TICK_RATE
	_observed_tick = pit.tick
	_observed_target = pit.rivet_pos
	var flight: float = e.pos.distance_to(pit.rivet_pos) / maxf(1.0, e.arch.weapon.speed_mps)
	var seconds: float = pit.roster.aim_lock_ticks * SimClock.TICK_DT + flight
	locked_point = EnemyBrain.led_offset(pit.rivet_pos, velocity, seconds, e.arch.weapon.aim_lead)


func _reposition(e: EnemyAgent, pit: EnemyPit, map: GuardRouteMap) -> void:
	e.enter(EnemyAgent.State.ENGAGE)
	if (
		not _site.is_finite()
		or _site.distance_to(pit.rivet_pos) < MIN_RANGE_M
		or not map.clear_line(e.pos, _site)
	):
		_site = _firing_site(e, pit, map)
	if not _site.is_finite():
		e.vel = Vector2.ZERO
		return
	var walk: Vector2 = EnemyMotor.arrive(e, _site, e.arch.speed_mps)
	EnemyMotor.steer(e, walk, pit.rivet_pos, pit)
	if e.pos.distance_to(_site) < 0.4:
		_site = Vector2.INF


func _firing_site(e: EnemyAgent, pit: EnemyPit, map: GuardRouteMap) -> Vector2:
	var away: Vector2 = pit.rivet_pos.direction_to(e.pos)
	if away == Vector2.ZERO:
		away = -e.facing
	var fallback: Vector2 = Vector2.INF
	for angle: float in SITE_ANGLES:
		var radial: Vector2 = away.rotated(angle * e.strafe_sign) * e.arch.preferred_m
		var site: Vector2 = (pit.rivet_pos + radial).clamp(pit.bounds.position, pit.bounds.end)
		if last_launch.distance_to(site) < NEW_SITE_M + 0.4 or not map.clear_line(e.pos, site):
			continue
		if map.clear_line(site, pit.rivet_pos):
			return site
		if not fallback.is_finite():
			fallback = site
	return fallback
