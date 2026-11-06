extends SceneTree
## n8 city, brief item 5: the streamed city's draw-recording cost per view. Runs the real main
## scene (the args after `--` go to it: --arena=city --bot=rivet --view=<id> --seed=<n>), samples
## ChunkView every frame for --frames=<n> (default 1800) and writes JSON to --out=<abs file>:
## per-frame streaming work (frame_us p50 / p99 / max over frames that recorded), each chunk's
## record time (frame_us summed while it was active), chunks recorded and frames over 2 ms.
## godot --path project -s res://dev/bench/chunk_cost.gd -- --arena=city --bot=rivet --view=tilt70
##   --out=C:/.../cost_tilt70.json   (wall-clock: label CONTENDED unless bench.lock was held)

const MAIN: String = "res://boot/main.tscn"

var _frames: int = 1800
var _out: String = ""
var _n: int = 0
## the CityView, untyped: a -s script compiles before the autoloads its classes name
var _view: Node = null
var _work: Array[int] = []
var _chunk_us: Array[int] = []
var _cur: int = 0
var _act: int = -1


func _initialize() -> void:
	_frames = _arg("--frames", "1800").to_int()
	_out = _arg("--out", "")
	root.add_child((load(MAIN) as PackedScene).instantiate())


func _process(_delta: float) -> bool:
	_n += 1
	if _view == null:
		_view = _find(root)
	else:
		var c: Object = _view.get("chunks")
		if c != null:
			_sample(c)
	if _n < _frames:
		return false
	_write()
	return true


func _sample(c: Object) -> void:
	var on: bool = c.get("frame_swapped")
	var us: int = c.get("frame_us")
	var act: int = c.get("activated")
	if on:
		_work.append(us)
		_cur += us
	if act != _act and _act >= 0:  # ChunkView counts a chunk when its last command is recorded
		_chunk_us.append(_cur)
		_cur = 0
	_act = act


func _find(n: Node) -> Node:
	var sc: Script = n.get_script()
	if sc != null and sc.get_global_name() == &"CityView":
		return n
	for ch: Node in n.get_children():
		var v: Node = _find(ch)
		if v != null:
			return v
	return null


static func _arg(flag: String, dflt: String) -> String:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with(flag + "="):
			return arg.get_slice("=", 1)
	return dflt


static func _pct(a: Array[int], q: float) -> float:
	if a.is_empty():
		return 0.0
	var s: Array[int] = a.duplicate()
	s.sort()
	return s[mini(s.size() - 1, int(q * s.size()))] / 1000.0


func _write() -> void:
	var over: int = _work.filter(func(u: int) -> bool: return u > 2000).size()
	var d: Dictionary = {
		"view": _arg("--view", "top"),
		"frames": _n,
		"chunks_recorded": _chunk_us.size(),
		"record_frames": _work.size(),
		"frame_ms_p50": _pct(_work, 0.5),
		"frame_ms_p99": _pct(_work, 0.99),
		"frame_ms_max": _pct(_work, 1.0),
		"frames_over_2ms": over,
		"chunk_ms_p50": _pct(_chunk_us, 0.5),
		"chunk_ms_max": _pct(_chunk_us, 1.0),
	}
	if _out != "":
		var f: FileAccess = FileAccess.open(_out, FileAccess.WRITE)
		@warning_ignore("return_value_discarded")
		f.store_string(JSON.stringify(d, "  ", true) + "\n")
