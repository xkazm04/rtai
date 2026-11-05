extends GutTest
## combat-notes (owner note "player's hold of melee weapons"): with a two-handed melee weapon the
## off claw closes on the hilt just ahead of the gun claw, along the blade (CutRig.hilt_dir), and
## follows the blade as it turns; the planted fault (one-handed) leaves it off the hilt.

const AIM_PX: float = 600.0


func test_off_claw_closes_on_the_hilt() -> void:
	for dir: Vector2 in [Vector2.RIGHT, Vector2(1, 1).normalized(), Vector2(1, -1).normalized()]:
		var gap: float = _hilt_gap(true, dir)
		gut.p("blade %s: off claw %.0f px from its hilt point" % [dir, gap])
		assert_lt(gap, 30.0, "the off claw is on the hilt")


func test_planted_one_hand_leaves_the_hilt() -> void:
	assert_gt(_hilt_gap(false, Vector2.RIGHT), 60.0, "planted: one hand leaves the off claw away")


func test_off_forearm_stays_side_on() -> void:
	var rig: CutRig = _held(true, Vector2.RIGHT)
	var off: RigLimbs = rig.sides[1 - rig.plan.gun_arm]
	assert_ne(off.fore_cell, rig.plan.endon_fore[1 - rig.plan.gun_arm], "no end-on forearm")
	assert_eq(off.fore.z_index, rig.plan.arm_above + 1, "drawn over the torso")


func _hilt_gap(two: bool, dir: Vector2) -> float:
	var rig: CutRig = _held(two, dir)
	var g: int = rig.plan.gun_arm
	var want: Vector2 = rig.sides[g].j_hand + dir * RigGrip.HILT_PX
	return rig.sides[1 - g].j_hand.distance_to(want)


func _held(two: bool, dir: Vector2) -> CutRig:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(RivetPlan.build(), RigVariant.rivet())
	rig.snap_facing(-PI * 0.5)
	rig.position = Vector2(500, 500)
	for _k: int in 30:
		rig.gun_out = true
		rig.aiming = false
		rig.two_hand_melee = two
		rig.hilt_dir = dir
		rig.face_to = -PI * 0.5
		rig.drive(SimClock.TICK_DT)
	return rig
