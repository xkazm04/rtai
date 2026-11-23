extends Scenario
## Real title button, pilot, end-card hold, quest subtitle and a separate cold Continue.

const MENU: PackedScene = preload("res://boot/quest1.tscn")


func run(tree: SceneTree) -> String:
	var original: String = Save.slots().root
	var scratch: String = TestTmp.dir("prologue_handover")
	SaveKit.wipe(scratch)
	Save.use_root(scratch)
	LaunchArgs.parse(["--seed=7"])
	var issue: String = _play(tree)
	if issue == "":
		issue = _resume(tree)
	if issue == "":
		issue = _skip(tree)
	Save.use_root(original)
	LaunchArgs.parse()
	PlayerActions.shipped().install()
	return issue


func _menu(tree: SceneTree, saving: bool) -> Quest1Game:
	var game: Quest1Game = MENU.instantiate() as Quest1Game
	game.new_game_path.campaign_menu = true
	game.settings_path = ""
	game.save_path = Checkpoint.DEFAULT_PATH if saving else ""
	tree.root.add_child(game)
	game.boot()
	return game


func _play(tree: SceneTree) -> String:
	var game: Quest1Game = _menu(tree, false)
	var drive: PrologueMenuDrive = PrologueMenuDrive.new()
	var issue: String = drive.press(game)
	if issue == "":
		var esc: InputEventAction = InputEventAction.new()
		esc.action = &"pause"
		esc.pressed = true
		game._unhandled_input(esc)
		if game.paused or game.card._panel.visible or game.new_game_path.prologue == null:
			issue = "the pause action interrupted the prologue"
	while issue == "" and drive.first_line_tick < 0:
		issue = drive.step()
	if issue == "":
		Log.info("scenario", "prologue handover: %s" % JSON.stringify(drive.result()))
		issue = write_evidence("prologue-handover.json", drive.result())
	_drop(game)
	return issue


func _resume(tree: SceneTree) -> String:
	var game: Quest1Game = _menu(tree, true)
	var drive: PrologueMenuDrive = PrologueMenuDrive.new()
	var issue: String = drive.press(game)
	var cp: Checkpoint
	var saved: Array[String] = []
	while issue == "" and game.new_game_path.prologue != null:
		cp = game.new_game_path.prologue.checkpoints.last
		if cp.beat not in saved:
			Save.flush()
			if Save.read_meta().get("point") != "prologue-" + cp.beat:
				issue = "missing autosave at " + cp.beat
				break
			saved.append(cp.beat)
		if cp.beat == "street_call":
			break
		issue = drive.step()
	Save.flush()
	_drop(game)
	if issue != "":
		return issue
	if saved != ["yard_arrival", "dale_patrol", "squad_arrival", "street_call"]:
		return "unexpected checkpoint sequence: " + str(saved)
	return _cold_continue(tree, cp)


func _cold_continue(tree: SceneTree, cp: Checkpoint) -> String:
	var game: Quest1Game = _menu(tree, true)
	var issue: String = ""
	if not game._can_continue():
		_drop(game)
		return "cold title did not offer Continue"
	game.card.continue_pressed.emit()
	var chapter: PrologueGame = game.new_game_path.prologue
	if (
		chapter == null
		or game.session != null
		or chapter.encounter.phase != PrologueEncounter.Phase.STREET
	):
		issue = "Continue missed the saved street beat"
	elif (
		chapter.world.context().clock.tick() != cp.tick
		or chapter.checkpoints.last.state_hash != cp.state_hash
	):
		issue = "Continue changed the street checkpoint tick or hash"
	_drop(game)
	return issue


func _skip(tree: SceneTree) -> String:
	LaunchArgs.parse(["--skip-prologue"])
	var game: Quest1Game = _menu(tree, false)
	game.card.start_button.pressed.emit()
	var direct: bool = game.session != null and game.new_game_path.prologue == null
	_drop(game)
	return "" if direct else "--skip-prologue failed to open quest 1 directly"


## The synchronous runner has not entered the tree, so _exit_tree cannot drop stage hooks.
func _drop(game: Quest1Game) -> void:
	for child: Node in game.get_children():
		if child is PrologueGame:
			var chapter: PrologueGame = child
			chapter.release()
	game.free()
