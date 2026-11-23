extends GutTest

var game: Quest1Game


func before_each() -> void:
	game = Quest1Game.new()
	game.save_path = ""
	game.settings_path = ""
	game.new_game_path.campaign_menu = true
	add_child(game)


func after_each() -> void:
	game.free()
	LaunchArgs.parse()
	PlayerActions.shipped().install()


func test_menu_start_enters_prologue_once() -> void:
	game.card.start_button.pressed.emit()
	var opened: PrologueGame = game.new_game_path.prologue
	assert_not_null(opened)
	game.card.start_pressed.emit()
	assert_same(game.new_game_path.prologue, opened)
	assert_null(game.session)


func test_skip_flag_opens_quest_one() -> void:
	LaunchArgs.parse(["--skip-prologue"])
	game.card.start_button.pressed.emit()
	assert_null(game.new_game_path.prologue)
	assert_not_null(game.session)


func test_embedded_quest_and_autostart_film_open_quest_one() -> void:
	game.new_game_path.campaign_menu = false
	game.card.start_pressed.emit()
	assert_null(game.new_game_path.prologue)
	assert_not_null(game.session)


func test_autostart_film_keeps_its_opening() -> void:
	LaunchArgs.parse(["--autostart"])
	game.card.start_pressed.emit()
	assert_null(game.new_game_path.prologue)
	assert_not_null(game.session)
