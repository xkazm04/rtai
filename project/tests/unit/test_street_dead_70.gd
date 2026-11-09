extends GutTest
## n10: a class drawn for the 70-degree camera lies in the cell for its heading, unturned.


func _cell_of(deg: float, pose: int = 0, odd: bool = false) -> int:
	return StreetDead70.cell(Vector2.from_angle(deg_to_rad(deg)), pose, odd)


func test_every_listed_class_has_a_five_by_two_sheet() -> void:
	for cls: String in StreetDead70.CLASSES:
		var tex: Texture2D = load(StreetDead70.DIR + cls + ".png") as Texture2D
		assert_not_null(tex, cls)
		if tex != null:
			assert_eq(
				tex.get_width() * StreetDead70.ROWS, tex.get_height() * StreetDead70.COLS, cls
			)


func test_a_class_without_a_sheet_keeps_the_plan_pose() -> void:
	assert_eq(StreetDead70.path_of("ped/head_hood"), "")
	assert_eq(StreetDead70.path_of("boss/king"), "")
	assert_string_ends_with(StreetDead70.path_of("cop/head_cap"), "dead70_cop_patrol.png")


func test_the_column_is_the_heads_screen_heading() -> void:
	assert_eq(_cell_of(0.0), 2, "right")
	assert_eq(_cell_of(-45.0), 3, "up-right")
	assert_eq(_cell_of(-90.0), 4, "up")
	assert_eq(_cell_of(180.0), 2, "left draws the right column")
	assert_eq(_cell_of(-135.0), 3, "up-left draws the up-right column")
	assert_eq(_cell_of(90.0), 0, "down")
	assert_eq(_cell_of(45.0), 1, "down-right")


func test_poses_sharing_a_heading_lie_in_different_rows() -> void:
	var even: Array[int] = [0, 2]
	var odd: Array[int] = [1, 3]
	for pair: Array[int] in [even, odd]:
		assert_ne(StreetDead70.FAMILY[pair[0]], StreetDead70.FAMILY[pair[1]], str(pair))


func test_the_second_row_starts_after_a_full_row() -> void:
	assert_eq(_cell_of(0.0, 1), StreetDead70.COLS + 2, "pose B on the back")
	assert_eq(_cell_of(0.0, 4, false), 2, "the across pose by the person: face down")
	assert_eq(_cell_of(0.0, 4, true), StreetDead70.COLS + 2, "the across pose by the person: back")


func test_only_a_head_lying_left_draws_mirrored() -> void:
	assert_true(StreetDead70.mirrored(Vector2.LEFT, false))
	assert_false(StreetDead70.mirrored(Vector2.RIGHT, true))
	assert_true(StreetDead70.mirrored(Vector2.UP, true), "straight up: by the person")
	assert_false(StreetDead70.mirrored(Vector2.UP, false), "straight up: by the person")


func test_lay_sets_the_cell_and_never_turns_the_sprite() -> void:
	var plan: Sprite2D = autofree(Sprite2D.new())
	plan.hframes = StreetDead70.COLS
	plan.vframes = StreetDead70.ROWS
	StreetDead70.lay(plan, Vector2.from_angle(deg_to_rad(-135.0)), 1, false)
	assert_eq(plan.frame, StreetDead70.COLS + 3)
	assert_true(plan.flip_h)
	assert_almost_eq(plan.rotation, 0.0, 0.0001)


func test_sprite_takes_the_sheets_grid() -> void:
	var card: Sprite2D = autofree(Sprite2D.new())
	var path: String = StreetDead70.DIR + "cop_patrol.png"
	var plan: Sprite2D = StreetDead70.sprite(card, path, StreetDead70.COLS, StreetDead70.ROWS)
	assert_eq(plan.hframes, StreetDead70.COLS)
	assert_eq(plan.vframes, StreetDead70.ROWS)
	assert_eq(plan.texture.resource_path, path)
	assert_same(StreetDead70.sprite(card, path, StreetDead70.COLS, StreetDead70.ROWS), plan)
