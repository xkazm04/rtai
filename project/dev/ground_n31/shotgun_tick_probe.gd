extends Node
## n31-19: the prologue's first shotgun shot tick under --bot --seed=7, headless
## (the pin of test_prologue_pump_tell).

const KNOWN_FLAGS: PackedStringArray = []
const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")


func _ready() -> void:
	LaunchArgs.parse(["--bot", "--seed=7"])
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child(game)
	game.world.set_process(false)
	game._open_view(game.stage.plan as PrologueYard)
	var cycle: PrologueShotgun = game.encounter.battle.fire.shotgun
	while cycle.shot_ticks.is_empty() and game.stage.tick < 30000:
		game.world.loop().step()
	Log.info("shotgun-tick", "first shot %s at stage tick %d" % [cycle.shot_ticks, game.stage.tick])
	get_tree().quit(0)
