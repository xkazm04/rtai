extends GutTest

var game: Quest1Game
var previous_root: String


func before_each() -> void:
	previous_root = Save.slots().root
	var root: String = TestTmp.dir("prologue_routing")
	SaveKit.wipe(root)
	Save.use_root(root)
	game = Quest1Game.new()
	game.save_path = ""
	game.settings_path = ""
	add_child(game)


func after_each() -> void:
	game.free()
	Save.use_root(previous_root)
	LaunchArgs.parse()
	PlayerActions.shipped().install()


func _press_campaign_start() -> void:
	game.new_game_path.campaign_menu = true
	game.card.start_button.pressed.emit()


func test_menu_start_enters_prologue_once() -> void:
	_press_campaign_start()
	var opened: PrologueGame = game.new_game_path.prologue
	assert_not_null(opened)
	assert_false(game.card._panel.visible)
	game.card.start_pressed.emit()
	assert_same(game.new_game_path.prologue, opened)
	assert_null(game.session)


func test_skip_flag_opens_quest_one() -> void:
	LaunchArgs.parse(["--skip-prologue"])
	_press_campaign_start()
	assert_null(game.new_game_path.prologue)
	assert_not_null(game.session)


func test_embedded_quest_opens_quest_one_by_default() -> void:
	game.card.start_pressed.emit()
	assert_null(game.new_game_path.prologue)
	assert_not_null(game.session)


func test_autostart_film_keeps_its_opening() -> void:
	LaunchArgs.parse(["--autostart"])
	_press_campaign_start()
	assert_null(game.new_game_path.prologue)
	assert_not_null(game.session)


func test_continue_loads_prologue_save_even_with_skip_flag() -> void:
	game.save_path = Checkpoint.DEFAULT_PATH
	_press_campaign_start()
	var cp: Checkpoint = game.new_game_path.prologue.checkpoints.last
	assert_eq(cp.beat, "yard_arrival")
	game.free()
	game = Quest1Game.new()
	game.settings_path = ""
	add_child(game)
	LaunchArgs.parse(["--skip-prologue"])
	game.card.continue_pressed.emit()
	var chapter: PrologueGame = game.new_game_path.prologue
	assert_not_null(chapter)
	assert_null(game.session)
	assert_eq(chapter.world.context().clock.tick(), cp.tick)
	assert_eq(chapter.checkpoints.last.state_hash, cp.state_hash)
	assert_true(chapter.checkpoints.writing)


func test_handover_save_uses_quest_one_reader_and_continue() -> void:
	game.save_path = Checkpoint.DEFAULT_PATH
	_press_campaign_start()
	var chapter: PrologueGame = game.new_game_path.prologue
	chapter.encounter.finished.emit()
	assert_true(chapter.is_queued_for_deletion())
	assert_null(game.new_game_path.prologue)
	var hash_before: String = game.session.world.loop().state_hash()
	game.card.continue_pressed.emit()
	assert_not_null(game.session)
	assert_eq(game.session.beat_id(), "b1-dumpster")
	assert_eq(game.session.world.loop().state_hash(), hash_before)


func test_replay_rejects_the_wrong_beat_and_state_hash() -> void:
	game.save_path = Checkpoint.DEFAULT_PATH
	_press_campaign_start()
	var cp: Checkpoint = game.new_game_path.prologue.checkpoints.last
	var body: Dictionary = cp.to_dict()
	var orphans: float = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	body["beat"] = "street_call"
	assert_true(game.new_game_path.accept(body) == null)
	body = cp.to_dict()
	body["state_hash"] = "0".repeat(64)
	assert_true(game.new_game_path.accept(body) == null)
	assert_eq(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT), orphans)
