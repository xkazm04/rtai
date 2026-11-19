class_name VaultCity
extends RefCounted
## Resolve each solid cell against its own generator's non-shadow draw commands. KerbDresser
## stamps inside the rotated art footprint for both furniture and parked cars. A cell covered
## by multiple solid sprites has no unique owner. Depth comes from the occupied cells.


class Prop:
	extends RefCounted
	var kind: String
	var bounds: Rect2


class Chunk:
	extends RefCounted
	var owners: Dictionary[Vector2i, Prop] = {}


var cells: StageCells
var _names: PackedStringArray = []
var _chunks: Dictionary[Vector2i, Chunk] = {}


func _init(source: StageCells) -> void:
	cells = source
	var table: Dictionary = CityGen.read_json(CitySystem.TEXTURES)
	for row: Dictionary in table["textures"]:
		@warning_ignore("return_value_discarded")
		_names.append(str(row["name"]))


## Each unknown cell remains its own solid box. A building or void always has unknown height.
func collect(
	bounds: Rect2, out: Dictionary[Rect2, String], owners: Dictionary[Rect2, Prop] = {}
) -> void:
	for y: int in range(floori(bounds.position.y), ceili(bounds.end.y)):
		for x: int in range(floori(bounds.position.x), ceili(bounds.end.x)):
			if not cells.solid(x, y):
				continue
			var cell: Vector2i = Vector2i(x, y)
			var box: Rect2 = Rect2(Vector2(cell), Vector2.ONE)
			var kind: String = ""
			if cells.code_at(x, y) == SimConst.C_PROP:
				var prop: Prop = owner(cell)
				if prop != null:
					box = prop.bounds
					kind = prop.kind if not out.has(box) or owners.get(box) == prop else ""
					owners[box] = prop
			out[box] = kind if out.get(box, kind) == kind else ""


func owner(cell: Vector2i) -> Prop:
	var key: Vector2i = cell / SimConst.CHUNK_CELLS
	if not _chunks.has(key):
		_chunks[key] = _index(cells._gen.gen_chunk(key.x, key.y))
	return _chunks[key].owners.get(cell)


func _index(chunk: CityChunk) -> Chunk:
	var index: Chunk = Chunk.new()
	var n: int = SimConst.CHUNK_CELLS
	var bounds: Rect2i = Rect2i(Vector2i(chunk.cx, chunk.cy) * n, Vector2i.ONE * n)
	for i: int in chunk.command_count():
		var t: int = chunk.tex[i]
		var o: int = i * CityChunk.XF_STRIDE
		if chunk.xf[o + 3] != 0.0 or not cells._gen.solid[t]:
			continue
		var center: Vector2 = Vector2(chunk.xf[o], chunk.xf[o + 1])
		var size_m: Vector2 = cells._gen.sizes[t]
		var extent: Vector2 = KerbDresser.quarter_turn(size_m, chunk.xf[o + 2]).abs()
		var area: Rect2 = Rect2(center - extent * 0.5, extent)
		var cover: Rect2i = Rect2i(area.position.floor(), area.end.ceil() - area.position.floor())
		var prop: Prop = Prop.new()
		prop.kind = _names[t] if t < _names.size() else ""
		_map_prop(index, prop, cover.intersection(bounds))
	for cell: Vector2i in index.owners:
		var prop: Prop = index.owners[cell]
		if prop != null:
			var square: Rect2 = Rect2(Vector2(cell), Vector2.ONE)
			prop.bounds = prop.bounds.merge(square) if prop.bounds.has_area() else square
	return index


func _map_prop(index: Chunk, prop: Prop, area: Rect2i) -> void:
	for y: int in range(area.position.y, area.end.y):
		for x: int in range(area.position.x, area.end.x):
			if cells.code_at(x, y) == SimConst.C_PROP:
				var cell: Vector2i = Vector2i(x, y)
				index.owners[cell] = null if index.owners.has(cell) else prop
