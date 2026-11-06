extends GutTest
## n7-ranged it11: a ready molotov is held cocked behind the gun shoulder; a throw whips the claw
## out ahead; off (`--throw-windup=off`) keeps it out at the aim (the before).

const AIM_PX: float = 600.0


func after_each() -> void:
	RigThrow.on = true


func test_a_ready_bottle_is_cocked_behind_the_shoulder() -> void:
	var rig: CutRig = _aimed(-1.0)
	assert_lt(_hand_ahead(rig), 0.0, "the claw sits behind the gun shoulder")


func test_off_holds_the_bottle_out_at_the_aim() -> void:
	RigThrow.on = false
	var rig: CutRig = _aimed(-1.0)
	assert_gt(_hand_ahead(rig), 80.0, "planted: off, the claw is out at the aim")


func test_the_throw_whips_the_claw_out_ahead() -> void:
	var rig: CutRig = _aimed(-1.0)
	var cocked: float = _hand_ahead(rig)
	rig.clips.recoil = -1.6
	rig.drive(SimClock.TICK_DT)
	var thrown: float = _hand_ahead(rig)
	gut.p("claw ahead of the gun shoulder: cocked %.0f px, thrown %.0f px" % [cocked, thrown])
	assert_gt(thrown - cocked, 100.0, "the release swings the claw out")


func test_the_reloads_cock_phase_draws_the_next_bottle_back() -> void:
	var chest: float = _hand_ahead(_aimed(1.5))
	var cocking: float = _hand_ahead(_aimed(2.99))
	assert_lt(cocking, chest - 40.0, "the cock phase pulls the claw back from the chest")


## How far the gun claw is ahead of the gun shoulder along the facing (torso frame, part px).
func _hand_ahead(rig: CutRig) -> float:
	var side: RigLimbs = rig.sides[rig.plan.gun_arm]
	return side.j_hand.x - side.j_shoulder.x


func _aimed(reload_k: float) -> CutRig:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(RivetPlan.build(), RigVariant.rivet())
	rig.snap_facing(-PI * 0.5)
	rig.position = Vector2(500, 500)
	for _k: int in 30:
		rig.gun_out = true
		rig.aiming = true
		rig.grip = RigGrip.Kind.THROWN
		rig.hold = &"thrown"
		rig.reload_k = reload_k
		rig.aim_at = rig.position + Vector2(0, -AIM_PX)
		rig.face_to = -PI * 0.5
		rig.drive(SimClock.TICK_DT)
	return rig


func test_the_bottle_stays_in_the_cocked_claw_until_the_release_is_posed() -> void:
	var rig: CutRig = _aimed(-1.0)
	rig.reload_k = 0.05
	assert_true(RigThrow.lag_frame(rig), "the reload started, the release not posed yet")
	rig.clips.recoil = -1.6
	rig.drive(SimClock.TICK_DT)
	assert_false(RigThrow.lag_frame(rig), "once the release is posed the bottle is gone")
	RigThrow.on = false
	rig.clips.recoil = 0.0
	rig.drive(SimClock.TICK_DT)
	assert_false(RigThrow.lag_frame(rig), "off: the before (hidden at once)")


func test_the_first_aim_rises_to_cocked_instead_of_snapping() -> void:
	var rig: CutRig = _aimed(-1.0)
	var cocked: float = _hand_ahead(rig)
	rig.throw_t = -1.0  # a fresh aim: the claw was not cocked a moment ago
	rig.drive(SimClock.TICK_DT)
	var first: float = _hand_ahead(rig)
	for _k: int in 20:
		rig.drive(SimClock.TICK_DT)
	gut.p("claw ahead: cocked %.0f px, first aimed frame %.0f px" % [cocked, first])
	assert_gt(first - cocked, 40.0, "the first aimed frame is still near the ready claw")
	assert_almost_eq(_hand_ahead(rig), cocked, 2.0, "a third of a second later it is cocked")
