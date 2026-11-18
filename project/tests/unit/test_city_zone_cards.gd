extends GutTest
## Every standing prop a zone row names (n18 districts item 3) has a card row in city_facades.json
## `props` with art on disk, so it stands up under the 70 camera. A prop without one draws only
## its plan art, flat, and nothing else fails. The basin boat is the exception: it lies flat in
## the water by design (DockDresser.quay_edge).

const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"
const LISTS: Array[String] = [
	"plaza_props", "plaza_singles", "apron_props", "kerb_props", "wall_props"
]
const SINGLES: Array[String] = ["plaza_centre", "quay_edge_prop"]

var _names: Dictionary[int, String] = {}
var _cards: Dictionary = {}
var _zones: Array = []


func before_all() -> void:
	for row: Dictionary in CityGen.read_json(TEXTURES).get("textures", []):
		var id: int = row["id"]
		_names[id] = str(row["name"])
	_cards = CityGen.read_json(PropCards.TABLE).get("props", {})
	_zones = CityGen.read_json(DISTRICT).get("zones", [])


## {texture id: "zone.key"} for every standing prop the zone rows name.
func _named() -> Dictionary[int, String]:
	var out: Dictionary[int, String] = {}
	for zone: Dictionary in _zones:
		for key: String in LISTS:
			for v: float in zone.get(key, []):
				var id: int = int(v)
				out[id] = "%s.%s" % [zone["id"], key]
		for key: String in SINGLES:
			var got: float = zone.get(key, -1.0)
			var one: int = int(got)
			if one >= 0:
				out[one] = "%s.%s" % [zone["id"], key]
	return out


func test_the_zone_rows_name_standing_props() -> void:
	assert_gt(_named().size(), 20, "the zones name their dressing")


func test_every_named_prop_has_a_card_row_with_art() -> void:
	var named: Dictionary[int, String] = _named()
	for id: int in named:
		var tex_name: String = _names.get(id, "")
		assert_ne(tex_name, "", "%s names texture %d, which exists" % [named[id], id])
		var row: Dictionary = _cards.get(tex_name, {})
		assert_false(
			row.is_empty(), "%s: %s has a card row in city_facades props" % [named[id], tex_name]
		)
		if row.is_empty():
			continue
		var art: String = str(row["art"]).replace("<art>", "p70")
		assert_true(ResourceLoader.exists(art), "%s card art %s" % [tex_name, art])
