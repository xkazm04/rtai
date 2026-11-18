extends Node
## Fixed-camera traffic evidence. One frame per four fixed sim ticks (encode at 15 fps).
## Counts only moving K_CAR centres inside the camera, with bikes disabled for both arms.

const KNOWN_FLAGS: PackedStringArray = [
	"--cars", "--zone", "--out", "--before", "--view", "--counts-only"
]
const CENTRES: Dictionary[String, Vector2] = {
	"docks": Vector2(1804, 1036), "downtown": Vector2(1036, 1036), "mixed": Vector2(524, 524)
}
const SEED_VALUE: int = 91
const FRAMES: int = 150
const STEP: int = 4

var _world := World.new()
var _city := CitySystem.new()
var _view := CityView.new()
var _label := Label.new()


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var zone: String = args.text("--zone")
	var out: String = args.text("--out")
	var target: int = int(args.number("--cars", 120))
	if not CENTRES.has(zone) or out.is_empty() or target < 1 or target > SimConst.CAP:
		Log.error(
			"zone_traffic_film", "requires --zone, --out and a traffic target within capacity"
		)
		get_tree().quit(2)
		return
	_setup(zone, target, args.has("--before"))
	await _view.prewarm()
	for warmup: int in 60:
		await get_tree().process_frame
		_world.loop().step()
	var ok: bool = DirAccess.make_dir_recursive_absolute(out) == OK
	if ok:
		ok = await _record(out, zone, args.has("--before"), args.has("--counts-only"))
	get_tree().quit(0 if ok else 1)


func _setup(zone: String, target: int, before: bool) -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	_world.start(Events, Data, SEED_VALUE)
	add_child(_world)
	_world.set_process(false)
	_city.bike_share = 0.0
	_world.add_system(_city)
	_city.steer_by_input = false
	_city.focus = CENTRES[zone]
	_city.target = _city.focus
	_city.body.on = false
	if before:
		var rng: RandomNumberGenerator = _world.context().rng.stream(CitySystem.SPAWN_STREAM)
		_city.spawner = CitySpawner.new(_city.sim, _city.residency, rng)
	_city.spawner.targets = CityTargets.street(0, target, 0)
	_city.spawner.rb = 68.0
	_city.spawner.r_min = 48.0
	add_child(_view)
	_view.zoom = 1.0
	_view.setup(_city)
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	layer.add_child(_label)
	_label.position = Vector2(12, 10)
	_label.add_theme_font_size_override("font_size", 21)
	_label.add_theme_constant_override("outline_size", 6)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	var plate := StyleBoxFlat.new()
	plate.bg_color = Color(0.04, 0.04, 0.04, 0.85)
	plate.set_content_margin_all(6)
	_label.add_theme_stylebox_override("normal", plate)


func _record(out: String, zone: String, before: bool, counts_only: bool) -> bool:
	var rows: Array[Dictionary] = []
	for frame: int in FRAMES:
		await get_tree().process_frame
		for step: int in STEP:
			_world.loop().step()
		var counts: Array[int] = _moving()
		var tick: int = _world.context().clock.tick()
		var n: int = counts.reduce(func(a: int, b: int) -> int: return a + b, 0)
		_label.text = (
			"%s  %s  |  tick %d  |  %d moving\nVan %d   Pickup %d   Taxi %d   Ambulance %d   Sedans %d"
			% [
				zone,
				"before" if before else "after",
				tick,
				n,
				counts[4],
				counts[5],
				counts[3],
				counts[6],
				counts[0] + counts[1] + counts[2] + counts[7]
			]
		)
		rows.append({"tick": tick, "art": counts, "moving": n})
		if counts_only:
			continue
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		if img.save_png(out.path_join("f%03d.png" % frame)) != OK:
			return false
	var file: FileAccess = FileAccess.open(out.path_join("ticks.json"), FileAccess.WRITE)
	return file != null and file.store_string(JSON.stringify(rows))


func _moving() -> Array[int]:
	var counts: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0]
	var snap: PackedFloat64Array = _city.sim.snapshot()
	var variants: PackedByteArray = _city.sim.get_variants()
	var size: Vector2 = get_viewport().get_visible_rect().size
	if DisplayServer.get_name() == "headless":
		size = Vector2(1920, 1080)
	var half: Vector2 = size * 0.5 / (SimConst.PX_PER_M * ViewMode.shared().zoom_of(1.0))
	var bounds := Rect2(_city.focus - half, half * 2.0)
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if int(snap[r]) >= SimConst.SNAP_PROJ_BASE:
			break
		var p := Vector2(snap[r + 4], snap[r + 5])
		if int(snap[r + 1]) == SimConst.K_CAR and snap[r + 8] > 0.2 and bounds.has_point(p):
			counts[variants[int(snap[r])]] += 1
	return counts
