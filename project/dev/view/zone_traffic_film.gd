extends Node
## Fixed-camera comparison of spawned traffic. Count the rendered car quads in the viewport
## on a fixed-seed first pass, then replay those ticks with the complete clip census on screen.

const KNOWN_FLAGS: PackedStringArray = [
	"--cars", "--zone", "--out", "--before", "--view", "--counts-only", "--ppm", "--still-tick"
]
## Art IDs in sim order mapped to van, pickup, taxi, ambulance and sedan counts.
const GROUP_BY_ART: Array[int] = [4, 4, 4, 2, 0, 1, 3, 4]
const SEED_VALUE: int = 91
const FRAMES: int = 150
const STEP: int = 4
const WARMUP: int = 60
## Quad size in metres from the city render writer, nose along the heading.
const CAR_HALF := Vector2(3.2, 1.6)

@export var traffic_foci: Dictionary[String, Vector2]
@export var close_up_centres: Dictionary[String, Vector2]

var _world: World
var _city: CitySystem
var _label: Label
var _out: String
var _zone: String
var _before: bool
var _target: int
var _ppm: int
var _centre: Vector2
var _bounds: Rect2
var _screen: PackedVector2Array
var _rows: Array[Dictionary] = []
var _totals: Array[int] = [0, 0, 0, 0, 0]


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	if not _configure(args):
		Log.error("zone_traffic_film", "Invalid zone, camera, traffic target or output")
		get_tree().quit(2)
		return
	_start_sim()
	for frame: int in FRAMES:
		_advance(STEP)
		var row: Dictionary = _census()
		_rows.append(row)
		for i: int in _totals.size():
			_totals[i] += row.art[i]
	var file: FileAccess = FileAccess.open(_out.path_join("ticks.json"), FileAccess.WRITE)
	if file == null or not file.store_string(JSON.stringify({"rows": _rows, "clip": _totals})):
		get_tree().quit(1)
		return
	if args.has("--counts-only"):
		get_tree().quit()
		return
	_world.free()
	_start_sim()
	var ok: bool = await _film(int(args.number("--still-tick", -1)))
	get_tree().quit(0 if ok else 1)


func _configure(args: ArenaArgs) -> bool:
	_zone = args.text("--zone")
	_out = args.text("--out")
	_before = args.has("--before")
	_target = int(args.number("--cars", 24))
	_ppm = int(args.number("--ppm", 32))
	if not traffic_foci.has(_zone) or _out.is_empty() or _target < 1 or _target > SimConst.CAP:
		return false
	var centres: Dictionary[String, Vector2] = close_up_centres if _ppm == 64 else traffic_foci
	_centre = centres.get(_zone, traffic_foci[_zone])
	if _ppm != 32 and _ppm != 64:
		return false
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var size: Vector2 = get_viewport().get_visible_rect().size
	if DisplayServer.get_name() == "headless":
		size = Vector2(1920, 1080)
	var half: Vector2 = size * 0.5 / ViewMode.shared().zoom_of(_ppm)
	_bounds = Rect2(_centre - half, 2.0 * half)
	var diagonal := Vector2(half.x, -half.y)
	_screen = PackedVector2Array(
		[_bounds.position, _centre + diagonal, _bounds.end, _centre - diagonal]
	)
	return DirAccess.make_dir_recursive_absolute(_out) == OK


func _start_sim() -> void:
	_world = World.new()
	_world.start(Events, Data, SEED_VALUE)
	add_child(_world)
	_world.set_process(false)
	_city = CitySystem.new()
	_city.bike_share = 0.0
	_world.add_system(_city)
	_city.steer_by_input = false
	_city.focus = traffic_foci[_zone]
	_city.target = _city.focus
	_city.body.on = false
	if _before:
		var rng: RandomNumberGenerator = _world.context().rng.stream(CitySystem.SPAWN_STREAM)
		_city.spawner = CitySpawner.new(_city.sim, _city.residency, rng)
	_city.spawner.targets = CityTargets.street(0, _target, 0)
	_city.spawner.rb = 68.0
	_city.spawner.r_min = 48.0
	_advance(WARMUP)


func _advance(steps: int) -> void:
	for step: int in steps:
		_world.loop().step()


func _in_frame(p: Vector2, head: Vector2) -> bool:
	if _bounds.has_point(p):
		return true
	if not _bounds.grow(CAR_HALF.length()).has_point(p):
		return false
	var nose: Vector2 = head * CAR_HALF.x
	var side: Vector2 = head.orthogonal() * CAR_HALF.y
	var quad := PackedVector2Array(
		[p - nose - side, p + nose - side, p + nose + side, p - nose + side]
	)
	return not Geometry2D.intersect_polygons(_screen, quad).is_empty()


func _census() -> Dictionary:
	var counts: Array[int] = [0, 0, 0, 0, 0]
	var moving: int = 0
	var snap: PackedFloat64Array = _city.sim.snapshot()
	var variants: PackedByteArray = _city.sim.get_variants()
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		var slot: int = int(snap[r])
		if slot >= SimConst.SNAP_PROJ_BASE:
			break
		if int(snap[r + 1]) != SimConst.K_CAR:
			continue
		var p := Vector2(snap[r + 4], snap[r + 5])
		if _in_frame(p, Vector2(snap[r + 6], snap[r + 7])):
			var art: int = variants[slot]
			counts[GROUP_BY_ART[art]] += 1
			moving += int(snap[r + 8] > 0.2)
	return {"art": counts, "moving": moving, "tick": _world.context().clock.tick()}


func _add_label() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_label = Label.new()
	layer.add_child(_label)
	_label.position = Vector2(12, 10)
	_label.add_theme_font_size_override("font_size", 21)
	var plate := StyleBoxFlat.new()
	plate.bg_color = Color(0.04, 0.04, 0.04, 0.90)
	plate.set_content_margin_all(6)
	_label.add_theme_stylebox_override("normal", plate)


func _caption(row: Dictionary) -> String:
	var fmt: String = "Van %d   Pickup %d   Taxi %d   Ambulance %d   Sedans %d"
	var total: int = _totals.reduce(func(a: int, b: int) -> int: return a + b, 0)
	var per: float = 100.0 / maxi(total, 1)
	var arm: String = " before" if _before else " after"
	var district: String = _zone.get_slice("/", 0).capitalize() + arm
	var sample: String = "%s   |   Tick %d   |   %s" % [district, row.tick, fmt % row.art]
	var shares: String = (
		"Vans+pickups %.0f%%   Taxis %.0f%%" % [(_totals[0] + _totals[1]) * per, _totals[2] * per]
	)
	return "%s\nClip (%d frames)   |   %s   |   %s" % [sample, FRAMES, fmt % _totals, shares]


func _film(still: int) -> bool:
	var view := CityView.new()
	view.zoom = float(_ppm) / SimConst.PX_PER_M
	view.kick_px = (_centre - _city.focus) * SimConst.PX_PER_M
	add_child(view)
	view.setup(_city)
	_add_label()
	await view.prewarm()
	for settle: int in WARMUP:
		await get_tree().process_frame
	for frame: int in FRAMES:
		await get_tree().process_frame
		_advance(STEP)
		var row: Dictionary = _census()
		if row != _rows[frame]:
			Log.error("zone_traffic_film", "Census diverged at tick %d" % row.tick)
			return false
		if still >= 0 and row.tick != still:
			continue
		_label.text = _caption(row)
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		if img.save_png(_out.path_join("f%03d.png" % frame)) != OK:
			return false
		if still >= 0:
			return true
	return still == -1
