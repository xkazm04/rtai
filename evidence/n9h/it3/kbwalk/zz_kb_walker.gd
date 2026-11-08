extends Node
## Scratch (n9 it3, not committed): quest 1 on a desktop row walked on keyboard events only.

var out: String = ""
var dev: String = "desktop_kb_glyphs"


func _ready() -> void:
	var a: PackedStringArray = OS.get_cmdline_user_args()
	out = a[0] if a.size() > 0 else "C:/tmp"
	dev = a[1] if a.size() > 1 else dev
	_walk.call_deferred()


func _walk() -> void:
	DeviceProfile.select(dev).apply(get_window())
	PlayerActions.shipped().install()
	var root: Window = get_tree().root
	var game: Quest1Game = (load("res://boot/quest1.tscn") as PackedScene).instantiate() as Quest1Game
	game.save_path = ""
	game.settings_path = ""
	root.add_child(game)
	game.boot()
	await _frames(20)
	_say("title focus %s" % _focus())
	await _shot(dev + "-1-title")
	_key(KEY_ENTER)
	await _frames(360)
	_key(KEY_D)  # a key: the prompts follow the device used last
	await _frames(30)
	_say("after A: session %s" % (game.session != null))
	await _shot(dev + "-2-prompt")
	_key(KEY_ESCAPE)
	await _frames(20)
	_say("after Start: paused %s focus %s" % [game.paused, _focus()])
	await _shot(dev + "-3-pause")
	get_tree().quit(0)


func _focus() -> String:
	var c: Control = get_tree().root.gui_get_focus_owner()
	if c == null:
		return "none"
	var t: String = (c as Button).text if c is Button else c.name
	var row: Node = c.get_parent()
	var lead: String = (row.get_child(0) as Label).text if row.get_child(0) is Label else ""
	return "%s [%s]" % [t, lead]


func _pad(b: JoyButton) -> void:
	for down: bool in [true, false]:
		var ev: InputEventJoypadButton = InputEventJoypadButton.new()
		ev.button_index = b
		ev.pressed = down
		Input.parse_input_event(ev)


func _key(k: Key) -> void:
	for down: bool in [true, false]:
		var ev: InputEventKey = InputEventKey.new()
		ev.keycode = k
		ev.physical_keycode = k
		ev.pressed = down
		Input.parse_input_event(ev)


func _frames(n: int) -> void:
	for i: int in n:
		await get_tree().process_frame


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var err: Error = get_tree().root.get_texture().get_image().save_png(out.path_join(name + ".png"))
	_say("shot %s (%d)" % [name, err])


func _say(s: String) -> void:
	Log.info("padwalk", s)
