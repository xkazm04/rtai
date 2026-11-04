class_name LatencyProbeRun
extends Node
## rivet-arsenal: input-to-motion latency in the live arena window (not fixed-fps): boots
## res://dev/arena/arena.tscn, and TRIALS times injects a move_right press through
## Input.parse_input_event (the same path as a key), then counts the rendered frames and the
## microseconds until Rivet's sim position moves (the frame that moves him also poses and draws
## him). Engine-side only: the swapchain and the display add their own frames on top.
## Launched by latency_probe_main.gd (a -s main script must not name global classes at parse time):
## "$GODOT_BIN" --rendering-driver d3d12 --path project
##   -s res://dev/rivet_arsenal/latency_probe_main.gd
##   -- --out=<json>

const WARM_FRAMES: int = 120
const TRIALS: int = 12
const HOLD_FRAMES: int = 12
const REST_FRAMES: int = 45

var _game: ArenaGame = null
var _frame: int = 0
var _trial: int = 0
var _pressed_at: int = -1
var _pressed_us: int = 0
var _from: Vector2 = Vector2.ZERO
var _frames: Array[int] = []
var _ms: Array[float] = []
var _next_at: int = WARM_FRAMES


func _ready() -> void:
	var scene: PackedScene = load("res://dev/arena/arena.tscn") as PackedScene
	_game = scene.instantiate() as ArenaGame
	add_child(_game)


func _process(_delta: float) -> void:
	_frame += 1
	if _game == null or _game.session == null:
		if _frame > 600:
			get_tree().quit(2)
		return
	var rivet: Fighter = _game.session.stage.arena.rivet
	if _pressed_at < 0 and _frame >= _next_at:
		_from = rivet.pos
		_pressed_at = _frame
		_pressed_us = Time.get_ticks_usec()
		_send(true)
	elif _pressed_at >= 0 and rivet.pos != _from and _frames.size() == _trial:
		_frames.append(_frame - _pressed_at)
		_ms.append(float(Time.get_ticks_usec() - _pressed_us) / 1000.0)
	if _pressed_at >= 0 and _frame - _pressed_at >= HOLD_FRAMES:
		_send(false)
		if _frames.size() == _trial:
			_frames.append(-1)
			_ms.append(-1.0)
		_trial += 1
		_pressed_at = -1
		_next_at = _frame + REST_FRAMES
	if _trial >= TRIALS or _frame > 5000:
		_finish()
		get_tree().quit(0 if _trial >= TRIALS else 1)


func _send(down: bool) -> void:
	var e: InputEventAction = InputEventAction.new()
	e.action = &"move_right"
	e.pressed = down
	e.strength = 1.0 if down else 0.0
	Input.parse_input_event(e)


func _finish() -> void:
	var out: Dictionary = {
		"schema": "gtai.rivet-latency/1",
		"what": "frames and ms from Input.parse_input_event(move_right) to Rivet's sim move",
		"frames": _frames,
		"ms": _ms,
		"fps": Engine.get_frames_per_second(),
		"note": "engine-side; the swapchain and the display add frames on top (CONTENDED machine)",
	}
	var path: String = ""
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			path = a.substr(6)
	if path != "":
		var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		var ok: bool = f.store_string(JSON.stringify(out, "  ", true) + "\n")
		assert(ok, "latency probe: could not write %s" % path)
