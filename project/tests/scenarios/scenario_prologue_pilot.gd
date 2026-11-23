extends Scenario
## The same scene, input source and 60 Hz loop as --bot, stepped without rendering
## or sleeping between ticks. A missing gate, answer or accept times out in its phase.

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
const PILOT: GDScript = preload("res://dev/bots/prologue_bot.gd")
const Watch = preload("res://dev/prologue_yard/yard_motion_watch.gd")
const BUDGET: int = 300 * SimClock.TICK_RATE
## SHA-256 over PrologueGame's sorted result JSON at the end card, measured before line_fire.
const LEGACY: Dictionary[int, String] = {
	7: "3d7547b9331afafe2946c4fe894c9e06a7691526e6e2e5034408f4863b7108cc",
	3: "e8e3f3843e5739d21b15759df6b273e1347b1bbfc199562e02835c0cdfa9b592",
	11: "0bc70fe79eb40f1cf7e03506e88ab88dfe4def6459fef0a3ee40ee268ff9b361",
	21: "f2db6c6381d3adc5b44f6a54cd68582daaa7b569a1f5770895c38c70af3b25c8",
	42: "c24e6541726ff885917bc6dd0210a21f33db7dd397ad67c29e514714d9207b7d",
}
const LINE_FIRE_TICKS: Dictionary[int, int] = {7: 11701, 3: 13014, 11: 10392, 21: 12158, 42: 13278}
## The cover milestone's sorted result bytes, before the dusk art and lights.
const COVER_SEED_7: String = "993e5b7f080f30c0fa8f1def74e274f6762e6a05a757859e354d41e45083eeba"


func run(tree: SceneTree) -> String:
	var reasons: Array[String] = []
	var measurements: Array[Dictionary] = []
	for dressing: String in ["", "torn_line", "plain"]:
		for seed_value: int in LINE_FIRE_TICKS:
			var flags: PackedStringArray = ["--seed=%d" % seed_value]
			if not dressing.is_empty():
				@warning_ignore("return_value_discarded")
				flags.append("--yard-dressing=" + dressing)
			LaunchArgs.parse(flags)
			var reason: String = _run_seed(tree, measurements)
			if not reason.is_empty():
				reasons.append("%s seed %d: %s" % [dressing, seed_value, reason])
	LaunchArgs.parse()
	var error: String = write_evidence("prologue-yard-pilots.json", {"runs": measurements})
	if error != "":
		reasons.append(error)
	return ", ".join(reasons)


func _run_seed(tree: SceneTree, measurements: Array[Dictionary]) -> String:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	tree.root.add_child(game)
	game.boot()
	game.world.set_process(false)
	var loop: SimLoop = game.world.loop()
	var pilot: InputSource = PILOT.new(game.stage, game.encounter)
	loop.set_input(pilot)
	var watch: Watch = Watch.new()
	watch.sample(game)
	var lowest: float = game.stage.arena.rivet.hp
	while game.encounter.street.end_tick < 0 and game.world.context().clock.tick() < BUDGET:
		loop.step()
		lowest = minf(lowest, game.stage.arena.rivet.hp)
		watch.sample(game)
	var result: Dictionary = game.result()
	var summary: Dictionary = {
		"dressing": (game.stage.plan as PrologueYard).dressing.id,
		"seed": result["seed"],
		"ended": result["ended"],
		"ticks": result["ticks"],
		"deaths": result["deaths"],
		"min_hp": lowest,
		"stuck": watch.stuck,
		"sha256": (JSON.stringify(result, "  ", true) + "\n").sha256_text()
	}
	measurements.append(summary)
	Log.info("scenario", "prologue pilot " + JSON.stringify(summary))
	var reason: String = _progress(game, result)
	if reason == "":
		reason = _dialogue(game.lines, game.encounter.spans)
	if reason == "":
		reason = _pin(summary)
	game.release()
	game.free()
	PlayerActions.shipped().install()
	return reason


func _pin(row: Dictionary) -> String:
	var seed_value: int = row["seed"]
	if row["dressing"] == "line_fire":
		if seed_value == 7 and row["sha256"] != COVER_SEED_7:
			return "seed-7 cover result bytes changed: " + str(row["sha256"])
		if row["ticks"] != LINE_FIRE_TICKS[seed_value]:
			return "finished in %d ticks, expected %d" % [row["ticks"], LINE_FIRE_TICKS[seed_value]]
	elif row["sha256"] != LEGACY[seed_value]:
		return "legacy result bytes changed: " + str(row["sha256"])
	return ""


func _progress(game: PrologueGame, result: Dictionary) -> String:
	var encounter: PrologueEncounter = game.encounter
	if not result["ended"]:
		return (
			"tick budget %d expired in encounter %d, street %d at %s"
			% [BUDGET, encounter.phase, encounter.street.phase, game.stage.arena.rivet.pos]
		)
	if result["beats_reached"] != [1, 2, 3]:
		return "unexpected beat order %s" % str(result["beats_reached"])
	if not encounter.patrol.cleared() or result["wave_one"]["standing"] != 0:
		return "patrol survived wave one"
	if encounter.battle.formation.boss.alive() or encounter.battle.formation.men_standing():
		return "commander or squad survived wave two"
	if not result.get("pistol_left", false) or game.stage.pilot.wheel.order() != [&"hands"]:
		return "pistol still carried at the gate"
	return _milestones(result)


func _milestones(result: Dictionary) -> String:
	var previous: int = -1
	for key: String in [
		"dale_died_tick",
		"wave_one_cleared_tick",
		"pistol_picked_tick",
		"mulroney_died_tick",
		"call_answered_tick",
		"channel_accepted_tick",
		"end_tick"
	]:
		var tick: int = result.get(key, -1)
		if tick <= previous:
			return "%s missing or out of order (%d after %d)" % [key, tick, previous]
		previous = tick
	if result.get("wave_two_cleared_tick", -1) != result["mulroney_died_tick"]:
		return "wave two did not clear on Mulroney's fall"
	if not result["call_answered"] or not result["channel_accepted"]:
		return "phone or radio never connected"
	return ""


func _dialogue(lines: PrologueLines, spans: Array[Dictionary]) -> String:
	var data: DataTable = DataTable.open(PrologueLines.TABLE, PrologueLines.SCHEMA)
	var expected: Array[String] = []
	for span: Dictionary in spans:
		# The hands checkpoint resumes after Dale's dialogue. The squad checkpoint replays beat two.
		if span["id"] == "dale_patrol":
			continue
		for row: Dictionary in data.array(data.raw, "rows"):
			if row["k"] == "line" and row["beat"] == span["beat"]:
				expected.append(str(row["id"]))
	if lines.shown != expected or lines.events.size() != expected.size():
		return (
			"expected %d spoken rows in checkpoint order, saw %s" % [expected.size(), lines.shown]
		)
	for i: int in expected.size():
		var event: Dictionary = lines.events[i]
		if event["id"] != expected[i] or not event["shown"] or event.get("skipped", false):
			return "pilot missed or skipped spoken row %s" % expected[i]
	return ""
