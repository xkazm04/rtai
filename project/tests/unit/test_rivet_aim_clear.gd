extends GutTest
## rivet-arsenal: an aimed long gun or tube clears Rivet's helmet. The weapon's line starts
## RigGrip.GUN_SIDE_BY out toward the gun shoulder and the helmet leans off the stock
## (RigGrip.head_lean). Planted fault: the old line (GUN_SIDE 0.3, no lean; the HIP hold keeps
## both) runs under the helmet.

const AIM_PX: float = 600.0


func test_aimed_long_gun_line_clears_the_helmet() -> void:
	for kind: int in [RigGrip.Kind.TWO_HAND_LONG, RigGrip.Kind.SHOULDER]:
		var rig: CutRig = _rig(kind, true)
		gut.p(
			(
				"aimed kind %d: line %.0f px off the helmet centre (half-width %.0f)"
				% [kind, _aim_gap(rig), _half(rig)]
			)
		)
		assert_gt(_aim_gap(rig), _half(rig), "the barrel line passes beside the helmet")
	var old: CutRig = _rig(RigGrip.Kind.HIP, true)
	gut.p("planted (GUN_SIDE 0.3, no lean): %.0f px" % _aim_gap(old))
	assert_lt(_aim_gap(old), _half(old), "planted fault: the old line runs under the helmet")


func test_helmet_leans_off_the_stock_only_when_aiming_long() -> void:
	var rig: CutRig = _rig(RigGrip.Kind.SHOULDER, true)
	var gun_y: float = rig.plan.shoulder[rig.plan.gun_arm].y
	var lean: float = RigGrip.head_lean(rig)
	assert_eq(signf(lean), -signf(gun_y), "aimed with a tube: the helmet leans to the off side")
	assert_eq(RigGrip.head_lean(_rig(RigGrip.Kind.SHOULDER, false)), 0.0, "carried: no lean")
	assert_eq(RigGrip.head_lean(_rig(RigGrip.Kind.ONE_HAND, true)), 0.0, "a pistol: no lean")


## The helmet's half-extent ACROSS the barrel line: the line runs forward (+x, the part's texture
## width), so the clearance is half the texture height (n5-cast: the hybrid's welder helmet is
## long front to back, 207 x 150 part px; the d4 helmet was about square).
func _half(rig: CutRig) -> float:
	return rig.head_spr.texture.get_height() * 0.5


## The aimed barrel line (through the gun claw toward the aim point): its distance from the
## helmet's centre, torso part px.
func _aim_gap(rig: CutRig) -> float:
	var claw: Vector2 = _claw(rig)
	var aim: Vector2 = rig.torso.global_transform.affine_inverse() * rig.aim_at
	return absf((rig.head.position - claw).cross((aim - claw).normalized()))


func _claw(rig: CutRig) -> Vector2:
	return rig.sides[rig.plan.gun_arm].j_hand


func _rig(kind: int, aiming: bool) -> CutRig:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(RivetPlan.build(), RigVariant.rivet())
	rig.snap_facing(-PI * 0.5)
	rig.position = Vector2(500, 500)
	for _k: int in 30:
		rig.gun_out = true
		rig.aiming = aiming
		rig.grip = kind
		rig.aim_at = rig.position + Vector2(0, -AIM_PX)
		rig.face_to = -PI * 0.5
		rig.drive(SimClock.TICK_DT)
	return rig
