extends Node
## D-Noir pass cost (lane noir, dev only): the junction riot city (NoirFrames.build_city), the
## same run measured in alternating blocks with the noir pass off (D4) and on, GPU and CPU
## render time from the RenderingServer's viewport measure. Windowed only (needs a GPU).
## Usage: godot --rendering-driver d3d12 --path project --resolution 1920x1080
##   res://dev/noir/noir_cost.tscn -- --out=<file.json> [--zoom=1.5]

const KNOWN_FLAGS: PackedStringArray = ["--out", "--zoom"]
const WARM: int = 120
const BLOCK: int = 120
const BLOCKS: int = 6

var _out: String = "user://noir_cost.json"
var _zoom: float = 1.5


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("noir_cost: unknown argument %s" % arg)
			get_tree().quit(2)
			return
		if flag == "--out":
			_out = arg.substr(flag.length() + 1)
		else:
			_zoom = arg.substr(flag.length() + 1).to_float()
	var built: Array = NoirFrames.build_city(self)
	var view: CityView = built[1]
	view.zoom = _zoom
	var chars: CityCharacters = built[3]
	await chars.bake()
	await view.prewarm()
	var vp: RID = get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	for i: int in WARM:
		await get_tree().process_frame
	var gpu: Dictionary[String, float] = {"d4": 0.0, "noir": 0.0}
	var cpu: Dictionary[String, float] = {"d4": 0.0, "noir": 0.0}
	for b: int in BLOCKS:
		var look: String = "noir" if b % 2 == 1 else "d4"
		view.set_noir(look == "noir")
		for i: int in 3:
			await get_tree().process_frame
		for i: int in BLOCK:
			await get_tree().process_frame
			gpu[look] += RenderingServer.viewport_get_measured_render_time_gpu(vp)
			cpu[look] += RenderingServer.viewport_get_measured_render_time_cpu(vp)
	_report(gpu, cpu)
	get_tree().quit(0)


func _report(gpu: Dictionary[String, float], cpu: Dictionary[String, float]) -> void:
	var n: float = BLOCK * BLOCKS * 0.5
	var size: Vector2i = get_window().size
	var r: Dictionary = {
		"schema": "gtai.noir-cost/1",
		"resolution": [int(size.x), int(size.y)],
		"zoom": _zoom,
		"frames_per_look": int(n),
		"gpu_ms": {"d4": gpu["d4"] / n, "noir": gpu["noir"] / n},
		"cpu_render_ms": {"d4": cpu["d4"] / n, "noir": cpu["noir"] / n},
		"gpu": RenderingServer.get_video_adapter_name(),
	}
	var f: FileAccess = FileAccess.open(_out, FileAccess.WRITE)
	if f != null:
		if not f.store_string(JSON.stringify(r, "  ", true)):
			printerr("noir_cost: cannot write %s" % _out)
	printerr("noir_cost: %s" % JSON.stringify(r))
