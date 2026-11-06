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


func test_the_flame_jet_stays_on_the_ground_straight_down() -> void:
	var s: Shot = Shot.new()
	s.origin = Vector2(1, 2)
	s.pos = Vector2(4, 2)
	var ci: Node2D = autofree(Node2D.new())
	assert_eq(ShotLift.jet(ci, s, 0.0), Vector2.ZERO, "top: the jet is the before, bit-identical")
	assert_eq(ShotLift.jet(ci, s, 3.0), Vector2.ZERO)


func test_a_claw_effect_keeps_its_ground_point_straight_down() -> void:
	var ci: Node2D = autofree(Node2D.new())
	assert_eq(ShotLift.claw_at(ci, Vector2(2, 5)), Vector2(2, 5), "top: the crackle is the before")
