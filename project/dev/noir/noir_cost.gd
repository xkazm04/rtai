extends Node
## D-Noir pass cost (lane noir, dev only): the junction riot city (NoirFrames.build_city), the
## same run measured in alternating blocks with the noir pass off (D4) and on, GPU and CPU
## render time from the RenderingServer's viewport measure. Windowed only (needs a GPU).
## Usage: godot --rendering-driver d3d12 --path project --resolution 1920x1080
##   res://dev/noir/noir_cost.tscn -- --out=<file.json> [--zoom=1.5] [--scene=roofs] [--shadows]
## --scene: a NoirFrames scene as the focus (default the junction). --shadows: the blocks alternate
## the noir pass WITHOUT and WITH the cast shadows (gpu_ms d4 = noir without shadows).

const KNOWN_FLAGS: PackedStringArray = ["--out", "--zoom", "--scene", "--shadows"]
const WARM: int = 120
const BLOCK: int = 120
const BLOCKS: int = 6

var _out: String = "user://noir_cost.json"
var _zoom: float = 1.5
var _scene: String = "junction"
var _shadows: bool = false


func _ready() -> void:
	if not _parse_args():
		get_tree().quit(2)
		return
	var built: Array = NoirFrames.build_city(self)
	var view: CityView = built[1]
	view.zoom = _zoom
	var city: CitySystem = built[2]
	city.focus = NoirFrames.SCENES.get(_scene, NoirFrames.JUNCTION)
	city.target = city.focus
	var chars: CityCharacters = built[3]
	await chars.bake()
	await view.prewarm()
	var vp: RID = get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	for i: int in WARM:
		await get_tree().process_frame
	var gpu: Dictionary[String, float] = {"d4": 0.0, "noir": 0.0}
	var cpu: Dictionary[String, float] = {"d4": 0.0, "noir": 0.0}
	var light: float = 0.0
	for b: int in BLOCKS:
		var look: String = "noir" if b % 2 == 1 else "d4"
		if _shadows and view.noir.shadows != null:
			view.noir.shadows.set_visible(look == "noir")
		else:
			view.set_noir(look == "noir")
		for i: int in 3:
			await get_tree().process_frame
		for i: int in BLOCK:
			await get_tree().process_frame
			gpu[look] += RenderingServer.viewport_get_measured_render_time_gpu(vp)
			cpu[look] += RenderingServer.viewport_get_measured_render_time_cpu(vp)
			light += view.noir.light_us / 1000.0 if look == "noir" else 0.0
	cpu["light"] = light
	_shadow_stats(view.noir.shadows, cpu)
	_report(gpu, cpu)
	get_tree().quit(0)


func _parse_args() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("noir_cost: unknown argument %s" % arg)
			return false
		if flag == "--out":
			_out = arg.substr(flag.length() + 1)
		elif flag == "--scene":
			_scene = arg.substr(flag.length() + 1)
		elif flag == "--shadows":
			_shadows = true
		else:
			_zoom = arg.substr(flag.length() + 1).to_float()
	return true


static func _shadow_stats(shadows: NoirShadows, cpu: Dictionary[String, float]) -> void:
	cpu["stamps"] = float(shadows.stamps) if shadows != null else 0.0
	cpu["chunks"] = float(shadows.chunk_count()) if shadows != null else 0.0
	cpu["record_max_ms"] = shadows.record_max_us / 1000.0 if shadows != null else 0.0


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
		"noir_light_cpu_ms": cpu["light"] / n,
		"scene": _scene,
		"shadow_stamps": roundi(cpu["stamps"]),
		"shadow_chunks": roundi(cpu["chunks"]),
		"shadow_record_max_ms": cpu["record_max_ms"],
		"blocks": "noir without / with cast shadows" if _shadows else "d4 / noir",
	}
	var f: FileAccess = FileAccess.open(_out, FileAccess.WRITE)
	if f != null:
		if not f.store_string(JSON.stringify(r, "  ", true)):
			printerr("noir_cost: cannot write %s" % _out)
	printerr("noir_cost: %s" % JSON.stringify(r))
