extends GutTest
## Check the baked district in world coordinates. Draw footprints can reach into the next
## chunk. The cell map alone misses overhangs and a prop stamp overwritten by a later tile.

var _chunks: Dictionary[Vector2i, CityChunk] = {}
var _crossings: Dictionary[Vector2i, Array] = {}
var _hits: Array[String] = []


func test_every_generated_crossing_is_clear() -> void:
	var gen := CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)
	var count: int = 0
	for cy: int in SimConst.CITY_CHUNKS:
		for cx: int in SimConst.CITY_CHUNKS:
			var ch: CityChunk = gen.gen_chunk(cx, cy)
			_chunks[ch.key()] = ch
			for i: int in ch.command_count():
				if ch.tex[i] == TilePainter.T_ZEBRA:
					var zebra := Footprint.new(gen, ch, i)
					for key: Vector2i in _chunk_keys(zebra.bounds):
						if not _crossings.has(key):
							_crossings[key] = []
						_crossings[key].append(zebra)
					count += 1
	for key: Vector2i in _chunks:
		for zebra: Footprint in _crossings.get(key, []):
			_check_cells(key, zebra)
		_check_solids(gen, _chunks[key])
	assert_gt(count, 0, "the district contains zebra decals")
	assert_true(_hits.is_empty(), "\n".join(_hits))


func _chunk_keys(rect: Rect2) -> Array[Vector2i]:
	var first := Vector2i((rect.position / SimConst.CHUNK_M).floor())
	var end := Vector2i((rect.end / SimConst.CHUNK_M).ceil())
	var keys: Array[Vector2i] = []
	for y: int in range(first.y, end.y):
		for x: int in range(first.x, end.x):
			keys.append(Vector2i(x, y))
	return keys


func _check_cells(key: Vector2i, zebra: Footprint) -> void:
	var n: int = SimConst.CHUNK_CELLS
	var origin: Vector2i = key * n
	var rect := zebra.bounds.intersection(Rect2(Vector2(origin), Vector2(n, n)))
	var cells: PackedByteArray = _chunks[key].cells
	for y: int in range(floori(rect.position.y), ceili(rect.end.y)):
		for x: int in range(floori(rect.position.x), ceili(rect.end.x)):
			var code: int = cells[(y - origin.y) * n + x - origin.x]
			if code != SimConst.C_VOID and code < SimConst.C_BUILD:
				continue
			var cell := Rect2(x, y, 1, 1)
			if zebra.angled and not zebra.overlaps_polygon(Footprint.corners(cell)):
				continue
			_hits.append("chunk %s zebra %s cell (%d,%d) code %d" % [key, zebra.centre, x, y, code])


func _check_solids(gen: CityGen, ch: CityChunk) -> void:
	for i: int in ch.command_count():
		if not gen.solid[ch.tex[i]] or ch.xf[i * CityChunk.XF_STRIDE + 3] != 0.0:
			continue
		var prop := Footprint.new(gen, ch, i)
		for key: Vector2i in _chunk_keys(prop.bounds):
			for zebra: Footprint in _crossings.get(key, []):
				var overlap: Rect2 = zebra.bounds.intersection(prop.bounds)
				if not overlap.has_area():
					continue
				if Vector2i((overlap.position / SimConst.CHUNK_M).floor()) != key:
					continue  # Report a pair crossing a chunk seam once.
				if (prop.angled or zebra.angled) and not zebra.overlaps_polygon(prop.polygon()):
					continue
				_hits.append(
					(
						"chunk %s zebra %s solid texture %d at %s"
						% [ch.key(), zebra.centre, ch.tex[i], prop.centre]
					)
				)


class Footprint:
	var centre: Vector2
	var bounds: Rect2
	var angled: bool
	var _size: Vector2
	var _xf: Transform2D

	func _init(gen: CityGen, ch: CityChunk, i: int) -> void:
		var k: int = i * CityChunk.XF_STRIDE
		centre = Vector2(ch.xf[k], ch.xf[k + 1])
		_size = gen.sizes[ch.tex[i]]
		var rot: float = ch.xf[k + 2]
		var turns: int = roundi(rot / (PI * 0.5))
		angled = not is_equal_approx(rot, turns * PI * 0.5)
		if angled:
			_xf = Transform2D(rot, centre)
			bounds = _xf * Rect2(-_size * 0.5, _size)
		else:
			var extent: Vector2 = _size if turns % 2 == 0 else Vector2(_size.y, _size.x)
			bounds = Rect2(centre - extent * 0.5, extent)

	static func corners(rect: Rect2) -> PackedVector2Array:
		var a: Vector2 = rect.position
		var b: Vector2 = rect.end
		return PackedVector2Array([a, Vector2(b.x, a.y), b, Vector2(a.x, b.y)])

	func polygon() -> PackedVector2Array:
		return _xf * corners(Rect2(-_size * 0.5, _size)) if angled else corners(bounds)

	func overlaps_polygon(other: PackedVector2Array) -> bool:
		return not Geometry2D.intersect_polygons(polygon(), other).is_empty()
