extends GutTest
## combat-notes (owner note 2026-11-04, "animation of melee weapons"): the held blade's swing
## (MeleeSwing) cocks past the arc (anticipation), crosses the aim line on the hit tick (the sim
## lands a melee hit on the first active tick), overshoots to the far side and holds there
## (follow-through) before it eases home; the smear runs over the cut. The night's linear sweep
## (the planted fault: the blade still fully cocked on the hit tick) fails the contact check.

const DT: float = 1.0 / 60.0
## The katana's first slash: windup 5, active 3, recovery 9 ticks.
const PH: Vector3 = Vector3(5.0 * DT, 3.0 * DT, 9.0 * DT)
const ARC: float = 1.27


func _contact_error(night: bool) -> float:
	MeleeSwing.sharp = not night
	var a: float = MeleeSwing.angle(PH.x, PH, 1.0, ARC)
	MeleeSwing.sharp = true
	return absf(a)


func test_the_blade_is_on_the_aim_line_on_the_hit_tick() -> void:
	assert_almost_eq(_contact_error(false), 0.0, 0.001, "contact on the hit tick")


func test_the_planted_late_sweep_is_caught() -> void:
	assert_gt(_contact_error(true), 1.0, "the night's sweep is still cocked on the hit tick")


func test_anticipation_overshoot_and_follow_through() -> void:
	var c0: float = MeleeSwing.cut_start(PH)
	assert_almost_eq(PH.x - c0, 2.0 * DT, 0.0001, "the cut takes the last two windup ticks")
	var cocked: float = MeleeSwing.angle(c0 - 0.0001, PH, 1.0, ARC)
	assert_gt(cocked, ARC * 1.2, "cocked past the hit's arc")
	var out: float = MeleeSwing.angle(PH.x + PH.y, PH, 1.0, ARC)
	assert_almost_eq(out, -ARC * MeleeSwing.FOLLOW, 0.001, "overshoots to the far side")
	var held: float = MeleeSwing.angle(PH.x + PH.y + PH.z * 0.3, PH, 1.0, ARC)
	assert_almost_eq(held, out, 0.001, "the follow-through holds")
	var home: float = MeleeSwing.angle(PH.x + PH.y + PH.z, PH, 1.0, ARC)
	assert_almost_eq(home, 0.0, 0.001, "back on the aim line at the end of the recovery")
	assert_lt(MeleeSwing.angle(c0 + DT, PH, -1.0, ARC), 0.0, "the other side mirrors")


func test_the_cut_moves_one_way_and_the_smear_covers_it() -> void:
	var c0: float = MeleeSwing.cut_start(PH)
	var last: float = MeleeSwing.angle(c0, PH, 1.0, ARC)
	for i: int in range(1, 11):
		var t: float = c0 + (PH.x + PH.y - c0) * float(i) / 10.0
		var a: float = MeleeSwing.angle(t, PH, 1.0, ARC)
		assert_lt(a, last + 0.0001, "the cut never swings back")
		assert_true(MeleeSwing.cutting(t - 0.0001, PH), "the smear runs through the cut")
		last = a
	assert_false(MeleeSwing.cutting(c0 - DT, PH), "no smear in the windup")
	assert_false(MeleeSwing.cutting(PH.x + PH.y + PH.z * 0.5, PH), "none in the recovery")
