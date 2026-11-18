extends GutTest
## The docks quay edge as an autotile (n18 districts item 3; registry sprite-and-atlas-production
## autotile-rule-set-completeness): every water tile's land sides, read from the generated cells
## around it, name a case with art, its coping joins the walk it borders, and the turn carries the
## art's drawn land (north; north + west for the corner) onto those sides.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"
## two quay chunks (column 15 = the city's east edge), a pier street between them
const CHUNKS: Array[Vector2i] = [Vector2i(15, 6), Vector2i(15, 7)]

var _gen: CityGen = null
var _chunks: Dictionary = {}


func before_all() -> void:
	_gen = CityGen.from_tables(DISTRICT, TEXTURES)
	for c: Vector2i in [Vector2i(14, 6), Vector2i(14, 7)] + CHUNKS:
		_chunks[c] = _gen.gen_chunk(c.x, c.y)


func _cell(x: int, y: int) -> int:
	var n: int = SimConst.CHUNK_CELLS
	var c: Vector2i = Vector2i(floori(float(x) / n), floori(float(y) / n))
	if not _chunks.has(c):
		return SimConst.C_VOID
	var ch: CityChunk = _chunks[c]
	return ch.cells[posmod(y, n) * n + posmod(x, n)]


func _docks() -> CityZone:
	return _gen.zones.rows[_gen.zones.index_of(&"docks")]


## The tiles DockPainter paints as water in the two chunks.
func _water_tiles() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var wx: int = DockPainter.water_x(_docks())
	for c: Vector2i in CHUNKS:
		for j: int in SimConst.CHUNK_TILES:
			for i: int in SimConst.CHUNK_TILES:
				var t: Vector2i = c * SimConst.CHUNK_TILES + Vector2i(i, j)
				if t.x >= wx and posmod(t.y, CityGen.PERIOD) > 2:
					out.append(t)
	return out


## Land sides: the neighbours (north, south, west) that are not water tiles (east is the city edge
## or more water). Read from the painted tile set, not from DockPainter's rule.
func _land_sides(t: Vector2i) -> int:
	var water: Array[Vector2i] = _water_tiles()
	var sides: int = 0
	if not water.has(t + Vector2i.UP) and _gen.zones.of_tile(t + Vector2i.UP).id == &"docks":
		sides |= DockPainter.EDGE_N
	if not water.has(t + Vector2i.DOWN) and _gen.zones.of_tile(t + Vector2i.DOWN).id == &"docks":
		sides |= DockPainter.EDGE_S
	if not water.has(t + Vector2i.LEFT):
		sides |= DockPainter.EDGE_W
	return sides


func test_every_land_neighbour_case_has_quay_art() -> void:
	var seen: Dictionary = {}
	for t: Vector2i in _water_tiles():
		var case: Array[int] = DockPainter.quay_case(_docks(), t)
		var land: int = _land_sides(t)
		assert_eq(case[0], land, "tile %s land sides" % t)
		if land != 0:
			assert_gte(case[1], 0, "tile %s (sides %d) has no quay art" % [t, land])
		else:
			assert_eq(case[1], -1, "open water %s draws no quay edge" % t)
		seen[land] = true
	for want: int in [0, DockPainter.EDGE_N, DockPainter.EDGE_S, DockPainter.EDGE_W]:
		assert_true(seen.has(want), "case %d never occurs" % want)
	assert_true(seen.has(DockPainter.EDGE_N | DockPainter.EDGE_W), "inner corner NW")
	assert_true(seen.has(DockPainter.EDGE_S | DockPainter.EDGE_W), "inner corner SW")


func test_the_coping_joins_the_walk_it_borders() -> void:
	for t: Vector2i in _water_tiles():
		var o: Vector2i = t * 8
		var land: int = _land_sides(t)
		# probe each side clear of the other sides' 5 m strips
		var w_y: int = 6 if land & DockPainter.EDGE_N else (1 if land & DockPainter.EDGE_S else 4)
		var mid_n: int = _cell(o.x + 6, o.y)
		var mid_s: int = _cell(o.x + 6, o.y + 7)
		var mid_w: int = _cell(o.x, o.y + w_y)
		assert_eq(mid_n == SimConst.C_WALK, bool(land & DockPainter.EDGE_N), "%s north" % t)
		assert_eq(mid_s == SimConst.C_WALK, bool(land & DockPainter.EDGE_S), "%s south" % t)
		assert_eq(mid_w == SimConst.C_WALK, bool(land & DockPainter.EDGE_W), "%s west" % t)
		var wy: int = 4
		if land & DockPainter.EDGE_N:
			wy = 7
		elif land & DockPainter.EDGE_S:
			wy = 0
		assert_eq(_cell(o.x + 7, o.y + wy), SimConst.C_BUILD, "%s keeps water off its land" % t)


func test_each_turn_carries_the_drawn_land_onto_the_land_sides() -> void:
	for sides: int in DockPainter.QUAY_CASES:
		var case: Array = DockPainter.QUAY_CASES[sides]
		var art: int = case[0]
		var turn: float = case[1]
		var drawn: Array[Vector2] = [Vector2.UP]
		if art == 1:
			drawn.append(Vector2.LEFT)
		var got: int = 0
		for v: Vector2 in drawn:
			got |= _side_bit(v.rotated(deg_to_rad(turn)))
		assert_eq(got, sides, "case %d" % sides)


func _side_bit(v: Vector2) -> int:
	if v.y < -0.5:
		return DockPainter.EDGE_N
	if v.y > 0.5:
		return DockPainter.EDGE_S
	return DockPainter.EDGE_W if v.x < -0.5 else 0
