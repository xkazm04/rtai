extends GutTest
## RigTilt lifts parts in rig-local space. Use bare nodes so these tests need no art or pose step.

var _saved_view: ViewMode = null
var _saved_eye: Vector2 = Vector2.ZERO
var _parent: Node2D = null
var _rig: CutRig = null


func before_each() -> void:
	_saved_view = ViewMode._shared
	_saved_eye = ViewMode.eye
	ViewMode._shared = ViewMode.new()
	_parent = Node2D.new()
	add_child_autofree(_parent)
	_rig = CutRig.new()
	_parent.add_child(_rig)
	_rig.plan = BodyPlan.new()
	_rig.plan.hip_z = 80.0
	_rig.plan.torso_pos = Vector2(13.0, -7.0)
	_rig.torso = Node2D.new()
	_rig.head = Node2D.new()
	_rig.add_child(_rig.torso)
	_rig.add_child(_rig.head)


func after_each() -> void:
	ViewMode._shared = _saved_view
	ViewMode.eye = _saved_eye


func test_flat_view_clears_a_previous_tilt_exactly() -> void:
	_rig.rotation = 0.73
	_rig.tilt_up = Vector2(3.0, -4.0)
	RigTilt.aim_up(_rig)
	assert_eq(_rig.tilt_up, Vector2.ZERO)
	assert_eq(RigTilt.body_lift(_rig), Vector2.ZERO)


func test_tilted_view_rotates_screen_up_by_negative_global_rotation() -> void:
	ViewMode._shared.pitch_deg = 45.0
	ViewMode._shared.height_k = 2.0
	_parent.rotation = 0.4
	_rig.rotation = 0.3
	_rig.scale = Vector2(2.0, 2.0)
	RigTilt.aim_up(_rig)
	_assert_vector(_rig.tilt_up, Vector2(-2.0 * sin(0.7), -2.0 * cos(0.7)))
	assert_almost_eq(_rig.tilt_up.length(), 2.0, 0.00001, "scale does not rescale up")
	_parent.rotation = 0.0
	_rig.rotation = 0.0
	RigTilt.aim_up(_rig)
	_assert_vector(_rig.tilt_up, Vector2(0.0, -2.0))


func test_perspective_uses_global_position_relative_to_the_eye() -> void:
	ViewMode._shared.eye_h_m = 2.0
	ViewMode.eye = Vector2(100.0, 200.0)
	_parent.position = Vector2(30.0, 40.0)
	_rig.position = Vector2(70.0, 160.0) + Vector2(3.0, -4.0) * (2.0 * SimConst.PX_PER_M)
	RigTilt.aim_up(_rig)
	_assert_vector(_rig.tilt_up, Vector2(3.0, -4.0))
	_rig.global_position = ViewMode.eye
	RigTilt.aim_up(_rig)
	assert_eq(_rig.tilt_up, Vector2.ZERO, "at the eye clears the previous radial tilt")


func test_a_tiny_nonzero_up_is_not_discarded_or_normalized() -> void:
	ViewMode._shared.pitch_deg = 45.0
	ViewMode._shared.height_k = 0.000001
	_rig.tilt_up = Vector2.ONE
	RigTilt.aim_up(_rig)
	assert_lt(_rig.tilt_up.y, 0.0)
	assert_almost_eq(_rig.tilt_up.y, -0.000001, 0.000000001)


func test_hip_height_at_rest_and_each_pose_endpoint() -> void:
	assert_eq(RigTilt.hip_h(_rig), 80.0)
	_rig.c_sprawl = 1.0
	assert_eq(RigTilt.hip_h(_rig), 20.0, "full sprawl retains one quarter height")
	_rig.c_sprawl = 0.0
	_rig.c_tuck = 1.0
	assert_eq(RigTilt.hip_h(_rig), 52.0, "full tuck retains 65 percent height")
	_rig.c_sprawl = 1.0
	assert_eq(RigTilt.hip_h(_rig), 13.0, "sprawl and tuck multiply")


func test_fractional_pose_multiplies_both_height_reductions() -> void:
	_rig.c_sprawl = 0.5
	_rig.c_tuck = 0.4
	assert_almost_eq(RigTilt.hip_h(_rig), 43.0, 0.000001)
	_rig.plan.hip_z = 160.0
	assert_almost_eq(RigTilt.hip_h(_rig), 86.0, 0.000001)


func test_zero_and_negative_plan_heights_are_used_without_a_floor() -> void:
	_rig.plan.hip_z = 0.0
	assert_eq(RigTilt.hip_h(_rig), 0.0)
	_rig.plan.hip_z = -80.0
	assert_eq(RigTilt.hip_h(_rig), -80.0)


func test_body_lift_scales_both_up_components_by_the_current_hip_height() -> void:
	_rig.tilt_up = Vector2(0.3, -0.4)
	_rig.c_sprawl = 0.5
	_rig.c_tuck = 0.4
	_assert_vector(RigTilt.body_lift(_rig), Vector2(12.9, -17.2))
	assert_eq(_rig.position, Vector2.ZERO, "querying lift does not move the rig")
	assert_eq(_rig.torso.position, Vector2.ZERO)
	_rig.plan.hip_z = 0.0
	assert_eq(RigTilt.body_lift(_rig), Vector2.ZERO)


func test_upper_lift_resets_torso_but_adds_to_the_posed_head() -> void:
	_rig.tilt_up = Vector2(0.3, -0.4)
	_rig.c_sprawl = 1.0
	_rig.c_tuck = 1.0
	_rig.torso.position = Vector2(900.0, 800.0)
	_rig.head.position = Vector2(5.0, 9.0)
	RigTilt.lift_upper(_rig)
	_assert_vector(_rig.torso.position, Vector2(15.145, -9.86))
	_assert_vector(_rig.head.position, Vector2(6.755, 6.66))
	RigTilt.lift_upper(_rig)
	_assert_vector(_rig.torso.position, Vector2(15.145, -9.86))
	_assert_vector(_rig.head.position, Vector2(8.51, 4.32))
	assert_eq(_rig.plan.torso_pos, Vector2(13.0, -7.0), "the authored plan stays unchanged")


func test_zero_tilt_restores_authored_torso_and_preserves_posed_head() -> void:
	_rig.torso.position = Vector2(900.0, 800.0)
	_rig.head.position = Vector2(5.0, 9.0)
	RigTilt.lift_upper(_rig)
	assert_eq(_rig.torso.position, Vector2(13.0, -7.0))
	assert_eq(_rig.head.position, Vector2(5.0, 9.0))


func _assert_vector(actual: Vector2, expected: Vector2) -> void:
	assert_almost_eq(actual.x, expected.x, 0.00001)
	assert_almost_eq(actual.y, expected.y, 0.00001)
