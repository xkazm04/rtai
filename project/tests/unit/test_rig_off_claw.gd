extends GutTest
## d7-held: Rivet's off claw on a two-claw weapon (RigOffClaw). Aiming a long gun, a tube or a
## hip weapon, the off forearm is the plain one (not the torch) and the claw's jaws sit on the
## drawn barrel line (through the gun claw's grip point toward the aim). A blade or a pistol keeps
## the torch arm free. Planted fault: the hand on the IK line (RigOffClaw.target skipped, the
## pre-fix hold) puts the jaws off the barrel.

const AIM_PX: float = 600.0
## The jaws' middle must lie within this of the barrel's centre line (torso part px; the plasma
## rifle's drawn body is about 70 px across at Rivet's held scale).
const ON_BARREL_PX: float = 25.0


func test_two_claw_holds_show_the_off_claw_and_plain_forearm() -> void:
	for hold: StringName in [&"long_gun", &"tube", &"heavy"]:
		var rig: CutRig = _rig(hold, true)
		var off: RigLimbs = rig.sides[1 - rig.plan.gun_arm]
		assert_true(off.grip.visible, "%s: the off claw shows" % hold)
		assert_eq(off.fore_cell, RigOffClaw.FORE, "%s: the plain forearm, not the torch" % hold)


func test_one_claw_and_carried_holds_keep_the_torch_arm() -> void:
	for c: Array in [[&"blade", true], [&"sidearm", true], [&"long_gun", false]]:
		var hold: StringName = c[0]
		var aiming: bool = c[1]
		var rig: CutRig = _rig(hold, aiming)
		var off: RigLimbs = rig.sides[1 - rig.plan.gun_arm]
		assert_false(off.grip.visible, "%s aiming=%s: no off claw" % c)
		assert_ne(off.fore_cell, RigOffClaw.FORE, "%s aiming=%s: the torch forearm" % c)


func test_the_jaws_sit_on_the_drawn_barrel() -> void:
	for hold: StringName in [&"long_gun", &"tube", &"heavy"]:
		var rig: CutRig = _rig(hold, true)
		gut.p("%s: jaws %.1f px off the barrel line" % [hold, _jaw_gap(rig)])
		assert_lt(_jaw_gap(rig), ON_BARREL_PX, "%s: the claw clamps the barrel" % hold)


func test_planted_ik_line_hand_misses_the_barrel() -> void:
	var rig: CutRig = _rig(&"long_gun", true)
	var off: RigLimbs = rig.sides[1 - rig.plan.gun_arm]
	var reach: float = rig.plan.upper_len + rig.plan.fore_len[1 - rig.plan.gun_arm]
	var ik: Vector3 = RigGrip.target(rig, Vector3.ZERO, false, reach)
	off.j_hand = Vector2(ik.x, ik.y)
	RigOffClaw.place(rig, 1 - rig.plan.gun_arm)
	gut.p("planted (IK line hand): jaws %.1f px off the barrel line" % _jaw_gap(rig))
	assert_gt(_jaw_gap(rig), ON_BARREL_PX, "planted fault: the IK-line hand misses the barrel")


## The off claw's jaw middle: its distance from the drawn barrel line, torso part px.
func _jaw_gap(rig: CutRig) -> float:
	var jaw: Vector2 = RigOffClaw.jaw_point(rig, 1 - rig.plan.gun_arm)
	var grip: Vector2 = RigOffClaw.grip_point(rig)
	var aim: Vector2 = rig.torso.global_transform.affine_inverse() * rig.aim_at
	return absf((jaw - grip).cross((aim - grip).normalized()))


func _rig(hold: StringName, aiming: bool) -> CutRig:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(RivetPlan.build(), RigVariant.rivet())
	rig.snap_facing(-PI * 0.5)
	rig.position = Vector2(500, 500)
	var h: HeldTable.Hold = HeldTable.shipped().holds[hold]
	for _k: int in 30:
		rig.gun_out = true
		rig.aiming = aiming
		rig.hold = hold
		rig.grip = h.kind
		rig.aim_at = rig.position + Vector2(0, -AIM_PX)
		rig.face_to = -PI * 0.5
		rig.drive(SimClock.TICK_DT)
	return rig
