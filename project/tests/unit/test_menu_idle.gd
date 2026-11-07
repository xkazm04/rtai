extends GutTest


func test_the_title_is_idle_and_play_is_not() -> void:
	assert_true(MenuIdle.wants_idle(false, false, ""), "the title")
	assert_false(MenuIdle.wants_idle(true, false, ""), "in play")


func test_the_pause_card_follows_paused_idle() -> void:
	assert_eq(MenuIdle.wants_idle(true, true, ""), MenuIdle.PAUSED_IDLE)


func test_the_off_flag_is_the_before() -> void:
	assert_false(MenuIdle.wants_idle(false, false, "off"))
	assert_false(MenuIdle.wants_idle(true, true, "off"))


func test_idle_caps_at_the_tick_unless_lower_or_the_lowproc_arm() -> void:
	assert_eq(MenuIdle.cap_when_idle(0, ""), SimClock.TICK_RATE)
	assert_eq(MenuIdle.cap_when_idle(144, ""), SimClock.TICK_RATE)
	assert_eq(MenuIdle.cap_when_idle(30, ""), 30)
	assert_eq(MenuIdle.cap_when_idle(0, "lowproc"), 0)


func test_headless_never_processes_or_touches_the_engine() -> void:
	var before_fps: int = Engine.max_fps
	var before_low: bool = OS.low_processor_usage_mode
	var idle: MenuIdle = MenuIdle.new("")
	add_child_autofree(idle)
	assert_false(idle.is_processing())
	assert_eq(Engine.max_fps, before_fps)
	assert_eq(OS.low_processor_usage_mode, before_low)
