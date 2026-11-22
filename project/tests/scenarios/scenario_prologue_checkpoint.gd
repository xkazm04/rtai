extends Scenario
## Exercise the two combat checkpoints in one unskipped pilot run. The only synthetic
## input is the lethal hit, after the pilot has already changed the state of each wave.

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
const PILOT: GDScript = preload("res://dev/bots/prologue_bot.gd")
const LIMIT: int = 360 * SimClock.TICK_RATE

var _forced: int = 0
var _verified: int = 0
var _previous: Array[Fighter] = []
var _spoken: Array[String] = []
var _squad_start: Vector2 = Vector2.INF
var _mark: Vector2 = Vector2.INF


func run(tree: SceneTree) -> String:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	tree.root.add_child(game)
	game.boot()
	game.world.set_process(false)
	game.result_path = TestTmp.dir("prologue_checkpoint").path_join("result.json")
	var pilot: InputSource = PILOT.new(game.stage, game.encounter)
	game.world.loop().set_input(pilot)
	var reason: String = ""
	while game.encounter.street.end_tick < 0 and game.stage.tick < LIMIT and reason.is_empty():
		game.world.loop().step()
		reason = _observe(game)
	if reason.is_empty():
		reason = _saved_result(game)
	Log.info(
		"scenario",
		(
			"prologue checkpoints: %d restores, end tick %d"
			% [_verified, game.encounter.street.end_tick]
		)
	)
	game.release()
	game.free()
	PlayerActions.shipped().install()
	return reason


func _observe(game: PrologueGame) -> String:
	var encounter: PrologueEncounter = game.encounter
	if encounter.deaths > _verified:
		if encounter.deaths != _forced or encounter.deaths != _verified + 1:
			return "unexpected death at tick %d" % game.stage.tick
		_verified += 1
		return _restored(game)
	if _forced != _verified:
		return ""
	var arena: CombatArena = game.stage.arena
	var battle: PrologueBattle = encounter.battle
	if game.stage.tick == encounter.done_tick:
		_squad_start = arena.rivet.pos
	if battle.pistol.marked_tick == game.stage.tick:
		_mark = game.stage.pilot.carry.ground.items[0].pos
	if _forced == 0 and encounter.phase == PrologueEncounter.Phase.HANDS:
		if arena.hostiles_alive() < 9:
			_kill(game)
	elif _forced == 1 and battle.ranged and arena.rivet.weapon == battle.pistol.id:
		if arena.hostiles_alive() < 8:
			_kill(game)
	return ""


func _kill(game: PrologueGame) -> void:
	_forced += 1
	_previous.assign(game.stage.arena.hostiles)
	_spoken.assign(game.lines.shown)
	game.stage.arena.rivet.take(game.stage.arena.rivet.max_hp, game.stage.tick, Vector2.LEFT)


func _restored(game: PrologueGame) -> String:
	var encounter: PrologueEncounter = game.encounter
	var hands: bool = _verified == 1
	var checkpoint: String = "dale_patrol" if hands else "squad_arrival"
	var phase: PrologueEncounter.Phase = (
		PrologueEncounter.Phase.HANDS if hands else PrologueEncounter.Phase.BEAT_TWO
	)
	if encounter.phase != phase or encounter.spans.size() < 2:
		return "left %s after death %d" % [checkpoint, _verified]
	var prior: Dictionary = encounter.spans[-2]
	var next: Dictionary = encounter.spans.back()
	if prior["id"] != checkpoint or prior["end_reason"] != "death" or next["id"] != checkpoint:
		return "wrong checkpoint boundary: %s -> %s" % [prior, next]
	if prior["end_tick"] != game.stage.tick or next["start_tick"] != game.stage.tick:
		return "checkpoint did not restart on the respawn tick"
	return _cast(game, hands)


func _cast(game: PrologueGame, hands: bool) -> String:
	var arena: CombatArena = game.stage.arena
	var expected: Vector2 = game.encounter.patrol.wave_start if hands else _squad_start
	if not arena.rivet.pos.is_equal_approx(expected) or arena.rivet.hp != arena.rivet.max_hp:
		return "Rivet did not restart healthy at %s (got %s)" % [expected, arena.rivet.pos]
	if arena.hostiles_alive() != (9 if hands else 8):
		return "wrong number of standing officers after death %d" % _verified
	for h: Fighter in arena.hostiles:
		if h.alive() and (h in _previous or h.hp != h.max_hp):
			return "officer %d was not freshly spawned after death %d" % [h.id, _verified]
	return _loadout_and_lines(game, hands)


func _loadout_and_lines(game: PrologueGame, hands: bool) -> String:
	var arena: CombatArena = game.stage.arena
	var carry: RivetCarry = game.stage.pilot.carry
	if (
		game.stage.pilot.wheel.order() != [&"hands"]
		or arena.rivet.weapon != &""
		or arena.gun != null
	):
		return "Rivet respawned armed"
	if hands:
		if game.encounter.patrol.dale.alive() or not carry.ground.items.is_empty():
			return "Dale or a floor pistol returned at the hands checkpoint"
		if game.lines.busy() or game.lines.shown != _spoken:
			return "the opening conversation replayed on the hands checkpoint"
		return ""
	var opening: String = "b2_l01_mulroney_line_up"
	_spoken.append(opening)
	if game.lines.current != opening or game.lines.shown != _spoken:
		return "the squad checkpoint did not restart with its own opening line"
	return _pistol(carry)


func _pistol(carry: RivetCarry) -> String:
	if carry.ground.items.size() != 1 or not carry.first_seen.is_empty():
		return "the collected pistol did not return to the ground"
	var item: WeaponPickups.Item = carry.ground.items[0]
	if item.id != &"pistol" or not item.pos.is_equal_approx(_mark):
		return "wrong pistol or mark after the squad checkpoint"
	return ""


func _saved_result(game: PrologueGame) -> String:
	if _verified != 2 or game.encounter.street.end_tick < 0:
		return "pilot stopped at tick %d after %d restores" % [game.stage.tick, _verified]
	if not FileAccess.file_exists(game.result_path):
		return "end card did not write the checkpoint run result"
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(game.result_path))
	if not parsed is Dictionary:
		return "unreadable checkpoint run result"
	var result: Dictionary = parsed
	if result.get("deaths") != 2 or result.get("beat_two_deaths") != 1:
		return "saved result did not count the two deaths, one in each wave"
	if (
		not result.get("ended")
		or not result.get("channel_accepted")
		or not result.get("pistol_left")
	):
		return "saved result missed the pistol handoff, radio or end card"
	return _dialogue(result)


func _dialogue(result: Dictionary) -> String:
	var table: DataTable = DataTable.open(PrologueLines.TABLE, PrologueLines.SCHEMA)
	var expected: Array[String] = []
	for beat: int in [1, 2, 2, 3]:
		for row: Dictionary in table.array(table.raw, "rows"):
			if row["beat"] == beat and row["k"] == "line":
				expected.append(str(row["id"]))
	if expected != result.get("lines_shown"):
		return "unexpected dialogue replay or missing row after the two deaths"
	return ""
