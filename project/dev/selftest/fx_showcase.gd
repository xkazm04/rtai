extends "res://dev/selftest/city_selftest.gd"
## The data-driven FX, evidenced: the selftest junction (seed 91) under --fixed-fps 60 at 32 / 48
## / 64 px/m, tree paused (same sim state), every fx kind spawned around the junction at a third of
## its life and stepped tick by tick (with their lights), captured with and without the fx.
##   godot --fixed-fps 60 --path project res://dev/selftest/fx_showcase.tscn -- --out=<dir>

const PPMS: Array[int] = [32, 48, 64]
const KINDS: Array[StringName] = [
	&"muzzle",
	&"tracer",
	&"impact",
	&"explosion",
	&"smoke",
	&"debris",
	&"ink_splat",
	&"crackle",
	&"casing",
	&"spark"
]


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
		get_tree().paused = false
		_view.zoom = ppm / SimConst.PX_PER_M
		for i: int in SETTLE_FRAMES:
			await get_tree().process_frame
		get_tree().paused = true
		await _shot("fx-%dppm-0-none.png" % ppm)
		_play(_world.context().clock.tick())
		await _shot("fx-%dppm-1-fx.png" % ppm)
	printerr(
		(
			"fx_showcase: alive %d dropped %d step %d us"
			% [
				_view.fx.alive() + _view.fx.glow.alive(),
				_view.fx.dropped + _view.fx.glow.dropped,
				_view.fx.last_us + _view.fx.glow.last_us
			]
		)
	)
	get_tree().quit(0)


## Spawns each kind at a third of its life before `now`, on a ring around the junction.
func _play(now: int) -> void:
	var c: Vector2 = JUNCTION * SimConst.PX_PER_M
	var start: int = now - 90
	for t: int in range(start, now + 1):
		for i: int in KINDS.size():
			var k: Dictionary = _view.fx.kinds[KINDS[i]]
			var life: int = k["life_ticks"]
			if t == now - maxi(1, life / 3):
				var at: Vector2 = (
					c + Vector2.from_angle(TAU * i / KINDS.size()) * 5.0 * SimConst.PX_PER_M
				)
				@warning_ignore("return_value_discarded")
				_view.fx.spawn(KINDS[i], at, TAU * i / KINDS.size(), t)
		_view.fx.step(t)
		_view.fx.glow.step(t)


func _shot(file: String) -> void:
	var world_px: Vector2 = (
		(_view.camera.position * _view.zoom).round() - get_viewport().get_visible_rect().size * 0.5
	)
	_view.lights.step(_world.context().clock.tick(), world_px)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	@warning_ignore("return_value_discarded")
	get_viewport().get_texture().get_image().save_png(_out.path_join(file))
