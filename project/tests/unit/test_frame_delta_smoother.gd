extends GutTest

const HZ60: float = 1.0 / 60.0


func _ticks(deltas: Array[float], smoother: FrameDeltaSmoother) -> Array[int]:
	var clock: SimClock = SimClock.new()
	var out: Array[int] = []
	for d: float in deltas:
		out.append(clock.advance(smoother.smooth(d) if smoother != null else d))
	return out


func _jittered() -> Array[float]:
	# frames averaging 1/60 s, 5 ms early / late in turn (mailbox on a loaded machine)
	var out: Array[float] = []
	for i: int in 120:
		out.append(HZ60 + (-0.005 if i % 2 == 0 else 0.005))
	return out


func test_jittered_frames_step_one_tick_each() -> void:
	var ticks: Array[int] = _ticks(_jittered(), FrameDeltaSmoother.new(HZ60))
	assert_eq(ticks.count(1), ticks.size(), "every frame steps exactly one tick")


func test_raw_jittered_frames_skip_ticks() -> void:
	# the before: the raw deltas give 0- and 2-tick frames (the mailbox no-tick frames)
	var ticks: Array[int] = _ticks(_jittered(), null)
	assert_gt(ticks.count(0) + ticks.count(2), 0)


func test_off_passes_raw() -> void:
	var s: FrameDeltaSmoother = FrameDeltaSmoother.new(0.0)
	assert_false(s.active())
	assert_eq(s.smooth(0.0213), 0.0213)


func test_a_hitch_passes_raw_and_resets() -> void:
	var s: FrameDeltaSmoother = FrameDeltaSmoother.new(HZ60)
	assert_almost_eq(s.smooth(HZ60 * 2.5), HZ60 * 2.5, 1e-9, "half an interval off: raw")
	assert_eq(s.smooth(2.0), 2.0, "a resume: raw")
	assert_almost_eq(s.smooth(HZ60 * 1.1), HZ60, 1e-9)


func test_a_dropped_vblank_keeps_two_intervals() -> void:
	var s: FrameDeltaSmoother = FrameDeltaSmoother.new(HZ60)
	assert_almost_eq(s.smooth(HZ60 * 2.05), HZ60 * 2.0, 1e-9)


func test_carry_keeps_the_long_run_time() -> void:
	var s: FrameDeltaSmoother = FrameDeltaSmoother.new(HZ60)
	var raw: float = 0.0
	var smoothed: float = 0.0
	for d: float in _jittered():
		raw += d
		smoothed += s.smooth(d)
	assert_almost_eq(smoothed, raw, HZ60, "within one interval of wall time")
