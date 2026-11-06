extends GutTest


func test_straight_down_nothing_lifts() -> void:
	assert_true(ViewMode.shared().is_flat(), "tests run under the default top view")
	assert_eq(ShotLift.up_m(), Vector2.ZERO, "top stays bit-identical")


func test_the_tilt_lifts_up_the_screen_by_the_gun_height() -> void:
	var tilt: ViewMode = ViewMode.of("tilt")
	var up: Vector2 = tilt.lift_px(ShotLift.GUN_H_M) / SimConst.PX_PER_M
	assert_lt(up.y, 0.0, "up the screen")
	assert_eq(up.x, 0.0)


func test_ground_hits_stay_on_the_ground_and_body_hits_lift() -> void:
	var at: Vector2 = Vector2(3, 4)
	assert_eq(ShotLift.hit_at(at, GunFx.Hit.GROUND), at)
	assert_eq(ShotLift.hit_at(at, GunFx.Hit.BODY), at + ShotLift.up_m())
	assert_eq(ShotLift.hit_at(at, GunFx.Hit.METAL), at + ShotLift.up_m())
