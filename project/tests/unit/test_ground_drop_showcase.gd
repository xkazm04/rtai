extends GutTest
## n17 npc-react: a dead guard's dropped gun draws its pickup's showcase drawing, one direction.


func test_the_muzzle_points_the_way_the_round_flew_on_screen() -> void:
	assert_eq(GroundDropShowcase.sign_x(Vector2(1.0, 0.3)), 1.0, "shot right: muzzle right")
	assert_eq(GroundDropShowcase.sign_x(Vector2(-1.0, 0.3)), -1.0, "shot left: mirrored")
	assert_eq(GroundDropShowcase.sign_x(Vector2(0.01, 1.0)), 1.0, "straight down the screen: +x")
	assert_eq(GroundDropShowcase.sign_x(Vector2(-0.01, -1.0)), 1.0, "no flicker near vertical")


func test_the_drop_is_the_pickups_own_drawing_by_the_views_art() -> void:
	var was: ViewMode = ViewMode.shared()
	ViewMode.select("combo")
	var tex: Texture2D = GroundDropShowcase.texture()
	var form: String = WeaponShowcase.form_of(ViewMode.shared())
	var art: StringName = ArsenalTable.shipped().art_id(GroundDropShowcase.PICKUP)
	assert_eq(art, &"machine_pistol", "the assault rifle's art stand-in, the gun Rivet then holds")
	assert_not_null(tex, "a showcase drawing under a tilt")
	if tex != null:
		assert_eq(tex.resource_path, WeaponShowcase.path_of(art, form))
	ViewMode.select("top")
	assert_null(GroundDropShowcase.texture(), "straight down: GroundRifle's sheet (the before)")
	ViewMode._shared = was


func test_a_drop_without_a_drawing_is_left_to_the_sheet() -> void:
	var was: ViewMode = ViewMode.shared()
	ViewMode.select("top")
	var ci: Node2D = autofree(Node2D.new())
	assert_false(GroundDropShowcase.draw(ci, Vector2.ZERO, Vector2.RIGHT, 1.0))
	ViewMode._shared = was


func test_it_lies_beside_the_shot_line_on_the_cameras_side() -> void:
	var at: Vector2 = Vector2(10.0, 10.0)
	var lies: Vector2 = GroundDropShowcase.lies_at(at, Vector2.RIGHT)
	assert_almost_eq(
		lies, at + Vector2(0.0, GroundDropShowcase.SIDE_M), Vector2.ONE * 1e-4, "shot east"
	)
	lies = GroundDropShowcase.lies_at(at, Vector2.LEFT)
	assert_almost_eq(
		lies, at + Vector2(0.0, GroundDropShowcase.SIDE_M), Vector2.ONE * 1e-4, "shot west"
	)
	lies = GroundDropShowcase.lies_at(at, Vector2.DOWN)
	assert_almost_eq(
		lies, at + Vector2(GroundDropShowcase.SIDE_M, 0.0), Vector2.ONE * 1e-4, "shot south"
	)
