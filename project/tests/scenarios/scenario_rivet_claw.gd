extends Scenario
## rivet-arsenal: the live arena played by ArenaRivetBot through the real pilot (walk, strafe,
## backpedal, sprint, two rolls, then the claw on the rivet_claw_cops station). Every claw must
## land (the follow-ups step in through the jab's knockback), both sparring cops (4 hp) drop on a
## finisher and the plain cop on one jab, the sprint crosses the tackle line, Rivet rolls twice,
## and the run replays identical on a fresh world (SIM-05).
## The held melee then charges the shock on a sparring pair (jab, charge, release: one landed
## discharge) and the stunned cop drops to two claws.
## TST-05: planted faults: the claw with no step-in must whiff and leave a sparring cop up; a
## shock with a 0.3 m reach must miss the cop.

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
	if claw.get("claw_whiffs", -1) != 0 or claw.get("claw_hits", 0) != 10:
		return "the claw did not land 10 of 10: %s" % claw
	if claw.get("claw_kills", 0) != 4:
		return "expected 4 cops down (2 finishers, 1 jab, the shocked cop's combo): %s" % claw
	var shocked: bool = claw.get("shock_discharges", 0) == 1 and claw.get("shock_landed", 0) == 1
	if tel["sprint_top_mps"] <= 5.0 or not shocked:
		return (
			"no sprint over 5 m/s (%.2f) or no single landed shock: %s"
			% [tel["sprint_top_mps"], claw]
		)
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
	s.stage.pilot.shock.shock.reach_m = 0.3
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
	if claw.get("shock_landed", 0) != 0:
		return "the planted 0.3 m shock still landed: %s" % claw
	return ""
