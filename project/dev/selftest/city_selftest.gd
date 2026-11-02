extends Node
## Render selftest (the `selftest` evidence): the real World + CitySystem + CityView in the D4
## look at a fixed junction with a crowd, prewarmed, captured after frame_post_draw at 32 px/m
## (zoom 1.0) and 48 px/m (zoom 1.5). Each frame is sanity-checked (size, not blank, enough
## distinct colours, actors on screen) and saved as PNG next to a gtai.selftest/1 result JSON.
## Windowed only (headless renders nothing). Usage:
##   godot --path project res://dev/selftest/city_selftest.tscn -- --out=<dir>

const KNOWN_FLAGS: PackedStringArray = ["--out"]
const MASTER_SEED: int = 91
const JUNCTION: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
const ZOOMS: Array[float] = [1.0, 1.5]
const SETTLE_FRAMES: int = 90

var _out: String = "user://selftest"
var _world: World = null
var _city: CitySystem = null
var _view: CityView = null
var _characters: CityCharacters = null


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("city_selftest: unknown argument %s" % arg)
			get_tree().quit(2)
			return
		_out = arg.substr(flag.length() + 1)
	_build()
	await _characters.bake()
	var warm_us: int = await _view.prewarm()
	var frames: Array[Dictionary] = []
	for zoom: float in ZOOMS:
		frames.append(await _capture(zoom))
	_finish(frames, warm_us)


func _build() -> void:
	_world = World.new()
	_world.start(Events, Data, MASTER_SEED)
	add_child(_world)
	_city = CitySystem.new(true)
	_world.add_system(_city)
	_city.steer_by_input = false
	_city.focus = JUNCTION
	_city.target = JUNCTION
	var t: CityTargets = CityTargets.riot(110, 16)
	t.cars = 40
	t.police_cars = 4
	_city.spawner.targets = t
	_city.spawner.riot_c = JUNCTION
	_view = CityView.new()
	add_child(_view)
	_view.setup(_city)
	_characters = CityCharacters.new(_city, _view, _world.context())


func _capture(zoom: float) -> Dictionary:
	_view.zoom = zoom
	for i: int in SETTLE_FRAMES:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	var ppm: int = roundi(zoom * SimConst.PX_PER_M)
	var file: String = "selftest-%dppm.png" % ppm
	var saved: bool = img.save_png(_out.path_join(file)) == OK
	var check: Dictionary = SelftestImage.check(img, get_viewport().get_visible_rect().size)
	check["file"] = file
	check["ppm"] = ppm
	check["visible_actors"] = _view.visible_actors
	check["ok"] = saved and check["ok"] and _view.visible_actors > 0
	return check


func _finish(frames: Array[Dictionary], warm_us: int) -> void:
	var ok: bool = true
	for f: Dictionary in frames:
		ok = ok and f["ok"]
	var res: Dictionary = {
		"schema": "gtai.selftest/1",
		"ok": ok and _view.textures.failures.is_empty(),
		"frames": frames,
		"prewarm_ms": warm_us / 1000.0,
		"texture_load_ms": _view.textures.load_us / 1000.0,
		"art_loaded": _view.textures.art_loaded,
		"placeholders": _view.textures.placeholders,
		"texture_failures": _view.textures.failures,
		"fx_cues": _view.fx_triggers.fired,
		"fx_dropped": _view.fx.dropped + _view.fx.glow.dropped + _view.fx.ground.dropped,
		"backend": String(_city.sim.backend_name()),
		"gpu": RenderingServer.get_video_adapter_name(),
		"debug_build": OS.is_debug_build(),
	}
	var f: FileAccess = FileAccess.open(_out.path_join("selftest-result.json"), FileAccess.WRITE)
	var written: bool = f != null and f.store_string(JSON.stringify(res, "  ", true))
	if f != null:
		f.close()
	printerr("city_selftest: %s" % JSON.stringify(res))
	get_tree().quit(0 if written and res["ok"] else 1)
