class_name CityZone
extends RefCounted
## One zone row of the district table (city_district.json `zones`, gtai.city-district/2): the
## layout rules the generator paints a chunk of this zone with. The defaults ARE the n14 city
## (generator v14), so a row that names nothing paints today's look.

const FLOATS: Array[String] = [
	"plaza_share",
	"big_share",
	"landmark_share",
	"long_share",
	"empty_share",
	"plaza_prop_share",
	"ped_corner",
	"ped_kerb",
	"ped_plaza",
	"density_min",
	"density_span",
]

var id: StringName = &"mixed"
## Block-level shares (a seeded draw per block or tile, under the share = yes).
var plaza_share: float = 0.12
var big_share: float = 0.35
var landmark_share: float = 0.3
var long_share: float = 0.3
var empty_share: float = 0.45
## Roof sets (city_textures ids). landmark_roofs: the named district roofs; generic_roofs: the
## square plain roofs; big_roofs: the 2 x 2 plates; long_roofs: the two-tile roofs.
var landmark_roofs: Array[int] = [14, 15, 16, 17, 18, 19, 20, 21]
var generic_roofs: Array[int] = [65, 66, 67, 68, 69, 70, 71]
var big_roofs: Array[int] = [78, 79, 80]
var long_roofs: Array[int] = [22, 23, 81]
## Plaza dressing: one prop per slot under plaza_prop_share, picked from plaza_props.
var plaza_props: Array[int] = [28, 33, 26, 28, 32, 29, 33]
var plaza_prop_share: float = 0.6
## Spawn densities (0-255 per tile) before the 4 x 4-chunk district factor
## density_min + density_span * noise.
var ped_corner: float = 90.0
var ped_kerb: float = 140.0
var ped_plaza: float = 255.0
var car_lane: int = 200
var density_min: float = 0.45
var density_span: float = 0.55
## Keep every n-th north-south street line (1 = all). 2 merges each pair of blocks across the
## dropped line into one long block (the docks' warehouse rows).
var street_keep_x: int = 1
## Tiles of quay apron + water at the city's east edge (0 = none; the docks).
var water_tiles: int = 0


static func from_row(row: Dictionary) -> CityZone:
	var z: CityZone = CityZone.new()
	z.id = StringName(str(row.get("id", "mixed")))
	for key: String in FLOATS:
		if row.has(key):
			var f: float = row[key]
			z.set(key, f)
	for key: String in ["car_lane", "street_keep_x", "water_tiles"]:
		if row.has(key):
			var f: float = row[key]
			z.set(key, int(f))
	for key: String in [
		"landmark_roofs", "generic_roofs", "big_roofs", "long_roofs", "plaza_props"
	]:
		if row.has(key):
			var values: Array = row[key]
			z.set(key, ints(values))
	return z


static func ints(values: Array) -> Array[int]:
	var out: Array[int] = []
	for v: float in values:
		out.append(int(v))
	return out
