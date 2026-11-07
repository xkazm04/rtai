class_name MinimizedCap
extends Node
## L12 (docs/perf/LEDGER.md): a minimized window cannot draw, so the engine drops the vsync wait and
## sleeps only `low_processor_usage_mode_sleep_usec` (6.9 ms) a loop: the game ran ~145 loops a
## second minimized and used MORE CPU than on screen (riot 0.35 -> 0.58 cores). Nothing is drawn
## while minimized and the sim steps on the 60 Hz tick, so the limiter is set to the tick rate while
## minimized and given back on restore. `--frame-cap=off` is the before. Never writes the sim.
## L14 (F18): the Windows limiter spins its last 1 ms a frame outside low-processor mode; nothing
## is drawn while minimized, so that mode is on too (it sleeps the whole gap).
## `--frame-cap=spin` = L12 only (the A/B arm).

var _flag: String = ""
var _minimized: bool = false
var _shown_fps: int = 0
var _shown_low: bool = false


## The limiter while minimized: the tick rate unless the flag is off or a lower cap is already set.
static func cap_when_minimized(current: int, flag: String) -> int:
	if flag == "off" or (current > 0 and current <= SimClock.TICK_RATE):
		return current
	return SimClock.TICK_RATE


## Low-processor mode while minimized (L14) unless the flag is off or the L12-only A/B arm.
static func low_when_minimized(flag: String) -> bool:
	return flag != "off" and flag != "spin"


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
		_shown_low = OS.low_processor_usage_mode
		Engine.max_fps = cap_when_minimized(_shown_fps, _flag)
		OS.low_processor_usage_mode = _shown_low or low_when_minimized(_flag)
		return
	OS.low_processor_usage_mode = _shown_low
	if Engine.max_fps == cap_when_minimized(_shown_fps, _flag):
		Engine.max_fps = _shown_fps
