extends Node
## City frames for the art lanes (night lane d4-production evidence): the real World +
## CitySystem + CityView (as the render selftest builds them) with a light crowd, the camera
## parked on a few fixed street points away from the selftest junction, so parked vehicles,
## kerbs and baked decals are on screen. Deterministic seed; captured at 32 and 48 px/m.
## Windowed only. Usage:
##   godot --rendering-driver d3d12 --path project res://dev/showcase/city_frame.tscn -- --out=<dir>

const MASTER_SEED: int = 91
const BASE: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
const FOCI: Array[Vector2] = [Vector2(30.0, -4.0), Vector2(-4.0, 30.0), Vector2(62.0, 30.0)]
const ZOOMS: Array[float] = [1.0, 1.5]
const SETTLE_FRAMES: int = 60

var _out: String = "user://city_frame"
var _city: CitySystem = null
var _view: CityView = null


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--out="):
			printerr("city_frame: unknown argument %s" % arg)
			get_tree().quit(2)
			return
		_out = arg.substr(6)
	var world: World = World.new()
	world.start(Events, Data, MASTER_SEED)
	add_child(world)
	_city = CitySystem.new(true)
	world.add_system(_city)
	_city.steer_by_input = false
	_set_focus(BASE + FOCI[0])
	var t: CityTargets = CityTargets.riot(40, 8)
	t.cars = 24
	t.police_cars = 2
	_city.spawner.targets = t
	_view = CityView.new()
	add_child(_view)
	_view.setup(_city)
	var characters: CityCharacters = CityCharacters.new(_city, _view, world.context())
	await characters.bake()
	await _view.prewarm()
	var ok: bool = DirAccess.make_dir_recursive_absolute(_out) == OK
	for i: int in FOCI.size():
		_set_focus(BASE + FOCI[i])
		for zoom: float in ZOOMS:
			ok = await _capture(i, zoom) and ok
	printerr("city_frame: placeholders=%d ok=%s" % [_view.textures.placeholders, ok])
	get_tree().quit(0 if ok else 1)


func _set_focus(p: Vector2) -> void:
	_city.focus = p
	_city.target = p
	_city.spawner.riot_c = p


func _capture(i: int, zoom: float) -> bool:
	_view.zoom = zoom
	for f: int in SETTLE_FRAMES:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	var file: String = "city-%d-%dppm.png" % [i, roundi(zoom * SimConst.PX_PER_M)]
	return img != null and img.save_png(_out.path_join(file)) == OK
