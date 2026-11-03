extends Scenario
## The slice's main scene (boot/quest1.tscn) played headless to "paid" through the bound input
## only: the Start button is pressed, then every tick CollectCallInputDriver turns the bot's
## decision into simulated input events (joypad sticks and trigger, the interact key), LiveInput
## samples them into TickInput, and StagePilot moves Rivet. The run is recorded and the log
## replays bit-identically on a fresh session (SIM-05). Leaves quest1-input.json.

const EVIDENCE_FILE: String = "quest1-input.json"
const TIMEOUT_TICKS: int = 25 * 60 * SimClock.TICK_RATE
const SAVE_PATH: String = "user://test_tmp/quest1/checkpoint.json"
const LOAD_BEAT: String = "b4-dock"
## The run's input log, kept for the exported exe's own --replay check (build/evidence).
const LOG_PATH: String = "user://test_tmp/quest1/input-run.replay.json"


func run(tree: SceneTree) -> String:
	var scene: PackedScene = load("res://boot/quest1.tscn") as PackedScene
	var game: Quest1Game = scene.instantiate() as Quest1Game
	game.save_path = ""
	tree.root.add_child(game)
	game.boot()
	game.card.start_button.pressed.emit()
	if game.session == null:
		game.free()
		return "the Start button did not open quest 1"
	var s: Quest1Session = game.session
	s.world.set_process(false)
	s.world.loop().start_recording()
	var driver: CollectCallInputDriver = CollectCallInputDriver.new(s.stage, s.system)
	var beats: Array[String] = []
	var saves: Array[Checkpoint] = []
	var hints: Array[StringName] = []
	_play(s, driver, beats, saves, hints)
	var log: ReplayLog = s.world.loop().finish_recording()
	var out: Dictionary = _evidence(s, driver, beats, log)
	out["log"] = ProjectSettings.globalize_path(LOG_PATH)
	out["log_saved"] = log.save(LOG_PATH) == OK
	var reason: String = _verdict(s, log, out)
	out["hints"] = hints
	if reason == "" and hints.size() < 10:
		reason = "the objective hints covered only %d prompts: %s" % [hints.size(), hints]
	out["checkpoints"] = saves.map(func(c: Checkpoint) -> String: return "%s@%d" % [c.beat, c.tick])
	if reason == "":
		reason = _check_checkpoint(saves, out)
	out["verdict"] = "pass" if reason == "" else reason
	var write_error: String = write_evidence(EVIDENCE_FILE, out)
	Log.info("scenario", "quest1 input: %s" % JSON.stringify(out))
	game.free()
	return reason if reason != "" else write_error


## Drives the run to the end, noting beats, beat checkpoints and objective prompts seen.
func _play(
	s: Quest1Session,
	driver: CollectCallInputDriver,
	beats: Array[String],
	saves: Array[Checkpoint],
	hints: Array[StringName]
) -> void:
	while not driver.done() and s.tick() < TIMEOUT_TICKS:
		driver.act()
		s.step()
		var hint: StringName = ObjectiveHint.of(s.stage, s.system).key
		if hint != &"" and not hints.has(hint):
			hints.append(hint)
		var cp: Checkpoint = s.poll_checkpoint()
		if cp != null:
			saves.append(cp)
		if beats.is_empty() or beats[-1] != s.beat_id():
			beats.append(s.beat_id())
	driver.release()


func _verdict(s: Quest1Session, log: ReplayLog, out: Dictionary) -> String:
	if not s.paid():
		var at: Array = [s.system.runner.state_name(), s.beat_id(), s.tick()]
		return "not paid: state %s at beat %s, tick %d" % at
	if log.input_changes() < 100:
		return "too few input changes (%d): the input path was idle" % log.input_changes()
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: Quest1Session = Quest1Session.open(bus, data)
	var divergence: String = again.world.verify_replay(log)
	out["replay"] = "identical" if divergence == "" else divergence
	again.world.free()
	bus.free()
	data.free()
	return "" if divergence == "" else "the recorded input did not replay: %s" % divergence


## The beat checkpoints: one per beat after the first, the Dock 9 one saved to a file, loaded,
## resumed on a fresh world to the same hash; a tampered copy is refused (TST-05).
func _check_checkpoint(saves: Array[Checkpoint], out: Dictionary) -> String:
	if saves.size() != 5:
		return "expected 5 beat checkpoints (b2..b6), got %d" % saves.size()
	var pick: Array[Checkpoint] = saves.filter(
		func(c: Checkpoint) -> bool: return c.beat == LOAD_BEAT
	)
	if pick.is_empty() or pick[0].save(SAVE_PATH) != OK:
		return "cannot save the %s checkpoint to %s" % [LOAD_BEAT, SAVE_PATH]
	var loaded: Checkpoint = Checkpoint.load_file(SAVE_PATH)
	if loaded == null or JSON.stringify(loaded.to_dict()) != JSON.stringify(pick[0].to_dict()):
		return "the checkpoint did not round-trip through %s" % SAVE_PATH
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var resumed: Quest1Session = Quest1Session.resume(bus, data, loaded)
	var ok: bool = resumed != null and resumed.beat_id() == LOAD_BEAT
	if resumed != null:
		resumed.world.free()
	loaded.inputs[loaded.inputs.size() / 2] = TickInput.new(0, 127, 0).pack()
	var tampered: Quest1Session = Quest1Session.resume(bus, data, loaded)
	var refused: bool = tampered == null
	if tampered != null:
		tampered.world.free()
	bus.free()
	data.free()
	out["checkpoint_load"] = {"beat": LOAD_BEAT, "resumed": ok, "tamper_refused": refused}
	if not ok:
		return "the %s checkpoint did not resume to its hash" % LOAD_BEAT
	return "" if refused else "a tampered checkpoint loaded (planted fault not caught)"


func _evidence(
	s: Quest1Session, d: CollectCallInputDriver, beats: Array[String], log: ReplayLog
) -> Dictionary:
	return {
		"scene": "res://boot/quest1.tscn",
		"path": "simulated InputEvents -> InputMap -> LiveInput -> TickInput -> StagePilot",
		"ticks": s.tick(),
		"seconds": s.tick() / float(SimClock.TICK_RATE),
		"state": s.system.runner.state_name(),
		"paid": s.stage.wallet.cash - s.cash_before,
		"beats": beats,
		"deaths": s.stage.deaths,
		"kills": s.stage.arena.kills,
		"shots": s.stage.shots_fired,
		"interact_presses": d.presses,
		"input_events": d.events_sent,
		"input_changes": log.input_changes(),
		"final_hash": log.final_hash,
	}
