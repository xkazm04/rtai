extends GutTest


func test_the_kings_legs_have_no_cream_rim_under_the_card_views() -> void:
	var saved: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("combo")
	var cards: BodyPlan = KingPlan.build()
	ViewMode._shared = ViewMode.of("tilt70")
	var tilt70: BodyPlan = KingPlan.build()
	ViewMode._shared = ViewMode.of("top")
	var top: BodyPlan = KingPlan.build()
	ViewMode._shared = saved
	assert_false(cards.leg_rim, "combo: ink outline only (owner d9)")
	assert_false(tilt70.leg_rim, "tilt70: ink outline only")
	assert_eq(top.leg_rim, KingPlan.LEG_RIM_TOP, "top keeps its look")
	assert_true(RivetPlan.build(RivetPlan.FORM_OPEN).leg_rim, "Rivet keeps his leg rim")
	assert_false(cards.arm_rim, "combo: the press plates, ink outline only")
	assert_false(tilt70.arm_rim, "tilt70: the press plates, ink outline only")
	assert_true(top.arm_rim, "top keeps its arm rim")
	assert_true(RivetPlan.build(RivetPlan.FORM_OPEN).arm_rim, "Rivet keeps his arm rim")
