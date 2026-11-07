extends GutTest


func test_a_minimized_window_is_capped_at_the_tick_rate() -> void:
	assert_eq(MinimizedCap.cap_when_minimized(0, ""), SimClock.TICK_RATE)
	assert_eq(MinimizedCap.cap_when_minimized(144, ""), SimClock.TICK_RATE)


func test_a_lower_cap_and_the_flag_are_kept() -> void:
	assert_eq(MinimizedCap.cap_when_minimized(30, ""), 30)
	assert_eq(MinimizedCap.cap_when_minimized(SimClock.TICK_RATE, ""), SimClock.TICK_RATE)
	assert_eq(MinimizedCap.cap_when_minimized(0, "off"), 0)
	assert_eq(MinimizedCap.cap_when_minimized(144, "off"), 144)


func test_headless_never_processes_or_touches_the_limiter() -> void:
	var before: int = Engine.max_fps
	var cap: MinimizedCap = MinimizedCap.new("")
	add_child_autofree(cap)
	assert_false(cap.is_processing())
	assert_eq(Engine.max_fps, before)


func test_low_processor_mode_while_minimized_unless_off_or_spin() -> void:
	assert_true(MinimizedCap.low_when_minimized(""))
	assert_false(MinimizedCap.low_when_minimized("off"))
	assert_false(MinimizedCap.low_when_minimized("spin"))
