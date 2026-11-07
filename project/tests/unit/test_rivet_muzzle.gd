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


func test_every_point_names_a_cut_strip() -> void:
	for path: String in RivetMuzzle._table():
		assert_true(ResourceLoader.exists(path), path)
