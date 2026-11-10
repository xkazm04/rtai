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
