extends RefCounted
## n31 foes: reads every living gauntlet wave member after each tick and tallies how long it waits
## to shoot. Read-only: clear_line (not sight_line, which bumps a counter), no RNG, no writes.

const Wave = preload("res://dev/foes_n31/waiting_wave.gd")
const Engaged = preload("res://dev/foes_n31/waiting_engaged.gd")
const SCHEMA: String = "gtai.foes-waiting/1"


class Foe:
	extends RefCounted
	var id: int = 0
	var wave: int = 0
	var arch: StringName = &""
	var melee: bool = false
	var first_clear_in: int = -1
	var first_clear_any: int = -1
	var first_shot: int = -1
	var last_shot: int = -1
	var window: int = 0
	var last_pos: Vector2 = Vector2.INF
	var speed: float = 0.0
	var done: bool = false


var _run: GauntletRun
var _foes: Dictionary[int, Foe] = {}
var _waves: Dictionary[int, Wave] = {}
## Wave number -> archetype -> members already matched to that row's `enemies` count.
var _claimed: Dictionary[int, Dictionary] = {}
var _shots: int = 0
var _split: bool = false


func _init(run: GauntletRun) -> void:
	_run = run


func observe(stage: ArenaStage) -> void:
	var arena: CombatArena = stage.arena
	var squad: ArenaSquad = arena.squad_ai
	if squad == null:
		return
	_shots = stage.shots_fired
	_split = Engaged.split_of(squad)
	var alive: Dictionary[int, int] = {}
	var ranged: Dictionary[int, int] = {}
	var pushing: Dictionary[int, int] = {}
	for h: Fighter in arena.hostiles:
		if not squad.owns(h):
			continue
		var foe: Foe = _foes.get(h.id, null)
		if foe == null:
			foe = _enroll(h, stage)
		if foe.done:
			continue
		if not h.alive():
			_retire(foe)
			continue
		alive[foe.wave] = alive.get(foe.wave, 0) + 1
		ranged[foe.wave] = ranged.get(foe.wave, 0) + int(not foe.melee)
		var mind: SquadMind = squad.minds[h.id] if squad.minds.has(h.id) else null
		var push: bool = _sample(foe, h, arena, mind)
		pushing[foe.wave] = pushing.get(foe.wave, 0) + int(push and not foe.melee)
	for n: int in _waves:
		var living: int = alive.get(n, 0)
		var shooters: int = ranged.get(n, 0)
		var pushers: int = pushing.get(n, 0)
		_waves[n].close_tick(arena.tick, living, shooters, stage.shots_fired)
		_waves[n].close_press(living, shooters, pushers)


func to_dict() -> Dictionary:
	for foe: Foe in _foes.values():
		if not foe.done:
			_retire(foe)
	var rows: Array = []
	var death_wave: int = -1 if _run.alive else _run.death_wave
	for row: Dictionary in _run.waves:
		var n: int = row.get("n", 0)
		if _waves.has(n):
			_waves[n].finish(_shots)
			rows.append(_waves[n].to_dict(row, death_wave))
	return {
		"schema": SCHEMA,
		"seed": _run.seed,
		"profile": String(_run.profile),
		"controls": String(_run.controls),
		"wave_reached": _run.wave,
		"death_wave": death_wave,
		"waves": rows,
	}


## Tallies one living member's tick; true when it is engaged or advancing (pressing share).
func _sample(foe: Foe, h: Fighter, arena: CombatArena, mind: SquadMind) -> bool:
	var wave: Wave = _waves[foe.wave]
	var k: Wave.Kind = wave.kind(foe.arch)
	var tick: int = arena.tick
	var dist: float = h.pos.distance_to(arena.rivet.pos)
	var clear: bool = arena.guard_map == null or arena.guard_map.clear_line(h.pos, arena.rivet.pos)
	var shot_at: int = mind.agent.shot_tick if mind != null else -1
	var fired: bool = (h.swing_tick if foe.melee else shot_at) == tick
	var state: EnemyAgent.State = mind.agent.state if mind != null else EnemyAgent.State.PATROL
	var busy: bool = Engaged.strict_busy(fired, h.burst_left, state)
	foe.last_shot = tick if fired else foe.last_shot
	var settling: bool = mind != null and Engaged.settling(mind.agent, tick, _split)
	var engaged: bool = Engaged.engaged(tick, foe.last_shot, foe.window, busy, settling)
	var step: Vector2 = h.pos - foe.last_pos if foe.last_pos.is_finite() else Vector2.ZERO
	foe.last_pos = h.pos
	foe.speed = step.length() / SimClock.TICK_DT
	k.alive_ticks += 1
	k.token_ticks += int(mind != null and mind.agent.token)
	if clear:
		_clear(foe, k, tick, busy, engaged)
	if clear and dist <= k.attack_m:
		_clear_in(foe, k, tick, busy, engaged)
	if fired:
		_fired(foe, k, wave, tick, dist)
	return engaged or (mind != null and Engaged.pushing(mind, step, arena, _split))


func _clear(foe: Foe, k: Wave.Kind, tick: int, busy: bool, engaged: bool) -> void:
	k.clear_ticks += 1
	k.clear_idle_ticks += int(not busy)
	k.clear_loose_ticks += int(not engaged)
	k.idle_speed_sum += 0.0 if busy else foe.speed
	if foe.first_clear_any < 0:
		foe.first_clear_any = tick


func _clear_in(foe: Foe, k: Wave.Kind, tick: int, busy: bool, engaged: bool) -> void:
	k.clear_in_ticks += 1
	k.clear_in_idle_ticks += int(not busy)
	k.clear_in_loose_ticks += int(not engaged)
	if foe.first_clear_in < 0:
		foe.first_clear_in = tick


func _fired(foe: Foe, k: Wave.Kind, wave: Wave, tick: int, dist: float) -> void:
	k.rounds += 1
	k.shot_dist_m.append(Wave.Kind.r2(dist))
	if not foe.melee:
		wave.note_fired(tick, foe.id)
	if foe.first_shot >= 0:
		return
	foe.first_shot = tick
	if foe.first_clear_in >= 0:
		k.react_s.append(Wave.Kind.r2((tick - foe.first_clear_in) * SimClock.TICK_DT))
	else:
		k.fired_before_clear += 1
	if foe.first_clear_any >= 0:
		k.react_any_s.append(Wave.Kind.r2((tick - foe.first_clear_any) * SimClock.TICK_DT))


## A new member belongs to the oldest wave row whose `enemies` count for its archetype is unmatched.
func _enroll(h: Fighter, stage: ArenaStage) -> Foe:
	var foe: Foe = Foe.new()
	foe.id = h.id
	foe.arch = h.archetype
	foe.wave = _run.wave
	for row: Dictionary in _run.waves:
		var n: int = row.get("n", 0)
		var counts: Dictionary = row.get("enemies", {})
		var taken: Dictionary = _claimed.get(n, {})
		var have: int = counts.get(String(h.archetype), 0)
		if taken.get(h.archetype, 0) < have:
			taken[h.archetype] = taken.get(h.archetype, 0) + 1
			_claimed[n] = taken
			foe.wave = n
			break
	if not _waves.has(foe.wave):
		var wave: Wave = Wave.new()
		wave.n = foe.wave
		wave.start_tick = stage.arena.tick
		wave.shots_begin = stage.shots_fired
		_waves[foe.wave] = wave
	var archetype: EnemyRoster.Archetype = stage.arena.squad_ai.pit.roster.archetype(h.archetype)
	var k: Wave.Kind = _waves[foe.wave].kind(foe.arch)
	k.n += 1
	k.melee = archetype.weapon.melee
	k.attack_m = archetype.attack_m
	foe.melee = k.melee
	foe.window = Engaged.foe_window(archetype, h, stage.arena.tuning)
	_foes[h.id] = foe
	return foe


func _retire(foe: Foe) -> void:
	foe.done = true
	if foe.first_shot >= 0:
		return
	var k: Wave.Kind = _waves[foe.wave].kind(foe.arch)
	k.never_fired += 1
	k.never_fired_clear += int(foe.first_clear_any >= 0)
	k.never_fired_clear_in += int(foe.first_clear_in >= 0)
