extends SceneTree
## ghost-forms (dev): the shipped quest 1 (boot/quest1.tscn, the sprite cast, no --rigs) started
## past its title card and played through real input events by CollectCallInputDriver (the pad a
## player holds), for filming the story voice (StoryVoice) on the quest's own whispers: b1's hide
## in the dumpster is the first. Needs a window. Usage: godot --path project --screen 0
##   --resolution 1280x800 --write-movie <avi> --quit-after <frames>
##   -s res://dev/ghost-forms/quest1_shipped_main.gd

const SCENE: String = "res://boot/quest1.tscn"
## Loaded at run time: a SceneTree script compiles before the autoloads, so no class names here.
const DRIVER: String = "res://dev/bots/collect_call_input_driver.gd"

var _game: Node = null
var _driver: Object = null


func _initialize() -> void:
	var packed: PackedScene = load(SCENE) as PackedScene
	if packed == null:
		printerr("quest1_shipped: %s does not load" % SCENE)
		quit(1)
		return
	_game = packed.instantiate()
	root.add_child(_game)
	_game.call_deferred(&"start")
	@warning_ignore("return_value_discarded")
	process_frame.connect(_drive)


func _drive() -> void:
	var session: Object = _game.get(&"session")
	if session == null:
		return
	if _driver == null:
		var script: GDScript = load(DRIVER) as GDScript
		_driver = script.new(session.get(&"stage"), session.get(&"system"))
	if not _driver.call(&"done"):
		_driver.call(&"act")
