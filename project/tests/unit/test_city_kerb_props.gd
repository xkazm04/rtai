extends GutTest
## A zone's own sidewalk furniture (n18 districts item 3, the asset lane's it472 downtown street
## cards + REQUEST 12 plan twins): downtown's kerb tiles pick from its row's kerb_props (street
## clocks, bollards, litter bins with the civic n14 pieces) and its walls from wall_props (no
## dumpsters, vending or crates), the mixed zone keeps KerbDresser.KERB_PROPS / WALL_PROPS and
## never stands a downtown piece.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"
## n14 kerb and wall pieces downtown's mixes leave out (payphone, bus stop, vending, dumpster,
## single bollard, crates): none may stand downtown.
const LEFT_OUT: Array[int] = [30, 31, 32, 34, 37, 39]

var _gen: CityGen = null


func before_all() -> void:
	_gen = CityGen.from_tables(DISTRICT, TEXTURES)


func _zone(id: StringName) -> CityZone:
	return _gen.zones.rows[_gen.zones.index_of(id)]


## Count of standing props by texture id over the chunks [x0, x1) x [y0, y1).
func _counts(x0: int, x1: int, y0: int, y1: int) -> Dictionary:
	var out: Dictionary = {}
	for cy: int in range(y0, y1):
		for cx: int in range(x0, x1):
			var ch: CityChunk = _gen.gen_chunk(cx, cy)
			for i: int in ch.tex.size():
				if ch.xf[i * CityChunk.XF_STRIDE + 3] == 0.0:
					out[ch.tex[i]] = _n(out, ch.tex[i]) + 1
	return out


func test_downtown_names_its_own_kerb_mix() -> void:
	var mix: Array[int] = _zone(&"downtown").kerb_props
	assert_gt(mix.size(), 0)
	assert_eq(_zone(&"mixed").kerb_props.size(), 0, "mixed keeps the n14 mix")
	for tex: int in LEFT_OUT:
		assert_false(mix.has(tex), "downtown leaves %d out" % tex)
		assert_false(_zone(&"downtown").wall_props.has(tex), "downtown walls leave %d out" % tex)


func test_downtown_kerbs_stand_its_pieces_and_none_left_out() -> void:
	var seen: Dictionary = _counts(6, 10, 6, 10)
	var own: int = 0
	for tex: int in _zone(&"downtown").kerb_props:
		if not KerbDresser.KERB_PROPS.has(tex):
			own += _n(seen, tex)
	assert_gt(own, 20, "downtown stands clocks, bollards and bins")
	for tex: int in LEFT_OUT:
		assert_eq(_n(seen, tex), 0, "downtown stands no %d" % tex)


func test_mixed_kerbs_never_stand_a_downtown_piece() -> void:
	var seen: Dictionary = _counts(0, 4, 0, 4)
	var n14: int = 0
	for tex: int in KerbDresser.KERB_PROPS:
		n14 += _n(seen, tex)
	assert_gt(n14, 20, "the mixed corner stands the n14 mix")
	for tex: int in _zone(&"downtown").kerb_props:
		if not KerbDresser.KERB_PROPS.has(tex):
			assert_eq(_n(seen, tex), 0, "mixed stands no %d" % tex)


func _n(counts: Dictionary, tex: int) -> int:
	var n: int = counts.get(tex, 0)
	return n
