class_name ArenaSquad
extends RefCounted
## Mirrors only active combatants. Token assignment and all motor neighbours use fighter ID
## order. Each hostile checks sight at most twice and scans the living neighbours once per tick.
## The staggered goal-search budget is in SquadMind. GuardBrain owns every real projectile.

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
			mind = SquadMind.new(h, pit.roster.archetype(&"contractor"))
		active[h.id] = mind
		var fx: FighterFx = arena.areas.effect(h) if arena.areas != null else null
		if fx != null and fx.holds():
			mind.agent.token = false
			mind.paused_rounds = 0
			continue
		mind.agent.pos = h.pos
		pit.agents.append(mind.agent)
		# Sparring partners with their trigger pinned by a station still steer and separate.
		if h.cooldown <= arena.tuning.weapon(h.weapon).cooldown_ticks:
			shooters.append(mind.agent)
		else:
			mind.agent.token = false
	minds = active
	EnemySquad.assign(shooters, pit.rivet_pos, pit.roster)
	_update_morale()
	return ordered


func _update_morale() -> void:
	var lost: int = 0
	for h: Fighter in _wave:
		lost += int(not h.alive())
	_fallen = float(lost) / _wave.size() if not _wave.is_empty() else 0.0


func step(h: Fighter, arena: CombatArena, rng: RandomNumberGenerator) -> Shot:
	var mind: SquadMind = minds[h.id]
	var e: EnemyAgent = mind.agent
	e.pos = h.pos
	e.sees = _map.clear_line(e.pos, pit.rivet_pos)
	var desired: Vector2 = mind.velocity(pit, _map, _fallen if _wave_ids.has(h.id) else 0.0)
	if not plant_no_separation:
		desired += EnemyMotor.separation(e, pit.agents, pit, SquadMind.SPACING_GAP_M, true)
	EnemyMotor.steer(e, desired, pit.rivet_pos, pit)
	h.pos = e.pos
	h.facing = e.facing
	var ready: bool = e.token and e.sees and h.pos.distance_to(pit.rivet_pos) <= e.arch.attack_m
	if not ready or not _map.clear_line(h.pos, pit.rivet_pos):
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
