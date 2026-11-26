extends Scenario
## The same scene, input source and 60 Hz loop as --bot, stepped without rendering
## or sleeping between ticks. A missing gate, answer or accept times out in its phase.

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
const PILOT: GDScript = preload("res://dev/bots/prologue_bot.gd")
const Watch = preload("res://dev/prologue_yard/yard_motion_watch.gd")
const BUDGET: int = 300 * SimClock.TICK_RATE
## SHA-256 over PrologueGame's sorted result JSON at the end card (torn_line and plain), measured
## before line_fire; re-pinned in n31 melee 02p3b (the melee hit follows the drawn blade).
const LEGACY: Dictionary[int, String] = {
	7: "34263b7abd8a43dd995c9752c41d606cbe1cd39eb989bc44dad49917e1db3d7e",
	3: "4a9e9741a6c6f9245ac37dd7a6027c00fc2160de92cd810d038e276eb6d49dc6",
	11: "37516f5d82a98c75091ccc26302107b8893daed1ad145e9c18fac2e8ad1080b6",
	21: "cc779316abfe0865722c4aec07cd01e38bf06856249ab9b52fa2e7060743d36e",
	42: "f00023e7f663761d256aae5643a305f9c1827793751a239d02f7d0eee9a54178",
}
## Finish ticks per seed, re-pinned in n31 melee 02p3b (melee sweep on).
const LINE_FIRE_TICKS: Dictionary[int, int] = {7: 11123, 3: 9956, 11: 10616, 21: 10168, 42: 10333}
## The shipped default is arched_line: raised_line's collision, so these ticks (raised_line one
## flag away). Since the melee sweep (n31 melee 02p3b) they no longer share line_fire's run.
const RAISED_LINE_TICKS: Dictionary[int, int] = {7: 11717, 3: 11210, 11: 10031, 21: 9576, 42: 10029}
## Seed 7's sorted result bytes per collision (raised_line, arched_line and line_fire),
## re-pinned on the n31 merge (melee sweep on + ground's yard footprints).
const COVER_SEED_7: String = "2285282b2739e400e99967142b2c2be6bb908fad224f1df965596879e300efa1"
const LINE_FIRE_SEED_7: String = "30fca0d8671cede4c9babb875db20e9b8c4b71076b0a80ccc097a52307c5ab0a"
## arched_line since n31-19: its conveyor boxes on the drawn machines' base, 12 solid arch supports.
const ARCHED_LINE_TICKS: Dictionary[int, int] = {
	7: 17712, 3: 10765, 11: 12611, 21: 10199, 42: 11758
}
const ARCHED_SEED_7: String = "eb040b06699ea72aa14f0b0283f26e6f6a46ae33faf607da89f8244086ca9068"


func run(tree: SceneTree) -> String:
	var reasons: Array[String] = []
	var measurements: Array[Dictionary] = []
	for dressing: String in ["", "raised_line", "line_fire", "torn_line", "plain"]:
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
	if row["dressing"] in ["line_fire", "raised_line", "arched_line"]:
		var arched: bool = row["dressing"] == "arched_line"
		var pinned: Dictionary[int, int] = (
			LINE_FIRE_TICKS
			if row["dressing"] == "line_fire"
			else (ARCHED_LINE_TICKS if arched else RAISED_LINE_TICKS)
		)
		var seed_7: String = ARCHED_SEED_7 if arched else COVER_SEED_7
		if row["dressing"] == "line_fire":
			seed_7 = LINE_FIRE_SEED_7
		if seed_value == 7 and row["sha256"] != seed_7:
			return "seed-7 cover result bytes changed: " + str(row["sha256"])
		if row["ticks"] != pinned[seed_value]:
			return "finished in %d ticks, expected %d" % [row["ticks"], pinned[seed_value]]
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
