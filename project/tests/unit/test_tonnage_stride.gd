extends GutTest


func test_tonnage_p70_redrawn_contacts_time_both_sides_of_each_frame() -> void:
	var steps: PackedFloat32Array = GhostStride.table_of("tonnage", "p70")
	# Column 2 carries one pad. Column 6 lands the front pad while the rear is still down.
	assert_eq(steps[1], 124.5 - 99.5)
	assert_eq(steps[2], 99.5 - 79.5)
	assert_eq(steps[5], 62.0 - 17.5)
	assert_eq(steps[6], 144.0 - 140.0)
