extends GutTest
## n30: the explosion light's outer band is amber (fire, heat), through the palette token `amber`;
## vermilion stays danger only. No other light kind moved.

const AMBER: Color = Color8(0xED, 0xAB, 0x42)


func _kinds() -> Dictionary:
	var parser: JSON = JSON.new()
	assert_eq(parser.parse(FileAccess.get_file_as_string("res://data/tables/lights.json")), OK)
	var out: Dictionary = {}
	var d: Dictionary = parser.data
	for row: Dictionary in d["kinds"]:
		var kid: String = row["id"]
		out[kid] = row
	return out


func test_the_explosion_rim_names_the_amber_token() -> void:
	var row: Dictionary = _kinds()["explosion"]
	var token: String = row["token"]
	var alt_token: String = row["alt_token"]
	assert_eq(token, "paper", "the core stays paper")
	assert_eq(alt_token, "amber")
	var rim: bool = row.get("rim", false)
	assert_true(rim, "the rim flag is on")
	var lights: LightLayer = autofree(LightLayer.new())
	var kind: Dictionary = lights.kinds[&"explosion"]
	var alt: Color = kind["alt_color"]
	assert_true(alt.is_equal_approx(AMBER), "alt_color %s" % alt)


func test_amber_is_not_vermilion_to_the_classifier() -> void:
	var pal: PaletteTokens = PaletteTokens.shared()
	assert_true(pal.color(&"amber").is_equal_approx(AMBER))
	assert_eq(pal.classify(pal.color(&"amber")), 0, "under verm_gate: no accent row needed")


func test_no_other_light_kind_changed() -> void:
	var kinds: Dictionary = _kinds()
	var want: Dictionary = {
		"muzzle_flash": ["paper", ""],
		"headlight": ["paper", ""],
		"siren": ["cop_blue_hi", "paper"],
		"fire": ["amber", "paper"],
		"street_lamp": ["paper", ""],
	}
	for kid: String in want:
		var row: Dictionary = kinds[kid]
		var pair: Array = want[kid]
		var want_token: String = pair[0]
		var want_alt: String = pair[1]
		var token: String = row["token"]
		var alt: String = row.get("alt_token", "")
		assert_eq(token, want_token, kid + " token")
		assert_eq(alt, want_alt, kid + " alt_token")
	var explosion: Dictionary = kinds["explosion"]
	var steps: int = explosion["steps"]
	var radius: float = explosion["radius_m"]
	var life: int = explosion["life_ticks"]
	assert_eq(steps, 3)
	assert_eq(radius, 6.0)
	assert_eq(life, 36)
