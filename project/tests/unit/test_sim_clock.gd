extends GutTest
## SIM-01: fixed 60 Hz steps from any frame pacing, at most 4 catch-up steps, one clamped delta.


func test_one_tick_per_60hz_frame() -> void:
	var clock: SimClock = SimClock.new()
	var steps: int = 0
	for i: int in 60:
		steps += clock.advance(SimClock.TICK_DT)
	assert_eq(steps, 60)


func test_fast_frames_accumulate() -> void:
	var clock: SimClock = SimClock.new()
	assert_eq(clock.advance(SimClock.TICK_DT / 2.0), 0)
	assert_eq(clock.advance(SimClock.TICK_DT / 2.0), 1)
	assert_almost_eq(clock.alpha(), 0.0, 1e-6)


func test_catch_up_is_capped_and_the_delta_clamped() -> void:
	var clock: SimClock = SimClock.new()
	assert_eq(clock.advance(0.5), SimClock.MAX_STEPS_PER_FRAME)
	assert_almost_eq(clock.frame_delta(), SimClock.MAX_FRAME_DELTA, 1e-9)
	assert_almost_eq(clock.dropped_seconds(), 0.5 - SimClock.MAX_FRAME_DELTA, 1e-9)
	assert_eq(clock.advance(-1.0), 0, "a negative delta is clamped to zero")


func test_total_ticks_follow_total_time_not_frame_count() -> void:
	var clock: SimClock = SimClock.new()
	var steps: int = 0
	for dt: float in [0.004, 0.03, 0.016, 0.05, 0.0, 0.0333]:
		steps += clock.advance(dt)
	assert_eq(steps, floori((0.004 + 0.03 + 0.016 + 0.05 + 0.0333) / SimClock.TICK_DT))


func test_tick_advances_only_on_complete() -> void:
	var clock: SimClock = SimClock.new()
	assert_eq(clock.advance(SimClock.TICK_DT), 1)
	assert_eq(clock.tick(), 0)
	clock.complete_tick()
	assert_eq(clock.tick(), 1)
	clock.reset()
	assert_eq(clock.tick(), 0)
