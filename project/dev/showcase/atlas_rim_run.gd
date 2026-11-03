class_name AtlasRimRun
extends Node
## Bakes the crowd atlas through CharacterRigs and writes <out>/atlas-<tag>.png and
## atlas-rim-<tag>.json (per look: opaque area and edge length of the first WALK cell).

var out_dir: String = ""
var tag: String = "run"
var _rigs: CharacterRigs = CharacterRigs.new()
var _bus: EventBus = EventBus.new()
var _data: DataStore = DataStore.new()


func _ready() -> void:
	add_child(_bus)
	add_child(_data)
	add_child(_rigs)
	_rigs.setup(World.build_context(_bus, _data, 3))


func shoot() -> int:
	await _rigs.bake_crowd()
	var atlas: CrowdAtlas = _rigs.atlas
	if atlas.texture == null:
		printerr("atlas_rim: nothing baked")
		return 1
	var img: Image = atlas.texture.get_image()
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(out_dir)
	@warning_ignore("return_value_discarded")
	img.save_png(out_dir.path_join("atlas-%s.png" % tag))
	var rows: Array[Dictionary] = []
	var c: int = CrowdAtlas.CELL_PX
	var col: int = CrowdAtlas.CLIP_FIRST[CrowdAtlas.Clip.WALK]
	for look: int in CrowdAtlas.LOOKS:
		rows.append(_cell_stats(img.get_region(Rect2i(col * c, look * c, c, c)), look))
	var f: FileAccess = FileAccess.open(
		out_dir.path_join("atlas-rim-%s.json" % tag), FileAccess.WRITE
	)
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify({"tag": tag, "ppm": 48, "cell_px": c, "looks": rows}, "	"))
	return 0


static func _cell_stats(cell: Image, look: int) -> Dictionary:
	var w: int = cell.get_width()
	var area: int = 0
	var edge: int = 0
	for y: int in w:
		for x: int in w:
			if cell.get_pixel(x, y).a < 0.5:
				continue
			area += 1
			var open: bool = x == 0 or y == 0 or x == w - 1 or y == w - 1
			if not open:
				open = (
					cell.get_pixel(x - 1, y).a < 0.5
					or cell.get_pixel(x + 1, y).a < 0.5
					or cell.get_pixel(x, y - 1).a < 0.5
					or cell.get_pixel(x, y + 1).a < 0.5
				)
			edge += 1 if open else 0
	return {"look": look, "area_px": area, "edge_px": edge}
