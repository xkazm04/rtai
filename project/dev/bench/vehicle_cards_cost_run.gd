extends Node
## n8 vehicles: what the traffic cards cost under a tilted view (render only, no sim). For each car
## count N: N cars on a lane grid filling the 32 px/m screen, headings turning every frame (the
## view pick, the depth sort and the MultiMesh writes all move), timed three ways per frame: the
## CPU time of VehicleCards.begin + put x N + finish (the script cost VehicleView pays), and the
## viewport's measured render CPU and GPU time with the cards shown, then hidden (the same N, the
## same frames: the difference is the cards' draw). `top` has no card atlas: nothing is drawn and
## the run says so. Writes gtai.bench/1-shaped JSON to --out and one line per N on stderr.

const KNOWN: PackedStringArray = ["--view", "--out", "--counts", "--frames", "--shot"]
const WARM: int = 60
const PPM: float = 32.0

var _args: Dictionary[String, String] = {
	"--out": "user://vehicle_cards_cost.json",
	"--counts": "32,64,128,256",
	"--frames": "240",
	"--shot": "",  # a PNG of the last shown frame (proof the cards drew)
}
var _cards: VehicleCards = null
var _counts: PackedInt32Array = PackedInt32Array()
var _ci: int = 0
var _frame: int = 0
var _phase: int = 0  # 0 shown, 1 hidden
var _rows: Array[Dictionary] = []
var _cpu: PackedFloat64Array = PackedFloat64Array()
var _rcpu: Array[PackedFloat64Array] = [PackedFloat64Array(), PackedFloat64Array()]
var _rgpu: Array[PackedFloat64Array] = [PackedFloat64Array(), PackedFloat64Array()]


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN.has(flag):
			printerr("vehicle_cards_cost: unknown argument %s" % arg)
			get_tree().quit(2)
			return
		_args[flag] = arg.substr(flag.length() + 1)
	for c: String in _args["--counts"].split(","):
		@warning_ignore("return_value_discarded")
		_counts.append(c.to_int())
	Engine.max_fps = 0
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)
	var cam: Camera2D = Camera2D.new()
	cam.zoom = Vector2.ONE * PPM / SimConst.PX_PER_M
	add_child(cam)
	_cards = VehicleCards.new()
	add_child(_cards)
	if VehicleCards.atlas() == null:
		printerr("vehicle_cards_cost: view %s has no card atlas: 0 cards drawn" % _view())
		_write()
		get_tree().quit(0)


func _process(_delta: float) -> void:
	if _ci >= _counts.size():
		return
	var n: int = _counts[_ci]
	var t0: int = Time.get_ticks_usec()
	_fill(n, _frame)
	var us: float = float(Time.get_ticks_usec() - t0)
	_cards.visible = _phase == 0
	_cards.under.visible = _phase == 0
	var frames: int = _args["--frames"].to_int()
	if _frame >= WARM:
		var vp: RID = get_viewport().get_viewport_rid()
		if _phase == 0:
			@warning_ignore("return_value_discarded")
			_cpu.append(us)
		@warning_ignore("return_value_discarded")
		_rcpu[_phase].append(RenderingServer.viewport_get_measured_render_time_cpu(vp))
		@warning_ignore("return_value_discarded")
		_rgpu[_phase].append(RenderingServer.viewport_get_measured_render_time_gpu(vp))
	_frame += 1
	if _frame < WARM + frames:
		return
	_frame = 0
	_phase += 1
	if _phase == 1 and _args["--shot"] != "":
		@warning_ignore("return_value_discarded")
		get_viewport().get_texture().get_image().save_png(_args["--shot"])
	if _phase < 2:
		return
	_row(n)
	_phase = 0
	_ci += 1
	if _ci >= _counts.size():
		_write()
		get_tree().quit(0)


## N cars on lanes 4 m apart, 6 m nose to tail, over the 60 x 34 m screen; headings spread and
## turning 1 degree a frame.
func _fill(n: int, frame: int) -> void:
	_cards.begin(VehicleCards.atlas())
	var cols: int = maxi(1, ceili(sqrt(float(n) * 1.8)))
	for i: int in n:
		var row: int = floori(float(i) / float(cols))
		var at: Vector2 = Vector2(float(i % cols) * 6.0 - 28.0, float(row) * 4.0 - 15.0)
		var a: float = deg_to_rad(float(i * 137 + frame))
		_cards.put(i % VehicleCards.ROWS, at, Vector2.from_angle(a), Color.WHITE, 0)
	_cards.finish()


func _row(n: int) -> void:
	var row: Dictionary = {
		"cars": n,
		"script_us_p50": _pct(_cpu, 0.5),
		"script_us_p95": _pct(_cpu, 0.95),
		"render_cpu_ms_p50_shown": _pct(_rcpu[0], 0.5),
		"render_cpu_ms_p50_hidden": _pct(_rcpu[1], 0.5),
		"gpu_ms_p50_shown": _pct(_rgpu[0], 0.5),
		"gpu_ms_p50_hidden": _pct(_rgpu[1], 0.5),
		"gpu_ms_p95_shown": _pct(_rgpu[0], 0.95),
	}
	_rows.append(row)
	printerr("vehicle_cards_cost: %s %s" % [_view(), JSON.stringify(row)])
	_cpu.clear()
	for k: int in 2:
		_rcpu[k].clear()
		_rgpu[k].clear()


static func _pct(v: PackedFloat64Array, q: float) -> float:
	if v.is_empty():
		return 0.0
	var s: PackedFloat64Array = v.duplicate()
	s.sort()
	return snappedf(s[clampi(int(q * float(s.size() - 1)), 0, s.size() - 1)], 0.001)


func _view() -> String:
	return String(ViewMode.shared().id)


func _write() -> void:
	var out: Dictionary = {
		"schema": "gtai.bench/1",
		"label": "vehicle_cards_cost",
		"view": _view(),
		"ppm": PPM,
		"frames": _args["--frames"].to_int(),
		"rows": _rows,
	}
	var path: String = _args["--out"]
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		printerr("vehicle_cards_cost: cannot write %s" % path)
		return
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify(out, "  ", true))
	f.close()
	printerr("vehicle_cards_cost: -> %s" % path)
