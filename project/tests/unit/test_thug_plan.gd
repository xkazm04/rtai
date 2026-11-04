extends GutTest


func test_thug_is_its_own_plan_not_kings() -> void:
	var thug: BodyPlan = ThugPlan.build()
	var king: BodyPlan = KingPlan.build(ThugPlan.SIZE_K)
	assert_eq(thug.name, "thug")
	assert_lt(thug.thigh_len, king.thigh_len, "short legs")
	assert_gt(thug.hip_y, king.hip_y, "a wide stance")
	assert_gt(thug.upper_len, king.upper_len, "long arms")
	assert_gt(thug.arm_w, king.arm_w, "heavy arms")


func test_thug_wears_no_collar_and_no_hose() -> void:
	var thug: BodyPlan = ThugPlan.build()
	assert_eq(thug.collar_part, "", "vermilion is Rivet's collar only")
	assert_eq(thug.hose_tex, "")
