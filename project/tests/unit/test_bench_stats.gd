extends GutTest
## BenchStats computes the section 20 metrics the bench evidence reports.


func test_metrics_over_known_frames() -> void:
	var s: BenchStats = BenchStats.new()
	var zero: PackedInt64Array = PackedInt64Array([0, 0, 0, 1])
	for i: int in BenchStats.WARMUP_FRAMES:
		s.add(500.0, zero, true, Vector2i(1, 1))
	for i: int in 200:
		var ms: float = 40.0 if i == 100 else 2.0
		s.add(ms, zero, i == 98, Vector2i(400, 50))
	var m: Dictionary[String, float] = s.metrics()
	assert_eq(m["framesMeasured"], 200.0, "warm-up excluded")
	assert_eq(m["worstFrameMs"], 40.0)
	assert_eq(m["worstSwapMs"], 40.0, "frame 100 is inside the window opened at 98")
	assert_almost_eq(m["low1Fps"], 1000.0 / 21.0, 0.01, "worst 1% = 2 frames: (40 + 2) / 2")
	assert_eq(m["p99CpuMs"], 2.0, "one slow frame in 200 is above p99")
	assert_eq(m["visibleMax"], 50.0)


func test_a_swap_window_closes_after_three_frames() -> void:
	var s: BenchStats = BenchStats.new()
	var zero: PackedInt64Array = PackedInt64Array([0, 0, 0, 1])
	for i: int in BenchStats.WARMUP_FRAMES + 10:
		var k: int = i - BenchStats.WARMUP_FRAMES
		s.add(30.0 if k == 6 else 1.0, zero, k == 2, Vector2i())
	assert_eq(s.metrics()["worstSwapMs"], 1.0, "frame 6 is outside the window opened at 2")
