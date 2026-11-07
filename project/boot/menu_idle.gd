class_name MenuIdle
extends Node
## L13 (docs/perf/LEDGER.md): the slice's title card is a still frame, but the engine drew and
## presented it 60 times a second (0.045 cores). While it is up (no session yet) the engine's
## low-processor mode is on: a loop draws only when a RenderingServer write happened
## (`Main::iteration`), and the limiter holds the loop at the tick rate, so the card costs 0.008
## cores and a button's hover or focus still redraws at once. The pause card measured a WASH (the
## city view behind it writes every frame, so it redraws anyway): PAUSED_IDLE keeps it off.
## `--menu-idle=off` is the before, `--menu-idle=lowproc` the mode without the tick cap (A/B arm).
## A child of the Game autoload: it reads the running scene, and is a no-op unless that is the
## slice (Quest1Game). Headless and `--write-movie`: it never processes. Never writes the sim.

## L13: true would idle the pause card too (measured WASH, 0.15-0.2 cores either way).
const PAUSED_IDLE: bool = false

var _flag: String = ""
var _idle: bool = false
var _shown_fps: int = 0
var _shown_low: bool = false


## True while a still card is on screen: before Start (the title); paused only with PAUSED_IDLE.
static func wants_idle(started: bool, paused: bool, flag: String) -> bool:
	return flag != "off" and (not started or (paused and PAUSED_IDLE))


## The limiter while idle: the tick rate, unless the A/B arm or a lower cap says otherwise.
static func cap_when_idle(current: int, flag: String) -> int:
	return current if flag == "lowproc" else MinimizedCap.cap_when_minimized(current, "")


func _init(flag: String = "") -> void:
	_flag = flag


func _ready() -> void:
	var off: bool = _flag == "off" or DisplayServer.get_name() == "headless"
	set_process(not off and Engine.get_write_movie_path() == "")


func _process(_delta: float) -> void:
	var game: Quest1Game = get_tree().current_scene as Quest1Game
	var now: bool = game != null and wants_idle(game.session != null, game.paused, _flag)
	if now == _idle:
		return
	_idle = now
	if now:
		_shown_fps = Engine.max_fps
		_shown_low = OS.low_processor_usage_mode
		Engine.max_fps = cap_when_idle(_shown_fps, _flag)
		OS.low_processor_usage_mode = true
		return
	OS.low_processor_usage_mode = _shown_low
	if Engine.max_fps == cap_when_idle(_shown_fps, _flag):
		Engine.max_fps = _shown_fps
