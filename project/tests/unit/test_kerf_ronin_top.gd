extends GutTest

const POSE = KerfRoninDrawn.Pose


func test_every_non_cut_pose_keeps_both_texture_tips_behind_the_shoulders() -> void:
	var rig: KerfRoninTop = add_child_autofree(KerfRoninTop.new())
	rig.position = Vector2(83, 105)
	rig.rotation = PI / 4.0
	var point: Vector2 = rig._parts.pivots_b["blade"]
	var texture: Image = rig._blade[0].texture.get_image()
	var tip_pixels: Rect2i = Rect2i(Vector2i(point.floor()), Vector2i(2, 2))
	assert_true(texture.get_region(tip_pixels).get_used_rect().has_area())
	var poses: Array[KerfRoninDrawn.Pose] = [
		POSE.HOVER, POSE.CRUISE, POSE.TURN, POSE.HIT, POSE.COCK, POSE.RECOVER, POSE.BLINK
	]
	for current: KerfRoninDrawn.Pose in poses:
		for yaw: float in [-540.0, 540.0]:
			rig.pose(POSE.CUT, 0.0, 0.0, 60)
			rig.pose(current, 6.0, yaw, 1)
			_assert_trailing_tips(rig)
			rig.pose(current, 6.0, yaw, 60)
			_assert_trailing_tips(rig)
			_assert_sweep(rig, current, yaw)
			if current in [POSE.HOVER, POSE.CRUISE, POSE.HIT, POSE.BLINK]:
				var left: Vector2 = _far_joint(rig, rig._blade[0], "blade")
				var right: Vector2 = _far_joint(rig, rig._blade[1], "blade")
				assert_true(left.is_equal_approx(right * Vector2(1, -1)))


func _assert_trailing_tips(rig: KerfRoninTop) -> void:
	var forward: Vector2 = rig.global_transform.x.normalized()
	for i: int in 2:
		var arm: Sprite2D = rig._upper[i]
		var blade: Sprite2D = rig._blade[i]
		assert_false(blade.centered or blade.flip_h or blade.flip_v)
		var tip: Vector2 = blade.to_global(blade.offset + rig._parts.pivots_b["blade"])
		var elbow: Vector2 = arm.to_global(arm.offset + rig._parts.pivots_b["upperarm"])
		var outward: Vector2 = rig.global_transform.y.normalized() * (-1.0 if i == 0 else 1.0)
		assert_true(elbow.is_equal_approx(blade.global_position))
		assert_lt((tip - arm.global_position).dot(forward), 0.0)
		assert_gt((tip - rig.global_position).dot(outward), 0.0)
		assert_lt((elbow - arm.global_position).dot(forward), 0.0)


func _assert_sweep(rig: KerfRoninTop, current: KerfRoninDrawn.Pose, yaw: float) -> void:
	var rear: Vector2 = -rig.global_transform.x.normalized()
	for i: int in 2:
		var arm: Sprite2D = rig._upper[i]
		var blade: Sprite2D = rig._blade[i]
		var elbow: Vector2 = blade.global_position
		var tip: Vector2 = blade.to_global(blade.offset + rig._parts.pivots_b["blade"])
		var upper_deg: float = rad_to_deg(absf(rear.angle_to(elbow - arm.global_position)))
		assert_lte(upper_deg, 55.01 if current == POSE.HIT else 50.01)
		if current == POSE.HOVER:
			assert_almost_eq(upper_deg, 45.0, 0.01)
		if current == POSE.TURN:
			var outer: bool = (i == 0) == (yaw > 0.0)
			assert_almost_eq(upper_deg, 50.0 if outer else 25.0, 0.01)
		var outward: Vector2 = rig.global_transform.y.normalized() * (-1.0 if i == 0 else 1.0)
		# Sample the belly of the printed crescent, relative to the actual elbow-to-tip line.
		var belly: Vector2 = blade.to_global(blade.offset + Vector2(190, 88))
		var chord: Vector2 = Geometry2D.get_closest_point_to_segment(belly, elbow, tip)
		assert_gt((belly - chord).dot(outward), 0.0)


func test_only_the_right_cutter_thrusts_along_facing_and_eases_back() -> void:
	var rig: KerfRoninTop = add_child_autofree(KerfRoninTop.new())
	var blade: Sprite2D = rig._blade[1]
	rig.pose(POSE.COCK, 0.0, 0.0, 60)
	var cock: Vector2 = _far_joint(rig, blade, "blade")
	rig.pose(POSE.CUT, 12.0, 0.0, 1)
	var in_between: Vector2 = _far_joint(rig, blade, "blade")
	rig.pose(POSE.CUT, 12.0, 0.0, 0)
	assert_eq(_far_joint(rig, blade, "blade"), in_between)
	rig.pose(POSE.CUT, 12.0, 0.0, 30)
	var cut: Vector2 = _far_joint(rig, blade, "blade")
	assert_lt(cock.x, in_between.x)
	assert_lt(in_between.x, cut.x)
	assert_gt(cut.x, rig._upper[1].position.x)
	assert_lt(_far_joint(rig, rig._blade[0], "blade").x, rig._upper[0].position.x)
	assert_almost_eq((cut - blade.position).angle(), 0.0, 0.001)
	rig.pose(POSE.RECOVER, 0.0, 0.0, 30)
	var recover: Vector2 = _far_joint(rig, blade, "blade")
	rig.pose(POSE.HOVER, 0.0, 0.0, 30)
	assert_gt(recover.x, _far_joint(rig, blade, "blade").x)


func test_tail_parts_share_a_root_and_crossfade_across_twelve_metres_per_second() -> void:
	var rig: KerfRoninTop = add_child_autofree(KerfRoninTop.new())
	assert_eq(rig._curled.position, rig._straight.position)
	assert_lt(rig._curled.position.x, 0.0)
	assert_lt(_far_joint(rig, rig._straight, "tail_straight").x, rig._straight.position.x)
	for speed: float in [0.0, 3.0, 6.0, 12.0, 16.0]:
		rig.pose(POSE.CRUISE, speed, 0.0, 1)
		var straight: float = minf(speed / 12, 1)
		assert_almost_eq(rig._straight.self_modulate.a, straight, 0.0001)
		assert_almost_eq(rig._curled.self_modulate.a, 1.0 - straight, 0.0001)


func test_echo_keeps_both_tail_weights_and_the_departing_blade_transforms() -> void:
	var rig: KerfRoninTop = add_child_autofree(KerfRoninTop.new())
	var snapshot: KerfEcho.Pose = add_child_autofree(KerfEcho.Pose.new())
	var sources: Array[Sprite2D] = []
	for part: Sprite2D in rig.get_children():
		sources.append(part)
	rig.position = Vector2(83, 105)
	rig.rotation = 0.71
	rig.pose(POSE.CRUISE, 9.0, 0.0, 20)
	snapshot.capture(sources, rig.position)
	for part: Sprite2D in sources:
		var copy: Sprite2D = snapshot.sprites[part.get_index()]
		assert_same(copy.texture, part.texture)
		assert_eq(copy.centered, part.centered)
		assert_eq(copy.offset, part.offset)
		assert_true(copy.transform.x.is_equal_approx(part.global_transform.x))
		assert_true(copy.transform.y.is_equal_approx(part.global_transform.y))
		assert_true(copy.position.is_equal_approx(part.global_position - rig.position))
	rig.pose(POSE.BLINK, 12.0, 0.0, 6)
	assert_eq(snapshot.sprites[rig._curled.get_index()].self_modulate.a, 0.25)
	assert_eq(snapshot.sprites[rig._straight.get_index()].self_modulate.a, 0.75)


func _far_joint(rig: KerfRoninTop, sprite: Sprite2D, id: String) -> Vector2:
	return sprite.transform * (rig._parts.pivots_b[id] + sprite.offset)
