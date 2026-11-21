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


func run(profile_id: StringName, run_seed: int, ticks: int) -> Dictionary:
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
	var ok: bool = _play(ticks, tape, sha)
	_sync()
	if not current.is_empty():
		_end("tick_limit")
	var result: Dictionary = {
		"schema": "gtai.bot-pit-probe/1",
		"profile": profile_id,
		"seed": run_seed,
		"enemy_brain": "mixed",
		"ticks": ticks,
		"tick_hz": SimClock.TICK_RATE,
		"input_sha256": sha.finish().hex_encode(),
		"waves": waves,
		"waves_cleared": cleared,
		"damage_taken": damage_taken,
		"deaths": deaths,
		"counters": brain.counters.report()
	}
	session.close()
	bus.free()
	data.free()
	return result if ok else {}


func _play(ticks: int, tape: InputTape, sha: HashingContext) -> bool:
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
	current.counters = _changes(brain.counters.report(), start_counts)
	current = {}


func _changes(now: Dictionary, before: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for key: String in now:
		if key == "form_ticks":
			var forms: Dictionary = {}
			var earlier: Dictionary = before[key]
			for id: StringName in now[key]:
				var count: int = now[key][id] - earlier.get(id, 0)
				if count > 0:
					forms[id] = count
			out[key] = forms
		else:
			out[key] = now[key] - before[key]
	return out
