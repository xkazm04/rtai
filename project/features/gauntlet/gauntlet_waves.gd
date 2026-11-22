class_name GauntletWaves
extends ArenaHook
## Street streaming runs first. Overlapping waves share the block and squad until it is clear.

signal pick_offered(ids: Array[StringName])

var done: bool = false
var draw: GauntletDraw
var manual_picks: bool = false
var pending: Array[StringName] = []
var owed_total: int = 0
var owed_index: int = 0
var owed_remaining: int:
	get:
		return owed_total - owed_index + int(not pending.is_empty())
var _run: GauntletRun
var _bonuses: GauntletBonusApply
var _street: GauntletStreet
var _picker: GauntletPilot
var _composer: GauntletComposer
var _limit: int
var _block: int = 0
var _first_wave: int
var _next_wave_tick: int
var _live: Array[GauntletLiveWave] = []


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
	(stage.arena as GauntletCombat).rivet_contact.connect(_contact)


func step(stage: ArenaStage, tick: int) -> void:
	if done or not pending.is_empty():
		return
	var dead: bool = not stage.arena.rivet.alive()
	if dead:
		_run.alive = false
		var newest: GauntletLiveWave = _newest_started()
		_run.death_wave = _run.wave if newest == null else newest.row["n"]
		done = true
	for i: int in range(_live.size() - 1, -1, -1):
		var wave: GauntletLiveWave = _live[i]
		if wave.start_tick < 0:
			continue
		wave.stats.sample(stage)
		var cleared: bool = wave.cleared()
		if cleared or dead:
			wave.finish(stage, _picker, tick, cleared)
			_live.remove_at(i)
	if dead:
		return
	if _live.is_empty():
		if is_finite(_street.forward_limit):
			_clear_block()
		elif _street.index > _block:
			_block = _street.index
			_first_wave = _run.wave + 1
			_street.hold_block(stage.arena)
			_schedule(stage, tick)
		return
	_fill(stage, tick)
	var newest: GauntletLiveWave = _live[-1]
	if newest.start_tick >= 0 and tick >= _next_wave_tick and not _at_limit():
		newest.row["timed_out"] = true
		_schedule(stage, tick)


func live_wave_count() -> int:
	return _live.size() - int(not _live.is_empty() and _live[-1].start_tick < 0)


func _newest_started() -> GauntletLiveWave:
	var count: int = live_wave_count()
	return _live[count - 1] if count > 0 else null


func wave_seconds(tick: int) -> float:
	var wave: GauntletLiveWave = _newest_started()
	if wave != null:
		return wave.seconds(tick)
	return _run.waves[-1].get("seconds", 0.0) if not _run.waves.is_empty() else 0.0


func _slots(arena: CombatArena) -> int:
	var slots: int = _street.max_alive
	for foe: Fighter in arena.hostiles:
		slots -= int(foe.alive())
	return maxi(0, slots)


func _schedule(stage: ArenaStage, tick: int) -> void:
	var roster: Array[StringName] = _composer.compose(_run.wave + 1)
	_live.append(GauntletLiveWave.new(roster, _slots(stage.arena)))
	_fill(stage, tick)


func _fill(stage: ArenaStage, tick: int) -> void:
	var slots: int = -1
	for wave: GauntletLiveWave in _live:
		if wave.remaining() == 0:
			continue
		if slots < 0:
			slots = _slots(stage.arena)
		if slots == 0:
			break
		var starting: bool = wave.start_tick < 0
		slots -= wave.spawn(stage, _street.current(), slots, tick, _run)
		if starting:
			# Keep this deadline if a younger roster falls before an older survivor.
			_next_wave_tick = tick + _street.timeout_ticks
			stage.arena.announce_wave(&"gauntlet", _run.wave)
			Log.info(
				"gauntlet",
				"wave %d tick %d block %d, %d alive" % [_run.wave, tick, _block, live_wave_count()]
			)


func _clear_block() -> void:
	_street.forward_limit = INF
	owed_total = _run.wave - _first_wave + 1
	owed_index = 0
	_next_offer()
	while not manual_picks and not pending.is_empty():
		if not choose(_picker.pick(pending)):
			Log.error("gauntlet", "bot could not take its offered upgrade")
			break


func pick_wave() -> int:
	return _first_wave + owed_index - 1


func _next_offer() -> void:
	while owed_index < owed_total:
		owed_index += 1
		pending = draw.offer(pick_wave(), _run.picks, _bonuses.owned())
		if not pending.is_empty():
			if manual_picks:
				pick_offered.emit(pending)
			return
	done = _at_limit()


func choose(index: int) -> bool:
	if index < 0 or index >= pending.size():
		return false
	var id: StringName = pending[index]
	if not _bonuses.apply(draw.rows[id]):
		return false
	_run.picks.append({"wave": pick_wave(), "offered": pending, "taken": id})
	pending = []
	_next_offer()
	return true


func _at_limit() -> bool:
	return _limit > 0 and _run.wave >= _limit


func _contact(victim: Fighter, counter: StringName) -> void:
	for wave: GauntletLiveWave in _live:
		wave.contact(victim, counter)


func _wounded(victim: Fighter, _weapon: StringName) -> void:
	_contact(victim, &"hits")


func _killed(
	victim: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName
) -> void:
	_wounded(victim, weapon)
