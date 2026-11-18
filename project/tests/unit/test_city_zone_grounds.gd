extends GutTest
## A zone's own ground (n18 districts item 3, the asset lane's it471 grounds): downtown's plaza
## tiles draw its plaza_ground (granite running bond) turned only 0 / 180 deg, the docks' quay
## apron draws its apron_ground, and the mixed zone's plazas keep the sidewalk paving 13.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"
const PAVING: int = 13

var _gen: CityGen = null


func before_all() -> void:
	_gen = CityGen.from_tables(DISTRICT, TEXTURES)


func _zone(id: StringName) -> CityZone:
	return _gen.zones.rows[_gen.zones.index_of(id)]


## [ground tex, rotation] at each tile centre of chunk (cx, cy) whose tile code is `code`.
func _grounds(cx: int, cy: int, code: int) -> Array[Vector2]:
	var c: CityChunk = _gen.gen_chunk(cx, cy)
	var out: Array[Vector2] = []
	for i: int in c.tex.size():
		var p: Vector2 = Vector2(c.xf[i * 4], c.xf[i * 4 + 1])
		if posmod(int(p.x), 8) != 4 or posmod(int(p.y), 8) != 4 or c.xf[i * 4 + 3] != 0.0:
			continue
		var t: Vector2i = Vector2i(int(p.x) / 8, int(p.y) / 8) - Vector2i(cx, cy) * 16
		if c.tiles[t.y * 16 + t.x] == code and _gen.sizes[c.tex[i]].x == 8.0:
			out.append(Vector2(c.tex[i], c.xf[i * 4 + 2]))
	return out


func test_the_rows_name_their_grounds() -> void:
	assert_gt(_zone(&"downtown").plaza_ground, PAVING)
	assert_gt(_zone(&"docks").apron_ground, PAVING)
	assert_eq(_zone(&"mixed").plaza_ground, -1)


func test_downtown_plazas_draw_the_zone_ground_in_half_turns() -> void:
	var want: int = _zone(&"downtown").plaza_ground
	var seen: int = 0
	for cy: int in range(6, 10):
		for cx: int in range(6, 10):
			for gr: Vector2 in _grounds(cx, cy, SimConst.T_PLAZA):
				seen += 1
				assert_eq(int(gr.x), want)
				var quarter: int = roundi(gr.y / (PI * 0.5))
				assert_eq(posmod(quarter, 2), 0, "a bond turned a quarter")
	assert_gt(seen, 20, "downtown has plaza tiles")


func test_mixed_plazas_keep_the_sidewalk_paving() -> void:
	var seen: int = 0
	for cy: int in range(0, 4):
		for cx: int in range(0, 4):
			for gr: Vector2 in _grounds(cx, cy, SimConst.T_PLAZA):
				seen += 1
				assert_eq(int(gr.x), PAVING)
	assert_gt(seen, 0, "the mixed corner has plaza tiles")


func test_the_quay_apron_draws_the_docks_apron_ground() -> void:
	var want: int = _zone(&"docks").apron_ground
	var aprons: int = 0
	for cy: int in range(0, 16):
		for gr: Vector2 in _grounds(15, cy, SimConst.T_PLAZA):
			aprons += 1 if int(gr.x) == want else 0
	assert_gt(aprons, 10, "the east edge's apron tiles draw the apron ground")
