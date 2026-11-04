extends SceneTree
## Frame time of the showcase reel in the arena (dev-only, never shipped): the arena scene in a
## real window, vsync off, the reel's bot driving (`--bot=reel` and any arena args pass through),
## each frame's wall time recorded after a warmup. Writes p50/p95/p99/max ms and the 1 % low fps
## as JSON to `--out`. Take it under C:/Users/kazda/kiro/gtai-n4/bench.lock; the machine is
## shared, so label it CONTENDED.
## Usage: godot --rendering-driver d3d12 --path project --resolution 1920x1080
##   -s res://dev/showcase/reel_frames.gd -- --out=<file.json> --bot=reel --rigs --clean
##   [--secs=75] [--weapon=pistol]

const ARENA: String = "res://dev/arena/arena.tscn"
const WARMUP_FRAMES: int = 120

var _out: String = ""
var _secs: float = 75.0
var _ms: PackedFloat64Array = PackedFloat64Array()
var _last_us: int = 0
var _frames: int = 0
var _start_us: int = 0


func _initialize() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	_out = args.text("--out")
	_secs = args.number("--secs", 75.0)
	if _out == "":
		printerr("reel_frames: needs --out=<file.json>")
		quit(2)
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	@warning_ignore("return_value_discarded")
	change_scene_to_file(ARENA)
	_start_us = Time.get_ticks_usec()


func _process(_delta: float) -> bool:
	var now: int = Time.get_ticks_usec()
	_frames += 1
	if _frames > WARMUP_FRAMES and _last_us > 0:
		@warning_ignore("return_value_discarded")
		_ms.append(float(now - _last_us) / 1000.0)
	_last_us = now
	if float(now - _start_us) / 1000000.0 >= _secs:
		_write()
		return true
	return false


func _write() -> void:
	var sorted: PackedFloat64Array = _ms.duplicate()
	sorted.sort()
	var n: int = sorted.size()
	var out: Dictionary = {"schema": "gtai.reel-frames/1", "frames": n, "secs": _secs}
	out["args"] = " ".join(OS.get_cmdline_user_args())
	if n > 0:
		out["p50_ms"] = sorted[n / 2]
		out["p95_ms"] = sorted[mini(n - 1, n * 95 / 100)]
		out["p99_ms"] = sorted[mini(n - 1, n * 99 / 100)]
		out["max_ms"] = sorted[n - 1]
		var worst: int = maxi(1, n / 100)
		var sum: float = 0.0
		for i: int in worst:
			sum += sorted[n - 1 - i]
		out["low1_fps"] = 1000.0 / (sum / float(worst))
	var f: FileAccess = FileAccess.open(_out, FileAccess.WRITE)
	if f == null:
		printerr("reel_frames: cannot write %s" % _out)
		return
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify(out, "  ", true) + "\n")
	f.close()
