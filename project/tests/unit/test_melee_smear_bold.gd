extends GutTest
## d8-weapons: the cut's smear is bolder under a tilt (the cut at hand height over bodies) and
## unchanged straight down: the default view never sets `bold`.


func test_the_default_view_draws_the_plain_smear() -> void:
	var v: MeleeSmearView = MeleeSmearView.new()
	add_child_autofree(v)
	assert_false(v.bold, "a new smear is plain")
	assert_eq(ShotLift.up_m(), Vector2.ZERO, "the default view lifts nothing, so bold stays off")
	assert_eq(v.ink_share(), MeleeSmearView.INK_A, "top keeps the iteration-4 ink band")


func test_a_tilt_draws_the_crescent() -> void:
	var v: MeleeSmearView = MeleeSmearView.new()
	add_child_autofree(v)
	v.bold = true
	assert_lt(v.ink_share(), MeleeSmearView.INK_A, "the crescent drops the grey sector")
	assert_gt(MeleeSmearView.BOLD_EDGE_PX, MeleeSmearView.EDGE_PX, "with a thicker rim")
