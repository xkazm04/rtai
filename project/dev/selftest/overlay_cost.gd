extends "res://dev/selftest/city_selftest.gd"
## The print-overlay cost (look_profiles.json `overlays`, core/render/README.md): the selftest
## junction at 64 px/m, alternating BLOCKS blocks of FRAMES frames between `d4` (overlay hidden)
## and `auto` (overlay at amount 1, same d4 base), median block GPU / CPU render ms. Reports
## live_overlays 0 when no overlay shader is in the tree. Windowed only. Usage:
##   godot --fixed-fps 60 --path project res://dev/selftest/overlay_cost.tscn -- --out=<dir>

const FRAMES: int = 30
const BLOCKS: int = 16
const PPM: float = 64.0


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--out="):
			get_tree().quit(2)
			return
		_out = arg.substr(6)
	_build()
	await _characters.bake()
	@warning_ignore("return_value_discarded")
	await _view.prewarm()
	_view.zoom = PPM / SimConst.PX_PER_M
	for i: int in SETTLE_FRAMES:
		await get_tree().process_frame
	var vp: RID = get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	var off: Array[Vector2] = []
	var on: Array[Vector2] = []
	for b: int in BLOCKS:
		_view.look_id = &"auto" if b % 2 == 1 else &"d4"
		await RenderingServer.frame_post_draw
		var sum: Vector2 = Vector2.ZERO
		for f: int in FRAMES:
			await RenderingServer.frame_post_draw
			sum += Vector2(
				RenderingServer.viewport_get_measured_render_time_gpu(vp),
				RenderingServer.viewport_get_measured_render_time_cpu(vp)
			)
		(on if b % 2 == 1 else off).append(sum / FRAMES)
	_write(_median(off), _median(on))


func _write(off: Vector2, on: Vector2) -> void:
	var res: Dictionary = {
		"schema": "gtai.overlay-cost/1",
		"ppm": PPM,
		"live_overlays": LookProfiles.shared().overlays.size(),
		"gpu_ms_overlay_off": off.x,
		"gpu_ms_overlay_on": on.x,
		"gpu_ms_delta": on.x - off.x,
		"cpu_render_ms_delta": on.y - off.y,
		"blocks": BLOCKS,
		"frames_per_block": FRAMES,
		"gpu": RenderingServer.get_video_adapter_name(),
	}
	var f: FileAccess = FileAccess.open(_out.path_join("overlay-cost.json"), FileAccess.WRITE)
	var ok: bool = f != null and f.store_string(JSON.stringify(res, "  ", true))
	if f != null:
		f.close()
	printerr("overlay_cost: %s" % JSON.stringify(res))
	get_tree().quit(0 if ok else 1)


static func _median(v: Array[Vector2]) -> Vector2:
	var xs: Array[float] = []
	var ys: Array[float] = []
	for p: Vector2 in v:
		xs.append(p.x)
		ys.append(p.y)
	xs.sort()
	ys.sort()
	return Vector2(xs[xs.size() / 2], ys[ys.size() / 2])
