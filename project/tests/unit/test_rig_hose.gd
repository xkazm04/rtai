extends GutTest
## Texture-free hose fixtures: world-space rope physics and rig-local drawing are separate.

var _rig: CutRig


func before_each() -> void:
	_rig = autofree(CutRig.new())
	_rig.plan = BodyPlan.new()
	_rig.plan.hose_n = 5
	_rig.plan.hose_from = Vector2(2, 3)
	_rig.plan.hose_along = 0.4
	_rig.plan.fore_len = PackedFloat32Array([91.0, 20.0])
	_rig.plan.hose_bulge = 20.0
	_rig.torso = Node2D.new()
	_rig.add_child(_rig.torso)
	_rig.sides[BodyPlan.R].fore = Sprite2D.new()
	_rig.add_child(_rig.sides[BodyPlan.R].fore)
	_rig.hose = Line2D.new()
	_rig.add_child(_rig.hose)


func _near(actual: Vector2, expected: Vector2, why: String) -> void:
	assert_almost_eq(actual.x, expected.x, 0.0001, why + " x")
	assert_almost_eq(actual.y, expected.y, 0.0001, why + " y")


func _seed(points: PackedVector2Array) -> void:
	_rig.plan.hose_n = points.size()
	_rig.hose_pts = points.duplicate()
	_rig.hose_prev = points.duplicate()


func test_initialization_and_resizing_build_straight_rope_without_stale_motion() -> void:
	for count: int in [5, 7, 3]:
		_rig.plan.hose_n = count
		RigHose.step(_rig, 0.0)
		assert_eq(_rig.hose_pts.size(), count)
		assert_eq(_rig.hose_prev.size(), count)
		for i: int in count:
			var expected: Vector2 = Vector2(2, 3).lerp(Vector2(8, 0), float(i) / (count - 1))
			_near(_rig.hose_pts[i], expected, "resizing discards the old rope")
			_near(_rig.hose_prev[i], expected, "resizing discards old momentum")
		_rig.hose_pts.fill(Vector2(100, 100))
		_rig.hose_prev.fill(Vector2(-100, -100))


func test_anchors_follow_transformed_torso_and_right_forearm_and_draw_locally() -> void:
	_rig.position = Vector2(40, -20)
	_rig.rotation = 0.7
	_rig.scale = Vector2(1.3, 0.8)
	_rig.torso.position = Vector2(-4, 6)
	_rig.torso.rotation = -0.3
	var fore: Sprite2D = _rig.sides[BodyPlan.R].fore
	fore.position = Vector2(7, 9)
	fore.rotation = 1.1
	fore.scale = Vector2(0.7, 1.2)
	RigHose.step(_rig, 0.1)
	fore.position += Vector2(3, -2)
	_rig.torso.position += Vector2(-2, 1)
	RigHose.step(_rig, 0.1)
	_near(_rig.hose_pts[0], _rig.torso.to_global(Vector2(2, 3)), "back plate stays pinned")
	_near(_rig.hose_pts[4], fore.to_global(Vector2(8, 0)), "torch stays pinned")
	assert_eq(_rig.hose.points.size(), _rig.plan.hose_n)
	for i: int in _rig.plan.hose_n:
		_near(_rig.to_global(_rig.hose.points[i]), _rig.hose_pts[i], "line uses rig local space")


func test_existing_rope_keeps_damped_inertia_and_records_pre_step_positions() -> void:
	_rig.plan.hose_from = Vector2.ZERO
	_rig.plan.fore_len[BodyPlan.R] = 0.0
	_seed(PackedVector2Array([Vector2.ZERO, Vector2(1, 2), Vector2.ZERO]))
	_rig.hose_prev[1] = Vector2(-1, 1)
	RigHose.step(_rig, 0.0)
	_near(_rig.hose_prev[1], Vector2(1, 2), "history is the position before integration")
	var movement: Vector2 = _rig.hose_pts[1] - Vector2(1, 2)
	assert_gt(movement.length(), 0.0, "momentum survives even with no rest attraction")
	assert_lt(movement.length(), Vector2(2, 1).length(), "inertia is damped")
	_near(movement.normalized(), Vector2(2, 1).normalized(), "inertia keeps its direction")
	RigHose.step(_rig, 0.0)
	var next_movement: Vector2 = _rig.hose_pts[1] - _rig.hose_prev[1]
	assert_gt(next_movement.length(), 0.0)
	assert_lt(next_movement.length(), movement.length(), "momentum decays on later steps")


func test_rest_shape_bulges_sideways_trails_backwards_and_rotates_with_facing() -> void:
	_rig.plan.hose_from = Vector2.ZERO
	_rig.plan.fore_len[BodyPlan.R] = 0.0
	for angle: float in [0.0, PI / 2.0, PI]:
		_rig.facing = angle
		_seed(PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]))
		RigHose.step(_rig, 0.1)
		var local_mid: Vector2 = _rig.hose_pts[1].rotated(-angle)
		assert_lt(local_mid.x, 0.0, "hose trails behind the facing")
		assert_gt(local_mid.y, 0.0, "hose bulges towards the character's right")
		assert_lt(local_mid.y, _rig.plan.hose_bulge * CutRig.SC, "rest attraction is gradual")
		_near(_rig.hose_pts[0], Vector2.ZERO, "back anchor")
		_near(_rig.hose_pts[2], Vector2.ZERO, "torch anchor")


func test_bulge_is_scaled_by_plan_and_tapers_towards_both_anchors() -> void:
	_rig.plan.hose_from = Vector2.ZERO
	_rig.plan.fore_len[BodyPlan.R] = 0.0
	RigHose.step(_rig, 0.01)
	var first: PackedVector2Array = _rig.hose_pts.duplicate()
	assert_gt(first[2].y, first[1].y, "bulge peaks halfway along the hose")
	assert_gt(first[1].y, 0.0)
	_near(first[1], first[3], "rest shape is symmetric along its length")
	_rig.hose_pts.clear()
	_rig.plan.hose_bulge *= 2.0
	RigHose.step(_rig, 0.01)
	assert_almost_eq(_rig.hose_pts[2].y, first[2].y * 2.0, 0.0001)
	assert_almost_eq(_rig.hose_pts[2].x, first[2].x, 0.0001, "bulge does not alter trailing")


func test_larger_time_step_attracts_more_without_overshooting_rest_shape() -> void:
	_rig.plan.hose_from = Vector2.ZERO
	_rig.plan.fore_len[BodyPlan.R] = 0.0
	RigHose.step(_rig, 0.01)
	var short_step: Vector2 = _rig.hose_pts[2]
	_rig.hose_pts.clear()
	RigHose.step(_rig, 0.02)
	var long_step: Vector2 = _rig.hose_pts[2]
	assert_gt(long_step.length(), short_step.length())
	assert_lt(long_step.length(), short_step.length() * 2.0, "exponential attraction eases off")
	_near(long_step.normalized(), short_step.normalized(), "time changes speed, not rest direction")


func test_slack_and_exact_length_segments_are_not_pushed_apart() -> void:
	for length: float in [0.0, 4.0, 10.0]:
		var points: PackedVector2Array = PackedVector2Array(
			[Vector2.ZERO, Vector2(length, 0), Vector2(length * 2.0, 0)]
		)
		_seed(points)
		RigHose._constrain(_rig, 3, 10.0)
		assert_eq(_rig.hose_pts, points, "constraint only shortens stretched links")


func test_stretched_anchor_links_shorten_without_moving_either_attachment() -> void:
	_seed(PackedVector2Array([Vector2.ZERO, Vector2(20, 30), Vector2(40, 0)]))
	var before: Vector2 = _rig.hose_pts[1]
	RigHose._constrain(_rig, 3, 25.0)
	_near(_rig.hose_pts[0], Vector2.ZERO, "first point stays attached")
	_near(_rig.hose_pts[2], Vector2(40, 0), "last point stays attached")
	assert_lt(_rig.hose_pts[1].distance_to(Vector2.ZERO), before.length())
	assert_lt(_rig.hose_pts[1].distance_to(Vector2(40, 0)), before.distance_to(Vector2(40, 0)))
	assert_eq(_rig.hose_prev[1], before, "constraint does not overwrite integration history")


func test_stretched_internal_link_moves_both_free_points_towards_each_other() -> void:
	_seed(PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2(30, 0), Vector2(30, 0)]))
	RigHose._constrain(_rig, 4, 10.0)
	_near(_rig.hose_pts[1], Vector2(10, 0), "first free point shares correction")
	_near(_rig.hose_pts[2], Vector2(20, 0), "second free point shares correction")
	_near(_rig.hose_pts[0], Vector2.ZERO, "back attachment is unchanged")
	_near(_rig.hose_pts[3], Vector2(30, 0), "torch attachment is unchanged")


func test_step_uses_attachment_distance_plus_slack_as_rope_length_budget() -> void:
	_rig.plan.hose_from = Vector2.ZERO
	_rig.plan.fore_len[BodyPlan.R] = 0.0
	var budget: float = RigHose.SLACK_PX / 2.0
	_seed(PackedVector2Array([Vector2.ZERO, Vector2(budget, 0), Vector2.ZERO]))
	RigHose.step(_rig, 0.0)
	_near(_rig.hose_pts[1], Vector2(budget, 0), "slack is available even with coincident anchors")
	_seed(PackedVector2Array([Vector2.ZERO, Vector2(budget * 2.0, 0), Vector2.ZERO]))
	RigHose.step(_rig, 0.0)
	assert_lt(_rig.hose_pts[1].x, budget * 2.0, "excess length is pulled in")
	assert_almost_eq(_rig.hose_pts[1].x, budget, budget * 0.01, "solver approaches length budget")


func test_separated_attachments_add_their_distance_to_the_slack_budget() -> void:
	_rig.plan.hose_from = Vector2.ZERO
	_rig.plan.fore_len[BodyPlan.R] = 0.0
	_rig.sides[BodyPlan.R].fore.position = Vector2(20, 0)
	var budget: float = (20.0 + RigHose.SLACK_PX) / 2.0
	var middle: Vector2 = Vector2(10, budget * 0.7)
	_seed(PackedVector2Array([Vector2.ZERO, middle, Vector2(20, 0)]))
	RigHose.step(_rig, 0.0)
	_near(_rig.hose_pts[1], middle, "attachment distance allows a longer slack rope")
	_seed(PackedVector2Array([Vector2.ZERO, Vector2(10, budget * 2.0), Vector2(20, 0)]))
	RigHose.step(_rig, 0.0)
	assert_almost_eq(_rig.hose_pts[1].distance_to(Vector2.ZERO), budget, budget * 0.02)
	assert_almost_eq(_rig.hose_pts[1].distance_to(Vector2(20, 0)), budget, budget * 0.02)


func test_two_point_hose_has_only_attachments_and_no_free_particles() -> void:
	_rig.plan.hose_n = 2
	RigHose.step(_rig, 0.1)
	assert_eq(_rig.hose_pts.size(), 2)
	assert_eq(_rig.hose_prev.size(), 2)
	_near(_rig.hose_pts[0], Vector2(2, 3), "back attachment")
	_near(_rig.hose_pts[1], Vector2(8, 0), "torch attachment")
	assert_eq(_rig.hose.points, _rig.hose_pts, "identity rig draws the attachment segment")
