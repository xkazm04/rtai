extends GutTest
## rivet-arsenal: a long gun or a tube rides beside Rivet's helmet, never across his face.


func _axis_dist(at: Vector2, rot: float, head: Vector2) -> float:
	return absf((at - head).dot(Vector2.from_angle(rot).orthogonal()))


func test_tube_over_the_head_is_moved_beside_it() -> void:
	var head: Vector2 = Vector2(0.0, 0.0)
	var at: Vector2 = Vector2(0.0, 6.0)  # the claw just in front, the barrel straight down
	var rot: float = PI * 0.5
	var shift: Vector2 = RivetCarryAngle.beside_head(at, rot, head, 10.0, 6.0)
	var clear: float = RivetCarryAngle.BESIDE * 16.0
	assert_almost_eq(_axis_dist(at + shift, rot, head), clear, 0.001)
	assert_almost_eq(shift.dot(Vector2.from_angle(rot)), 0.0, 0.001, "sideways only")


func test_keeps_the_side_the_gun_is_already_on() -> void:
	var shift: Vector2 = RivetCarryAngle.beside_head(
		Vector2(-3.0, 6.0), PI * 0.5, Vector2.ZERO, 10.0, 6.0
	)
	assert_lt(shift.x, 0.0)


func test_a_gun_already_clear_is_not_moved() -> void:
	var shift: Vector2 = RivetCarryAngle.beside_head(
		Vector2(30.0, 6.0), PI * 0.5, Vector2.ZERO, 10.0, 6.0
	)
	assert_eq(shift, Vector2.ZERO)


func test_the_planted_fault_would_be_caught() -> void:
	# The fault: no shift at all leaves the axis through the head's centre.
	assert_lt(_axis_dist(Vector2(0.0, 6.0), PI * 0.5, Vector2.ZERO), RivetCarryAngle.BESIDE * 16.0)


func _step(c: RivetCarryAngle, carry: bool) -> float:
	return c.step(carry, Vector2.RIGHT, Vector2(5.0, 3.0), Vector2.ZERO, 0.0)


func test_carry_eases_across_and_back() -> void:
	var c: RivetCarryAngle = RivetCarryAngle.new()
	var first: float = _step(c, true)
	var full: float = first
	for i: int in 12:
		full = _step(c, true)
	assert_lt(absf(first), absf(full), "eases in")
	assert_almost_eq(full, -RivetCarryAngle.ACROSS_RAD, 0.001, "barrel toward the off side")
	var back: float = full
	for i: int in 12:
		back = _step(c, false)
	assert_eq(back, 0.0, "aim: back on the line")


func test_only_long_guns_and_tubes() -> void:
	assert_true(RivetCarryAngle.applies(RigGrip.Kind.SHOULDER))
	assert_true(RivetCarryAngle.applies(RigGrip.Kind.TWO_HAND_LONG))
	assert_false(RivetCarryAngle.applies(RigGrip.Kind.ONE_HAND))
	assert_false(RivetCarryAngle.applies(RigGrip.Kind.THROWN))
