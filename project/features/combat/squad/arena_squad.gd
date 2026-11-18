class_name ArenaSquad
extends RefCounted
## Mirrors only active combatants. Token assignment and all motor neighbours use fighter ID
## order. Each hostile checks sight at most twice and scans the living neighbours once per tick.
## Planning slots are shared across living guards. GuardBrain owns every real projectile.

const ROUTES_PER_TICK: int = 2

var pit: EnemyPit
var minds: Dictionary[int, SquadMind] = {}
var plant_no_separation: bool = false
var _map: GuardRouteMap
var _wave: Array[Fighter] = []
var _wave_ids: Dictionary[int, bool] = {}
var _fallen: float = 0.0


func _init(map: GuardRouteMap) -> void:
	_map = map
	pit = EnemyPit.new(EnemyRoster.shipped(EnemyRoster.TABLE, true), null)
	pit.bounds = map.region().grow(-GuardRouteMap.WALL_MARGIN_M)


## Apply combat stats once, at spawn, before views or shots can observe this fighter.
func equip(h: Fighter, id: StringName, tuning: CombatTuning) -> void:
	var a: EnemyRoster.Archetype = pit.roster.archetype(id)
	h.archetype = a.id
	h.machine = a.body == &"robot"
	if h.machine:
		h.max_hp = a.hp
		h.hp = a.hp
	h.weapon = &"" if a.weapon.melee else a.production_weapon
	h.cooldown = mini(h.cooldown, tuning.weapon(a.production_weapon).cooldown_ticks)


func begin_wave(standing: Array[Fighter]) -> void:
	_wave = standing.duplicate()
	_wave_ids.clear()
	for h: Fighter in _wave:
		_wave_ids[h.id] = true


func assign(arena: CombatArena) -> Array[Fighter]:
	pit.tick = arena.tick
	pit.rivet_pos = arena.rivet.pos
	pit.rivet_radius = arena.rivet.radius_m
	pit.agents.clear()
	var shooters: Array[EnemyAgent] = []
	var active: Dictionary[int, SquadMind] = {}
	var ordered: Array[Fighter] = []
	for h: Fighter in arena.hostiles:
		if h.alive():
			ordered.append(h)
	ordered.sort_custom(func(a: Fighter, b: Fighter) -> bool: return a.id < b.id)
	for h: Fighter in ordered:
		if h.brain_owned or h.kind != Fighter.Kind.GUARD:
			continue
		var mind: SquadMind = minds.get(h.id)
		if mind == null:
			mind = SquadMind.new(h, pit.roster.archetype(h.archetype))
		active[h.id] = mind
		var fx: FighterFx = arena.areas.effect(h) if arena.areas != null else null
		if fx != null and fx.holds():
			mind.agent.token = false
			mind.paused_rounds = 0
			h.swing_left = 0
			continue
		mind.agent.pos = h.pos
		pit.agents.append(mind.agent)
		# Sparring partners with their trigger pinned by a station still steer and separate.
		if mind.available(h, arena):
			shooters.append(mind.agent)
		else:
			mind.agent.token = false
	minds = active
	_schedule()
	EnemySquad.assign(shooters, pit.rivet_pos, pit.roster)
	_update_morale()
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
	var e: EnemyAgent = mind.agent
	e.pos = h.pos
	e.sees = _map.sight_line(e.pos, pit.rivet_pos)
	var desired: Vector2 = mind.velocity(pit, _map, _fallen if _wave_ids.has(h.id) else 0.0)
	if h.swing_left > 0:
		desired = Vector2.ZERO
	if not plant_no_separation:
		var gap: float = EnemyMotor.SEPARATION_GAP_M if e.melee() else SquadMind.SPACING_GAP_M
		desired += EnemyMotor.separation(e, pit.agents, pit, gap, true)
	EnemyMotor.steer(e, desired, pit.rivet_pos, pit)
	h.pos = e.pos
	h.facing = e.facing
	if e.melee():
		mind.swing(h, arena, _map)
		return null
	return _ranged(mind, h, arena, rng)


func _ranged(mind: SquadMind, h: Fighter, arena: CombatArena, rng: RandomNumberGenerator) -> Shot:
	var e: EnemyAgent = mind.agent
	var ready: bool = e.token and e.sees and h.pos.distance_to(pit.rivet_pos) <= e.arch.attack_m
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
