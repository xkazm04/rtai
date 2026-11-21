extends RefCounted
## Measure all attempted pit waves. A death or tick limit leaves clear_s null.

var session: ArenaSession
var brain: GauntletBot
var view: BotViewArena
var waves: Array[Dictionary] = []
var current: Dictionary = {}
var deaths: int = 0
var damage_taken: float = 0.0
var start_damage: float
var start_deaths: int
var start_counts: Dictionary
var wave_n: int = 0
var cleared: int = 0
var _wire: bool


func run(
	profile_id: StringName, run_seed: int, ticks: int, wire: bool = false, wave_cap: int = 0
) -> Dictionary:
	_wire = wire
	var profile: BotProfile = BotProfile.shipped(profile_id)
	var sha: HashingContext = HashingContext.new()
	if profile == null or sha.start(HashingContext.HASH_SHA256) != OK:
		return {}
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var options: ArenaArgs = ArenaArgs.new()
	options.values["--enemy-brain"] = "mixed"
	session = ArenaSession.open_with_args(bus, data, run_seed, null, options)
	view = BotViewArena.new(session.stage, session.actions)
	brain = GauntletBot.new(view, session.actions, profile, run_seed)
	var tape: InputTape = InputTape.new(brain)
	session.world.loop().set_input(tape)
	@warning_ignore("return_value_discarded")
	bus.wave_started.connect(_started)
	var ok: bool = _play(ticks, tape, sha, wave_cap)
	_sync()
	if not current.is_empty():
		_end("tick_limit")
	var result: Dictionary = _wire_result() if wire else _probe_result()
	result["profile"] = profile_id
	result["seed"] = run_seed
	result["input_sha256"] = sha.finish().hex_encode()
	session.close()
	bus.free()
	data.free()
	return result if ok else {}


func _probe_result() -> Dictionary:
	return {
		"schema": "gtai.bot-pit-probe/1",
		"enemy_brain": "mixed",
		"ticks": session.tick(),
		"tick_hz": SimClock.TICK_RATE,
		"waves": waves,
		"waves_cleared": cleared,
		"damage_taken": damage_taken,
		"deaths": deaths,
		"counters": brain.counters.report()
	}


func _wire_result() -> Dictionary:
	var run_state: GauntletRun = GauntletRun.new()
	run_state.alive = deaths == 0
	for attempt: Dictionary in waves:
		run_state.wave = attempt.n
		run_state.waves.append(
			BotCounters.wave_row(attempt, session.pilot.ghosts.forms.table.order)
		)
	var result: Dictionary = run_state.to_result()
	result["sim_s"] = session.tick() * SimClock.TICK_DT
	return result


func _play(ticks: int, tape: InputTape, sha: HashingContext, wave_cap: int) -> bool:
	var word: PackedByteArray = PackedByteArray()
	if word.resize(8) != OK:
		return false
	for i: int in ticks:
		var before_hp: float = session.stage.arena.rivet.hp
		var respawns: int = session.stage.deaths
		session.step()
		var after_hp: float = (
			session.stage.arena.rivet.hp if session.stage.deaths == respawns else 0.0
		)
		damage_taken += maxf(0.0, before_hp - after_hp)
		deaths = session.stage.deaths + int(not session.stage.arena.rivet.alive())
		word.encode_u64(0, tape.change_inputs[-1])
		if sha.update(word) != OK:
			return false
		if wave_n > 0:
			_begin()
		if not current.is_empty():
			if session.stage.pit.waves_cleared > cleared:
				cleared += 1
				_end("cleared")
			elif deaths > start_deaths:
				_end("death")
		if _wire and (deaths > 0 or (wave_cap > 0 and cleared >= wave_cap)):
			break
	return true


func _started(encounter: StringName, ordinal: int) -> void:
	if encounter == &"arena_pit":
		wave_n = ordinal


func _sync() -> void:
	view.refresh()
	brain.counters.observe_totals(view.player())


func _begin() -> void:
	_sync()
	current = {"n": wave_n, "start_tick": session.stage.tick, "clear_s": null}
	if _wire:
		var enemies: Dictionary[StringName, int] = {}
		for foe: BotView.Hostile in view.hostiles():
			enemies[foe.archetype] = enemies.get(foe.archetype, 0) + 1
		current["enemies"] = enemies
	waves.append(current)
	start_damage = damage_taken
	start_deaths = deaths
	start_counts = brain.counters.report()
	wave_n = 0


func _end(status: String) -> void:
	_sync()
	var start: int = current.start_tick
	current.status = status
	current.end_tick = session.stage.tick
	if status == "cleared":
		current.clear_s = (session.stage.tick - start) * SimClock.TICK_DT
	current.damage_taken = damage_taken - start_damage
	current.deaths = deaths - start_deaths
	current.counters = brain.counters.since(start_counts)
	current = {}
