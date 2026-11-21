class_name GauntletWaves
extends ArenaHook
## Runs after street streaming on each simulation tick. The first block is the approach.
## A live cohort holds the far seam. The squad keeps its fighters until every member falls.

const TIMEOUT_TICKS: int = 90 * SimClock.TICK_RATE
const BONUSES: String = "res://data/tables/gauntlet_bonuses.json"

var done: bool = false
var _run: GauntletRun
var _street: GauntletStreet
var _picker: GauntletPilot
var _composer: GauntletComposer
var _limit: int
var _block: int = 0
var _start: int = -1
var _start_shots: int
var _start_damage: float
var _hits: int
var _members: Array[Fighter] = []
var _offers: Array[Dictionary] = []
var _rng: RandomNumberGenerator


static func attach(
	session: GauntletSession, run: GauntletRun, picker: GauntletPilot, limit: int
) -> GauntletWaves:
	var w: GauntletWaves = GauntletWaves.new()
	w._run = run
	w._street = session.street
	w._picker = picker
	w._limit = limit
	session.stage.hooks.append(w)
	w.setup(session.stage, session.world.context())
	return w


func setup(stage: ArenaStage, ctx: WorldContext) -> void:
	_composer = GauntletComposer.shipped(ctx.rng)
	_rng = ctx.rng.stream(&"gauntlet_offers")
	var t: DataTable = DataTable.open(BONUSES, "gtai.gauntlet_bonuses/1")
	_offers.assign(t.array(t.raw, "rows"))
	@warning_ignore("return_value_discarded")
	stage.arena.wounded.connect(_wounded)
	@warning_ignore("return_value_discarded")
	stage.arena.kill_landed.connect(_killed)
	@warning_ignore("return_value_discarded")
	stage.arena.struck.connect(_struck)


func step(stage: ArenaStage, tick: int) -> void:
	if done:
		return
	if not stage.arena.rivet.alive():
		_finish(stage, tick, false)
		done = true
		_run.alive = false
	elif _start < 0:
		if _street.index > _block:
			_spawn(stage, tick)
	elif _cleared():
		_finish(stage, tick, true)
		_pick()
		done = _limit > 0 and _run.wave >= _limit
	elif tick - _start >= TIMEOUT_TICKS:
		_finish(stage, tick, false)
		_run.death_by = &"timeout"
		_run.alive = false
		done = true


func _spawn(stage: ArenaStage, tick: int) -> void:
	var arena: CombatArena = stage.arena
	for dead: Fighter in _members:
		arena.hostiles.erase(dead)
	_members.clear()
	arena.squad_ai.clear_wave()
	var block: GauntletSegment = _street.current()
	_block = _street.index
	_street.forward_limit = block.end_x() - arena.rivet.radius_m
	var enemies: Dictionary[String, int] = {}
	var roster: Array[StringName] = _composer.compose(_run.wave + 1)
	for i: int in roster.size():
		var at: Vector2 = block.spawns[i % block.spawns.size()]
		var foe: Fighter = arena.squad_ai.spawn_member(arena, at, roster[i])
		foe.pos = at
		_members.append(foe)
		var id: String = String(foe.archetype)
		var previous: int = enemies.get(id, 0)
		enemies[id] = previous + 1
	_run.begin_wave(enemies)
	_start = tick
	_start_shots = stage.shots_fired
	_start_damage = stage.telemetry.damage_taken
	_hits = 0
	arena.announce_wave(&"gauntlet", _run.wave)
	Log.info(
		"gauntlet", "wave %d tick %d block %s enemies %s" % [_run.wave, tick, block.id, enemies]
	)


func _cleared() -> bool:
	for member: Fighter in _members:
		if member.alive():
			return false
	return true


func _finish(stage: ArenaStage, tick: int, cleared: bool) -> void:
	if _start < 0:
		return
	var row: Dictionary = _run.waves[-1]
	row["shots"] = stage.shots_fired - _start_shots
	row["hits"] = _hits
	row["damage_taken"] = stage.telemetry.damage_taken - _start_damage
	if cleared:
		row["seconds"] = (tick - _start) * SimClock.TICK_DT
	_street.forward_limit = INF
	_start = -1


func _pick() -> void:
	var offered: Array[StringName] = _draw()
	var choice: int = _picker.pick(offered)
	_run.picks.append({"wave": _run.wave, "offered": offered, "taken": offered[choice]})


## The initial draw is uniform without replacement among cards unlocked on this wave.
func _draw() -> Array[StringName]:
	var pool: Array[StringName] = []
	for row: Dictionary in _offers:
		var min_wave: float = row["min_wave"]
		if min_wave <= _run.wave:
			pool.append(StringName(str(row["id"])))
	var offered: Array[StringName] = []
	for i: int in 3:
		var index: int = _rng.randi_range(0, pool.size() - 1)
		offered.append(pool[index])
		pool.remove_at(index)
	return offered


## Count damaging contacts against wave members. A claw strike can hit several bodies.
func _wounded(victim: Fighter, _weapon: StringName) -> void:
	if _start >= 0 and _members.has(victim):
		_hits += 1


func _killed(
	victim: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName
) -> void:
	_wounded(victim, weapon)


func _struck(victim: Fighter, _dir: Vector2, lethal: bool, weapon: StringName) -> void:
	if victim.kind == Fighter.Kind.RIVET and lethal and not done:
		_run.death_by = weapon
