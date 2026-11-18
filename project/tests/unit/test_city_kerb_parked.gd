extends GutTest
## KerbDresser's n14 kerb rules, pinned by numbers rather than only the golden hash list (n18
## districts: mutate scored kerb_dresser.gd 0/10 with the unit tests, the golden list alone
## caught its faults): over the mixed zone's chunks, a street lamp stands on every other kerb
## tile, a parked car on about 0.4 of them, and every lamp and parked car casts one shadow copy.

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"
## Mixed-zone chunks (the docks band starts at chunk x 13, downtown spans 6-10).
const CHUNKS: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(2, 3)]

var _stands: Dictionary = {}  # tex -> stand count
var _shadows: Dictionary = {}  # tex -> shadow copy count


func before_all() -> void:
	var gen: CityGen = CityGen.from_tables(DISTRICT, TEXTURES)
	for k: Vector2i in CHUNKS:
		assert_eq(gen.zones.id_of_chunk(k.x, k.y), &"mixed")
		var ch: CityChunk = gen.gen_chunk(k.x, k.y)
		for i: int in ch.tex.size():
			var t: int = ch.tex[i]
			var into: Dictionary = _shadows if ch.xf[i * CityChunk.XF_STRIDE + 3] > 0.0 else _stands
			var had: int = into.get(t, 0)
			into[t] = had + 1


func test_lamps_and_parked_cars_stand_in_numbers() -> void:
	var lamps: int = _stands.get(KerbDresser.T_LAMP, 0)
	var cars: int = _count(_stands, KerbDresser.PARKED)
	assert_gt(lamps, 20, "lamps on every other kerb tile")
	# kerb tiles ~ 2 * lamps; a parked car on 0.4 of them -> cars / lamps ~ 0.8
	var ratio: float = cars / float(lamps)
	assert_between(ratio, 0.6, 1.0, "%d parked cars for %d lamps" % [cars, lamps])


func test_every_lamp_and_parked_car_casts_one_shadow_copy() -> void:
	var cars: int = _count(_stands, KerbDresser.PARKED)
	assert_gt(cars, 0)
	assert_eq(_count(_shadows, KerbDresser.PARKED), cars, "parked cars")
	var lamps: int = _stands.get(KerbDresser.T_LAMP, 0)
	var lamp_shadows: int = _shadows.get(KerbDresser.T_LAMP, 0)
	assert_eq(lamp_shadows, lamps, "lamps")


func _count(counts: Dictionary, texs: Array[int]) -> int:
	var n: int = 0
	var seen: Dictionary = {}
	for t: int in texs:
		if not seen.has(t):
			seen[t] = true
			var c: int = counts.get(t, 0)
			n += c
	return n
