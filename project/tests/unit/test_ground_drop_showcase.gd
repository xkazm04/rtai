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
	assert_eq(
		WeaponArtKey.of(art), &"assault_rifle", "the pickup and held rifle share their own art"
	)
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


func test_it_lies_past_his_feet_away_from_his_body() -> void:
	StreetDeadRests.reset()
	var at: Vector2 = Vector2(10.0, 10.0)
	var k: float = Ink.PX_PER_M
	StreetDeadRests.all[7] = Vector4(10.0 * k, 10.0 * k, 10.0 * k, 9.0 * k)  # chest up the screen
	var lies: Vector2 = GroundDropShowcase.place(at, Vector2.RIGHT)
	var want: Vector2 = at + Vector2(0.0, GroundDropShowcase.PAST_M)
	assert_almost_eq(lies, want, Vector2.ONE * 1e-4, "below his feet, whatever the shot")
	StreetDeadRests.reset()


func test_with_no_rest_it_lies_across_the_shot_on_the_cameras_side() -> void:
	StreetDeadRests.reset()
	var at: Vector2 = Vector2(10.0, 10.0)
	var e: Vector2 = Vector2.ONE * 1e-4
	var down: Vector2 = at + Vector2(0.0, GroundDropShowcase.SIDE_M)
	assert_almost_eq(GroundDropShowcase.place(at, Vector2.LEFT), down, e, "shot west: below")
	assert_almost_eq(GroundDropShowcase.place(at, Vector2.RIGHT), down, e, "shot east: below")
	var right: Vector2 = at + Vector2(GroundDropShowcase.SIDE_M, 0.0)
	assert_almost_eq(GroundDropShowcase.place(at, Vector2.DOWN), right, e, "shot south: right")


func test_a_drop_lies_where_it_first_landed_when_his_rest_appears() -> void:
	# film dr_machine_pistol t190 -> t191: the gun jumped ~1 m when the corpse published its rest.
	var at: Vector2 = Vector2(31.25, 17.5)
	var k: float = Ink.PX_PER_M
	StreetDeadRests.reset()
	var first: Vector2 = GroundDropShowcase.lies_at(at, Vector2.RIGHT)
	StreetDeadRests.all[9] = Vector4(at.x * k, at.y * k, (at.x + 1.0) * k, at.y * k)
	assert_ne(GroundDropShowcase.place(at, Vector2.RIGHT), first, "the rule now says past his feet")
	assert_eq(GroundDropShowcase.lies_at(at, Vector2.RIGHT), first, "but the gun stays put")
	StreetDeadRests.reset()
