extends Scenario
## Quest 1 runs its pilot before the city resolves the street bodies. Observe both positions
## after the whole world step, including the one the city will hand to the pilot next tick.


func run(_tree: SceneTree) -> String:
	var tape: StreetMovesTape = StreetMovesTape.new()
	var first: StreetMovesTrace = StreetMovesTrace.record(tape)
	if first.failure != "":
		return first.failure
	var replay: StreetMovesTrace = StreetMovesTrace.record(tape, first)
	if replay.failure != "":
		return replay.failure
	if (
		first.digest != replay.digest
		or first.counts != replay.counts
		or first.starts != replay.starts
	):
		return "street replay changed final digest or counters"
	Log.info("moves_street", "replay identical %s, %s" % [first.digest, first.counts])
	Log.info("moves_street", "vaults %s at ticks %s" % [first.kinds, first.starts])
	if not first.first_footprint.is_empty():
		Log.info(
			"moves_street", "unconditional 2D footprint counterexample: " + first.first_footprint
		)
	Log.info(
		"moves_street",
		(
			"centres over target: stage %d city %d; road landings near traffic %d"
			% [first.target_feet, first.target_resolved, first.road_landings]
		)
	)
	var coverage: String = _coverage(first)
	if coverage != "":
		return coverage
	var control: String = _station_control(tape, true)
	return _off(tape) if control.is_empty() else control


func _coverage(first: StreetMovesTrace) -> String:
	for k: String in first.counts:
		if k not in ["overlaps", "snaps"] and first.counts[k] == 0:
			return "missing street coverage: " + k
	if first.road_landings == 0 or not _crossed_both(first.kinds):
		return "expected a parked car, kerb furniture, and a road landing beside moving traffic"
	return ""


func _crossed_both(kinds: Dictionary[String, int]) -> bool:
	var parked: bool = false
	var furniture: bool = false
	for kind: String in kinds:
		parked = parked or StreetMovesTape.CARS.has(kind)
		furniture = furniture or not StreetMovesTape.CARS.has(kind)
	return parked and furniture


## Quest cover has no protecting station face. Exercise the same cover edge beside an actual
## station on the city block, counting its snap separately from the quest's refusals.
func _station_control(tape: StreetMovesTape, expected: bool) -> String:
	var plan: ArenaPlan = ArenaPlan.shipped()
	var stations: ArenaStations = ArenaStations.new()
	stations.add_file(ArenaStations.DIR + "/arena.json")
	var stage: ArenaStage = ArenaStage.new(ArenaPlan.shipped(plan.city_base), stations)
	stage.cells = StageCells.shipped()
	stage.setup(World.build_context(Events, Data, StreetMovesTape.SEED))
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	stage.pilot.motion.vault.bind_solids(stage)
	stage.arena.rivet.pos = plan.city_base + Vector2(4, 11.75)
	for word: int in tape.words:
		var c: TickInput = TickInput.unpack(word)
		var buttons: int = c.buttons
		if (
			(buttons & (1 << stage.pilot.actions.bit(&"cover"))) == 0
			or (buttons & (1 << stage.pilot.actions.bit(&"roll"))) != 0
		):
			continue
		stage.step(0, c)
		var snapped: bool = stage.pilot.motion.cover.spot != null
		Log.info("moves_street", "city-block station control snaps %d" % int(snapped))
		if snapped != expected:
			return "recorded cover press at a city-block station: expected snap %s" % expected
		return VaultTrial.forbidden_contact(stage)
	return "no cover edge in the street tape"


func _off(tape: StreetMovesTape) -> String:
	var saved: PackedStringArray = LaunchArgs.unknown()
	for flag: String in LaunchArgs.KNOWN_FLAGS:
		if LaunchArgs.has(flag):
			@warning_ignore("return_value_discarded")
			saved.append("%s=%s" % [flag, LaunchArgs.value(flag)])
	LaunchArgs.parse(PackedStringArray(["--no-vault", "--no-cover"]))
	var off: StreetMovesTrace = StreetMovesTrace.record(tape)
	var station: String = _station_control(tape, false)
	LaunchArgs.parse(saved)
	if off.failure != "":
		return off.failure
	Log.info("moves_street", "off %s" % off.counts)
	return (
		station
		if off.counts["vault_starts"] == 0 and off.counts["snaps"] == 0
		else "off moves fired"
	)
