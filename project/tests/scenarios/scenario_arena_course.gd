extends Scenario
## The arena's course station played by its scripted player (ArenaCourseBot): Rivet weaves the
## slalom and runs the corridor with the real pilot. The run must finish inside LIMIT_TICKS,
## turn hard (the slalom) and replay identical on a fresh world (SIM-05).
## TST-05: a planted fault (the stick never moves) must not finish.

const LIMIT_TICKS: int = 30 * SimClock.TICK_RATE
const EVIDENCE_FILE: String = "arena-course-telemetry.json"


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = ArenaSession.open(Events, Data)
	var bot: ArenaCourseBot = ArenaCourseBot.new(s.stage)
	s.world.loop().set_input(bot)
	s.world.loop().start_recording()
	while s.tick() < LIMIT_TICKS and bot.finished_tick < 0:
		s.step()
	var log: ReplayLog = s.world.loop().finish_recording()
	var tel: Dictionary = s.stage.telemetry_dict()
	tel["course_time_s"] = float(bot.finished_tick) * SimClock.TICK_DT
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, tel)
	var turn: float = s.stage.telemetry.turn_dps_peak
	s.world.free()
	if bot.finished_tick < 0:
		return "the course bot did not finish in %d ticks (waypoint %d)" % [LIMIT_TICKS, bot.next]
	if turn < 180.0:
		return "the slalom never turned hard (peak %.0f deg/s)" % turn
	var divergence: String = _replay(log)
	return divergence if divergence != "" else _planted()


func _replay(log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = ArenaSession.open(bus, data)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	return "" if divergence == "" else "arena course replay diverged: %s" % divergence


func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data)
	var bot: ArenaCourseBot = ArenaCourseBot.new(s.stage)
	bot.stick_scale = 0.0
	s.world.loop().set_input(bot)
	while s.tick() < LIMIT_TICKS / 4:
		s.step()
	var finished: bool = bot.finished_tick >= 0
	s.world.free()
	bus.free()
	data.free()
	return "a bot that never moved still finished the course" if finished else ""
