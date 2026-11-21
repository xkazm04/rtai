class_name GauntletWaves
extends ArenaHook
## Runs after street streaming on each simulation tick. The first block is the approach.
## A live cohort holds the far seam. The squad keeps its fighters until every member falls.

signal pick_offered(ids: Array[StringName])

const TIMEOUT_TICKS: int = 90 * SimClock.TICK_RATE

var done: bool = false
var draw: GauntletDraw
var manual_picks: bool = false
var pending: Array[StringName] = []
var _run: GauntletRun
var _bonuses: GauntletBonusApply
var _street: GauntletStreet
var _picker: GauntletPilot
var _composer: GauntletComposer
var _limit: int
var _block: int = 0
var _start: int = -1
var _stats: GauntletWaveStats = GauntletWaveStats.new()
var _hits: int
var _members: Array[Fighter] = []


static func attach(
	session: GauntletSession, run: GauntletRun, picker: GauntletPilot, limit: int
) -> GauntletWaves:
	var w: GauntletWaves = GauntletWaves.new()
	w._run = run
	w._bonuses = session.bonuses
	w._street = session.street
	w._picker = picker
	w._limit = limit
	session.stage.hooks.append(w)
	w.setup(session.stage, session.world.context())
	return w


func setup(stage: ArenaStage, ctx: WorldContext) -> void:
	_composer = GauntletComposer.shipped(ctx.rng)
	draw = GauntletDraw.new(ctx.rng)
	@warning_ignore("return_value_discarded")
	stage.arena.wounded.connect(_wounded)
	@warning_ignore("return_value_discarded")
	stage.arena.kill_landed.connect(_killed)
	@warning_ignore("return_value_discarded")
	stage.arena.struck.connect(_struck)


func step(stage: ArenaStage, tick: int) -> void:
	if done or not pending.is_empty():
		return
	if _start >= 0:
		_stats.sample(stage)
	if not stage.arena.rivet.alive():
		_finish(stage, tick, false)
		done = true
		_run.alive = false
	elif _start < 0:
		if _street.index > _block:
			_spawn(stage, tick)
	elif _cleared():
		_finish(stage, tick, true)
		_pick(stage)
		done = pending.is_empty() and _at_limit()
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
	# The same invisible seam bounds a retreating guard; its brain still pursues across the block.
	arena.squad_ai.pit.bounds.end.x = _street.forward_limit
	var enemies: Dictionary[String, int] = {}
	var roster: Array[StringName] = _composer.compose(_run.wave + 1)
	for i: int in roster.size():
		var at: Vector2 = block.spawns[i % block.spawns.size()]
		var foe: Fighter = arena.squad_ai.spawn_member(arena, at, roster[i])
		# Reused anchors keep the arena spawner's seeded spread, constrained to this block.
		var offset: Vector2 = (
			(foe.pos - at).limit_length(1.2) if i >= block.spawns.size() else Vector2.ZERO
		)
		foe.pos = stage.walls.push_out(at + offset, foe.radius_m)
		_members.append(foe)
		var id: String = String(foe.archetype)
		var previous: int = enemies.get(id, 0)
		enemies[id] = previous + 1
	_run.begin_wave(enemies)
	_start = tick
	_stats.begin(stage)
	_hits = 0
	arena.announce_wave(&"gauntlet", _run.wave)
	Log.info(
		"gauntlet", "wave %d tick %d block %s enemies %s" % [_run.wave, tick, block.id, enemies]
	)


func wave_seconds(tick: int) -> float:
	if _start >= 0:
		return (tick - _start) * SimClock.TICK_DT
	if _run.waves.is_empty():
		return 0.0
	var seconds: float = _run.waves[-1].get("seconds", 0.0)
	return seconds


func _cleared() -> bool:
	for member: Fighter in _members:
		if member.alive():
			return false
	return true


func _finish(stage: ArenaStage, tick: int, cleared: bool) -> void:
	if _start < 0:
		return
	var row: Dictionary = _run.waves[-1]
	_stats.finish(stage, row)
	row["hits"] = _hits
	if cleared:
		row["seconds"] = (tick - _start) * SimClock.TICK_DT
	else:
		Log.info(
			"gauntlet",
			(
				"wave %d ended after %d ticks at %s, hp %.1f"
				% [_run.wave, tick - _start, stage.arena.rivet.pos, stage.arena.rivet.hp]
			)
		)

	_street.forward_limit = INF
	_start = -1


func _pick(stage: ArenaStage) -> void:
	var owned: Array[StringName] = [stage.arena.rivet.weapon]
	if stage.pilot.carry != null:
		owned.append_array(stage.pilot.carry.slots)
	var forms: GhostForms = stage.pilot.ghosts.forms
	for id: StringName in forms.table.order:
		if forms.locks.allows(forms.table, id):
			owned.append(id)
	pending = draw.offer(_run.wave, _run.picks, owned)
	if pending.is_empty():
		return
	if manual_picks:
		pick_offered.emit(pending)
	elif not choose(_picker.pick(pending)):
		pending = []


func choose(index: int) -> bool:
	if index < 0 or index >= pending.size():
		return false
	var id: StringName = pending[index]
	if not _bonuses.apply(draw.rows[id]):
		return false
	_run.picks.append({"wave": _run.wave, "offered": pending, "taken": id})
	pending = []
	done = _at_limit()
	return true


func _at_limit() -> bool:
	return _limit > 0 and _run.wave >= _limit


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
