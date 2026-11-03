extends "res://dev/selftest/city_selftest.gd"
## Per-pass GPU cost (core/render/README.md "Per-pass costs"): the selftest junction riot at one
## zoom, cycling BLOCKS rounds of FRAMES-frame blocks through configs that each switch ONE pass
## off (`full` = everything on; `no_actors` = the whole actors canvas, `no_rigs` / `no_peds` /
## `no_ped_shadows` / `no_cars` = its parts: rigs, atlas crowd, crowd shadows, moving cars).
## Reports the median block GPU / CPU render ms per config and the delta to `full` = that
## pass's cost. Run it on the low-end GPU too (`--gpu-index 1`) and at the
## Deck's 1280x800 (`--resolution 1280x800`). Windowed only. Usage:
##   godot --fixed-fps 60 [--gpu-index N] [--resolution WxH] --path project
##     res://dev/selftest/pass_cost.tscn -- --out=<dir> [--ppm=48] [--tag=<name>]

const FRAMES: int = 30
const BLOCKS: int = 8
const CONFIGS: PackedStringArray = [
	"full",
	"no_print",
	"no_actors",
	"no_rigs",
	"no_peds",
	"no_ped_shadows",
	"no_cars",
	"no_lights",
	"no_fx"
]

var _ppm: float = 48.0
var _tag: String = "pass-cost"


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		var value: String = arg.substr(flag.length() + 1)
		if flag == "--out":
			_out = value
		elif flag == "--ppm":
			_ppm = value.to_float()
		elif flag == "--tag":
			_tag = value
		else:
			printerr("pass_cost: unknown argument %s" % arg)
			get_tree().quit(2)
			return
	_build()
	await _characters.bake()
	@warning_ignore("return_value_discarded")
	await _view.prewarm()
	_view.zoom = _ppm / SimConst.PX_PER_M
	for i: int in SETTLE_FRAMES:
		await get_tree().process_frame
	_write(await _measure())


func _measure() -> Dictionary:
	var vp: RID = get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	var blocks: Dictionary = {}
	for c: String in CONFIGS:
		blocks[c] = [] as Array[Vector2]
	for b: int in BLOCKS:
		for c: String in CONFIGS:
			_set_config(c)
			await RenderingServer.frame_post_draw
			var sum: Vector2 = Vector2.ZERO
			for f: int in FRAMES:
				await RenderingServer.frame_post_draw
				sum += Vector2(
					RenderingServer.viewport_get_measured_render_time_gpu(vp),
					RenderingServer.viewport_get_measured_render_time_cpu(vp)
				)
			var list: Array[Vector2] = blocks[c]
			list.append(sum / FRAMES)
	_set_config("full")
	return blocks


func _set_config(c: String) -> void:
	_view.set_look_enabled(c != "no_print")
	_view.actor_layer().visible = c != "no_actors"
	_characters.rigs.visible = c != "no_rigs"
	var nodes: Array[MultiMeshInstance2D] = _view.crowd.nodes
	nodes[SimConst.RL_PEDS].visible = c != "no_peds"
	nodes[SimConst.RL_PED_SHADOWS].visible = c != "no_ped_shadows"
	nodes[SimConst.RL_CARS].visible = c != "no_cars"
	nodes[SimConst.RL_CAR_SHADOWS].visible = c != "no_cars"
	_view.lights.visible = c != "no_lights"
	var fx_on: bool = c != "no_fx"
	_view.fx.visible = fx_on
	_view.fx.ground.visible = fx_on
	_view.fx.glow.visible = fx_on


func _write(blocks: Dictionary) -> void:
	var first: Array[Vector2] = blocks["full"]
	var full: Vector2 = _median(first)
	var configs: Dictionary = {}
	for c: String in CONFIGS:
		var list: Array[Vector2] = blocks[c]
		var m: Vector2 = _median(list)
		configs[c] = {"gpu_ms": m.x, "cpu_render_ms": m.y, "gpu_ms_saved": full.x - m.x}
	var size: Vector2 = get_viewport().get_visible_rect().size
	var win: Vector2i = DisplayServer.window_get_size()
	var res: Dictionary = {
		"schema": "gtai.pass-cost/1",
		"ppm": _ppm,
		"resolution": "%dx%d" % [win.x, win.y],
		"canvas": "%dx%d" % [int(size.x), int(size.y)],
		"gpu": RenderingServer.get_video_adapter_name(),
		"blocks": BLOCKS,
		"frames_per_block": FRAMES,
		"configs": configs,
	}
	var path: String = _out.path_join("%s.json" % _tag)
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var ok: bool = f != null and f.store_string(JSON.stringify(res, "  ", true))
	if f != null:
		f.close()
	printerr("pass_cost: %s" % JSON.stringify(res))
	get_tree().quit(0 if ok else 1)


static func _median(v: Array[Vector2]) -> Vector2:
	var xs: Array[float] = []
	var ys: Array[float] = []
	for p: Vector2 in v:
		xs.append(p.x)
		ys.append(p.y)
	xs.sort()
	ys.sort()
	@warning_ignore("integer_division")
	return Vector2(xs[xs.size() / 2], ys[ys.size() / 2])
