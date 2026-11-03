extends Scenario
## The arena's pit station played by its scripted player (ArenaPitBot): Rivet enters through the
## west door and fights the pit's waves (real GuardBrain contractors, real rifles, cover that
## stops shots both ways). Must clear at least one wave inside LIMIT_TICKS and replay identical
## on a fresh world (SIM-05). TST-05: a planted fault (aim, never fire) must kill nobody.

const LIMIT_TICKS: int = 60 * SimClock.TICK_RATE
const EVIDENCE_FILE: String = "arena-pit-telemetry.json"


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = ArenaSession.open(Events, Data)
	var bot: ArenaPitBot = ArenaPitBot.new(s.stage, s.actions)
	s.world.loop().set_input(bot)
	s.world.loop().start_recording()
	while s.tick() < LIMIT_TICKS and bot.done_tick < 0:
		s.step()
	var log: ReplayLog = s.world.loop().finish_recording()
	var tel: Dictionary = s.stage.telemetry_dict()
	tel["pit_done_s"] = float(bot.done_tick) * SimClock.TICK_DT
	tel["pit_waves_cleared"] = s.stage.pit.waves_cleared
	tel["shots_stopped_by_cover"] = s.stage.dodges.blocked
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, tel)
	var cleared: int = s.stage.pit.waves_cleared
	var waves: int = s.stage.pit.wave
	s.world.free()
	if cleared < 1:
		return "the pit bot cleared no wave in %d ticks (wave %d)" % [LIMIT_TICKS, waves]
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
	return "" if divergence == "" else "arena pit replay diverged: %s" % divergence


func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data)
	var bot: ArenaPitBot = ArenaPitBot.new(s.stage, s.actions)
	bot.trigger = false
	s.world.loop().set_input(bot)
	while s.tick() < LIMIT_TICKS / 3:
		s.step()
	var kills: int = s.stage.pit.kills
	s.world.free()
	bus.free()
	data.free()
	return "a bot that never fired still killed %d pit guards" % kills if kills > 0 else ""
