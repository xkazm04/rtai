extends Scenario
## Lane ghost-powers: the ghosts' attack beats (GhostReel, `--bot=ghosts`) in the arena's real
## fight, one fresh ArenaSession per run. Tonnage must slam twice, crush both cars and flatten
## (signature style crush); Dent must seize the cruiser, strike with it and blow it up. Each beat
## replays identically on a fresh world (SIM-05) and gives the same state on the same seed.
## TST-05: a planted fault per ghost (Tonnage's crush_m 0, Dent's blast_damage 0) must change
## the outcome.

const EVIDENCE_FILE: String = "ghost-attacks.json"
const TICKS: Dictionary[StringName, int] = {&"tonnage": 620, &"dent": 360}
const FAULTS: Dictionary[StringName, StringName] = {
	&"tonnage": &"crush_m", &"dent": &"blast_damage"
}


func run(_tree: SceneTree) -> String:
	var out: Dictionary = {}
	for ghost: StringName in TICKS:
		var clean: Dictionary = _run(ghost, false, true)
		var tele: Dictionary = clean["telemetry"]
		out[String(ghost)] = tele
		var reason: String = _judge(ghost, tele)
		if reason != "":
			return reason
		if clean["replay"] != "":
			return "%s replay diverged: %s" % [ghost, clean["replay"]]
		var again: Dictionary = _run(ghost, false, false)
		if again["state"] != clean["state"]:
			return "%s: the same seed gave a different outcome" % ghost
		var faulty: Dictionary = _run(ghost, true, false)
		out["planted_" + String(ghost)] = faulty["telemetry"]
		if faulty["state"] == clean["state"]:
			return "%s: the planted %s = 0 went unseen" % [ghost, FAULTS[ghost]]
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, out)
	return ""


func _judge(ghost: StringName, t: Dictionary) -> String:
	if ghost == &"tonnage":
		var h: Dictionary = t.get("tonnage", {})
		if h.get("slams", 0) < 2 or h.get("cars_crushed", 0) < 2 or t.get("crush", 0) < 3:
			return "tonnage beat fell short: %s" % JSON.stringify(t)
		return ""
	var d: Dictionary = t.get("dent", {})
	if d.get("seizes", 0) != 1 or d.get("strikes", 0) < 1 or d.get("blasts", 0) != 1:
		return "dent beat fell short: %s" % JSON.stringify(t)
	return ""


func _run(ghost: StringName, fault: bool, record: bool) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data)
	var input: GhostReelInput = GhostReelInput.attach(s.stage, s.actions)
	input.reel.ghost = ghost
	s.world.loop().set_input(input)
	if fault:
		var block: Dictionary = (
			s.pilot.hauler.attacks.block(ghost)
			if ghost == &"tonnage"
			else s.pilot.dent.attacks.block(ghost)
		)
		block[String(FAULTS[ghost])] = 0.0
	if record:
		s.world.loop().start_recording()
	while s.tick() < TICKS[ghost]:
		s.step()
	var buf: StreamPeerBuffer = StreamPeerBuffer.new()
	s.pilot.write_state(buf)
	input.reel.write_state(buf)
	for h: ArenaHook in s.stage.hooks:
		if h is BrutalityHook:
			h.write_state(buf)
	var t: Dictionary = input.reel.telemetry()
	t["crush"] = _crushes(s)
	var replay: String = ""
	if record:
		replay = _replay(ghost, s.world.loop().finish_recording())
	s.world.free()
	bus.free()
	data.free()
	return {"state": buf.data_array, "telemetry": t, "replay": replay}


func _crushes(s: ArenaSession) -> int:
	for h: ArenaHook in s.stage.hooks:
		if h is BrutalityHook:
			return (h as BrutalityHook).kills.by_style.get(&"crush", 0)
	return 0


func _replay(ghost: StringName, log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data)
	var reel: GhostReel = GhostReelInput.attach(s.stage, s.actions).reel
	reel.ghost = ghost
	var divergence: String = s.world.verify_replay(log)
	s.world.free()
	bus.free()
	data.free()
	return divergence
