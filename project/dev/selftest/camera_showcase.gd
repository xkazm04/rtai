extends "res://dev/selftest/city_selftest.gd"
## Camera feel, evidenced: the selftest junction (seed 91) under --fixed-fps 60 (one tick a frame)
## with a CameraRig on the view: on foot (32 px/m), then the car mode eased to 48 px/m captured
## every STRIDE ticks, then an explosion shake. Writes camera-<n>.png and camera-showcase.json.
##   godot --fixed-fps 60 --path project res://dev/selftest/camera_showcase.tscn -- --out=<dir>

const STRIDE: int = 9

var _log: Array[Dictionary] = []


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--out="):
			get_tree().quit(2)
			return
		_out = arg.substr(6)
	_build()
	_view.rig = CameraRig.new()
	await _characters.bake()
	@warning_ignore("return_value_discarded")
	await _view.prewarm()
	for i: int in SETTLE_FRAMES:
		await get_tree().process_frame
	var clock: SimClock = _world.context().clock
	_view.rig.set_mode(&"car", clock.tick())
	for k: int in 5:
		await _shot("camera-%d-ease.png" % k)
		for i: int in STRIDE:
			await get_tree().process_frame
	_view.rig.kick(&"explosion", clock.tick())
	for i: int in 3:
		await get_tree().process_frame
	await _shot("camera-5-shake.png")
	var f: FileAccess = FileAccess.open(_out.path_join("camera-showcase.json"), FileAccess.WRITE)
	var ok: bool = f != null and f.store_string(JSON.stringify(_log, "  ", true))
	printerr("camera_showcase: %s" % JSON.stringify(_log))
	get_tree().quit(0 if ok else 1)


func _shot(file: String) -> void:
	await RenderingServer.frame_post_draw
	@warning_ignore("return_value_discarded")
	get_viewport().get_texture().get_image().save_png(_out.path_join(file))
	var off: Vector2 = _view.rig.offset_px(SimConst.PX_PER_M)
	_log.append({"file": file, "ppm": _view.rig.ppm(), "offset_px": [off.x, off.y]})
