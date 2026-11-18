extends GutTest


func test_tonnage_p70_drawn_steps_measure_both_sides_of_each_redrawn_frame() -> void:
	var steps: PackedFloat32Array = PackedFloat32Array(GhostStride.TABLES["tonnage/p70"])
	# Column 2 carries one pad. Column 6 lands the front pad while the rear is still down.
	assert_eq(steps[1], 124.5 - 99.5)
	assert_eq(steps[2], 99.5 - 79.5)
	assert_eq(steps[5], 62.0 - 17.5)
	assert_eq(steps[6], 144.0 - 140.0)


func test_cap_preserves_cycle_total_and_uncapped_step_ratios() -> void:
	# 100 / 5 = 20. Capping 60 at 30 pushes 25 over the cap too.
	var steps: PackedFloat32Array = [5.0, 60.0, 0.0, 25.0, 10.0]
	var capped: PackedFloat32Array = GhostStride.capped_steps(steps, 1.5)
	var total: float = 0.0
	for step: float in capped:
		total += step
		assert_lte(step, 30.0)
	assert_almost_eq(total, 100.0, 0.00001)
	assert_eq(capped[1], 30.0)
	assert_eq(capped[3], 30.0)
	assert_eq(capped[2], 0.0)
	assert_almost_eq(capped[4], 2.0 * capped[0], 0.00001)
	assert_eq(steps[1], 60.0, "input contacts stay available")


func test_cap_off_and_loose_cap_reproduce_the_input() -> void:
	var steps: PackedFloat32Array = [5.0, 0.0, 25.0]
	for share: float in [0.0, INF, 4.0]:
		assert_eq(GhostStride.capped_steps(steps, share), steps)
	assert_eq(GhostStride.capped_steps(PackedFloat32Array(), 1.0), PackedFloat32Array())


func test_even_cap_and_redistribution_to_zero_weight_frames() -> void:
	var steps: PackedFloat32Array = [0.0, 12.0, 0.0]
	assert_eq(GhostStride.capped_steps(steps, 1.0), PackedFloat32Array([4.0, 4.0, 4.0]))
	assert_eq(GhostStride.capped_steps(steps, 1.5), PackedFloat32Array([3.0, 6.0, 3.0]))


func test_fractional_steps_keep_their_proportions_at_any_scale() -> void:
	var steps: PackedFloat32Array = [0.125, 0.375, 2.5]
	assert_eq(GhostStride.capped_steps(steps, 2.0), PackedFloat32Array([0.25, 0.75, 2.0]))
	# The tightest feasible cap is the mean.
	assert_eq(GhostStride.capped_steps(steps, 0.5), PackedFloat32Array([1.0, 1.0, 1.0]))


func test_shipped_walk_timing_uses_the_filmed_cap_for_each_pitch() -> void:
	assert_eq(GhostStride.MAX_STEP_SHARE["tonnage/p70"], 2.0)
	assert_eq(GhostStride.MAX_STEP_SHARE["tonnage/p55"], 0.0)
	var p70: PackedFloat32Array = PackedFloat32Array(GhostStride.TABLES["tonnage/p70"])
	assert_eq(GhostStride.table_of("tonnage", "p70"), GhostStride.capped_steps(p70, 2.0))
	var p55: PackedFloat32Array = PackedFloat32Array(GhostStride.TABLES["tonnage/p55"])
	assert_eq(GhostStride.table_of("tonnage", "p55"), p55)
	var ohm: PackedFloat32Array = PackedFloat32Array(GhostStride.TABLES["ohm/p70"])
	assert_eq(GhostStride.table_of("ohm", "p70"), ohm)
