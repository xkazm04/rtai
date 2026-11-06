extends Scenario
## F-05 exit (SIM-05): record 60 s of the dummy sim headless with jittery frame deltas, save the
## log, reload it, replay it bit-identically; a different frame pattern gives the same run
## (render decoupling, SIM-01); planted input and seed mutations are caught (TST-05).

const SECONDS: int = 60
const MASTER_SEED: int = 20261102
const TAMPER_TICK: int = 1800
var _path: String = TestTmp.dir("replay").path_join("replay_60s.json")


func run(_tree: SceneTree) -> String:
	var recorded: ReplayLog = DummyRun.record(SECONDS, MASTER_SEED, 1)
	var reason: String = _check_substance(recorded)
	if reason == "":
		reason = _check_round_trip_and_replay(recorded)
	if reason == "":
		reason = recorded.first_divergence(DummyRun.record(SECONDS, MASTER_SEED, 2))
		reason = "" if reason == "" else "a different frame pattern changed the sim: %s" % reason
	if reason == "":
		reason = _check_planted_mutations()
	if reason == "":
		Log.info("scenario", _summary(recorded))
	return reason


func _check_substance(log: ReplayLog) -> String:
	if log.ticks < SECONDS * SimClock.TICK_RATE:
		return "recorded only %d ticks" % log.ticks
	if log.timeline.size() < 60 or log.input_changes() < 60:
		return "scenario too trivial to prove anything"
	return ""


func _check_round_trip_and_replay(recorded: ReplayLog) -> String:
	if DirAccess.make_dir_recursive_absolute(_path.get_base_dir()) != OK:
		return "cannot create %s" % _path.get_base_dir()
	if recorded.save(_path) != OK:
		return "cannot save %s" % _path
	var loaded: ReplayLog = ReplayLog.load_file(_path)
	if loaded == null:
		return "saved log does not load back"
	var reason: String = recorded.first_divergence(loaded)
	if reason != "":
		return "file round trip changed the log: %s" % reason
	reason = DummyRun.replay(loaded)
	return "" if reason == "" else "replay diverged: %s" % reason


func _check_planted_mutations() -> String:
	var tampered: ReplayLog = ReplayLog.load_file(_path)
	tampered.tamper_input(TAMPER_TICK, TickInput.new(7, TickInput.AXIS_MAX, -TickInput.AXIS_MAX))
	var caught: String = DummyRun.replay(tampered)
	var first_checkpoint_after: int = TAMPER_TICK + ReplayLog.CHECKPOINT_EVERY
	if not caught.ends_with("at tick %d" % first_checkpoint_after):
		return "planted input mutation at tick %d not localised: %s" % [TAMPER_TICK, caught]
	var reseeded: ReplayLog = ReplayLog.load_file(_path)
	reseeded.master_seed += 1
	if DummyRun.replay(reseeded) == "":
		return "planted seed mutation was not detected"
	return ""


func _summary(log: ReplayLog) -> String:
	return (
		"replay_60s: %d ticks, %d events, %d input changes, %d checkpoints, final %s"
		% [
			log.ticks,
			log.timeline.size(),
			log.input_changes(),
			log.checkpoints.size(),
			log.final_hash.left(16),
		]
	)
