extends GutTest


func before_each() -> void:
	StreetDeadPlan.reset()


func test_every_mapped_row_has_a_five_pose_strip() -> void:
	for row: String in StreetDeadPlan.CLASS_OF:
		var tex: Texture2D = load(StreetDeadPlan.path_of(row)) as Texture2D
		assert_not_null(tex, row)
		if tex != null:
			assert_eq(tex.get_width(), tex.get_height() * StreetDeadPlan.POSES, row)


func test_an_unmapped_row_keeps_its_drawn_lying_frame() -> void:
	assert_eq(StreetDeadPlan.path_of("boss/king"), "")


func test_every_drawn_walker_row_lies_in_a_plan_pose() -> void:
	for row: String in StreetWalkerCards.ROWS:
		assert_true(StreetDeadPlan.CLASS_OF.has(row), row + " has no plan dead strip")


func test_neighbours_never_share_a_pose() -> void:
	var seen: Dictionary[int, bool] = {}
	for i: int in 3:
		var pose: int = StreetDeadPlan.pick(100 + i, &"death_bullet", Vector2(i * 8.0, 0.0))
		assert_false(seen.has(pose), "pose %d twice within NEAR_M" % pose)
		seen[pose] = true


func test_far_apart_bodies_may_share_a_pose() -> void:
	var far: float = StreetDeadPlan.NEAR_M * CharacterRigs.PX_PER_M * 4.0
	var a: int = StreetDeadPlan.pick(7, &"death_melee", Vector2.ZERO)
	StreetDeadPlan.reset()
	var b: int = StreetDeadPlan.pick(7, &"death_melee", Vector2(far, 0.0))
	assert_eq(a, b, "the hash alone picks when no neighbour is near")


func test_a_sinking_body_keeps_its_pelvis_where_it_lay() -> void:
	var whole: float = StreetWalkerFall.rest_scale(0.3, 1.0)
	assert_almost_eq(StreetWalkerFall.rest_scale(0.15, 0.5), whole, 0.0001)
	assert_almost_eq(StreetWalkerFall.rest_scale(0.03, 0.1), whole, 0.0001)


func test_a_redrawn_corpse_keeps_its_pose() -> void:
	var a: int = StreetDeadPlan.pick(42, &"death_blast", Vector2.ZERO)
	assert_eq(StreetDeadPlan.pick(42, &"death_blast", Vector2.ZERO), a)


func test_the_pose_comes_from_the_weapon_class() -> void:
	var melee: PackedInt32Array = StreetDeadPlan.BY_KIND[&"death_melee"]
	for i: int in 6:
		StreetDeadPlan.reset()
		assert_has(melee, StreetDeadPlan.pick(i, &"death_melee", Vector2.ZERO))


func test_the_body_slides_into_its_rest_and_lands_big() -> void:
	var t0: float = StreetWalkerFall.FALL_AT[StreetWalkerFall.FALL_FRAMES - 1]
	var land: Vector2 = StreetDeadPlan.motion(&"death_blast", t0)
	assert_almost_eq(land.x, 1.2, 0.001)
	assert_almost_eq(land.y, StreetDeadPlan.LAND_SCALE, 0.001)
	var rest: Vector2 = StreetDeadPlan.motion(&"death_blast", StreetDeadPlan.SLIDE_END)
	assert_almost_eq(rest.x, 0.0, 0.0001)
	assert_almost_eq(rest.y, 1.0, 0.0001)
	assert_lt(StreetDeadPlan.motion(&"death_melee", t0).x, land.x, "melee slides less than a blast")


func test_the_crowd_atlas_gets_a_plan_pose_turned_to_the_bake() -> void:
	var a: Image = StreetCrowdCorpse.plan_cell("p70", "cop/head_cap", 0)
	var e: Image = StreetCrowdCorpse.plan_cell("p70", "cop/head_cap", 4)
	assert_not_null(a)
	assert_not_null(e)
	if a != null:
		assert_lte(maxi(a.get_width(), a.get_height()), CrowdAtlas.CELL_PX)
	assert_not_null(StreetCrowdCorpse.plan_cell("p70", "ped/head_jogger", 0))
	assert_null(StreetCrowdCorpse.plan_cell("p70", "boss/king", 0))


func test_two_bodies_on_one_spot_end_a_body_apart() -> void:
	var at: Vector2 = Vector2(100.0, 100.0)
	assert_ne(StreetDeadPlan.pick(1, &"", at), StreetDeadPlan.pick(2, &"", at), "poses differ")
	var a: Vector2 = StreetDeadHeading.resting(1, at, 0.0)
	var b: Vector2 = StreetDeadHeading.resting(2, at, 0.0)
	var space: float = StreetQuestDeadPush.SPACE_M * CharacterRigs.PX_PER_M
	assert_gte(a.distance_to(b), space - 0.5)


func test_the_push_is_nothing_at_the_blow_and_whole_once_settled() -> void:
	var at: Vector2 = Vector2(100.0, 100.0)
	assert_gte(StreetDeadPlan.pick(1, &"", at), 0)
	assert_gte(StreetDeadPlan.pick(2, &"", at), 0)
	assert_eq(StreetDeadHeading.resting(1, at, 1.0), at, "not moved at the blow")
	assert_ne(StreetDeadHeading.resting(1, at, 0.0), at, "pushed once settled")


func test_a_push_into_a_wall_takes_a_free_spot_instead() -> void:
	StreetDeadPlan._lying[7] = Vector3(0.0, 0.0, 0.0)
	var wall: Callable = func(px: Vector2) -> bool: return px.x > 10.0
	var push: Vector2 = StreetQuestDeadPush.push_of(8, Vector2.ZERO, 32.0, wall)
	var hit: bool = wall.call(push)
	assert_false(hit, "not in the wall")
	assert_gte(push.length(), StreetQuestDeadPush.SPACE_M * 32.0 - 0.5, "clear of the body")


func test_a_body_with_no_neighbour_stays_though_its_spot_is_solid() -> void:
	var wall: Callable = func(_px: Vector2) -> bool: return true
	assert_eq(StreetQuestDeadPush.push_of(9, Vector2.ZERO, 32.0, wall), Vector2.ZERO)


func test_a_lying_body_stops_short_of_the_first_wall() -> void:
	var wall_x: float = 40.0
	StreetDeadPlan.solid = func(px: Vector2) -> bool: return px.x >= wall_x
	assert_almost_eq(StreetDeadPlan.free_px(Vector2.ZERO, Vector2.RIGHT, 80.0), 30.0, 0.001)
	assert_almost_eq(StreetDeadPlan.free_px(Vector2.ZERO, Vector2.LEFT, 80.0), 80.0, 0.001)
	StreetDeadPlan.solid = Callable()
	assert_almost_eq(StreetDeadPlan.free_px(Vector2.ZERO, Vector2.RIGHT, 80.0), 80.0, 0.001)
