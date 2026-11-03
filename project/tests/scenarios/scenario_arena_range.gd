extends Scenario
## The arena's range station played by its scripted player (ArenaRangeBot): Rivet walks to the
## firing line and shoots every dummy with the real pilot and arena. The run must land hits,
## time-to-kill samples and an input latency, and replay identical on a fresh world (SIM-05).
## TST-05: a planted fault (the bot never pulls the trigger) must report zero hits.

const TICKS: int = 20 * SimClock.TICK_RATE
const EVIDENCE_FILE: String = "arena-range-telemetry.json"


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = ArenaSession.open(Events, Data)
	var bot: ArenaRangeBot = ArenaRangeBot.new(s.stage, s.actions)
	s.world.loop().set_input(bot)
	s.world.loop().start_recording()
	while s.tick() < TICKS:
		s.step()
	var log: ReplayLog = s.world.loop().finish_recording()
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, s.stage.telemetry_dict())
	var verdict: String = _verdict(s.stage)
	s.world.free()
	if verdict != "":
		return verdict
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = ArenaSession.open(bus, data)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	if divergence != "":
		return "arena range replay diverged: %s" % divergence
	return _planted()


func _verdict(stage: ArenaStage) -> String:
	var tel: ArenaTelemetry = stage.telemetry
	if tel.hits < 4:
		return "the range bot landed %d hits in %d shots" % [tel.hits, tel.shots]
	if stage.targets.ttk_s.size() < 3:
		return "time to kill sampled on %d targets" % stage.targets.ttk_s.size()
	if tel.latency_mean() < 0.0:
		return "no input-to-motion latency measured"
	return ""


## The trigger never pulled: the dummies must report no hits.
func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data)
	var bot: ArenaRangeBot = ArenaRangeBot.new(s.stage, s.actions)
	bot.trigger = false
	s.world.loop().set_input(bot)
	while s.tick() < TICKS / 2:
		s.step()
	var hits: int = s.stage.targets.total_hits()
	s.world.free()
	bus.free()
	data.free()
	return "" if hits == 0 else "a bot that never fired still scored %d hits" % hits
