extends Node
## Seventeen native city slots on a pavement. Move only the focus for the stills;
## in the movie the native walkers advance for 600 ticks. Check the actual rig mask.
const KNOWN_FLAGS: PackedStringArray = ["--out", "--motion", "--slot-preview"]
const NEEDS_WINDOW: bool = true
const FIXED_FPS: int = 60
const N: int = 17
const TARGET: int = 15
const BASE: Vector2 = Vector2(32, 32)
const PX: float = SimConst.PX_PER_M
const LOOKS: Array[int] = [0, 6, 7]

var _out: String
var _motion: bool
var _slot_preview: bool
var _stage: SubViewport = SubViewport.new()
var _world: Node2D = Node2D.new()
var _rigs: CharacterRigs = CharacterRigs.new()
var _layers: CrowdLayers = CrowdLayers.new()
var _rows: CityFeedRows = CityFeedRows.new()
var _sim: CitySimBackend = CitySimNative.best()
var _events: Array[Dictionary] = []


func _ready() -> void:
	for arg: String in LaunchArgs.unknown():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
	_motion = LaunchArgs.unknown().has("--motion")
	_slot_preview = LaunchArgs.unknown().has("--slot-preview")
	if (
		(_slot_preview and _motion)
		or _out.is_empty()
		or DirAccess.make_dir_recursive_absolute(_out) != OK
	):
		get_tree().quit(2)
		return
	ViewMode.select("tilt70")
	_make_stage()
	await _rigs.bake_crowd()
	var people: MultiMeshInstance2D = _layers.nodes[SimConst.RL_PEDS]
	people.texture = _rigs.atlas.texture
	people.material = _rigs.atlas.crowd_material()
	var ok: bool = _rigs.atlas.baked
	for look: int in [0] if _motion else LOOKS:
		ok = await _take(look) and ok
	if not _motion:
		people.hide()
		_rigs.hide()
		await RenderingServer.frame_post_draw
		ok = _stage.get_texture().get_image().save_png(_out.path_join("ground.png")) == OK and ok
	var file: FileAccess = FileAccess.open(_out.path_join("ring.json"), FileAccess.WRITE)
	var report: Dictionary = {
		"schema": "gtai.crowd-pop-ring/1",
		"backend": _sim.backend_name(),
		"events": _events,
		"slot_preview": _slot_preview
	}
	ok = file != null and file.store_string(JSON.stringify(report)) and ok
	get_tree().quit(0 if ok else 1)


func _make_stage() -> void:
	_stage.size = Vector2i(960, 480) if _motion else Vector2i(224, 192)
	_stage.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_stage)
	_stage.add_child(_world)
	_ground()
	_layers.attach(_world)
	_world.add_child(_rigs)
	_rigs.setup(World.build_context(Events, Data, 5))
	_rigs.set_process(false)
	_rigs.zoom = 1.0 if _motion else 2.0


func _ground() -> void:
	var tile: Texture2D = load("res://features/city/art/ground/sidewalk_tone.png") as Texture2D
	for y: int in range(-2, 3):
		for x: int in range(-3, 5):
			var spr: Sprite2D = Sprite2D.new()
			spr.texture = tile
			spr.scale = Vector2.ONE * 8.0 * PX / tile.get_width()
			spr.position = (BASE + Vector2(x, y) * 8.0) * PX
			_world.add_child(spr)


func _spawn(look: int) -> bool:
	_sim.init(5)
	_sim.set_radii(50, 100, 20)
	var cells: PackedByteArray = CityChunk.zeros(CityChunk.CELLS)
	cells.fill(SimConst.C_WALK)
	_sim.stamp_chunk(0, 0, CityChunk.zeros(CityChunk.TILES), cells)
	for i: int in N:
		var pos: Vector2 = Vector2((i % 5 - 2) * 1.8, (i / 5 - 1) * 2.2)
		if i >= TARGET:
			pos = Vector2(7 if i == TARGET else -7, 0)
		var v: int = look if i == TARGET else [0, 2, 3, 4, 7][i % 5]
		var kind: int = SimConst.K_COP if v == 6 else SimConst.K_PED
		var dx: float = -1.0 if _motion and i % 3 == 1 else 1.0
		var spec: PackedFloat64Array = [
			kind, BASE.x + pos.x, BASE.y + pos.y, dx, 0, v, 0, 1.0 + 0.06 * i, BASE.y + pos.y, 0
		]
		if _sim.spawn(spec) != i:
			return false
	_sim.set_render(_layers.rids(), CrowdAtlas.clip_table())
	_sim.set_person_px(CrowdAtlas.cell_world_px())
	return true


func _take(look: int) -> bool:
	if not _spawn(look):
		return false
	# Empty the selection and release pooled looks between takes.
	_rigs.feed.count = 0
	_rigs.step_ticks(0)
	_rigs._select_in = 0  # Select on tick 1 of every take, then on ticks 5, 9, ... 33.
	var prev: bool = false
	var switches: int = 0
	var ok: bool = true
	for tick: int in range(1, 601 if _motion else 34):
		var f: Vector2 = BASE + Vector2(0.5 if tick < 30 else -0.5, 0)
		if _motion:
			f = BASE + Vector2(3.0 * cos(tick * TAU / 360), 0)
			_sim.step(SimClock.TICK_DT, f.x, f.y, BASE.x, BASE.y)
		var row: int = _draw(f)
		var full: bool = row >= 0 and _rigs.full_row(row)
		if tick > 1 and full != prev:
			switches += 1
		if prev != full or (not _motion and tick >= 31):
			_events.append({"look": look, "tick": tick, "full": full, "slot": TARGET})
		prev = full
		if not _motion and tick >= 31:
			ok = (full == (tick < 33)) and ok
		if (_motion and tick % 4 == 0) or (not _motion and tick >= 31):
			await RenderingServer.frame_post_draw
			var name: String = (
				"frame-%04d" % (tick / 4)
				if _motion
				else "%s-t%d" % [RigVariant.crowd(look).tag, tick]
			)
			ok = (
				_stage.get_texture().get_image().save_png(_out.path_join(name + ".png")) == OK
				and ok
			)
	return ok and switches > 0


func _draw(focus: Vector2) -> int:
	_rows.fill(
		_rigs.feed, _sim.snapshot(), _sim.get_variants(), focus, (BASE + Vector2(12, 0)) * PX
	)
	_rigs.focus = focus * PX
	_rigs.step_ticks(1)
	var full: PackedInt32Array = []
	for i: int in _rigs.feed.count:
		if _rigs.full_row(i):
			@warning_ignore("return_value_discarded")
			full.append(_rigs.feed.ids[i])
	_sim.set_rig_slots(full)
	_sim.write_render(BASE.x - 35, BASE.y - 15, BASE.x + 35, BASE.y + 15)
	if _slot_preview:
		_preview_slot()
	var z: Vector2 = ViewMode.shared().zoom_of(_rigs.zoom)
	var centre: Vector2 = (BASE + Vector2(7, -0.85)) * PX
	if _motion:
		centre = (focus + Vector2(0, -0.5)) * PX
	var canvas: Transform2D = Transform2D.IDENTITY.scaled(z)
	canvas.origin = Vector2(_stage.size) * 0.5 - centre * z
	_stage.canvas_transform = canvas
	return _rigs.feed.ids.find(TARGET)


## The two gfx writer changes only: populate custom.y on the one native baked instance.
func _preview_slot() -> void:
	var mm: RID = _layers.multimeshes[SimConst.RL_PEDS].get_rid()
	var buf: PackedFloat32Array = RenderingServer.multimesh_get_buffer(mm)
	for row: int in _rigs.feed.count:
		if not _rigs.full_row(row):
			buf[13] = float(_rigs.feed.ids[row] + 1)
			RenderingServer.multimesh_set_buffer(mm, buf)
			return
