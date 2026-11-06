extends GutTest

const ART: String = "res://features/city/art/view/<art>/prop_payphone.png"


func _cards() -> PropCards:
	var names: Array[String] = ["road", "payphone", "barricade"]
	var props: Dictionary = {
		"payphone": {"art": ART, "cell_w_m": 1.2},
		"barricade": {"art": ART, "cell_w_m": 2.0, "turn": 1},
	}
	return PropCards.make(props, names, "p70", {"p70": "p55"})


func test_only_named_props_stand() -> void:
	var cards: PropCards = _cards()
	assert_eq(cards.size(), 2)
	assert_false(cards.has(0), "a texture not in the table stays flat")
	assert_true(cards.has(1))


func test_facing_from_the_turn() -> void:
	var cards: PropCards = _cards()
	assert_eq(cards.facing(1, 0.0), Vector2i(0, 0), "front toward the camera")
	assert_eq(cards.facing(1, PI * 0.25), Vector2i(1, 0), "three-quarter, as drawn")
	assert_eq(cards.facing(1, -PI * 0.25), Vector2i(1, 1), "three-quarter, mirrored")
	assert_eq(cards.facing(1, PI * 0.5), Vector2i(2, 0), "side")
	assert_eq(cards.facing(1, PI), Vector2i(4, 0), "back, never mirrored")
	assert_eq(cards.facing(2, 0.0), Vector2i(2, 0), "a row's turn adds a quarter")


func test_cards_move_to_the_roofs_band() -> void:
	var bands: PackedByteArray = _cards().bands(PackedByteArray([0, 3, 3]))
	assert_eq(bands, PackedByteArray([0, 4, 4]))


func test_missing_art_falls_back_to_the_named_key() -> void:
	var tex: Texture2D = PropCards.art_texture(ART, "p99", {"p99": "p55"})
	assert_not_null(tex, "p99 has no strip: the p55 one draws")
