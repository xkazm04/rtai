extends GutTest


func test_line_and_charge_include_the_lane_edges_but_not_past_the_flat_ends() -> void:
	var origin: Vector2 = Vector2(10.0, -7.0)
	for shape: BossAttack.Shape in [BossAttack.Shape.LINE, BossAttack.Shape.CHARGE]:
		var attack: BossAttack = _attack(shape)
		for along: float in [0.0, 4.0, 8.0]:
			for side: float in [-3.0, 0.0, 3.0]:
				assert_true(
					BossZone.hits(attack, origin, Vector2.UP, origin + Vector2(side, -along), 1.0),
					"shape %s includes along=%s, side=%s" % [shape, along, side]
				)
		for offset: Vector2 in [
			Vector2(0.0, 0.01), Vector2(0.0, -8.01), Vector2(-3.01, -4.0), Vector2(3.01, -4.0)
		]:
			assert_false(
				BossZone.hits(attack, origin, Vector2.UP, origin + offset, 1.0),
				"shape %s excludes offset %s even with a target radius" % [shape, offset]
			)


func test_lane_uses_half_the_width_and_adds_the_target_radius() -> void:
	for shape: BossAttack.Shape in [BossAttack.Shape.LINE, BossAttack.Shape.CHARGE]:
		var attack: BossAttack = _attack(shape)
		assert_true(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2(4, 2), 0.0))
		assert_false(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2(4, 2.01), 0.0))
		assert_false(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2(4, -2.01), 0.0))
		assert_true(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2(4, 2.5), 1.0))


func test_zero_length_and_width_lane_only_hits_its_origin_for_a_point_target() -> void:
	var attack: BossAttack = _attack(BossAttack.Shape.LINE)
	attack.range_m = 0.0
	attack.width_m = 0.0
	assert_true(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2.ZERO, 0.0))
	for point: Vector2 in [Vector2(-0.01, 0), Vector2(0.01, 0), Vector2(0, 0.01)]:
		assert_false(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, point, 0.0))


func test_circle_includes_radius_plus_target_radius_in_every_direction() -> void:
	var attack: BossAttack = _attack(BossAttack.Shape.CIRCLE)
	var origin: Vector2 = Vector2(-12.0, 9.0)
	for offset: Vector2 in [Vector2(5, 0), Vector2(-5, 0), Vector2(0, 5), Vector2(3, -4)]:
		assert_true(BossZone.hits(attack, origin, Vector2.LEFT, origin + offset, 1.0))
		assert_false(BossZone.hits(attack, origin, Vector2.LEFT, origin + offset * 1.002, 1.0))
	assert_true(BossZone.hits(attack, origin, Vector2.ZERO, origin, 0.0))
	assert_true(BossZone.hits(attack, origin, Vector2.ZERO, origin + Vector2(4, 0), 0.0))
	assert_false(BossZone.hits(attack, origin, Vector2.ZERO, origin + Vector2(4.01, 0), 0.0))
	attack.radius_m = 0.0
	assert_true(BossZone.hits(attack, origin, Vector2.RIGHT, origin, 0.0))
	assert_false(BossZone.hits(attack, origin, Vector2.RIGHT, origin + Vector2(0.01, 0), 0.0))


func test_cone_range_includes_target_radius_but_rejects_just_beyond_it() -> void:
	var attack: BossAttack = _attack(BossAttack.Shape.CONE)
	var origin: Vector2 = Vector2(3.0, 11.0)
	assert_true(BossZone.hits(attack, origin, Vector2.DOWN, origin + Vector2(0, 9), 1.0))
	assert_false(BossZone.hits(attack, origin, Vector2.DOWN, origin + Vector2(0, 9.01), 1.0))
	assert_true(BossZone.hits(attack, origin, Vector2.DOWN, origin + Vector2(0, 8), 0.0))
	assert_false(BossZone.hits(attack, origin, Vector2.DOWN, origin + Vector2(0, 8.01), 0.0))


func test_a_point_exactly_on_a_cone_edge_is_inside() -> void:
	var attack: BossAttack = _attack(BossAttack.Shape.CONE)
	attack.arc_deg = 180.0
	for side: float in [-1.0, 1.0]:
		var edge: Vector2 = Vector2(0, side * 4.0)
		assert_true(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, edge, 0.0), "on the edge")
		var past: Vector2 = Vector2(-0.01, side * 4.0)
		assert_false(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, past, 0.0), "past it")


func test_cone_uses_half_the_arc_on_both_sides_of_the_aim() -> void:
	var attack: BossAttack = _attack(BossAttack.Shape.CONE)
	attack.arc_deg = 60.0
	for degrees: float in [-29.9, 29.9, -30.1, 30.1]:
		var point: Vector2 = Vector2.from_angle(deg_to_rad(degrees)) * 4.0
		assert_eq(
			BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, point, 0.0),
			absf(degrees) < 30.0,
			"arc_deg is the full cone angle: %s degrees" % degrees
		)


func test_cone_expands_each_angular_edge_by_the_body_grazing_angle() -> void:
	var attack: BossAttack = _attack(BossAttack.Shape.CONE)
	attack.arc_deg = 60.0
	# At distance 2 with radius 1, the body adds 30 degrees to the 30-degree half arc.
	for degrees: float in [-59.9, 59.9, -60.1, 60.1]:
		var point: Vector2 = Vector2.from_angle(deg_to_rad(degrees)) * 2.0
		assert_eq(
			BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, point, 1.0),
			absf(degrees) < 60.0,
			"a body grazing either side is hit: %s degrees" % degrees
		)
	assert_false(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2(1, 1), 0.0))
	assert_true(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2(1, 1), 0.5))


func test_cone_hits_a_body_covering_the_origin_even_behind_the_aim() -> void:
	var attack: BossAttack = _attack(BossAttack.Shape.CONE)
	attack.arc_deg = 0.0
	assert_true(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2.ZERO, 0.0))
	assert_true(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2(-1, 0), 2.0))
	assert_true(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2(-2, 0), 2.0))
	assert_false(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2(-2.01, 0), 2.0))
	assert_true(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2(4, 0), 0.0))
	assert_false(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2(4, 0.01), 0.0))


func test_charge_body_contact_adds_both_radii_and_half_the_attack_width() -> void:
	var attack: BossAttack = _attack(BossAttack.Shape.CHARGE)
	var body_at: Vector2 = Vector2(17.0, -8.0)
	# 2 m body + half the 4 m width + 1 m target = 5 m contact radius.
	for offset: Vector2 in [Vector2(5, 0), Vector2(-5, 0), Vector2(0, -5), Vector2(3, 4)]:
		assert_true(BossZone.body_hits(body_at, 2.0, attack, body_at + offset, 1.0))
		assert_false(BossZone.body_hits(body_at, 2.0, attack, body_at + offset * 1.002, 1.0))
	assert_true(BossZone.body_hits(body_at, 0.0, attack, body_at + Vector2(2, 0), 0.0))
	assert_false(BossZone.body_hits(body_at, 0.0, attack, body_at + Vector2(2.01, 0), 0.0))


func test_charge_body_contact_is_local_to_current_body_not_the_full_attack_lane() -> void:
	var attack: BossAttack = _attack(BossAttack.Shape.CHARGE)
	var point: Vector2 = Vector2(7.0, 0.0)
	assert_true(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, point, 0.0))
	assert_false(BossZone.body_hits(Vector2.ZERO, 1.0, attack, point, 0.0))
	attack.range_m = 0.0
	assert_true(BossZone.body_hits(point, 1.0, attack, point, 0.0))
	attack.width_m = 0.0
	assert_true(BossZone.body_hits(point, 0.0, attack, point, 0.0))
	assert_false(BossZone.body_hits(point, 0.0, attack, point + Vector2(0.01, 0), 0.0))


func test_no_shape_never_hits_even_at_the_origin_or_with_a_large_target() -> void:
	var attack: BossAttack = _attack(BossAttack.Shape.NONE)
	assert_false(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2.ZERO, 0.0))
	assert_false(BossZone.hits(attack, Vector2.ZERO, Vector2.RIGHT, Vector2(1, 0), 100.0))


func _attack(shape: BossAttack.Shape) -> BossAttack:
	var attack: BossAttack = BossAttack.new()
	attack.shape = shape
	attack.range_m = 8.0
	attack.width_m = 4.0
	attack.radius_m = 4.0
	attack.arc_deg = 60.0
	return attack
