extends GutTest
## Body-space landmarks at the starts, midpoints and ends of the drawn poses.

var pose: TonnagePose
var sample: TonnagePose.Sample


func before_each() -> void:
	pose = TonnagePose.new(0.9, 5, 10, 10)
	sample = TonnagePose.Sample.new()


func test_zero_ticks_hold_the_fresh_carry_pose() -> void:
	sample.windup = 1.0
	pose.step(sample, 0)
	assert_eq(pose.torso, Vector3(-0.55, 0.0, 1.55))
	assert_eq(pose.pitch, 0.0)
	assert_false(pose.act)
	assert_eq(pose.armed_k, 0.0)
	assert_eq(pose.lean_k, 1.0)
	assert_eq(pose.plant_k, 0.0)


func test_torso_lead_is_capped_in_the_local_facing_frame() -> void:
	sample.velocity = Vector2(-8.0, 6.0)
	sample.facing = PI / 2.0
	sample.bob_m = 0.12
	pose.step(sample, 10)
	# Ten ticks into the critical spring's step response, it is 59.3994% of the way there.
	assert_almost_eq(pose.torso, Vector3(-0.451991, 0.130679, 1.67), Vector3.ONE * 0.00001)
	assert_almost_eq(pose.pitch, 0.053905, 0.00001)


func test_cruising_hands_trail_the_body_and_bob_together() -> void:
	sample.velocity = Vector2(1.2, 1.6)
	sample.bob_m = 0.12
	pose.step(sample, 10)
	# Both palms trail the torso's forward and sideways lead; the slower bob is still rising.
	var offset: Vector3 = Vector3(-0.033285, -0.027737, 0.097335)
	assert_almost_eq(pose.right, TonnagePose.CARRY + offset, Vector3.ONE * 0.00001)
	assert_almost_eq(pose.left, Vector3(1.0, -0.8, 1.4) + offset, Vector3.ONE * 0.00001)


func test_first_ram_hit_starts_a_four_tick_stroke_and_ten_tick_return() -> void:
	sample.ramming = true
	pose.step(sample, 4)
	assert_eq(pose.column, TonnagePose.Pose.ARMED)
	var tucked: Vector3 = Vector3(-0.25, -1.05, 1.45)
	var bumper: Vector3 = Vector3(1.2, 0.25, 1.1)
	assert_eq(pose.left, tucked)
	assert_eq(pose.right, bumper)
	sample.ram_hits = 1
	pose.step(sample, 1)
	assert_almost_eq(pose.right.x, bumper.x + 0.15, 0.00001)
	pose.step(sample, 8)
	assert_almost_eq(pose.right.x, bumper.x + 0.3, 0.00001)
	assert_eq(pose.left, tucked)


func test_windup_and_landing_have_distinct_hand_spacing() -> void:
	sample.windup = 1.0
	pose.step(sample, 1)
	assert_true(pose.act)
	assert_eq(pose.left, Vector3(0.95, -1.5, 2.6))
	assert_eq(pose.right, Vector3(0.95, 1.5, 2.6))
	sample.windup = 0.0
	sample.stomp_age = 0
	pose.step(sample, 1)
	assert_eq(pose.left, Vector3(1.2, -0.7, 0.0))
	assert_eq(pose.right, Vector3(1.2, 0.7, 0.0))
	assert_almost_eq(pose.torso, Vector3(-0.19, 0.0, 1.27), Vector3.ONE * 0.00001)
	assert_almost_eq(pose.pitch, 0.24, 0.00001)


func test_lift_progresses_before_unplanting_the_palms() -> void:
	sample.stomp_age = 8
	pose.step(sample, 1)
	# Three of nine lift intervals, smoothstep(1/3) = 7/27, from 0.21 to 0.8 m.
	var lift: float = 0.21 + 0.59 * 7.0 / 27.0
	assert_almost_eq(pose.left.z, lift, 0.00001)
	assert_almost_eq(pose.right.z, lift, 0.00001)
	assert_almost_eq(pose.pitch, 0.24 * (1.0 - lift), 0.00001)
	sample.stomp_age = 25
	pose.step(sample, 1)
	assert_almost_eq(pose.plant_k, 0.5, 0.00001)
	assert_almost_eq(pose.right, Vector3(1.1, 0.75, 1.1), Vector3.ONE * 0.00001)
	assert_almost_eq(pose.pitch, 0.024, 0.00001)
	sample.stomp_age = -1
	pose.step(sample, 1)
	assert_eq(pose.plant_k, 0.0)
	assert_false(pose.act)


func test_cruise_starts_above_walking_speed() -> void:
	sample.velocity = Vector2(1.5, 0.0)
	pose.step(sample, 1)
	assert_eq(pose.column, TonnagePose.Pose.CARRY)
	sample.velocity.x = 1.51
	pose.step(sample, 1)
	assert_eq(pose.column, TonnagePose.Pose.CRUISE)


func test_new_pose_receives_its_first_contact_on_the_first_tick() -> void:
	sample.ram_hits = 1
	pose.step(sample, 1)
	assert_almost_eq(pose.right.x, TonnagePose.CARRY.x + 0.15, 0.00001)


func test_half_brace_keeps_the_cruise_cell_until_the_fist_leads() -> void:
	sample.ramming = true
	sample.velocity = Vector2(2.0, 0.0)
	pose.step(sample, 2)
	assert_eq(pose.armed_k, 0.5)
	assert_eq(pose.lean_k, 1.0)
	assert_eq(pose.column, TonnagePose.Pose.CRUISE)
