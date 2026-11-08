extends GutTest
## d9 rivet: the drawn figure's measured muzzle (RivetMuzzle, data/tables/rivet_muzzle.json).

const P70: String = "res://features/characters/art/view/p70/"


func test_a_fire_cell_has_its_drawn_flash_root_inside_the_cell() -> void:
	var path: String = P70 + "rivet_eq_pistol.png"
	var tex: Texture2D = load(path) as Texture2D
	var w: float = tex.get_width() / float(RivetFrames.EQ_CELLS)
	var p: Vector2 = RivetMuzzle.point(path, RivetFrames.Eq.FIRE_SIDE)
	assert_gt(p.x, w * 0.5, "the side flash is right of the body")
	assert_lt(p.x, w)
	assert_between(p.y, 0.0, float(tex.get_height()))


func test_a_left_strip_points_left_and_a_facing_has_no_point() -> void:
	var left: String = P70 + "rivet_eq_pistol_left.png"
	var tex: Texture2D = load(left) as Texture2D
	var w: float = tex.get_width() / float(RivetFrames.LEFT_CELLS)
	assert_lt(RivetMuzzle.point(left, 1).x, w * 0.25)
	assert_eq(RivetMuzzle.point(P70 + "rivet_eq_pistol.png", 0), Vector2(-1.0, -1.0))
	assert_eq(RivetMuzzle.point(P70 + RivetStrips.BASE, 0), Vector2(-1.0, -1.0))


func test_a_shot_off_the_fire_cell_leaves_the_drawn_gun() -> void:
	# n10: fired up the screen he keeps the facing cell, which had no point: flash on his helmet
	for art: String in ["p70", "p55"]:
		var path: String = RivetStrips.DIR + art + "/rivet_eq_pistol.png"
		var tex: Texture2D = load(path) as Texture2D
		var w: float = tex.get_width() / float(RivetFrames.EQ_CELLS)
		for cell: int in [3, 4]:  # octant 7 and 5 (mirrored), octant 6
			var p: Vector2 = RivetMuzzle.point(path, cell)
			assert_gt(p.x, w * 0.6, "%s cell %d: the barrel right of the body" % [art, cell])
			assert_between(p.y, tex.get_height() * 0.3, tex.get_height() * 0.8, "the arm's height")


func test_a_gun_the_drawn_back_hides_has_no_point() -> void:
	assert_eq(RivetMuzzle.point(P70 + "rivet_eq_gatling.png", 4), Vector2(-1.0, -1.0))
	assert_gt(RivetMuzzle.point(P70 + "rivet_eq_gatling.png", 3).x, 0.0, "its 3/4 view shows it")


func test_the_barrels_spin_up_on_the_drawn_gun() -> void:
	# n10: the whirl rings the muzzle before the first round; the facing had no point (the ring sat
	# on the ground beside the gun for the whole windup).
	for art: String in ["p70", "p55"]:
		var path: String = RivetStrips.DIR + art + "/rivet_eq_gatling.png"
		var tex: Texture2D = load(path) as Texture2D
		var w: float = tex.get_width() / float(RivetFrames.EQ_CELLS)
		var p: Vector2 = RivetMuzzle.point(path, 2)
		assert_gt(p.x, w * 0.6, "%s side facing: the barrel right of the body" % art)
		assert_between(p.y, tex.get_height() * 0.3, tex.get_height() * 0.85, "at the arm's height")


func test_every_point_names_a_cut_strip() -> void:
	for path: String in RivetMuzzle._table():
		assert_true(ResourceLoader.exists(path), path)
