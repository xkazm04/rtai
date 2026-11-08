extends GutTest

const DRAWN: Array[Vector2] = [
	Vector2(0, -1), Vector2(1, -1), Vector2(-1, -1), Vector2(1, 0), Vector2(-1, 0)
]


func _is_drawn(head: Vector2) -> bool:
	for d: Vector2 in DRAWN:
		if head.dot(d.normalized()) > 0.9999:
			return true
	return false


func test_every_blow_lays_the_head_on_a_drawn_heading() -> void:
	for pose: int in StreetDeadPlan.POSES:
		for deg: int in range(0, 360, 7):
			var blow: Vector2 = Vector2.from_angle(deg_to_rad(float(deg)))
			var head: Vector2 = StreetDeadHeading.head_of(blow, pose, deg % 2 == 0)
			assert_true(_is_drawn(head), "pose %d blow %d -> %s" % [pose, deg, head])


func test_no_head_ever_points_at_the_camera() -> void:
	for pose: int in StreetDeadPlan.POSES:
		for deg: int in range(0, 360, 5):
			var blow: Vector2 = Vector2.from_angle(deg_to_rad(float(deg)))
			assert_lte(StreetDeadHeading.head_of(blow, pose, false).y, 0.001, "blow %d" % deg)


func test_the_head_follows_a_blow_away_from_the_camera() -> void:
	assert_almost_eq(StreetDeadHeading.head_of(Vector2.UP, 0, false).dot(Vector2.UP), 1.0, 0.0001)
	var left: Vector2 = StreetDeadHeading.head_of(Vector2.LEFT, 0, false)
	assert_almost_eq(left.dot(Vector2.LEFT), 1.0, 0.0001)


func test_neighbouring_poses_do_not_lie_in_one_row() -> void:
	for blow: Vector2 in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		var even: Vector2 = StreetDeadHeading.head_of(blow, 0, false)
		var odd: Vector2 = StreetDeadHeading.head_of(blow, 1, false)
		assert_lt(even.dot(odd), 0.99, "blow %s" % blow)


func test_the_across_pose_is_never_rotated_only_mirrored() -> void:
	var pose: int = StreetDeadHeading.ACROSS_POSE
	for blow: Vector2 in [Vector2.RIGHT, Vector2.LEFT, Vector2(0.3, 0.9), Vector2(-0.2, -0.9)]:
		var head: Vector2 = StreetDeadHeading.head_of(blow, pose, true)
		var flip: bool = StreetDeadHeading.flipped(head, pose, true)
		assert_eq(flip, blow.x < 0.0, "mirrored for its side")
		assert_almost_eq(wrapf(StreetDeadHeading.angle_of(head, pose, flip), -PI, PI), 0.0, 0.0001)


func test_a_head_up_pose_turns_exactly_to_the_heading() -> void:
	assert_almost_eq(StreetDeadHeading.angle_of(Vector2.UP, 0, false), 0.0, 0.0001)
	assert_almost_eq(StreetDeadHeading.angle_of(Vector2.RIGHT, 0, false), PI * 0.5, 0.0001)
	var mirrored: float = StreetDeadHeading.angle_of(Vector2.UP, 2, true)
	assert_almost_eq(wrapf(mirrored, -PI, PI), 0.0, 0.0001, "the mirror keeps the head up")


func test_no_body_gets_a_free_turn_in_the_drawn_set() -> void:
	for h: int in [1, 77, 90210]:
		assert_eq(StreetDeadHeading.jitter(h), 0.0)


func test_the_contact_shadow_lies_down_the_sun() -> void:
	var off: Vector2 = StreetDeadHeading.shadow_off(32.0)
	assert_gt(off.x, 0.0)
	assert_gt(off.y, 0.0)
	assert_almost_eq(off.length(), StreetDeadHeading.SHADOW_M * 32.0, 0.001)


func test_the_shadow_sits_under_the_body_and_leaves_with_it() -> void:
	var card: Sprite2D = autofree(Sprite2D.new())
	var plan: Sprite2D = Sprite2D.new()
	plan.hframes = StreetDeadPlan.POSES
	card.add_child(plan)
	StreetDeadHeading.shade(card, plan)
	var sh: Sprite2D = card.get_node(StreetDeadHeading.SHADOW_NODE) as Sprite2D
	assert_lt(sh.get_index(), plan.get_index(), "drawn before the body")
	StreetDeadHeading.unshade(card)
	assert_null(card.get_node_or_null(StreetDeadHeading.SHADOW_NODE))
