extends Scenario
## The same scene, input source and 60 Hz loop as --bot, stepped without rendering
## or sleeping between ticks. A missing gate, answer or accept times out in its phase.

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
const PILOT: GDScript = preload("res://dev/bots/prologue_bot.gd")
const BUDGET: int = 300 * SimClock.TICK_RATE


func run(tree: SceneTree) -> String:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	tree.root.add_child(game)
	game.boot()
	game.world.set_process(false)
	var pilot: InputSource = PILOT.new(game.stage, game.encounter)
	var loop: SimLoop = game.world.loop()
	loop.set_input(pilot)
	while game.encounter.street.end_tick < 0 and game.world.context().clock.tick() < BUDGET:
		loop.step()
	var result: Dictionary = game.result()
	var reason: String = _progress(game, result)
	if reason == "":
		reason = _dialogue(game.lines)
	Log.info(
		"scenario", "prologue pilot: %d ticks, %d deaths" % [result["ticks"], result["deaths"]]
	)
	game.release()
	game.free()
	PlayerActions.shipped().install()
	return reason


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


func _dialogue(lines: PrologueLines) -> String:
	var data: DataTable = DataTable.open(PrologueLines.TABLE, PrologueLines.SCHEMA)
	var expected: Array[String] = []
	for row: Dictionary in data.array(data.raw, "rows"):
		if row["k"] == "line":
			expected.append(str(row["id"]))
	if lines.shown != expected or lines.events.size() != expected.size():
		return (
			"expected %d spoken rows once in table order, saw %s" % [expected.size(), lines.shown]
		)
	for i: int in expected.size():
		var event: Dictionary = lines.events[i]
		if event["id"] != expected[i] or not event["shown"] or event.get("skipped", false):
			return "pilot missed or skipped spoken row %s" % expected[i]
	return ""
