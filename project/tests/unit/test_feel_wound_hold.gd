extends GutTest
## Lane n7-ranged it21: a light kill's stop starts hold_delay_ticks after the hit (hit_feel.json),
## so the frozen frame shows the wound; a heavy stop still starts on the hit tick, and a zero delay
## is the timing before (--wound-hold=off).


func _cam(clock: SimClock) -> FeelCam:
	return FeelCam.attach(null, clock, HitFeel.shipped())


func test_a_light_kill_holds_two_ticks_after_the_hit() -> void:
	var clock: SimClock = SimClock.new()
	var cam: FeelCam = _cam(clock)
	var ticks: int = cam.hit(&"pistol", &"light", Vector2.RIGHT, true, 1000)
	assert_gt(ticks, 0, "a light kill takes the kill stop")
	assert_eq(clock.held(), 0.0, "nothing held on the hit tick")
	@warning_ignore("return_value_discarded")
	cam.offset_px(1001, 1.0)
	assert_eq(clock.held(), 0.0, "nor one tick on")
	@warning_ignore("return_value_discarded")
	cam.offset_px(1002, 1.0)
	assert_almost_eq(clock.held(), ticks * SimClock.TICK_DT, 1e-6, "the stop starts 2 ticks on")
	assert_eq(cam.held_ticks, ticks, "held once")
	@warning_ignore("return_value_discarded")
	cam.offset_px(1003, 1.0)
	assert_eq(cam.held_ticks, ticks, "and not again")


func test_a_heavy_stop_still_starts_on_the_hit_tick() -> void:
	var clock: SimClock = SimClock.new()
	var cam: FeelCam = _cam(clock)
	var ticks: int = cam.hit(&"hand_cannon", &"heavy", Vector2.RIGHT, true, 500)
	assert_gt(ticks, 0)
	assert_almost_eq(
		clock.held(), ticks * SimClock.TICK_DT, 1e-6, "melee and heavy classes unchanged"
	)


func test_a_zero_delay_is_the_before() -> void:
	var clock: SimClock = SimClock.new()
	var cam: FeelCam = _cam(clock)
	var row: Dictionary = cam.feel._rows[&"light"]
	row["hold_delay"] = 0
	var ticks: int = cam.hit(&"pistol", &"light", Vector2.RIGHT, true, 1000)
	assert_almost_eq(clock.held(), ticks * SimClock.TICK_DT, 1e-6, "held on the hit tick")
