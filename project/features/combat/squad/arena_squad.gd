class_name ArenaSquad
extends RefCounted
## Mirrors the living members of the current pit or street wave in fighter ID order. Each hostile
## checks sight at most twice and scans its living neighbours once per tick. The wave shares its
## planning slots. GuardBrain owns every real projectile.

const ROUTES_PER_TICK: int = 2

var mounts: FoeMounts = FoeMounts.new()
var moves: MoveTable = MoveTable.shipped()
var carry: MoveCarry
var shield_cover: FoeShieldCover = FoeShieldCover.new()
var rockets: FoeRocketFlight = FoeRocketFlight.new()
var pit: EnemyPit
var minds: Dictionary[int, SquadMind] = {}
var plant_no_separation: bool = false
var _map: GuardRouteMap
var _wave: Dictionary[Fighter, bool] = {}
var _fallen: float = 0.0


func _init(map: GuardRouteMap) -> void:
	pit = EnemyPit.new(EnemyRoster.shipped(EnemyRoster.TABLE, true), null)
	set_route_map(map)


func set_route_map(map: GuardRouteMap) -> void:
	_map = map
	pit.bounds = map.region().grow(-GuardRouteMap.WALL_MARGIN_M)
	for h: Fighter in _wave:
		h.pursuit = GuardPursuit.new(map)
	for mind: SquadMind in minds.values():
		mind.forget_route()


## Only the encounter spawner enrolls guards. Station spawns retain their own guard behaviour.
func spawn_member(arena: CombatArena, at: Vector2, id: StringName = &"") -> Fighter:
	var h: Fighter = arena.spawn_guard(at)
	if arena.guard_map != _map:
		h.pursuit = GuardPursuit.new(_map)
	_wave[h] = true
	var a: EnemyRoster.Archetype = pit.roster.archetype(id)
	h.archetype = a.id
	h.machine = a.body == &"robot"
	if h.machine:
		h.max_hp = a.hp
		h.hp = a.hp
	h.weapon = &"" if a.weapon.melee else a.production_weapon
	if a.explicit_spawn and not a.weapon.melee:
		h.weapon = a.weapon.id
	if a.weapon.id in [&"rocket", &"turret_gun", &"war_cannon"]:
		FoeRocket.enable_lines(arena, pit.roster)
	if a.explicit_spawn and h.machine:
		h.body_class = &"robot"
	if a.id == &"sentry_turret":
		mounts.pin(h)
	elif a.id == &"shield_robot":
		shield_cover.carriers.append(h)
	h.cooldown = mini(h.cooldown, arena.tuning.weapon(a.production_weapon).cooldown_ticks)
	return h


func clear_wave() -> void:
	shield_cover.carriers.clear()
	mounts.anchors.clear()
	_wave.clear()
	minds.clear()
	pit.agents.clear()


func owns(h: Fighter) -> bool:
	return _wave.has(h)


## A bolt can land on a newly spawned member before the first squad assignment.
func mind_for(h: Fighter) -> SquadMind:
	if not minds.has(h.id):
		minds[h.id] = SquadMind.new(h, pit.roster.archetype(h.archetype))
	return minds[h.id]


## Wave members step in ID order before station navigation can spend their route budget.
## Everyone outside the wave keeps the arena's original step order.
func assign(arena: CombatArena) -> Array[Fighter]:
	rockets.collect(arena)
	pit.tick = arena.tick
	pit.rivet_pos = arena.rivet.pos
	pit.rivet_radius = arena.rivet.radius_m
	pit.agents.clear()
	var shooters: Array[EnemyAgent] = []
	var active: Dictionary[int, SquadMind] = {}
	var ordered: Array[Fighter] = []
	var others: Array[Fighter] = []
	for h: Fighter in arena.hostiles:
		if owns(h) and h.alive() and not h.brain_owned and h.kind == Fighter.Kind.GUARD:
			ordered.append(h)
		else:
			others.append(h)
	ordered.sort_custom(func(a: Fighter, b: Fighter) -> bool: return a.id < b.id)
	for h: Fighter in ordered:
		var mind: SquadMind = mind_for(h)
		active[h.id] = mind
		var fx: FighterFx = arena.areas.effect(h) if arena.areas != null else null
		if fx != null and mind.walker == null and fx.holds():
			mind.agent.token = false
			mind.paused_rounds = 0
			h.swing_left = 0
			continue
		mind.agent.pos = h.pos
		pit.agents.append(mind.agent)
		if arena.tick >= mind.stun_until and mind.available(h, arena):
			shooters.append(mind.agent)
		else:
			mind.agent.token = false
	minds = active
	_schedule()
	EnemySquad.assign(shooters, pit.rivet_pos, pit.roster)
	_update_morale()
	ordered.append_array(others)
	return ordered


## Agents are already sorted by id. Drain last tick's requests before admitting new ones.
func _schedule() -> void:
	var slots: int = ceili(float(pit.agents.size()) / SquadMind.PLAN_TICKS)
	var cover_ceiling: int = _map.cover_searches + slots
	var route_ceiling: int = _map.searches + ROUTES_PER_TICK
	for e: EnemyAgent in pit.agents:
		var mind: SquadMind = minds[e.id]
		mind.cover_ceiling = cover_ceiling
		mind.search_ceiling = route_ceiling
		mind.retry_route(_map)


func _update_morale() -> void:
	var lost: int = 0
	for h: Fighter in _wave:
		lost += int(not h.alive())
	_fallen = float(lost) / _wave.size() if not _wave.is_empty() else 0.0


func step(h: Fighter, arena: CombatArena, rng: RandomNumberGenerator) -> Shot:
	var mind: SquadMind = minds[h.id]
	if arena.tick < mind.stun_until:
		return null
	var e: EnemyAgent = mind.agent
	e.pos = h.pos
	e.sees = _map.sight_line(e.pos, pit.rivet_pos)
	if mind.walker != null:
		return mind.walker.step(mind, h, arena, _map)
	if mind.turret != null:
		return mind.turret.step(e, h, arena)
	if mind.rocket != null:
		return mind.rocket.step(mind, h, arena, self, _map)
	if mind.shield != null:
		mind.shield.step(mind, h, arena, _map)
		return null
	var desired: Vector2 = shield_cover.velocity(mind, self, _map, _fallen)
	if h.swing_left > 0:
		desired = Vector2.ZERO
	if not plant_no_separation and not mind.mobile_goal.is_finite():
		var gap: float = EnemyMotor.SEPARATION_GAP_M if e.melee() else SquadMind.SPACING_GAP_M
		desired += EnemyMotor.separation(e, pit.agents, pit, gap, true)
	EnemyMotor.steer(e, desired, pit.rivet_pos, pit)
	h.pos = e.pos
	h.facing = e.facing
	var shot: Shot
	if e.melee():
		mind.swing(h, arena, _map)
	else:
		shot = _ranged(mind, h, arena, rng)
	return shot


func _ranged(mind: SquadMind, h: Fighter, arena: CombatArena, rng: RandomNumberGenerator) -> Shot:
	var e: EnemyAgent = mind.agent
	if e.arch.explicit_spawn:
		return FoeAttacks.trigger(e, h, arena)
	var ready: bool = e.token and e.has_shot_at(pit.rivet_pos)
	if not ready or not _map.sight_line(h.pos, pit.rivet_pos):
		if h.burst_left > 0:
			mind.paused_rounds = h.burst_left
		h.burst_left = 0
		return null
	if mind.paused_rounds > 0:
		h.burst_left = mind.paused_rounds
		mind.paused_rounds = 0
	var left: int = h.burst_left
	var shot: Shot = GuardBrain.trigger(h, arena.tuning, rng)
	if shot != null:
		e.shot_tick = pit.tick
	if shot != null or left > 0:
		e.state = EnemyAgent.State.FIRE
	elif h.burst_left > 0:
		e.state = EnemyAgent.State.WINDUP
	elif mind.motion == EnemyAgent.State.ENGAGE:
		e.state = EnemyAgent.State.RECOVER
	return shot
