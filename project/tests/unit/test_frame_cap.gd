extends GutTest


func test_a_fast_display_with_vsync_is_capped_at_the_tick_rate() -> void:
	assert_eq(FrameCap.cap_for(144.0, true, 0, ""), SimClock.TICK_RATE)
	assert_eq(FrameCap.cap_for(120.0, true, 0, ""), SimClock.TICK_RATE)
	assert_eq(FrameCap.cap_for(61.5, true, 0, ""), SimClock.TICK_RATE)


func test_a_tick_rate_display_keeps_plain_vsync() -> void:
	assert_eq(FrameCap.cap_for(59.94, true, 0, ""), 0)
	assert_eq(FrameCap.cap_for(60.0, true, 0, ""), 0)
	assert_eq(FrameCap.cap_for(61.0, true, 0, ""), 0)


func test_vsync_off_the_flag_and_an_explicit_cap_are_kept() -> void:
	assert_eq(FrameCap.cap_for(144.0, false, 0, ""), 0)
	assert_eq(FrameCap.cap_for(144.0, true, 0, "off"), 0)
	assert_eq(FrameCap.cap_for(144.0, true, 90, ""), 90)
	assert_eq(FrameCap.cap_for(144.0, true, 30, "off"), 30)


func test_headless_apply_leaves_the_limiter_alone() -> void:
	var before: int = Engine.max_fps
	FrameCap.apply("")
	assert_eq(Engine.max_fps, before)


func test_the_pacing_option_caps_a_tick_rate_display_only_when_steady() -> void:
	assert_eq(FrameCap.pacing_cap(0, false), 0, "efficient: no limiter at 60 Hz")
	assert_eq(FrameCap.pacing_cap(0, true), SimClock.TICK_RATE, "steady: the limiter on top")
	assert_eq(FrameCap.pacing_cap(60, false), 60, "a fast display keeps its tick-rate cap")
	assert_eq(FrameCap.pacing_cap(90, true), 90, "an explicit cap wins")


func test_headless_pacing_leaves_the_limiter_alone() -> void:
	var before: int = Engine.max_fps
	FrameCap.apply("")
	FrameCap.apply_pacing(true)
	assert_eq(Engine.max_fps, before)
