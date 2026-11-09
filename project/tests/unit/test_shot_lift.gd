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


func test_the_back_tank_keeps_its_z_straight_down() -> void:
	assert_eq(ShotLift.back_z(Vector2(0, 1)), 0, "top: the tank draws as before, facing down")
	assert_eq(ShotLift.back_z(Vector2(0, -1)), 0, "top: and facing up")


func _rifle_shot() -> Shot:
	var s: Shot = Shot.new()
	s.spec = WeaponSpec.new()
	s.origin = Vector2(1, 2)
	s.vel = Vector2(0, -10)
	return s


func test_a_lifted_round_starts_on_the_published_muzzle_and_lets_go() -> void:
	# n10: fired up the screen the flash sat on the gun and the tracer on his helmet
	var ci: Node2D = add_child_autofree(Node2D.new())
	var held: Sprite2D = add_child_autofree(Sprite2D.new())
	held.position = Vector2(300, 100)
	HeldMuzzle.publish(held, Vector2.ZERO)
	var s: Shot = _rifle_shot()
	var up: Vector2 = Vector2(0, -0.5)
	var tip: Vector2 = HeldMuzzle.at_m(ci, Vector2.ZERO)
	var line0: Vector2 = s.origin + s.vel.normalized().orthogonal() * WeaponFxArt.GUN_SIDE_M + up
	assert_eq(
		ShotLift.to_muzzle(ci, s, 0.0, up), tip - line0, "the first flown metre is on the tip"
	)
	var half: Vector2 = ShotLift.to_muzzle(ci, s, WeaponFxArt.CONVERGE_M * 0.5, up)
	assert_almost_eq(half.x, (tip - line0).x * 0.5, 0.001, "half way, half the pull")
	assert_eq(ShotLift.to_muzzle(ci, s, WeaponFxArt.CONVERGE_M, up), Vector2.ZERO, "let go")
	HeldMuzzle.reset()


func test_no_published_muzzle_no_pull() -> void:
	var ci: Node2D = add_child_autofree(Node2D.new())
	HeldMuzzle.reset()
	assert_eq(ShotLift.to_muzzle(ci, _rifle_shot(), 0.0, Vector2(0, -0.5)), Vector2.ZERO)


class RoundProbe:
	extends Node2D
	## Calls ShotLift.round_at where the game does: inside _draw, with the muzzle fresh.

	var shot: Shot = null
	var held: Sprite2D = null
	var at: Vector2 = Vector2(4.0, 5.0)
	var flown: float = 0.0
	var drawn: Vector2 = Vector2.ZERO
	var tip: Vector2 = Vector2.ZERO
	var ran: int = 0

	func _draw() -> void:
		HeldMuzzle.publish(held, Vector2.ZERO)
		tip = HeldMuzzle.at_m(self, Vector2.ZERO)
		drawn = ShotLift.round_at(self, shot, at, flown)
		ran += 1


func _drawn_probe(view: String, flown: float) -> RoundProbe:
	var saved: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of(view)
	var probe: RoundProbe = RoundProbe.new()
	probe.held = add_child_autofree(Sprite2D.new())
	probe.held.position = Vector2(300, 100)
	probe.shot = _rifle_shot()
	probe.flown = flown
	add_child_autofree(probe)
	await wait_process_frames(2)
	HeldMuzzle.reset()
	ViewMode._shared = saved
	return probe


func test_the_drawn_round_carries_the_pull_under_a_tilt() -> void:
	# n10: the path the game draws, not to_muzzle alone (red if round_at stops calling it)
	var up: Vector2 = ViewMode.of("tilt").lift_px(ShotLift.GUN_H_M) / SimConst.PX_PER_M
	var probe: RoundProbe = await _drawn_probe("tilt", 0.0)
	assert_gt(probe.ran, 0, "_draw ran")
	var dir: Vector2 = probe.shot.vel.normalized()
	var line0: Vector2 = probe.shot.origin + dir.orthogonal() * WeaponFxArt.GUN_SIDE_M + up
	assert_eq(probe.drawn, probe.at + up + (probe.tip - line0), "the round starts on the tip")


func test_the_drawn_round_is_let_go_and_the_top_view_never_pulls() -> void:
	var up: Vector2 = ViewMode.of("tilt").lift_px(ShotLift.GUN_H_M) / SimConst.PX_PER_M
	var far: RoundProbe = await _drawn_probe("tilt", WeaponFxArt.CONVERGE_M)
	assert_eq(far.drawn, far.at + up, "past CONVERGE_M the round is on the lifted sim line")
	var top: RoundProbe = await _drawn_probe("top", 0.0)
	assert_eq(top.drawn, top.at, "straight down nothing moves")
