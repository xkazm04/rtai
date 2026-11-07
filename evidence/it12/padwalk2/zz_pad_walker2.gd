extends Node
## Scratch (it12, not committed): quest 1 under the Deck row, the failed and paid cards on pad events only.

var out: String = ""
var quits: int = 0
var game: Quest1Game = null


func _ready() -> void:
	out = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "C:/tmp"
	_walk.call_deferred()


func _walk() -> void:
	DeviceProfile.select("deck").apply(get_window())
	game = (load("res://boot/quest1.tscn") as PackedScene).instantiate() as Quest1Game
	game.save_path = ""
	game.settings_path = ""
	get_tree().root.add_child(game)
	game.boot()
	for c: Dictionary in game.card.quit_pressed.get_connections():
		var cb: Callable = c["callable"]
		game.card.quit_pressed.disconnect(cb)
	var _e: int = game.card.quit_pressed.connect(func() -> void: quits += 1)
	await _frames(20)
	_pad(JOY_BUTTON_A)
	await _frames(90)
	_say("after A: session %s" % (game.session != null))
	game.session.system.runner._fail(&"rivet_wasted")
	await _frames(10)
	_say("real fail: state %s focus %s" % [game.session.system.runner.state_name(), _focus()])
	await _shot("padwalk-deck-failed")
	_pad(JOY_BUTTON_A)
	await _frames(5)
	_say("A on the failed card: quit_pressed %d" % quits)
	game.card.show_failed(true)
	await _frames(5)
	_say("failed + checkpoint: focus %s" % _focus())
	_pad(JOY_BUTTON_DPAD_DOWN)
	await _frames(3)
	_say("d-pad down: focus %s" % _focus())
	_pad(JOY_BUTTON_DPAD_UP)
	await _frames(3)
	_say("d-pad up: focus %s" % _focus())
	await _shot("padwalk-deck-failed-retry")
	_pad(JOY_BUTTON_A)
	await _frames(90)
	_say("A on Retry: session %s state %s card %s" % [game.session != null, game.session.system.runner.state_name(), game.card._panel.visible])
	game.session.system.runner._succeed()
	var waited: int = 0
	while not game._ended and waited < 2400:
		await _frames(10)
		waited += 10
	_say("the paid card came after %d frames (the closing lines play out first)" % waited)
	await _frames(5)
	_say("real success: state %s paid %s focus %s" % [game.session.system.runner.state_name(), game.session.paid(), _focus()])
	await _shot("padwalk-deck-paid")
	_pad(JOY_BUTTON_A)
	await _frames(5)
	_say("A on the paid card: quit_pressed %d" % quits)
	get_tree().quit(0)


func _focus() -> String:
	var c: Control = get_tree().root.gui_get_focus_owner()
	if c == null:
		return "none"
	return (c as Button).text if c is Button else String(c.name)


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
