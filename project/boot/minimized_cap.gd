class_name MinimizedCap
extends Node
## L12 (docs/perf/LEDGER.md): a minimized window cannot draw, so the engine drops the vsync wait and
## sleeps only `low_processor_usage_mode_sleep_usec` (6.9 ms) a loop: the game ran ~145 loops a
## second minimized and used MORE CPU than on screen (riot 0.35 -> 0.58 cores). Nothing is drawn
## while minimized and the sim steps on the 60 Hz tick, so the limiter is set to the tick rate while
## minimized and given back on restore. `--frame-cap=off` is the before. Never writes the sim.

var _flag: String = ""
var _minimized: bool = false
var _shown_fps: int = 0


## The limiter while minimized: the tick rate unless the flag is off or a lower cap is already set.
static func cap_when_minimized(current: int, flag: String) -> int:
	if flag == "off" or (current > 0 and current <= SimClock.TICK_RATE):
		return current
	return SimClock.TICK_RATE


func _init(flag: String = "") -> void:
	_flag = flag


func _ready() -> void:
	var off: bool = _flag == "off" or DisplayServer.get_name() == "headless"
	set_process(not off and Engine.get_write_movie_path() == "")


func _process(_delta: float) -> void:
	var now: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED
	if now == _minimized:
		return
	_minimized = now
	if now:
		_shown_fps = Engine.max_fps
		Engine.max_fps = cap_when_minimized(_shown_fps, _flag)
	elif Engine.max_fps == cap_when_minimized(_shown_fps, _flag):
		Engine.max_fps = _shown_fps
