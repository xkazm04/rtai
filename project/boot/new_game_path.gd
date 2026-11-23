class_name NewGamePath
extends RefCounted
## The main menu owns the campaign. Embedded quest films, benchmarks and tapes keep
## their quest-only Start button. An embedding host can opt into the campaign menu.

const PROLOGUE: PackedScene = preload("res://boot/prologue/prologue.tscn")

var campaign_menu: bool = false
var prologue: PrologueGame


func press_start(game: Quest1Game) -> void:
	if prologue != null or game.session != null:
		return
	var main_menu: bool = game.is_inside_tree() and game.get_tree().current_scene == game
	var quest_film: bool = OS.is_debug_build() and LaunchArgs.has("--autostart")
	if (campaign_menu or main_menu) and not quest_film and not LaunchArgs.has("--skip-prologue"):
		open_prologue(game)
	else:
		game.start()


func open_prologue(game: Quest1Game) -> void:
	prologue = PROLOGUE.instantiate() as PrologueGame
	prologue.embedded = true
	game.card.hide_all()
	game.add_child(prologue)
	prologue.boot()
	@warning_ignore("return_value_discarded")
	prologue.encounter.finished.connect(_handover.bind(game), CONNECT_ONE_SHOT)


func _handover(game: Quest1Game) -> void:
	prologue.queue_free()
	prologue = null
	game.start()
