extends "res://dev/selftest/city_selftest.gd"
## The arena zoom in the game path, evidenced: the selftest junction (seed 91, `--site=` as the
## selftest) under --fixed-fps 60, a CameraRig on foot (32 px/m) listening to the game's Events like
## World wires it, then Events.boss_engaged: the zoom eases to the arena's 64 px/m and the `auto`
## look blends D4 -> D5 on the way. Captures every STRIDE ticks; writes arena-<n>.png and
## arena-showcase.json (px/m and the D4 -> D5 blend weight per shot).
##   godot --fixed-fps 60 --path project res://dev/selftest/arena_showcase.tscn -- --out=<dir>

const STRIDE: int = 9
const SHOTS: int = 5

var _log: Array[Dictionary] = []


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if flag == "--out":
			_out = arg.substr(6)
		elif flag != "--site" or not set_site(arg.substr(7)):
			get_tree().quit(2)
			return
	_build()
	_view.rig = CameraRig.new()
	var clock: SimClock = _world.context().clock
	_view.rig.listen(Events, clock)
	await _characters.bake()
	@warning_ignore("return_value_discarded")
	await _view.prewarm()
	for i: int in SETTLE_FRAMES:
		await get_tree().process_frame
	Events.boss_engaged.emit(&"quartermaster-mertz")
	for k: int in SHOTS:
		await _shot("arena-%d.png" % k)
		for i: int in STRIDE:
			await get_tree().process_frame
	var f: FileAccess = FileAccess.open(_out.path_join("arena-showcase.json"), FileAccess.WRITE)
	var ok: bool = f != null and f.store_string(JSON.stringify(_log, "  ", true))
	printerr("arena_showcase: %s" % JSON.stringify(_log))
	get_tree().quit(0 if ok else 1)


func _shot(file: String) -> void:
	await RenderingServer.frame_post_draw
	@warning_ignore("return_value_discarded")
	get_viewport().get_texture().get_image().save_png(_out.path_join(file))
	var ppm: float = _view.rig.ppm()
	var w: float = LookProfiles.shared().blend_weight(ppm)
	_log.append({"file": file, "mode": String(_view.rig.mode), "ppm": ppm, "d5_weight": w})
