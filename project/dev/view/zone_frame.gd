extends Node
## Zone stills and drives through the generated city (n18 districts evidence): the real World +
## CitySystem + CityView + a light crowd (as dev/showcase/city_frame), the camera parked on named
## world points, a place's door (CityPlaces) or a straight drive between two points. Windowed only.
## Usage: godot --rendering-driver d3d12 --path project res://dev/view/zone_frame.tscn --
##   --out=<dir> [--at=<name>:<x>,<y>;...] [--place=<id>,...] [--zooms=1,1.5]
##   [--drive=<x0>,<y0>,<x1>,<y1>,<mps>] (one PNG every 2nd frame at the first zoom, 30 fps)
##   [--settle=<frames>] [--look=<id>]; --view=<id> is read by ViewMode.

const MASTER_SEED: int = 91
const KNOWN: PackedStringArray = [
	"--out", "--at", "--place", "--zooms", "--drive", "--settle", "--look", "--view"
]

var _out: String = "user://zone_frame"
var _city: CitySystem = null
var _view: CityView = null
var _shots: Array[Array] = []
var _zooms: Array[float] = [1.0, 1.5]
var _settle: int = 60
var _look: StringName = &""
var _drive: PackedFloat32Array = PackedFloat32Array()


func _ready() -> void:
	var args: Dictionary = _parse()
	if args.is_empty():
		get_tree().quit(2)
		return
	var world: World = World.new()
	world.start(Events, Data, MASTER_SEED)
	add_child(world)
	_city = CitySystem.new(true)
	world.add_system(_city)
	_city.steer_by_input = false
	_add_places(str(args.get("--place", "")))
	var shot0: Vector2 = _shots[0][1] if not _shots.is_empty() else Vector2.ZERO
	var first: Vector2 = Vector2(_drive[0], _drive[1]) if _drive.size() >= 2 else shot0
	_focus(first)
	var t: CityTargets = CityTargets.riot(24, 4)
	t.cars = 24
	t.police_cars = 2
	_city.spawner.targets = t
	_view = CityView.new()
	add_child(_view)
	_view.setup(_city)
	if _look != &"":
		_view.look_id = _look
	var characters: CityCharacters = CityCharacters.new(_city, _view, world.context())
	await characters.bake()
	await _view.prewarm()
	var ok: bool = DirAccess.make_dir_recursive_absolute(_out) == OK
	for shot: Array in _shots:
		var at: Vector2 = shot[1]
		_focus(at)
		for zoom: float in _zooms:
			ok = (
				await _capture("%s-%dppm" % [shot[0], roundi(zoom * SimConst.PX_PER_M)], zoom)
				and ok
			)
	if _drive.size() == 5:
		ok = await _drive_clip() and ok
	printerr("zone_frame: placeholders=%d ok=%s" % [_view.textures.placeholders, ok])
	get_tree().quit(0 if ok else 1)


func _parse() -> Dictionary:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		var key: String = arg.split("=")[0]
		if not KNOWN.has(key):
			printerr("zone_frame: unknown argument %s" % arg)
			return {}
		args[key] = arg.substr(key.length() + 1)
	_out = str(args.get("--out", _out))
	_settle = str(args.get("--settle", "60")).to_int()
	_look = StringName(str(args.get("--look", "")))
	if args.has("--zooms"):
		_zooms.clear()
		for v: String in str(args["--zooms"]).split(","):
			_zooms.append(v.to_float())
	for spec: String in str(args.get("--at", "")).split(";", false):
		var parts: PackedStringArray = spec.split(":")
		var xy: PackedStringArray = parts[1].split(",")
		_shots.append([parts[0], Vector2(xy[0].to_float(), xy[1].to_float())])
	_drive = PackedFloat32Array(
		Array(str(args.get("--drive", "")).split(",", false)).map(
			func(v: String) -> float: return v.to_float()
		)
	)
	args["ok"] = true
	return args


func _add_places(ids: String) -> void:
	if ids == "":
		return
	var places: CityPlaces = CityPlaces.shipped(_city.gen)
	for id: String in ids.split(","):
		var p: Dictionary = places.place(id)
		if p.is_empty():
			printerr("zone_frame: place %s does not resolve" % id)
			continue
		var door: Vector2 = p["door"]
		printerr("zone_frame: place %s door %s cell %s" % [id, door, p["cell"]])
		_shots.append(["place-" + id, door + Vector2(0.0, -6.0)])


func _focus(p: Vector2) -> void:
	_city.focus = p
	_city.target = p
	_city.spawner.riot_c = p


func _capture(file: String, zoom: float) -> bool:
	_view.zoom = zoom
	for f: int in _settle:
		await get_tree().process_frame
	return await _save(file)


## A straight drive at <mps>, one PNG every 2nd tick (30 fps when run with --fixed-fps 60).
func _drive_clip() -> bool:
	var a: Vector2 = Vector2(_drive[0], _drive[1])
	var b: Vector2 = Vector2(_drive[2], _drive[3])
	var frames: int = ceili(a.distance_to(b) / (_drive[4] * SimClock.TICK_DT))
	_view.zoom = _zooms[0]
	_focus(a)
	for f: int in _settle:
		await get_tree().process_frame
	var ok: bool = true
	for f: int in frames:
		_focus(a.lerp(b, float(f) / frames))
		await get_tree().process_frame
		if f % 2 == 0:
			ok = await _save("drive-%05d" % floori(f * 0.5)) and ok
	return ok


func _save(file: String) -> bool:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	return img != null and img.save_png(_out.path_join(file + ".png")) == OK
