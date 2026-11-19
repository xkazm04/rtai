extends Node
## Measure the finished atlas on the city quad and an independent, uncropped CutRig at 64 px/m.
## The reference reuses the baker's pose times and treadmill. Its framing is independent.
const KNOWN_FLAGS: PackedStringArray = ["--out", "--check"]
const NEEDS_WINDOW: bool = true
const SLOT: int = 512
const ZOOM: float = 2.0

var _cells: Array[Dictionary] = []
var _summaries: Array[Dictionary] = []
var _valid: bool = true


func _ready() -> void:
	var path: String = ""
	for arg: String in LaunchArgs.unknown():
		if arg.begins_with("--out="):
			path = arg.substr(6)
	if path.is_empty() or DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		get_tree().quit(2)
		return
	for view: String in ["tilt70", "top"]:
		ViewMode.select(view)
		await _measure(view)
	var report: Dictionary = {
		"schema": "gtai.crowd-pop/1",
		"ppm": 64,
		"cell_px": CrowdAtlas.CELL_PX,
		"bake_zoom": CrowdAtlas.BAKE_ZOOM,
		"quad_world_px": CrowdAtlas.cell_world_px(),
		"bbox": "[width,height,last nontransparent y relative to actor]; alpha > 0",
		"look_summaries": _summaries,
		"cells": _cells
	}
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var ok: bool = file != null and file.store_string(JSON.stringify(report))
	get_tree().quit(
		0 if ok and _valid and _cells.size() == 2 * CrowdAtlas.LOOKS * CrowdAtlas.cols() else 1
	)


func _measure(view: String) -> void:
	var atlas: CrowdAtlas = CrowdAtlas.new()
	var baker: CrowdBaker = CrowdBaker.new()
	add_child(baker)
	await baker.bake(atlas)
	baker.queue_free()
	if not atlas.baked:
		_valid = false
		return
	var stage: Reference = Reference.new()
	add_child(stage)
	stage.prepare(atlas)
	var sheet: Image = atlas.texture.get_image()
	for clip: int in CrowdAtlas.CLIPS:
		var c: CrowdAtlas.Clip = clip as CrowdAtlas.Clip
		stage._start_clip(c)
		var at: float = 0.0
		for frame: int in CrowdAtlas.FRAMES[c]:
			var want: float = CrowdBaker._frame_time(c, frame)
			stage._advance(want - at)
			at = want
			var col: int = CrowdAtlas.CLIP_FIRST[c] + frame
			stage.show_cells(col)
			await RenderingServer.frame_post_draw
			var shot: Image = stage._vp.get_texture().get_image()
			for look: int in CrowdAtlas.LOOKS:
				_record(view, look, col, sheet, shot)
	for look: int in CrowdAtlas.LOOKS:
		_summarize(view, RigVariant.crowd(look).tag)
	stage.queue_free()
	await get_tree().process_frame


func _record(view: String, look: int, col: int, sheet: Image, shot: Image) -> void:
	var c: int = CrowdAtlas.CELL_PX
	var tile: Image = sheet.get_region(Rect2i(col * c, look * c, c, c))
	var raw: Rect2i = tile.get_used_rect()
	var edges: Array[String] = []
	if raw.position.x == 0:
		edges.append("left")
	if raw.position.y == 0:
		edges.append("top")
	if raw.end.x == c:
		edges.append("right")
	if raw.end.y == c:
		edges.append("bottom")
	var live: Array[int] = _bbox(shot, look, 0)
	var baked: Array[int] = _bbox(shot, look, 1)
	if raw.size == Vector2i.ZERO or live[1] == 0 or baked[1] == 0:
		_valid = false
	_cells.append(
		{
			"view": view,
			"look": RigVariant.crowd(look).tag,
			"col": col,
			"border": edges,
			"texel_xywh": [raw.position.x, raw.position.y, raw.size.x, raw.size.y],
			"baked": baked,
			"live": live,
			"height_ratio": baked[1] / maxf(1.0, live[1])
		}
	)


static func _bbox(shot: Image, look: int, row: int) -> Array[int]:
	var r: Rect2i = shot.get_region(Rect2i(look * SLOT, row * SLOT, SLOT, SLOT)).get_used_rect()
	return [r.size.x, r.size.y, r.end.y - 1 - SLOT / 2]


func _summarize(view: String, tag: String) -> void:
	var clipped: int = 0
	var lo: float = INF
	var hi: float = 0.0
	var dh: int = 0
	var dy: int = 0
	for row: Dictionary in _cells:
		if row.view != view or row.look != tag:
			continue
		var border: Array[String] = row.border
		var ratio: float = row.height_ratio
		var baked: Array[int] = row.baked
		var live: Array[int] = row.live
		clipped += int(not border.is_empty())
		lo = minf(lo, ratio)
		hi = maxf(hi, ratio)
		dh = maxi(dh, absi(baked[1] - live[1]))
		dy = maxi(dy, absi(baked[2] - live[2]))
	if LaunchArgs.unknown().has("--check") and (clipped > 0 or dh > 1 or dy > 1):
		_valid = false
	_summaries.append(
		{
			"view": view,
			"look": tag,
			"clipped": clipped,
			"height_ratio": [lo, hi],
			"max_height_error_px": dh,
			"max_feet_error_px": dy
		}
	)
	Log.info(
		"crowd-pop",
		(
			"%s %s: %d clipped, height %.3f..%.3f, height/feet error %d/%d px"
			% [view, tag, clipped, lo, hi, dh, dy]
		)
	)


class Reference:
	extends CrowdBaker
	var mesh_node: MultiMeshInstance2D = MultiMeshInstance2D.new()
	var screen_zoom: Vector2

	func prepare(atlas: CrowdAtlas) -> void:
		PartMaterials.set_view(ZOOM)
		_make_stage()
		screen_zoom = ViewMode.shared().zoom_of(ZOOM)
		_vp.size = Vector2i(CrowdAtlas.LOOKS * SLOT, 2 * SLOT)
		_vp.canvas_transform = Transform2D.IDENTITY.scaled(screen_zoom)
		var mm: MultiMesh = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_2D
		mm.use_custom_data = true
		mm.mesh = CrowdLayers._quad()
		mm.instance_count = CrowdAtlas.LOOKS
		mesh_node.multimesh = mm
		mesh_node.texture = atlas.texture
		mesh_node.material = atlas.crowd_material()
		_vp.add_child(mesh_node)

	func _centre(look: int) -> Vector2:
		return Vector2((look + 0.5) * SLOT, 0.5 * SLOT) / screen_zoom

	func show_cells(col: int) -> void:
		var mm: MultiMesh = mesh_node.multimesh
		for look: int in CrowdAtlas.LOOKS:
			var pos: Vector2 = _centre(look) + Vector2(0.0, SLOT / screen_zoom.y)
			var basis: Transform2D = Transform2D.IDENTITY.scaled(
				Vector2.ONE * CrowdAtlas.cell_world_px()
			)
			basis.origin = pos
			mm.set_instance_transform_2d(look, basis)
			mm.set_instance_custom_data(look, Color(look * CrowdAtlas.cols() + col, 0, 0, 0))
