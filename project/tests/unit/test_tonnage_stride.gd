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


func test_tonnage_midpoints_only_draw_while_walking_in_right_profile() -> void:
	var saved: ViewMode = ViewMode.shared()
	ViewMode.select("combo")
	var rig: TonnageRig = autofree(TonnageRig.new())
	var host: Node2D = add_child_autofree(Node2D.new())
	var drawn: GhostDrawn = rig.drawn
	var mid: String = GhostDrawn.path_of("p70", "tonnage", "walk8_mid")
	var seen: Dictionary[int, bool] = {}
	for i: int in 160:
		host.position.x += 1.0
		assert_true(drawn.step(host, [], 32.0, 1.0, 0.0))
		if drawn._spr.texture.resource_path == mid:
			seen[drawn._spr.frame_coords.x] = true
			drawn._show_cell(drawn._walk, 4, drawn._col)
			assert_eq(
				drawn._spr.texture.resource_path, GhostDrawn.path_of("p70", "tonnage", "walk8_left")
			)
			drawn._show_cell(drawn._act, 0, GhostDrawn.HIT_COL)
			assert_eq(drawn._spr.texture.resource_path, GhostDrawn.path_of("p70", "tonnage", "act"))
	assert_eq(seen.size(), 10)
	drawn._phase = 0.33  # stopping during the C5-to-C6 window should show the standing key
	for i: int in GhostDrawn.STILL_FRAMES + 1:
		assert_true(drawn.step(host, [], 32.0, 1.0, 0.0))
	assert_eq(drawn._spr.texture.resource_path, GhostDrawn.path_of("p70", "tonnage"))
	assert_eq(drawn._spr.frame_coords, Vector2i(4, 2))
	ViewMode._shared = saved


func test_each_filmed_midpoint_enters_and_exits_at_its_two_neighbours() -> void:
	var expected: Array[Vector2] = [
		Vector2(0.41336418, 0.45897461),
		Vector2(0.02125453, 0.06408207),
		Vector2(0.10969352, 0.15529278),
		Vector2(0.20085933, 0.24645859),
		Vector2(0.32216594, 0.36776520),
		Vector2(0.55525040, 0.59146157),
		Vector2(0.62209652, 0.64704200),
		Vector2(0.67830032, 0.72363135),
		Vector2(0.76924733, 0.81484658),
		Vector2(0.86042561, 0.90602487),
	]
	var starts: Array[int] = [5, 0, 1, 2, 4, 8, 9, 10, 11, 12]
	var steps: PackedFloat32Array = GhostStride.table_of("tonnage", "p70")
	var path: String = GhostDrawn.path_of("p70", "tonnage")
	var mid: String = GhostDrawn.path_of("p70", "tonnage", "walk8_mid")
	var sheet: GhostSheet = GhostSheet.walk_of(path, steps)
	var spr: Sprite2D = autofree(Sprite2D.new())
	var windows: Array[Vector2] = GhostStride.tonnage_windows(steps)
	assert_eq(windows.size(), expected.size())
	for i: int in expected.size():
		assert_almost_eq(windows[i], expected[i], Vector2.ONE * 0.000001)
		var w: Vector2 = windows[i]
		for col: int in [starts[i], starts[i] + 1]:
			sheet.show(spr, 0, col, w.x - 0.000001)
			assert_eq(spr.texture.resource_path, path)
			sheet.show(spr, 0, col, w.x)
			assert_eq(spr.texture.resource_path, mid)
			assert_eq(spr.frame_coords, Vector2i(i, 2))
			sheet.show(spr, 0, col, w.y - 0.000001)
			assert_eq(spr.texture.resource_path, mid)
			sheet.show(spr, 0, col, w.y)
			assert_eq(spr.texture.resource_path, path)
		sheet.show(spr, 0, posmod(starts[i] - 1, 16), w.x)
		assert_eq(spr.texture.resource_path, path)


func test_eight_key_walks_keep_their_own_sheet() -> void:
	var steps: PackedFloat32Array = GhostStride.table_of("tonnage", "p55")
	var spr: Sprite2D = autofree(Sprite2D.new())
	for art: String in ["p55", "p70"]:
		var path: String = GhostDrawn.path_of(art, "tonnage")
		GhostSheet.walk_of(path, steps).show(spr, 0, 5, 0.42)
		assert_eq(spr.texture.resource_path, path)
