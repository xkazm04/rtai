extends Node
## Measure real presentation-loop intervals while the ordinary prologue drives its own clock.

const KNOWN_FLAGS: PackedStringArray = ["--yard-dressing", "--out"]
const NEEDS_WINDOW: bool = true
const WINDOW_US: int = 60_000_000
const BUDGET_US: int = 16_700
const SIZE: Vector2i = Vector2i(1920, 1080)

var _game: PrologueGame
var _arm: String
var _out: String
var _first_us: int = -1
var _previous_us: int
var _first_unix: float
var _first_tick: int
var _intervals: PackedInt64Array = PackedInt64Array()


func _ready() -> void:
	set_process(false)
	var args: ArenaArgs = ArenaArgs.parse()
	for key: String in args.values:
		if key not in KNOWN_FLAGS:
			_fail("unknown option " + key)
			return
	_out = args.text("--out")
	_arm = args.text("--yard-dressing")
	if (
		not _out.is_absolute_path()
		or _arm not in ["plain", "torn_line", "line_fire", "raised_line", "arched_line"]
	):
		_fail("expected a yard dressing and an absolute JSON output path")
		return
	if DisplayServer.get_name() == "headless" or get_window().size != SIZE:
		_fail("use a 1920x1080 window")
		return
	if LaunchArgs.engine_fixed_fps() or not Engine.get_write_movie_path().is_empty():
		_fail("frame timing requires real time")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED:
		_fail("the window could not disable vsync")
		return
	LaunchArgs.parse(["--seed=7", "--yard-dressing=" + _arm])
	ViewMode.select("tilt70")
	_game = preload("res://boot/prologue/prologue.tscn").instantiate()
	add_child(_game)
	if _game.world == null or (_game.stage.plan as PrologueYard).dressing.id != _arm:
		_fail("requested pilot and dressing did not start")
		return
	const Pilot = preload("res://dev/bots/prologue_bot.gd")
	_game.world.loop().set_input(Pilot.new(_game.stage, _game.encounter))
	process_priority = -100
	set_process(true)


func _process(_dt: float) -> void:
	var now_us: int = Time.get_ticks_usec()
	if _first_us < 0:
		_first_us = now_us
		_previous_us = now_us
		_first_unix = Time.get_unix_time_from_system()
		_first_tick = _game.world.context().clock.tick()
		return
	var interval: int = now_us - _previous_us
	@warning_ignore("return_value_discarded")
	_intervals.append(interval)
	_previous_us = now_us
	if now_us - _first_us >= WINDOW_US:
		set_process(false)
		_finish(now_us, Time.get_unix_time_from_system())


func _finish(now_us: int, end_unix: float) -> void:
	_intervals.sort()
	var count: int = _intervals.size()
	var row: Dictionary[String, Variant] = {
		"schema": "gtai.yard-frame-sample/1",
		"dressing": _arm,
		"debug_build": OS.is_debug_build(),
		"pid": OS.get_process_id(),
		"viewport": [get_window().size.x, get_window().size.y],
		"gpu": RenderingServer.get_video_adapter_name(),
		"cpu": OS.get_processor_name(),
		"driver": RenderingServer.get_current_rendering_driver_name(),
		"max_fps": Engine.max_fps,
		"vsync_disabled": DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_DISABLED,
		"start_unix_s": _first_unix,
		"end_unix_s": end_unix,
		"start_tick": _first_tick,
		"end_tick": _game.world.context().clock.tick(),
		"elapsed_s": float(now_us - _first_us) / 1_000_000.0,
		"frame_count": count,
		"p50_ms": float(_intervals[ceili(0.50 * count) - 1]) / 1000.0,
		"p99_ms": float(_intervals[ceili(0.99 * count) - 1]) / 1000.0,
		"worst_ms": float(_intervals[count - 1]) / 1000.0,
		"over_16_7_ms": count - _intervals.bsearch(BUDGET_US, false),
	}
	var file: FileAccess = FileAccess.open(_out, FileAccess.WRITE)
	if file == null or not file.store_string(JSON.stringify(row, "  ", true, true) + "\n"):
		_fail("could not write " + _out)
		return
	Log.info("yard-frame-probe", "%s, %d frames in %.3f s" % [_arm, count, row["elapsed_s"]])
	get_tree().quit()


func _fail(message: String) -> void:
	Log.error("yard-frame-probe", message)
	get_tree().quit(2)
