extends "res://dev/selftest/city_selftest.gd"
## The car look-ahead in the game path, evidenced: the selftest junction (seed 91) under
## --fixed-fps 60 (one tick a frame), a CameraRig snapped to `--mode=` (default `car`, 48 px/m;
## `on_foot` = 32 px/m, which leads nothing by data) and the focus driven
## east at SPEED_MPS by moving CitySystem.focus (as a cutscene or the player would); a pickup ring
## marks the focus. CityView feeds the rig from the focus itself (CameraRig.follow), so the camera
## leads the motion. Then Events.player_hit(robo-tazer) fires `player_hit` (sparks, shake) and
## `player_hit_robo_tazer` (the crackle; hitstop-tazer.png inside the hold): the sim tick per frame
## shows the hit-stop hold (rivet_hit, 3 ticks). Writes lead-<tick>.png and
## lead-showcase.json (lead per shot, ticks per frame around the hit).
##   godot --fixed-fps 60 --path project res://dev/selftest/lead_showcase.tscn -- --out=<dir>
##   [--mode=on_foot]

const SPEED_MPS: float = 15.0
const SHOTS: Array[int] = [0, 30, 60, 150]

var _log: Array[Dictionary] = []
var _mode: StringName = &"car"


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg.begins_with("--mode="):
			_mode = StringName(arg.substr(7))
		else:
			get_tree().quit(2)
			return
	_build()
	_view.rig = CameraRig.new()
	_view.rig.snap(_mode)
	await _characters.bake()
	@warning_ignore("return_value_discarded")
	await _view.prewarm()
	for i: int in SETTLE_FRAMES:
		await get_tree().process_frame
	var ring: int = _view.markers.add(&"pickup", _city.focus * SimConst.PX_PER_M)
	var driven: int = 0
	for at: int in SHOTS:
		while driven < at:
			_city.focus += Vector2(SPEED_MPS, 0.0) * SimClock.TICK_DT
			_city.target = _city.focus
			_view.markers.move(ring, _city.focus * SimConst.PX_PER_M)
			driven += 1
			await get_tree().process_frame
		await _shot("lead-%03d.png" % at, at)
	await _hitstop()
	var f: FileAccess = FileAccess.open(_out.path_join("lead-showcase.json"), FileAccess.WRITE)
	var ok: bool = f != null and f.store_string(JSON.stringify(_log, "  ", true))
	printerr("lead_showcase: %s" % JSON.stringify(_log))
	get_tree().quit(0 if ok else 1)


func _shot(file: String, driven: int) -> void:
	await RenderingServer.frame_post_draw
	@warning_ignore("return_value_discarded")
	get_viewport().get_texture().get_image().save_png(_out.path_join(file))
	var off: Vector2 = _view.rig.offset_px(SimConst.PX_PER_M)
	var entry: Dictionary = {"file": file, "driven_ticks": driven, "ppm": _view.rig.ppm()}
	entry["lead_m"] = [off.x / SimConst.PX_PER_M, off.y / SimConst.PX_PER_M]
	_log.append(entry)


## Fires player_hit on the game's Events through the view's FxTriggers (as World wires it) and
## logs the sim tick of the next frames: a held clock repeats a tick.
func _hitstop() -> void:
	var clock: SimClock = _world.context().clock
	_view.fx_triggers.listen(
		Events, clock, func() -> Vector2: return _city.focus * SimConst.PX_PER_M
	)
	var ticks: Array[int] = [clock.tick()]
	Events.player_hit.emit(&"robo-tazer")
	for i: int in 6:
		await get_tree().process_frame
		ticks.append(clock.tick())
		if i == 1:
			await _shot("hitstop-tazer.png", -1)
	_log.append({"fired": _view.fx_triggers.fired, "fx_alive": _view.fx.glow.alive()})
	_log.append({"hitstop_ticks_per_frame": ticks, "stops": _view.fx_triggers.stops})
