extends GutTest
## perf L3: the strip cache hands out the very texture a plain load() did (no pixel can move),
## a prefetched strip included; the fall grid a row draws is found while the person stands.

## n11 it18: the suit falls through the drawn in-betweens (StreetFallBetween.swap).
const SUIT_FALL: String = "p70/ped_suit_between_fall.png"
const DIR: String = StreetWalkerCards.DIR


func test_path_of_names_the_rows_fall_grid() -> void:
	assert_eq(StreetWalkerFall.path_of("p70", "ped/head_hair"), SUIT_FALL)
	assert_eq(StreetWalkerFall.path_of("p55", "cop/head_cap"), "p55/cop_patrol_long_fall.png")


func test_path_of_falls_back_to_p70_for_a_p55_pedestrian() -> void:
	assert_eq(StreetWalkerFall.path_of("p55", "ped/head_hair"), SUIT_FALL)


func test_path_of_is_empty_for_a_row_with_no_grid() -> void:
	assert_eq(StreetWalkerFall.path_of("p70", "no/such_row"), "")


func test_get_tex_is_the_loaded_texture() -> void:
	var path: String = DIR + "p70/ped_suit_walk.png"
	var t: Texture2D = StreetStrips.get_tex(path)
	assert_not_null(t)
	assert_same(t, load(path) as Texture2D)
	assert_same(StreetStrips.get_tex(path), t)


func test_a_prefetched_strip_is_the_loaded_texture() -> void:
	var path: String = DIR + "p70/ped_hood_long_fall.png"
	StreetStrips.prefetch(path)
	var t: Texture2D = StreetStrips.get_tex(path)
	assert_not_null(t)
	assert_same(t, load(path) as Texture2D)
	assert_eq(t.get_width(), (load(path) as Texture2D).get_width())
