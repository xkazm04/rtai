extends GutTest


func test_no_lean_without_a_hit() -> void:
	assert_eq(GhostRecoil.tilt(-1, 0.0), 0.0)
	assert_eq(GhostRecoil.tilt(GhostDrawn.HIT_TICKS, 0.0), 0.0)


func test_facing_right_leans_back_left_at_full_on_the_hit_tick() -> void:
	assert_almost_eq(GhostRecoil.tilt(0, 0.0), -deg_to_rad(GhostRecoil.LEAN_DEG), 1e-5)


func test_facing_left_leans_the_other_way() -> void:
	assert_gt(GhostRecoil.tilt(0, PI), 0.0)


func test_toward_the_camera_does_not_lean() -> void:
	assert_almost_eq(GhostRecoil.tilt(0, PI / 2.0), 0.0, 1e-5)


func test_the_lean_eases_out_over_the_hit() -> void:
	var a: float = absf(GhostRecoil.tilt(2, 0.0))
	var b: float = absf(GhostRecoil.tilt(6, 0.0))
	assert_gt(a, b)
	assert_gt(b, 0.0)


func test_zero_lean_turns_it_off() -> void:
	assert_eq(GhostRecoil.tilt(0, 0.0, 0.0), 0.0)


func test_tonnage_leans_less_than_the_others_and_the_rest_keep_the_full_lean() -> void:
	assert_eq(GhostRecoil.lean_of("kerf"), GhostRecoil.LEAN_DEG)
	assert_lt(GhostRecoil.lean_of("tonnage"), GhostRecoil.LEAN_DEG)
	assert_gt(GhostRecoil.lean_of("tonnage"), 0.0)


func test_a_blow_from_the_left_tips_a_right_facing_ghost_forward_away_from_it() -> void:
	var lean: float = deg_to_rad(GhostRecoil.LEAN_DEG)
	# facing right, shot from behind (the round travels +x): the top goes right, away from the shooter
	assert_almost_eq(GhostRecoil.tilt(0, 0.0, GhostRecoil.LEAN_DEG, Vector2.RIGHT), lean, 0.0001)
	assert_almost_eq(GhostRecoil.tilt(0, 0.0, GhostRecoil.LEAN_DEG, Vector2.LEFT), -lean, 0.0001)


func test_a_side_blow_tips_a_toward_facing_ghost() -> void:
	var t: float = GhostRecoil.tilt(0, PI * 0.5, GhostRecoil.LEAN_DEG, Vector2(-1.0, 0.0))
	assert_lt(t, 0.0, "a round travelling left tips the camera-facing ghost left")


func test_an_unknown_blow_keeps_the_facing_lean() -> void:
	assert_eq(
		GhostRecoil.tilt(0, 0.0), GhostRecoil.tilt(0, 0.0, GhostRecoil.LEAN_DEG, Vector2.ZERO)
	)


func test_the_arena_hands_the_blow_line_to_the_victim() -> void:
	var f: Fighter = Fighter.new()
	f.hp = 3.0
	f.take(1.0, 7, Vector2(0.0, -1.0))
	assert_eq(f.hp, 2.0)
	assert_eq(f.hurt_tick, 7)
	assert_eq(f.hurt_dir, Vector2(0.0, -1.0))
