extends GutTest
## n15 combat (DEFECTS: a baton swing drew a flat white hexagon ring round Rivet): the smear's
## kept angles are unwrapped and the fan spans at most MeleeSmearView.MAX_SPAN back from the
## newest angle; `--melee-smear=n7` (the before) keeps the raw list.


func _fan(degs: Array[float]) -> MeleeSmearView:
	var v: MeleeSmearView = MeleeSmearView.new()
	add_child_autofree(v)
	v._n7 = 0
	for d: float in degs:
		v.feed(Vector2.ZERO, deg_to_rad(d), 40.0, true)
	return v


func _span(fan: PackedFloat32Array) -> float:
	return absf(fan[-1] - fan[0])


func test_a_300_degree_sweep_draws_at_most_max_span() -> void:
	var fan: PackedFloat32Array = _fan([0.0, 100.0, 200.0, 300.0]).fan()
	assert_almost_eq(_span(fan), MeleeSmearView.MAX_SPAN, 0.001)
	assert_almost_eq(fan[-1], deg_to_rad(300.0), 0.001, "the newest angle leads")


func test_a_step_across_the_seam_takes_the_short_way() -> void:
	var fan: PackedFloat32Array = _fan([170.0, -170.0]).fan()
	assert_almost_eq(_span(fan), deg_to_rad(20.0), 0.001)


func test_a_short_cut_is_drawn_whole() -> void:
	var fan: PackedFloat32Array = _fan([0.0, 30.0, 60.0]).fan()
	assert_eq(fan.size(), 3)
	assert_almost_eq(_span(fan), deg_to_rad(60.0), 0.001)


func test_the_chords_are_fine_and_n7_keeps_the_raw_fan() -> void:
	var v: MeleeSmearView = _fan([0.0, 100.0, 200.0, 300.0])
	assert_gte(v._steps(0.0, deg_to_rad(100.0)), 16, "6 degree chords")
	v._n7 = 1
	assert_eq(v.fan().size(), 4, "n7: every kept angle")
	assert_eq(v._steps(0.0, deg_to_rad(100.0)), MeleeSmearView.STEPS)
