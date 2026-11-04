extends Scenario
## rivet-arsenal: the live arena played by ArenaRivetBot through the real pilot (walk, strafe,
## backpedal, sprint, two rolls, then the claw on the rivet_claw_cops station). Every claw must
## land (the follow-ups step in through the jab's knockback), both sparring cops (4 hp) drop on a
## finisher and the plain cop on one jab, the sprint crosses the tackle line, Rivet rolls twice,
## and the run replays identical on a fresh world (SIM-05).
## TST-05: a planted fault (the claw with no step-in) must whiff and leave a sparring cop up.

const LIMIT_TICKS: int = 30 * SimClock.TICK_RATE
const EVIDENCE_FILE: String = "rivet-claw-telemetry.json"
const STATION: String = "rivet_claw_cops"


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = ArenaSession.open(Events, Data)
	var bot: ArenaRivetBot = ArenaRivetBot.new(s.stage, s.actions)
	s.world.loop().set_input(bot)
	s.world.loop().start_recording()
	var top: float = 0.0
	while s.tick() < LIMIT_TICKS and bot.finished_tick < 0:
		s.step()
		if s.stage.pilot.motion.phase == PlayerMotion.Phase.FREE:
			top = maxf(top, s.stage.pilot.motion.velocity().length())
	var log: ReplayLog = s.world.loop().finish_recording()
	var tel: Dictionary = s.stage.telemetry_dict()
	tel["sprint_top_mps"] = top
	tel["rolls"] = s.stage.pilot.motion.rolls
	tel["finished_tick"] = bot.finished_tick
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, tel)
	s.world.free()
	var reason: String = _judge(tel, bot)
	if reason != "":
		return reason
	var divergence: String = _replay(log)
	return divergence if divergence != "" else _planted()


func _judge(tel: Dictionary, bot: ArenaRivetBot) -> String:
	var claw: Dictionary = tel.get(STATION, {})
	if bot.finished_tick < 0:
		return "the rivet bot did not finish in %d ticks (step %d)" % [LIMIT_TICKS, bot.index]
	if claw.get("claw_whiffs", -1) != 0 or claw.get("claw_hits", 0) != 7:
		return "the claw did not land 7 of 7: %s" % claw
	if claw.get("claw_kills", 0) != 3:
		return "expected 3 cops down (2 finishers, 1 jab): %s" % claw
	if tel["sprint_top_mps"] <= 5.0:
		return "the sprint never crossed the 5 m/s tackle line (%.2f)" % tel["sprint_top_mps"]
	if tel["rolls"] != 2:
		return "expected 2 rolls, got %d" % tel["rolls"]
	return ""


func _replay(log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = ArenaSession.open(bus, data)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	return "" if divergence == "" else "rivet claw replay diverged: %s" % divergence


func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data)
	var t: MeleeTable = MeleeTable.shipped()
	for h: MeleeHit in t.hits:
		h.lunge_m = 0.0
	s.stage.pilot.melee = PlayerMelee.new(t)
	var bot: ArenaRivetBot = ArenaRivetBot.new(s.stage, s.actions)
	s.world.loop().set_input(bot)
	while s.tick() < LIMIT_TICKS and bot.finished_tick < 0:
		s.step()
	var claw: Dictionary = s.stage.telemetry_dict().get(STATION, {})
	s.world.free()
	bus.free()
	data.free()
	if claw.get("claw_whiffs", 0) == 0 or claw.get("claw_kills", 0) >= 3:
		return "the planted no-step-in claw still landed everything: %s" % claw
	return ""
