extends GutTest
## d9 rivet: the strip pick (base, equipped, drawn left) and the hand rule's fallback.

const P70: String = "res://features/characters/art/view/p70/"
const P55: String = "res://features/characters/art/view/p55/"


func test_top_has_no_strip() -> void:
	assert_eq(RivetStrips.strip_of("", &"pistol"), "")


func test_a_weapon_out_takes_its_equipped_strip() -> void:
	assert_eq(RivetStrips.strip_of("p70", &"pistol"), P70 + "rivet_eq_pistol.png")
	assert_eq(RivetStrips.strip_of("p55", &"katana"), P55 + "rivet_eq_katana.png")
	assert_eq(RivetStrips.strip_of("p70", &""), P70 + RivetStrips.BASE)


func test_every_one_handed_hold_has_a_drawn_left_strip_at_70() -> void:
	for w: StringName in RivetStrips.ONE_HAND:
		var path: String = RivetStrips.left_of("p70", w)
		assert_eq(path, P70 + "rivet_eq_%s_left.png" % w)
		var tex: Texture2D = load(path) as Texture2D
		assert_eq(tex.get_width() % RivetFrames.LEFT_CELLS, 0, String(w))


func test_without_a_left_strip_the_base_figure_draws() -> void:
	assert_eq(RivetStrips.left_of("p55", &"pistol"), P55 + RivetStrips.BASE)
