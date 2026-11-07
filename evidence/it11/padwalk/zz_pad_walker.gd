extends Node
## Scratch (it11, not committed): quest 1 under the Deck row walked on pad events only.

var out: String = ""


func _ready() -> void:
	out = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "C:/tmp"
	_walk.call_deferred()


func _walk() -> void:
	DeviceProfile.select("deck").apply(get_window())
	var root: Window = get_tree().root
	var game: Quest1Game = (load("res://boot/quest1.tscn") as PackedScene).instantiate() as Quest1Game
	game.save_path = ""
	game.settings_path = ""
	root.add_child(game)
	game.boot()
	await _frames(20)
	_say("title focus %s" % _focus())
	await _shot("pad-walk-1-title")
	_pad(JOY_BUTTON_A)
	await _frames(90)
	_say("after A: session %s" % (game.session != null))
	_pad(JOY_BUTTON_START)
	await _frames(20)
	_say("after Start: paused %s focus %s" % [game.paused, _focus()])
	for i: int in 1:
		_pad(JOY_BUTTON_DPAD_UP)
		await _frames(3)
	_say("after 1 up: focus %s" % _focus())
	_pad(JOY_BUTTON_A)
	await _frames(10)
	_say("after A: cap %d max_fps %d focus %s" % [game.settings.frame_cap, Engine.max_fps, _focus()])
	await _shot("pad-walk-2-pause-cap30")
	_pad(JOY_BUTTON_A)
	await _frames(10)
	_say("after A: cap %d max_fps %d" % [game.settings.frame_cap, Engine.max_fps])
	await _shot("pad-walk-3-pause-cap40")
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


func _frames(n: int) -> void:
	for i: int in n:
		await get_tree().process_frame


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var err: Error = get_tree().root.get_texture().get_image().save_png(out.path_join(name + ".png"))
	_say("shot %s (%d)" % [name, err])


func _say(s: String) -> void:
	Log.info("padwalk", s)
