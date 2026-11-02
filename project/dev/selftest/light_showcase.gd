extends "res://dev/selftest/city_selftest.gd"
## The 2D light model, evidenced: the selftest junction (seed 91) under --fixed-fps 60 at 32 / 48
## / 64 px/m, the tree paused (same sim state) and captured with no lights, with the demo lights
## (a blast, muzzle flashes, headlights, a siren, a fire) in the day grade and in the night grade.
## Then the cost: GPU and CPU render time over COST_FRAMES with 0 lights and with the full budget.
##   godot --fixed-fps 60 --path project res://dev/selftest/light_showcase.tscn -- --out=<dir>

const PPMS: Array[int] = [32, 48, 64]
const COST_FRAMES: int = 30
## Interleaved measurement blocks (even = lights hidden, odd = shown).
const BLOCKS: int = 16


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
	for ppm: int in PPMS:
		await _frames(ppm)
	var cost: Dictionary = await _cost()
	var f: FileAccess = FileAccess.open(_out.path_join("light-cost.json"), FileAccess.WRITE)
	var ok: bool = f != null and f.store_string(JSON.stringify(cost, "  ", true))
	printerr("light_showcase: %s" % JSON.stringify(cost))
	get_tree().quit(0 if ok else 1)


func _frames(ppm: int) -> void:
	get_tree().paused = false
	_view.lights.set_grade(&"day")
	_view.zoom = ppm / SimConst.PX_PER_M
	for i: int in SETTLE_FRAMES:
		await get_tree().process_frame
	get_tree().paused = true
	var handles: Array[int] = []
	await _shot("light-%dppm-0-none.png" % ppm)
	handles = _demo_lights(_world.context().clock.tick())
	await _shot("light-%dppm-1-day.png" % ppm)
	_view.lights.set_grade(&"night")
	await _shot("light-%dppm-2-night.png" % ppm)
	for h: int in handles:
		_view.lights.remove(h)
	await _shot("light-%dppm-3-night-none.png" % ppm)


func _demo_lights(tick: int) -> Array[int]:
	var c: Vector2 = JUNCTION * SimConst.PX_PER_M
	var m: float = SimConst.PX_PER_M
	var out: Array[int] = []
	out.append(_view.lights.add(&"explosion", c + Vector2(-7, -4) * m, 0.0, tick - 6))
	out.append(_view.lights.add(&"fire", c + Vector2(6, 5) * m, 0.0, tick))
	out.append(_view.lights.add(&"siren", c + Vector2(9, -5) * m, 0.0, tick))
	out.append(_view.lights.add(&"headlight", c + Vector2(-12, 6) * m, 0.0, tick))
	out.append(_view.lights.add(&"headlight", c + Vector2(-12, 7.6) * m, 0.0, tick))
	for k: int in 4:
		var at: Vector2 = c + Vector2(2.0 + k * 1.5, -2.5 + k) * m
		out.append(_view.lights.add(&"muzzle_flash", at, -0.6 + k * 0.4, tick - k))
	return out


func _shot(file: String) -> void:
	var cam: Camera2D = _view.camera
	var world_px: Vector2 = (
		(cam.position * _view.zoom).round() - get_viewport().get_visible_rect().size * 0.5
	)
	_view.lights.step(_world.context().clock.tick(), world_px)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	@warning_ignore("return_value_discarded")
	get_viewport().get_texture().get_image().save_png(_out.path_join(file))


func _cost() -> Dictionary:
	get_tree().paused = false
	_view.lights.set_grade(&"day")
	_view.zoom = 1.5
	var vp: RID = get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	var c: Vector2 = JUNCTION * SimConst.PX_PER_M
	for i: int in _view.lights.max_lights:
		var at: Vector2 = (
			c + Vector2((i % 8) - 4.0, floorf(i / 8.0) - 4.0) * 3.0 * SimConst.PX_PER_M
		)
		@warning_ignore("return_value_discarded")
		_view.lights.add(&"fire", at, 0.0, 0)
	# interleaved blocks (lights hidden / shown), median of the block means: GPU clock and
	# power-state drift between two long runs swamped the delta (four runs: -0.87 .. +1.32 ms)
	var off: Array[Vector2] = []
	var on: Array[Vector2] = []
	for b: int in BLOCKS:
		_view.lights.visible = b % 2 == 1
		await RenderingServer.frame_post_draw
		var m: Vector2 = await _measure(vp)
		(on if b % 2 == 1 else off).append(m)
	_view.lights.visible = true
	var none: Vector2 = _median(off)
	var full: Vector2 = _median(on)
	return {
		"schema": "gtai.light-cost/1",
		"ppm": 48,
		"lights": _view.lights.active,
		"dropped": _view.lights.dropped,
		"gpu_ms_no_lights": none.x,
		"gpu_ms_full_budget": full.x,
		"gpu_ms_delta": full.x - none.x,
		"blocks": BLOCKS,
		"frames_per_block": COST_FRAMES,
		"cpu_render_ms_no_lights": none.y,
		"cpu_render_ms_full_budget": full.y,
		"light_step_us": _view.lights.last_us,
		"gpu": RenderingServer.get_video_adapter_name(),
	}


static func _median(v: Array[Vector2]) -> Vector2:
	var xs: Array[float] = []
	var ys: Array[float] = []
	for p: Vector2 in v:
		xs.append(p.x)
		ys.append(p.y)
	xs.sort()
	ys.sort()
	return Vector2(xs[xs.size() / 2], ys[ys.size() / 2])


## Mean (GPU, CPU) render ms over COST_FRAMES frames.
func _measure(vp: RID) -> Vector2:
	var sum: Vector2 = Vector2.ZERO
	for i: int in COST_FRAMES:
		await RenderingServer.frame_post_draw
		sum += Vector2(
			RenderingServer.viewport_get_measured_render_time_gpu(vp),
			RenderingServer.viewport_get_measured_render_time_cpu(vp)
		)
	return sum / COST_FRAMES
