extends SceneTree
## ghost-forms (dev): the shipped quest 1 (boot/quest1.tscn, the sprite cast, no --rigs) started
## past its title card and played through real input events (the left stick and the bound keys
## of power_hauler / power_gearbox, as a player presses them), for filming the ghost forms on the
## shipped path (StoryForms): walk, Q into Tonnage, walk, Q out, G to Dent, Q in, G to Kerf, G to
## Ohm, Q out. Needs a window. Usage: godot --path project --screen 0 --resolution 1280x800
##   --write-movie <avi> --quit-after 1140 -s res://dev/ghost-forms/quest1_forms_main.gd
##   [-- --ppm=64] (the close-up: the game's own zoom, px per metre)

const SCENE: String = "res://boot/quest1.tscn"
## The presses (one frame down, then up): PRESS_AT[i] presses PRESS[i].
const PRESS_AT: Array[int] = [150, 420, 520, 560, 740, 900, 1060]
const PRESS: Array[StringName] = [
	&"power_hauler",
	&"power_hauler",
	&"power_gearbox",
	&"power_hauler",
	&"power_gearbox",
	&"power_gearbox",
	&"power_hauler",
]
## The left stick: STICK[i] from frame STICK_AT[i] on.
const STICK_AT: Array[int] = [0, 60, 140, 200, 400, 600, 720, 770, 880, 930, 1040]
const STICK: Array[Vector2] = [
	Vector2.ZERO,
	Vector2(0.6, 0.0),
	Vector2.ZERO,
	Vector2(0.7, 0.3),
	Vector2.ZERO,
	Vector2(-0.7, 0.0),
	Vector2.ZERO,
	Vector2(0.0, 0.8),
	Vector2.ZERO,
	Vector2(0.5, -0.4),
	Vector2.ZERO,
]

var _game: Node = null
var _frame: int = 0


func _initialize() -> void:
	var packed: PackedScene = load(SCENE) as PackedScene
	if packed == null:
		printerr("quest1_forms: %s does not load" % SCENE)
		quit(1)
		return
	_game = packed.instantiate()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--ppm="):
			_game.set(&"px_per_m", arg.substr(6).to_float())
	root.add_child(_game)
	_game.call_deferred(&"start")
	@warning_ignore("return_value_discarded")
	process_frame.connect(_drive)


func _drive() -> void:
	if _game.get(&"session") == null:
		return
	_frame += 1
	for i: int in STICK_AT.size():
		if STICK_AT[i] == _frame:
			_axis(JOY_AXIS_LEFT_X, STICK[i].x)
			_axis(JOY_AXIS_LEFT_Y, STICK[i].y)
	for i: int in PRESS_AT.size():
		if PRESS_AT[i] == _frame:
			_key(PRESS[i], true)
			printerr("quest1_forms: frame %d press %s" % [_frame, PRESS[i]])
		elif PRESS_AT[i] + 2 == _frame:
			_key(PRESS[i], false)
	Input.flush_buffered_events()


func _axis(axis: JoyAxis, value: float) -> void:
	var ev: InputEventJoypadMotion = InputEventJoypadMotion.new()
	ev.device = 0
	ev.axis = axis
	ev.axis_value = value
	Input.parse_input_event(ev)


func _key(action: StringName, down: bool) -> void:
	for bound: InputEvent in InputMap.action_get_events(action):
		if bound is InputEventKey:
			var ev: InputEventKey = bound.duplicate() as InputEventKey
			ev.pressed = down
			Input.parse_input_event(ev)
			return
