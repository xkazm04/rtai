extends GutTest


func _trigger(id: StringName) -> Trigger:
	return Trigger.new(WeaponTable.shipped().weapon(id))


func test_line_stops_at_range_and_flags_out_of_reach() -> void:
	var t: Trigger = _trigger(&"flamethrower")
	var r: AimReadout = AimReadout.of(t, Vector2.ZERO, Vector2(40, 0))
	assert_false(r.in_range)
	assert_almost_eq(r.line_to.x, t.spec.range_m, 0.001)
	var near: AimReadout = AimReadout.of(t, Vector2.ZERO, Vector2(2, 0))
	assert_true(near.in_range)
	assert_almost_eq(near.line_to.x, 2.0, 0.001)


func test_reticle_opens_with_bloom() -> void:
	var t: Trigger = _trigger(&"machine_pistol")
	var before: float = AimReadout.of(t, Vector2.ZERO, Vector2(10, 0)).reticle_radius_m
	for i: int in 5:
		t.add_bloom()
	var after: float = AimReadout.of(t, Vector2.ZERO, Vector2(10, 0)).reticle_radius_m
	assert_gt(after, before * 1.5, "five shots of bloom widen the ring")
