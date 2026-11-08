extends Node

var _game: Quest1Game
var _driver: CollectCallInputDriver
var _left: int = 0


func _ready() -> void:
	var a: Dictionary = {"--row": "deck", "--from": "5800", "--frames": "2700"}
	for arg: String in OS.get_cmdline_user_args():
		a[arg.get_slice("=", 0)] = arg.get_slice("=", 1)
	DeviceProfile.select(str(a["--row"])).apply(get_window())
	PlayerActions.shipped().install()
	_game = (load("res://boot/quest1.tscn") as PackedScene).instantiate() as Quest1Game
	_game.save_path = ""
	_game.settings_path = ""
	add_child(_game)
	_game.card.start_button.pressed.emit()
	var s: Quest1Session = _game.session
	s.world.set_process(false)
	s.live.viewport = null
	_driver = CollectCallInputDriver.new(s.stage, s.system)
	while s.tick() < str(a["--from"]).to_int() and not _driver.done():
		_driver.act()
		s.step()
	_left = str(a["--frames"]).to_int()
	Log.info("q1deck", "at tick %d beat %s zoom %.2f" % [s.tick(), s.beat_id(), DeviceProfile.zoom()])


func _process(_delta: float) -> void:
	if _driver == null:
		return
	_driver.act()
	_game.session.step()
	_left -= 1
	if _left <= 0 or _driver.done():
		Log.info("q1deck", "done at tick %d beat %s" % [_game.session.tick(), _game.session.beat_id()])
		_driver.release()
		_driver = null
		get_tree().quit(0)
