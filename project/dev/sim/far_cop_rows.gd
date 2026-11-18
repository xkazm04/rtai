extends Node
## Heat-3 street, fixed seed/ticks. FAR_COP_OUT is the capture directory, FAR_COP_PPM is 16 or 32.
## FAR_COP_CLIP=1 also saves 10 s of unmodified city frames at 15 fps. At the three sample ticks,
## freeze the sim and draw twice: native first, then the same clip/frame with baked_cell's look.
## Read both submitted buffers. The second draw is a dev preview of the character API.

const SEED: int = 18
const STILLS: Array[int] = [120, 240, 360]
const COLS: int = CrowdAtlas.FRAMES_PER_LOOK

var _world: World = World.new()
var _city: CitySystem = CitySystem.new()
var _view: CityView = CityView.new()
var _heat: CityHeat
var _characters: CityCharacters
var _out: String = OS.get_environment("FAR_COP_OUT")
var _ppm: int = OS.get_environment("FAR_COP_PPM").to_int()
var _clip: bool = OS.get_environment("FAR_COP_CLIP") == "1"
var _rows: Array[Dictionary] = []
var _feed_rows: CityFeedRows = CityFeedRows.new()
var _extended: RigFeed = RigFeed.new()


func _ready() -> void:
	if _ppm not in [16, 32] or _out.is_empty() or DirAccess.make_dir_recursive_absolute(_out) != OK:
		Log.error("farcop", "set FAR_COP_OUT and FAR_COP_PPM (16 or 32)")
		get_tree().quit(2)
		return
	_world.start(Events, Data, SEED)
	add_child(_world)
	_world.set_process(false)
	_world.add_system(_city)
	_city.steer_by_input = false
	_city.spawner.riot_c = _city.focus
	_city.spawner.targets = CityTargets.riot(40, 24)
	_city.spawner.targets.cars = 24
	_heat = CityHeat.new(_city)
	_world.add_system(_heat)
	_heat.last_seen = _city.target
	_heat.ever_seen = true
	_heat.meter.set_level(3)
	add_child(_view)
	_view.zoom = float(_ppm) / SimConst.PX_PER_M
	_view.setup(_city)
	_characters = CityCharacters.new(_city, _view, _world.context())
	await _characters.bake()
	@warning_ignore("return_value_discarded")
	await _view.prewarm()
	_view.set_process(false)
	var ok: bool = _characters.rigs.atlas.baked and await _record()
	get_tree().quit(0 if ok else 1)


func _record() -> bool:
	var end: int = 600 if _clip else STILLS[-1]
	for tick: int in range(1, end + 1):
		_world.loop().step()
		_view._process(0.0)
		await RenderingServer.frame_post_draw
		if _heat.meter.level != 3 or _world.context().clock.tick() != tick:
			return false
		if _clip and tick % 4 == 0 and not _save("clip_%04d" % tick):
			return false
		if tick in STILLS and not await _sample(tick):
			return false
	var data: Dictionary = {
		"schema": "gtai.far-cop-rows/1",
		"seed": SEED,
		"ticks": STILLS,
		"heat": 3,
		"ppm": _ppm,
		"backend": "native" if _city.sim is CitySimNative else "reference",
		"summary_source": "character preview (baked_cell row, sim clip and frame)",
		"summary": _summary("atlas_row"),
		"sim_render": _summary("sim_row"),
		"rows": _rows
	}
	var file: FileAccess = FileAccess.open(_out.path_join("probe_%d.json" % _ppm), FileAccess.WRITE)
	Log.info("farcop", "%s, sim %s" % [data.summary, data.sim_render])
	return not _rows.is_empty() and file != null and file.store_string(JSON.stringify(data, "\t"))


func _save(stem: String) -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	return img != null and img.save_png(_out.path_join("%s_%dppm.png" % [stem, _ppm])) == OK


func _sample(tick: int) -> bool:
	var mm: RID = _view.crowd.rids()[SimConst.RL_PEDS]
	var count: int = _city.sim.get_render_counts()[SimConst.RL_PEDS]
	var buffer: PackedFloat32Array = RenderingServer.multimesh_get_buffer(mm)
	var snap: PackedFloat64Array = _city.sim.snapshot()
	var index: Dictionary[Vector2, Array] = _people(snap)
	var variants: PackedByteArray = _city.sim.get_variants()
	var start: int = _rows.size()
	if not _save("city_t%d" % tick):
		return false
	for j: int in count:
		var b: int = j * SimConst.RL_STRIDE
		var pos: Vector2 = Vector2(buffer[b + 3], buffer[b + 7])
		if not index.has(pos) or index[pos].is_empty():
			Log.error("farcop", "unmatched instance %d at %s tick %d" % [j, pos, tick])
			return false
		var r: int = index[pos].pop_front()
		if int(snap[r + 1]) != SimConst.K_COP:
			continue
		var row: Dictionary = _row(tick, int(snap[r]), pos, snap, variants)
		row.instance = j
		var sim_cell: int = roundi(buffer[b + 12])
		var character_row: int = row.character_row
		row.sim_cell = sim_cell
		row.sim_row = floori(float(sim_cell) / COLS)
		buffer[b + 12] = float(character_row * COLS + sim_cell % COLS)
		_rows.append(row)
	RenderingServer.multimesh_set_buffer(mm, buffer)
	await RenderingServer.frame_post_draw
	return _read_preview(mm, start) and _save("character_t%d" % tick)


func _read_preview(mm: RID, start: int) -> bool:
	var drawn: PackedFloat32Array = RenderingServer.multimesh_get_buffer(mm)
	for i: int in range(start, _rows.size()):
		var row: Dictionary = _rows[i]
		var instance: int = row.instance
		var cell: int = roundi(drawn[instance * SimConst.RL_STRIDE + 12])
		var look: int = floori(float(cell) / COLS)
		row.cell = cell
		row.atlas_row = look
		row.is_cop = RigVariant.crowd(look).kind == BodyPlan.Kind.COP
		if row.atlas_row != row.character_row:
			return false
	return true


## Match the uploaded origins to sim slots (the writer emits slot order even for coincident actors).
func _people(snap: PackedFloat64Array) -> Dictionary[Vector2, Array]:
	var index: Dictionary[Vector2, Array] = {}
	var rigs: CharacterRigs = _characters.rigs
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		var id: int = int(snap[r])
		if id >= SimConst.SNAP_PROJ_BASE:
			break
		if int(snap[r + 1]) not in [SimConst.K_PED, SimConst.K_COP]:
			continue
		if rigs.rig_for(id) != null or id in rigs.rest.ids():
			continue
		var pos: Vector2 = Vector2(snap[r + 4], snap[r + 5]) * SimConst.PX_PER_M
		if not index.has(pos):
			index[pos] = []
		index[pos].append(r)
	return index


func _row(
	tick: int, id: int, pos: Vector2, snap: PackedFloat64Array, variants: PackedByteArray
) -> Dictionary:
	var rigs: CharacterRigs = _characters.rigs
	var live: RigFeed = rigs.feed
	var i: int = live.ids.find(id)
	var in_feed: bool = i >= 0 and i < live.count
	if not in_feed:
		# Wider than the 18 m near feed: ask the same city adapter for this actor's feed row.
		_feed_rows.fill(
			_extended, snap, variants, pos / SimConst.PX_PER_M, _city.target * SimConst.PX_PER_M
		)
		rigs.feed = _extended
		i = _extended.ids.find(id)
	var cell: int = rigs.baked_cell(i, tick * SimClock.TICK_DT)
	var screen: Vector2 = (
		_view.crowd.nodes[SimConst.RL_PEDS].get_global_transform_with_canvas() * pos
	)
	var result: Dictionary = {
		"tick": tick,
		"actor_id": id,
		"kind": rigs.feed.kinds[i],
		"look_of": rigs.feed.look_of(i),
		"in_city_feed": in_feed,
		"screen_px": [screen.x, screen.y],
		"character_row": floori(float(cell) / COLS)
	}
	rigs.feed = live
	return result


func _summary(key: String) -> Dictionary:
	var peds: int = 0
	var histogram: Dictionary[int, int] = {}
	for row: Dictionary in _rows:
		var look: int = row[key]
		histogram[look] = histogram.get(look, 0) + 1
		if RigVariant.crowd(look).kind == BodyPlan.Kind.PED:
			peds += 1
	return {
		"cop_rows_baked": _rows.size(),
		"drawn_as_ped": peds,
		"drawn_as_cop": _rows.size() - peds,
		"row_counts": histogram
	}
