extends Node
## City frames for the art lanes (night lane d4-production evidence): the real World +
## CitySystem + CityView (as the render selftest builds them) with a light crowd, the camera
## parked on a few fixed street points away from the selftest junction, so parked vehicles,
## kerbs and baked decals are on screen. Deterministic seed; captured at 32 and 48 px/m.
## Windowed only. Usage:
##   godot --rendering-driver d3d12 --path project res://dev/showcase/city_frame.tscn -- --out=<dir>
##   [--hud=<ui scale>,...]  also captures each frame with the dev HudOverlay at those UI scales.
##   [--cars=<n>] [--police=<n>] [--settle=<frames>]  traffic targets (24, 2), frames per shot (60).
##   [--zooms=<z>,...]  zooms to shoot (1 = 32 px/m; default 1,1.5; 2 = 64 px/m).
##   [--look=<id>]  the look profile (default `auto`); [--foci=<i>,...] which FOCI to shoot.
##   [--pan=<frames>]  after each shot, pans east at PAN_MPS for that many frames, one PNG each,
##   plus city-<i>-<ppm>-pan.json (camera screen px per frame); [--nosnap] the sub-pixel camera.
##   Run with --fixed-fps 60 for a deterministic frame (one sim tick per rendered frame).

const MASTER_SEED: int = 91
const BASE: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
## 0-2 the d4-production streets; 3 the junction centre, 4 a street between two building
## blocks, 5 and 6 the generator's STRIKE paint and fist stencil (GENERATOR 9), 7 a block with the
## 2 x 2 T1-scale roof (GENERATOR 10) (opt-in: --foci=3,4)
const FOCI: Array[Vector2] = [
	Vector2(30.0, -4.0),
	Vector2(-4.0, 30.0),
	Vector2(62.0, 30.0),
	Vector2(0.0, 0.0),
	Vector2(-36.0, 0.0),
	Vector2(2.1, -44.0),
	Vector2(-28.0, 57.0),
	Vector2(92.0, 28.0)
]
const ZOOMS: Array[float] = [1.0, 1.5]
const SETTLE_FRAMES: int = 60
## the pan speed (m/s): a slow car, a non-integer px step per frame at every zoom
const PAN_MPS: float = 7.3

var _out: String = "user://city_frame"
var _city: CitySystem = null
var _view: CityView = null
var _hud_scales: Array[float] = []
var _hud: HudOverlay = null
var _cars: int = 24
var _police: int = 2
var _settle: int = SETTLE_FRAMES
var _zooms: Array[float] = ZOOMS.duplicate()
var _look: StringName = &""
var _foci: Array[int] = [0, 1, 2]
var _pan: int = 0
var _snap: bool = true


func _ready() -> void:
	if not _parse_args():
		get_tree().quit(2)
		return
	var world: World = World.new()
	world.start(Events, Data, MASTER_SEED)
	add_child(world)
	_city = CitySystem.new(true)
	world.add_system(_city)
	_city.steer_by_input = false
	_set_focus(BASE + FOCI[0])
	var t: CityTargets = CityTargets.riot(40, 8)
	t.cars = _cars
	t.police_cars = _police
	_city.spawner.targets = t
	_view = CityView.new()
	add_child(_view)
	_view.setup(_city)
	if _look != &"":
		_view.look_id = _look
	_view.snap_px = _snap
	var characters: CityCharacters = CityCharacters.new(_city, _view, world.context())
	await characters.bake()
	await _view.prewarm()
	var ok: bool = DirAccess.make_dir_recursive_absolute(_out) == OK
	for i: int in _foci:
		_set_focus(BASE + FOCI[i])
		for zoom: float in _zooms:
			ok = await _capture(i, zoom) and ok
	printerr("city_frame: placeholders=%d ok=%s" % [_view.textures.placeholders, ok])
	get_tree().quit(0 if ok else 1)


func _parse_args() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg.begins_with("--hud="):
			for v: String in arg.substr(6).split(","):
				_hud_scales.append(v.to_float())
		elif arg.begins_with("--cars="):
			_cars = arg.substr(7).to_int()
		elif arg.begins_with("--police="):
			_police = arg.substr(9).to_int()
		elif arg.begins_with("--settle="):
			_settle = arg.substr(9).to_int()
		elif arg.begins_with("--look="):
			_look = StringName(arg.substr(7))
		elif arg.begins_with("--foci="):
			_foci.clear()
			for v: String in arg.substr(7).split(","):
				_foci.append(v.to_int())
		elif arg.begins_with("--pan="):
			_pan = arg.substr(6).to_int()
		elif arg == "--nosnap":
			_snap = false
		elif arg.begins_with("--zooms="):
			_zooms.clear()
			for v: String in arg.substr(8).split(","):
				_zooms.append(v.to_float())
		else:
			printerr("city_frame: unknown argument %s" % arg)
			return false
	return true


func _set_focus(p: Vector2) -> void:
	_city.focus = p
	_city.target = p
	_city.spawner.riot_c = p


func _capture(i: int, zoom: float) -> bool:
	_view.zoom = zoom
	for f: int in _settle:
		await get_tree().process_frame
	var file: String = "city-%d-%dppm" % [i, roundi(zoom * SimConst.PX_PER_M)]
	var ok: bool = await _save(file)
	if _pan > 0:
		ok = await _shoot_pan(file) and ok
	for s: float in _hud_scales:
		if _hud == null:
			_hud = HudOverlay.new()
			add_child(_hud)
		_hud.visible = true
		_hud.build(s)
		await get_tree().process_frame
		ok = await _save("%s-hud%d" % [file, roundi(s * 100.0)]) and ok
		_hud.visible = false
	return ok


## Pans east one tick per frame; the world under a pixel-snapped camera moves by whole px.
func _shoot_pan(file: String) -> bool:
	var ok: bool = true
	var cams: Array = []
	var start: Vector2 = _city.focus
	for f: int in _pan:
		_set_focus(start + Vector2(PAN_MPS * SimClock.TICK_DT * (f + 1), 0.0))
		await get_tree().process_frame
		ok = await _save("%s-pan-%02d" % [file, f]) and ok
		var c: Vector2 = _view.camera.position * _view.zoom
		cams.append([c.x, c.y])
	_set_focus(start)
	var fa: FileAccess = FileAccess.open(_out.path_join(file + "-pan.json"), FileAccess.WRITE)
	if fa == null:
		return false
	return fa.store_string(JSON.stringify({"cam_px": cams, "snap": _snap})) and ok


func _save(file: String) -> bool:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	return img != null and img.save_png(_out.path_join(file + ".png")) == OK
