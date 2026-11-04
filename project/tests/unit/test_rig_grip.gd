extends GutTest
## rivet-arsenal: RigGrip on Rivet's real rig. Aimed up the screen with a two-handed grip, the off
## claw comes forward onto the aim line ahead of the gun claw (under the barrel); the planted fault
## (grip ONE_HAND, the old one-arm aim) must leave the off claw hanging off the line.

const AIM_PX: float = 600.0


func test_grip_kinds_from_rivet_arsenal_classes() -> void:
	var a: ArsenalTable = ArsenalTable.shipped()
	assert_eq(RigGrip.kind_of(a.grip_of(&"pistol").id), RigGrip.Kind.ONE_HAND)
	assert_eq(RigGrip.kind_of(a.grip_of(&"plasma_rifle").id), RigGrip.Kind.TWO_HAND_LONG)
	assert_eq(RigGrip.kind_of(a.grip_of(&"rocket_launcher").id), RigGrip.Kind.SHOULDER)
	assert_eq(RigGrip.kind_of(a.grip_of(&"flamethrower").id), RigGrip.Kind.HIP)
	assert_eq(RigGrip.kind_of(a.grip_of(&"chainsaw").id), RigGrip.Kind.HIP)
	assert_eq(RigGrip.kind_of(&"no_such_class"), RigGrip.Kind.ONE_HAND)


func test_two_hand_off_claw_rides_the_aim_line() -> void:
	var two: Vector2 = _off_hand(RigGrip.Kind.TWO_HAND_LONG)
	var one: Vector2 = _off_hand(RigGrip.Kind.ONE_HAND)
	gut.p("off claw (off line px, ahead px): two-hand %s, one-hand %s" % [two, one])
	assert_lt(two.x, 40.0, "two-hand: the off claw is on the barrel line")
	assert_gt(two.y, 0.0, "two-hand: the off claw is ahead of the gun claw")
	assert_gt(one.x, two.x * 2.0, "planted fault: one-hand leaves the off claw off the line")


func test_shoulder_pulls_the_gun_claw_in() -> void:
	assert_lt(_gun_reach(RigGrip.Kind.SHOULDER), _gun_reach(RigGrip.Kind.ONE_HAND) * 0.6)


func test_reload_pulls_the_magazine_and_comes_back() -> void:
	var out: float = _reload_gap(0.95)
	var back: float = _reload_gap(1.95)
	gut.p(
		(
			"reload: off claw to gun claw %.0f px at the magazine, %.0f px back at the gun"
			% [out, back]
		)
	)
	assert_gt(out, 60.0, "the off claw leaves the gun for the magazine")
	assert_lt(back, 10.0, "and brings the new one back to the gun")
	assert_lt(_reload_gap(0.0), 10.0, "planted: a reload stuck at phase 0 shows no magazine")


func _reload_gap(k: float) -> float:
	var rig: CutRig = _aimed(RigGrip.Kind.TWO_HAND_LONG, k)
	return rig.sides[0].j_hand.distance_to(rig.sides[1].j_hand)


## (distance of the off claw from the barrel line through the gun claw, how far ahead of the
## gun claw along it), part px
## in the torso's frame (RigLimbs joints).
func _off_hand(kind: int) -> Vector2:
	var rig: CutRig = _aimed(kind)
	var gun: Vector2 = rig.sides[rig.plan.gun_arm].j_hand
	var off: Vector2 = rig.sides[1 - rig.plan.gun_arm].j_hand
	var sh: Vector2 = rig.sides[rig.plan.gun_arm].j_shoulder
	var aim: Vector2 = rig.torso.global_transform.affine_inverse() * rig.aim_at
	var dir: Vector2 = (aim - sh).normalized()
	var across: float = absf((off - gun).cross(dir))
	return Vector2(across, (off - gun).dot(dir))


func _gun_reach(kind: int) -> float:
	var rig: CutRig = _aimed(kind)
	var side: RigLimbs = rig.sides[rig.plan.gun_arm]
	return side.j_hand.distance_to(side.j_shoulder)


func _aimed(kind: int, reload_k: float = -1.0) -> CutRig:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(RivetPlan.build(), RigVariant.rivet())
	rig.snap_facing(-PI * 0.5)
	rig.position = Vector2(500, 500)
	for _k: int in 30:
		rig.gun_out = true
		rig.aiming = true
		rig.grip = kind
		rig.reload_k = reload_k
		rig.aim_at = rig.position + Vector2(0, -AIM_PX)
		rig.face_to = -PI * 0.5
		rig.drive(SimClock.TICK_DT)
	return rig
