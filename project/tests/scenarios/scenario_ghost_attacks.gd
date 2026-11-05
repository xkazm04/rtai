extends Scenario
## Lane ghost-powers: the ghosts' attack beats (GhostReel, `--bot=ghosts`) in the arena's real
## fight, one fresh ArenaSession per run. Tonnage must slam twice, crush both cars and flatten
## (signature style crush); Dent must seize the cruiser, strike with it and blow it up; Kerf must
## blink-slice the whole group (four humans split, the robot in two cuts); Ohm's forked bolts must
## stun and burn down the group, kill the robot and burn the cruiser. Each beat
## replays identically on a fresh world (SIM-05) and gives the same state on the same seed.
## TST-05: a planted fault per ghost (Tonnage's crush_m 0, Dent's blast_damage 0, Kerf's
## human_damage 0, Ohm's machine_k 0) must change the outcome.

const EVIDENCE_FILE: String = "ghost-attacks.json"
const TICKS: Dictionary[StringName, int] = {
	&"tonnage": 620, &"dent": 360, &"kerf": 520, &"ohm": 600
}
const FAULTS: Dictionary[StringName, StringName] = {
	&"tonnage": &"crush_m", &"dent": &"blast_damage", &"kerf": &"human_damage", &"ohm": &"machine_k"
}

## Each beat's floor: [telemetry block ("" = top level), key, minimum].
const NEEDS: Dictionary[StringName, Array] = {
	&"tonnage": [["tonnage", "slams", 2], ["tonnage", "cars_crushed", 2], ["", "crush", 3]],
	&"dent":
	[["dent", "seizes", 1], ["dent", "strikes", 1], ["dent", "blasts", 1], ["dent", "rides", 30]],
	&"kerf": [["kerf", "slices", 6], ["", "split", 4], ["", "ghost_dead", 5]],
	&"ohm": [["ohm", "struck", 8], ["ohm", "cars_hit", 1], ["", "ghost_dead", 5]],
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
	for need: Array in NEEDS[ghost]:
		var block: String = need[0]
		var from: Dictionary = t if block == "" else t.get(block, {})
		var got: float = from.get(need[1], 0)
		var floor_n: int = need[2]
		if got < floor_n:
			return "%s beat fell short (%s < %d): %s" % [ghost, need[1], need[2], JSON.stringify(t)]
	return ""


func _run(ghost: StringName, fault: bool, record: bool) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data)
	var input: GhostReelInput = GhostReelInput.attach(s.stage, s.actions)
	input.reel.ghost = ghost
	s.world.loop().set_input(input)
	if fault:
		_attacks(s, ghost).block(ghost)[String(FAULTS[ghost])] = 0.0
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
	t["crush"] = _style(s, &"crush")
	t["split"] = _style(s, &"split")
	var replay: String = ""
	if record:
		replay = _replay(ghost, s.world.loop().finish_recording())
	s.world.free()
	bus.free()
	data.free()
	return {"state": buf.data_array, "telemetry": t, "replay": replay}


func _attacks(s: ArenaSession, ghost: StringName) -> GhostAttacks:
	if ghost == &"tonnage":
		return s.pilot.hauler.attacks
	if ghost == &"ohm":
		return s.pilot.ohm.attacks
	return s.pilot.kerf.attacks if ghost == &"kerf" else s.pilot.dent.attacks


func _style(s: ArenaSession, style: StringName) -> int:
	for h: ArenaHook in s.stage.hooks:
		if h is BrutalityHook:
			return (h as BrutalityHook).kills.by_style.get(style, 0)
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
