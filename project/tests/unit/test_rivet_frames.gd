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


func test_every_one_handed_hold_has_a_drawn_left_strip_at_both_pitches() -> void:
	for art: String in ["p70", "p55"]:
		for w: StringName in RivetStrips.ONE_HAND:
			var path: String = RivetStrips.left_of(art, w)
			assert_eq(path, RivetStrips.DIR + art + "/rivet_eq_%s_left.png" % w)
			var tex: Texture2D = load(path) as Texture2D
			assert_eq(tex.get_width() % RivetFrames.LEFT_CELLS, 0, String(w))


func test_without_a_left_strip_the_base_figure_draws() -> void:
	assert_eq(RivetStrips.left_of("p55", &"katana"), P55 + RivetStrips.BASE)


func test_the_flamer_fires_its_drawn_flame_only_along_side_and_camera() -> void:
	for o: int in 8:
		assert_eq(RivetFrames.fires_drawn(&"flamethrower", o), o in [0, 2, 4], "octant %d" % o)
		assert_true(RivetFrames.fires_drawn(&"pistol", o), "pistol octant %d" % o)


func test_the_flamer_facings_carry_the_nozzle_at_both_pitches() -> void:
	for art: String in ["p70", "p55"]:
		var path: String = RivetStrips.DIR + art + "/rivet_eq_flamethrower.png"
		for cell: int in 5:
			assert_gt(RivetMuzzle.point(path, cell).x, 0.0, "%s cell %d" % [art, cell])
