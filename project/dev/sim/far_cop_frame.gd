extends Node
## Far foot-cop evidence. Read custom.x from the real people MultiMesh after drawing, and match
## each transform's origin to the cop in the same tick's sim snapshot. Near rigs have no entry.
const KNOWN_FLAGS: PackedStringArray = ["--out", "--ppm", "--view", "--reference"]
const MASTER_SEED: int = 18
const TICK: int = 90

var _world := World.new()
var _view := CityView.new()
var _city: CitySystem
var _heat: CityHeat


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var out: String = args.text("--out")
	if out.is_empty() or DirAccess.make_dir_recursive_absolute(out) != OK:
		get_tree().quit(2)
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	_world.start(Events, Data, MASTER_SEED)
	add_child(_world)
	_world.set_process(false)
	_city = CitySystem.new(not args.has("--reference"))
	_world.add_system(_city)
	_city.steer_by_input = false
	_city.spawner.riot_c = _city.focus
	_city.spawner.targets = CityTargets.riot(0, 80)
	_heat = CityHeat.new(_city)
	_world.add_system(_heat)
	_heat.tune.living = true
	_heat.meter.set_level(3)
	_heat.last_seen = _city.target
	_heat.ever_seen = true
	_city.sim.set_heat(3, _city.target.x, _city.target.y)
	_view.zoom = args.number("--ppm", 16) / SimConst.PX_PER_M
	add_child(_view)
	_view.setup(_city)
	var people := CityCharacters.new(_city, _view, _world.context())
	await people.bake()
	await _view.prewarm()
	for tick: int in TICK:
		await get_tree().process_frame
		_world.loop().step()
	await RenderingServer.frame_post_draw
	get_tree().quit(0 if _save(out) else 1)


func _save(out: String) -> bool:
	var mm: MultiMesh = _view.crowd.multimeshes[SimConst.RL_PEDS]
	var buffer: PackedFloat32Array = RenderingServer.multimesh_get_buffer(mm.get_rid())
	var count: int = RenderingServer.multimesh_get_visible_instances(mm.get_rid())
	if buffer.size() < count * SimConst.RL_STRIDE:
		return false
	var by_pos: Dictionary[Vector2, int] = _cop_slots()
	var hits: Array[Dictionary] = []
	var rows: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0]
	for i: int in count:
		var base: int = i * SimConst.RL_STRIDE
		var pos := Vector2(buffer[base + 3], buffer[base + 7])
		if not by_pos.has(pos):
			continue
		var slot: int = by_pos[pos]
		var row: int = floori(buffer[base + 12] / CrowdAtlas.cols())
		if row < 0 or row >= rows.size():
			return false
		rows[row] += 1
		var screen: Vector2 = _view.get_canvas_transform() * pos
		hits.append({"slot": slot, "row": row, "x": roundi(screen.x), "y": roundi(screen.y)})
	var result: Dictionary = {
		"rows": rows,
		"instances": hits,
		"submitted_people": count,
		"backend": _city.sim.backend_name(),
		"tick": _world.context().clock.tick(),
		"heat": _city.sim.heat_level(),
		"seed": MASTER_SEED,
	}
	var file: FileAccess = FileAccess.open(out.path_join("readback.json"), FileAccess.WRITE)
	var img: Image = get_viewport().get_texture().get_image()
	return (
		not hits.is_empty()
		and _city.sim.heat_level() == 3
		and file != null
		and file.store_string(JSON.stringify(result, "  "))
		and img.save_png(out.path_join("t%d.png" % TICK)) == OK
	)


func _cop_slots() -> Dictionary[Vector2, int]:
	var slots: Dictionary[Vector2, int] = {}
	var snap: PackedFloat64Array = _city.sim.snapshot()
	var variants: PackedByteArray = _city.sim.get_variants()
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		var slot: int = int(snap[r])
		if slot >= SimConst.SNAP_PROJ_BASE:
			break
		if int(snap[r + 1]) == SimConst.K_COP and variants[slot] == CitySpawner.ART_COP:
			var pos := Vector2(snap[r + 4], snap[r + 5]) * SimConst.PX_PER_M
			slots[pos] = slot
	return slots
