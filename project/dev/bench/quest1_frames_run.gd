extends Node
## quest1_frames' body, loaded once the autoloads exist.

var out_path: String = ""
var from_tick: int = 5800
var frames: int = 1200
var _game: Quest1Game
var _driver: CollectCallInputDriver
var _times: Array[int] = []
var _last_us: int = 0


func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var scene: PackedScene = load("res://boot/quest1.tscn") as PackedScene
	_game = scene.instantiate() as Quest1Game
	_game.save_path = ""
	_game.settings_path = ""
	add_child(_game)
	_game.card.start_button.pressed.emit()
	var s: Quest1Session = _game.session
	s.world.set_process(false)
	s.live.viewport = null
	_driver = CollectCallInputDriver.new(s.stage, s.system)
	while s.tick() < from_tick and not _driver.done():
		_driver.act()
		s.step()
	for i: int in 30:
		await get_tree().process_frame
	_last_us = Time.get_ticks_usec()


func _process(_delta: float) -> void:
	if _driver == null or _last_us == 0:
		return
	var now: int = Time.get_ticks_usec()
	_times.append(now - _last_us)
	_last_us = now
	_driver.act()
	_game.session.step()
	if _times.size() >= frames or _driver.done():
		_finish()


func _finish() -> void:
	_driver.release()
	var sorted: Array[int] = _times.duplicate()
	sorted.sort()
	var out: Dictionary = {
		"schema": "gtai.slice-frames/1",
		"label": "CONTENDED (shared machine, other lanes running)",
		"scene": "res://boot/quest1.tscn (quest 1 on the city, 300 people, 32 px/m)",
		"beat": _game.session.beat_id(),
		"from_tick": from_tick,
		"frames": sorted.size(),
		"p50_ms": _pct(sorted, 0.5),
		"p95_ms": _pct(sorted, 0.95),
		"p99_ms": _pct(sorted, 0.99),
		"max_ms": sorted[-1] / 1000.0 if not sorted.is_empty() else 0.0,
		"vsync": "off",
		"size":
		[get_viewport().get_visible_rect().size.x, get_viewport().get_visible_rect().size.y],
	}
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if f != null:
		@warning_ignore("return_value_discarded")
		f.store_string(JSON.stringify(out, "  ", true))
		f.close()
	Log.info("bench", JSON.stringify(out))
	_driver = null
	get_tree().quit(0 if f != null else 1)


static func _pct(sorted: Array[int], q: float) -> float:
	if sorted.is_empty():
		return 0.0
	return sorted[mini(int(q * sorted.size()), sorted.size() - 1)] / 1000.0
