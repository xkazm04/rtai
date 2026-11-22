extends Scenario
## Two fresh arenas play the first Ohm cast from the same pad inputs.

const SEED: int = 1  # Rivet gets an uninterrupted wind-up on this opening cast.


func run(_tree: SceneTree) -> String:
	var first: Dictionary = _cast()
	var second: Dictionary = _cast()
	if first != second:
		return "delayed Ohm cast diverged across the two runs"
	if first["release"] != first["decision"] + 3 or first["struck"] < 1:
		return "expected a bolt and a hit three ticks after the press: %s" % first
	return write_evidence("ohm-bolt-delay.json", first)


func _cast() -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	LaunchArgs.parse(["--ohm-bolt-delay=on", "--controls=" + String(ControlsMode.id())])
	var s: ArenaSession = ArenaSession.open(bus, data, SEED)
	LaunchArgs.parse()
	var input: GhostReelInput = GhostReelInput.attach(s.stage, s.actions)
	input.reel.ghost = OhmStage.GHOST
	s.world.loop().set_input(input)
	s.world.loop().start_recording()
	s.step()
	var decision: int = input.reel.started_tick + OhmBeat.FIRST_BOLT
	var hashes: Array[String] = []
	while s.tick() < decision + 5:
		s.step()
		if s.stage.tick >= decision:
			hashes.append(s.world.loop().state_hash())
	var result: Dictionary = {
		"decision": decision,
		"release": s.pilot.ohm.bolt_tick,
		"struck": s.pilot.ohm.struck,
		"cast_hashes": hashes,
		"replay": s.world.loop().finish_recording().to_dict(),
	}
	s.world.free()
	bus.free()
	data.free()
	return result
