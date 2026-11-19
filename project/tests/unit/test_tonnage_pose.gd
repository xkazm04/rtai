extends GutTest

const CUT: int = 5
const FOLLOW: int = 10
const HIT: int = 10

var _pose: TonnagePose
var _sample: TonnagePose.Sample


func before_each() -> void:
	_pose = TonnagePose.new(0.9, CUT, FOLLOW, HIT)
	_sample = TonnagePose.Sample.new()


func test_cruise_and_carry_fists_stay_level_on_every_tick() -> void:
	for i: int in 100:
		_sample.velocity = Vector2(2.4, 0.0) if i >= 20 and i < 70 else Vector2.ZERO
		_sample.bob_m = 0.12 * sin(TAU * i / 110.0)
		_pose.step(_sample, 1)
		assert_eq(_pose.left.z, _pose.right.z)
		assert_gte(_pose.left.z, 1.0)
		assert_eq(
			_pose.column,
			TonnagePose.Pose.CRUISE if _sample.velocity.x > 0 else TonnagePose.Pose.CARRY
		)


func test_only_pound_contacts_the_road_and_both_hands_land_together() -> void:
	for i: int in 30:
		_sample.windup = (i + 1) / 30.0
		_pose.step(_sample, 1)
		assert_eq(_pose.column, TonnagePose.Act.RAISE)
		assert_gte(minf(_pose.left.z, _pose.right.z), 0.2)
	assert_almost_eq(_pose.right.z, 2.6, 0.0001)
	_sample.windup = 0.0
	for age: int in 45:
		_sample.stomp_age = age
		_pose.step(_sample, 1)
		if age < CUT:
			assert_true(_pose.act)
			assert_eq(_pose.column, TonnagePose.Act.POUND)
			assert_eq(_pose.left, _pose.landing(-1.0))
			assert_eq(_pose.right, _pose.landing(1.0))
			assert_gt(_pose.left.x, _pose.press_ahead_m)
			assert_lt(_pose.torso.x, _pose.press_ahead_m)
		else:
			assert_gte(minf(_pose.left.z, _pose.right.z), 0.2)
			assert_eq(_pose.act, age < CUT + FOLLOW)
	assert_eq(_pose.right, TonnagePose.CARRY)


func test_charge_braces_and_the_contact_strokes_only_the_bumper() -> void:
	_sample.ramming = true
	_sample.hurt_age = 0
	for i: int in 6:
		_pose.step(_sample, 1)
		if _pose.armed_k > 0.5:
			assert_eq(_pose.lean_k, 0.0)
			assert_eq(_pose.column, TonnagePose.Pose.ARMED)
	assert_eq(_pose.armed_k, 1.0)
	var bumper: Vector3 = _pose.right
	var tucked: Vector3 = _pose.left
	_sample.ram_hits = 1
	_pose.step(_sample, 4)
	assert_almost_eq(_pose.right.x, bumper.x + 0.6, 0.0001)
	assert_eq(_pose.left, tucked)
	_pose.step(_sample, 10)
	assert_eq(_pose.right, bumper)


func test_recoil_expires_on_the_shared_hit_tick() -> void:
	for age: int in HIT + 1:
		_sample.hurt_age = age
		_pose.step(_sample, 1)
		assert_eq(_pose.lean_k, 1.0)
		assert_eq(_pose.column, TonnagePose.Pose.RECOIL if age < HIT else TonnagePose.Pose.CARRY)


func test_three_ticks_match_singles_including_the_slam_boundary() -> void:
	var single: TonnagePose = TonnagePose.new(_pose.press_ahead_m, CUT, FOLLOW, HIT)
	_sample.velocity = Vector2(3.4, -0.3)
	_sample.facing = 0.5
	_sample.ramming = true
	_sample.stomp_age = 1
	_pose.step(_sample, 3)
	for i: int in 3:
		_sample.stomp_age = i - 1
		single.step(_sample, 1)
	assert_eq(_pose.torso, single.torso)
	assert_eq(_pose.pitch, single.pitch)
	assert_eq(_pose.right, single.right)
	assert_eq(_pose.left, single.left)
	assert_eq(_pose.armed_k, single.armed_k)
	assert_eq(_pose.column, single.column)
