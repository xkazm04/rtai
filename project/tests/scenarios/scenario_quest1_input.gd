extends Scenario
## The slice's main scene (boot/quest1.tscn) played headless to "paid" through the bound input
## only: the Start button is pressed, then every tick CollectCallInputDriver turns the bot's
## decision into simulated input events (joypad sticks and trigger, the interact key), LiveInput
## samples them into TickInput, and StagePilot moves Rivet. The run is recorded and the log
## replays bit-identically on a fresh session (SIM-05). Leaves quest1-input.json.

const EVIDENCE_FILE: String = "quest1-input.json"
const TIMEOUT_TICKS: int = 25 * 60 * SimClock.TICK_RATE


func run(tree: SceneTree) -> String:
	var scene: PackedScene = load("res://boot/quest1.tscn") as PackedScene
	var game: Quest1Game = scene.instantiate() as Quest1Game
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
	while not driver.done() and s.tick() < TIMEOUT_TICKS:
		driver.act()
		s.step()
		if beats.is_empty() or beats[-1] != s.beat_id():
			beats.append(s.beat_id())
	driver.release()
	var log: ReplayLog = s.world.loop().finish_recording()
	var out: Dictionary = _evidence(s, driver, beats, log)
	var reason: String = _verdict(s, log, out)
	out["verdict"] = "pass" if reason == "" else reason
	var write_error: String = write_evidence(EVIDENCE_FILE, out)
	Log.info("scenario", "quest1 input: %s" % JSON.stringify(out))
	game.free()
	return reason if reason != "" else write_error


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
