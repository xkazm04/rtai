extends GutTest


func test_median_orders_timeouts_after_kills_including_a_last_tick_kill() -> void:
	var limit: int = FoeTtkTrial.LIMIT
	var timeout: int = MoveTtkStats.order_tick(null)
	assert_eq(timeout, limit + 1)
	assert_eq(MoveTtkStats.order_tick(limit), limit)
	var odd: float = MoveTtkStats.kill_median_s([timeout, limit, 1.0])
	var even: float = MoveTtkStats.kill_median_s([timeout, 60.0, 120.0, 1.0])
	assert_eq(odd, 30.0)
	assert_eq(even, 1.5)
	assert_true(MoveTtkStats.kill_median_s([limit, timeout]) == null)
	assert_true(MoveTtkStats.kill_median_s([timeout]) == null)


func test_pairs_compare_each_seed_and_keep_unknown_differences_censored() -> void:
	assert_true(MoveTtkStats.delta_ticks(60, null) == null)
	assert_true(MoveTtkStats.delta_ticks(null, 60) == null)
	var delta: int = MoveTtkStats.delta_ticks(91, 16)
	assert_eq(delta, -75)
	var pairs: Array[Dictionary] = [_pair(60, 180), _pair(120, 60), _pair(240, 120)]
	var summary: Dictionary = MoveTtkStats.summarize(pairs, "on")
	assert_eq(
		summary,
		{
			"off_median_s": 2.0,
			"on_median_s": 2.0,
			"paired_median_delta_s": -1.0,
			"seeds_faster": 2,
			"off_total_uses": 0,
			"on_total_uses": 6,
			"off_median_damage": 2.0,
			"on_median_damage": 0.5,
		}
	)
	pairs.append(_pair(null, 30))
	pairs.append(_pair(null, null))
	summary = MoveTtkStats.summarize(pairs, "on")
	var faster: int = summary.seeds_faster
	assert_eq(faster, 3)
	assert_true(summary.paired_median_delta_s == null)


func _pair(off: Variant, on: Variant) -> Dictionary:
	return {
		"off": {"kill_tick": off, "damage_to_rivet": 2.0, "move_uses": 0},
		"on":
		{
			"kill_tick": on,
			"damage_to_rivet": 0.5,
			"move_uses": 2,
			"delta_ticks": MoveTtkStats.delta_ticks(off, on),
		}
	}
