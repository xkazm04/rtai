extends GutTest
## Plaza singles (n18 districts item 3: the it471 coffee kiosk and food cart): a downtown plaza
## block stands each of its zone's plaza_singles at most once, on a tile off the middle, and never
## as a slot prop (a kiosk drawn as a slot prop stood five times in one plaza). A prop draws
## its shadow first (xf flag 1), then itself (flag 0): only the prop is counted.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"

var _gen: CityGen = null
var _down: CityZone = null


func before_all() -> void:
	_gen = CityGen.from_tables(DISTRICT, TEXTURES)
	_down = _gen.zones.rows[_gen.zones.index_of(&"downtown")]


## Per plaza block (key: block coords), how many of each single it draws, over downtown.
func _counts() -> Dictionary[Vector2i, Dictionary]:
	var out: Dictionary[Vector2i, Dictionary] = {}
	for cy: int in range(6, 10):
		for cx: int in range(6, 10):
			var c: CityChunk = _gen.gen_chunk(cx, cy)
			for i: int in c.tex.size():
				if not _down.plaza_singles.has(c.tex[i]) or c.xf[i * 4 + 3] != 0.0:
					continue
				var bk: Vector2i = Vector2i(
					floori(c.xf[i * 4] / 64.0), floori(c.xf[i * 4 + 1] / 64.0)
				)
				if not out.has(bk):
					out[bk] = {}
				var n: int = out[bk].get(c.tex[i], 0)
				out[bk][c.tex[i]] = n + 1
	return out


func test_the_downtown_row_names_singles_not_slot_props() -> void:
	assert_gt(_down.plaza_singles.size(), 0)
	for tex: int in _down.plaza_singles:
		assert_false(_down.plaza_props.has(tex), "single %d is not a slot prop" % tex)


func test_each_single_stands_at_most_once_a_plaza_block() -> void:
	var counts: Dictionary[Vector2i, Dictionary] = _counts()
	assert_gt(counts.size(), 3, "downtown plazas draw their singles")
	for bk: Vector2i in counts:
		for tex: Variant in counts[bk]:
			var n: int = counts[bk][tex]
			assert_eq(n, 1, "block %s single %s" % [bk, tex])


func test_a_single_never_takes_the_middle_tile() -> void:
	for y: int in range(3, 8):
		for x: int in range(3, 8):
			var t: Vector2i = Vector2i(16 * 8 + x, 16 * 8 + y)
			if x == 5 and y == 5:
				assert_eq(TilePainter.plaza_single(_gen, _down, t), -1)
