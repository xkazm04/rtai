extends GutTest
## Fixed-tick movement on data only: no brain, scene tree or shipped balance table.

var _e: EnemyAgent
var _pit: EnemyPit


func before_each() -> void:
	_e = _agent(Vector2.ZERO)
	_pit = EnemyPit.new(EnemyRoster.new(), RngRegistry.new(1).stream(&"enemy_ai"))
	_pit.rivet_pos = Vector2(100.0, 100.0)


func _agent(at: Vector2) -> EnemyAgent:
	var arch: EnemyRoster.Archetype = EnemyRoster.Archetype.new()
	arch.speed_mps = 6.0
	arch.accel_mps2 = 60.0
	arch.turn_rad_per_tick = 0.2
	var agent: EnemyAgent = EnemyAgent.make(1, arch, at)
	agent.state = EnemyAgent.State.ENGAGE
	return agent


func _vector(actual: Vector2, expected: Vector2) -> void:
	assert_almost_eq(actual.x, expected.x, 0.000001, "x component")
	assert_almost_eq(actual.y, expected.y, 0.000001, "y component")


func _advance(velocity: Vector2, dash: bool, look_at: Vector2 = Vector2.RIGHT) -> void:
	if dash:
		EnemyMotor.dash(_e, velocity, _pit)
	else:
		EnemyMotor.move(_e, velocity, look_at, [], _pit)


func test_move_eases_velocity_and_integrates_one_tick_without_snapping() -> void:
	_e.pos = Vector2(2.0, 3.0)
	EnemyMotor.move(_e, Vector2(3.0, 4.0), Vector2(20.0, 3.0), [], _pit)
	_vector(_e.vel, Vector2(0.6, 0.8))
	_vector(_e.pos, Vector2(2.01, 3.0 + 0.8 / 60.0))
	var velocities: Array[float] = [3.0, 0.4, 0.0, 10.0]
	var wants: Array[float] = [0.0, 0.0, -0.5, 100.0]
	var expected: Array[float] = [2.0, 0.0, -0.5, 9.0]
	for i: int in velocities.size():
		_e.vel = Vector2(velocities[i], 0.0)
		EnemyMotor.move(_e, Vector2(wants[i], 0.0), Vector2.RIGHT, [], _pit)
		_vector(_e.vel, Vector2(expected[i], 0.0))


func test_speed_limit_applies_after_separation_with_panic_multiplier() -> void:
	_e.arch.accel_mps2 = 6000.0
	for state: EnemyAgent.State in [
		EnemyAgent.State.ENGAGE, EnemyAgent.State.PATROL, EnemyAgent.State.PANIC
	]:
		_e.state = state
		_e.vel = Vector2.ZERO
		EnemyMotor.move(_e, Vector2(30.0, 40.0), Vector2.UP, [], _pit)
		var speed: float = 9.6 if state == EnemyAgent.State.PANIC else 6.0
		_vector(_e.vel, Vector2(0.6, 0.8) * speed)
	_e.state = EnemyAgent.State.ENGAGE
	_e.pos = Vector2.ZERO
	var other: EnemyAgent = _agent(Vector2(-0.5, 0.0))
	EnemyMotor.move(_e, Vector2(5.0, 0.0), Vector2.RIGHT, [other], _pit)
	_vector(_e.vel, Vector2(6.0, 0.0))


func test_engaged_enemy_aims_from_new_position_independently_of_velocity() -> void:
	_e.arch.turn_rad_per_tick = PI
	EnemyMotor.move(_e, Vector2.RIGHT, Vector2(1.0 / 60.0, 1.0), [], _pit)
	_vector(_e.facing, Vector2.DOWN)
	_e.pos = Vector2.ZERO
	_e.vel = Vector2.ZERO
	EnemyMotor.move(_e, Vector2.DOWN, Vector2(-1.0, 1.0 / 60.0), [], _pit)
	_vector(_e.facing, Vector2.LEFT)


func test_patrol_and_panic_face_velocity_only_above_point_three() -> void:
	_e.arch.turn_rad_per_tick = PI
	for state: EnemyAgent.State in [EnemyAgent.State.PATROL, EnemyAgent.State.PANIC]:
		_e.state = state
		for speed: float in [0.0, 0.2999, 0.3001]:
			_e.facing = Vector2.RIGHT
			_e.vel = Vector2(0.0, speed)
			EnemyMotor.move(_e, _e.vel, _e.pos + Vector2.LEFT, [], _pit)
			_vector(_e.facing, Vector2.DOWN if speed > 0.3 else Vector2.RIGHT)


func test_turn_normalizes_caps_both_signs_and_takes_shortest_arc_without_overshoot() -> void:
	for sign_value: float in [-1.0, 1.0]:
		_e.facing = Vector2(2.0, 0.0)
		EnemyMotor.turn_toward(_e, Vector2(0.0, sign_value * 4.0))
		_vector(_e.facing, Vector2.RIGHT.rotated(sign_value * 0.2))
	_e.facing = Vector2.RIGHT
	EnemyMotor.turn_toward(_e, Vector2.RIGHT.rotated(0.05) * 5.0)
	_vector(_e.facing, Vector2.RIGHT.rotated(0.05))
	_e.facing = Vector2.RIGHT.rotated(PI - 0.05)
	EnemyMotor.turn_toward(_e, Vector2.RIGHT.rotated(-PI + 0.05))
	_vector(_e.facing, Vector2.RIGHT.rotated(-PI + 0.05))
	for direction: Vector2 in [Vector2.ZERO, Vector2(0.0, 0.000999)]:
		_e.facing = Vector2(2.0, 0.0)
		EnemyMotor.turn_toward(_e, direction)
		assert_eq(_e.facing, Vector2(2.0, 0.0), "guard leaves facing untouched")
	EnemyMotor.turn_toward(_e, Vector2(0.0, 0.001))
	_vector(_e.facing, Vector2.RIGHT.rotated(0.2))


func test_arrival_stops_inclusively_scales_speed_and_takes_full_speed_detours() -> void:
	for distance: float in [0.0, 0.249, 0.25]:
		assert_eq(EnemyMotor.arrive(_e, Vector2(distance, 0.0), 4.0), Vector2.ZERO)
	assert_eq(EnemyMotor.arrive(_e, Vector2(2.0, 0.0), 4.0, 2.0), Vector2.ZERO)
	_vector(EnemyMotor.arrive(_e, Vector2(2.001, 0.0), 4.0, 2.0), Vector2(4.0, 0.0))
	_vector(EnemyMotor.arrive(_e, Vector2(0.251, 0.0), 4.0), Vector2.RIGHT)
	var distances: Array[float] = [0.1, 0.374, 0.375, 0.75, 1.499, 1.5, 3.0]
	var speeds: Array[float] = [1.0, 1.0, 1.0, 2.0, 3.9973333333, 4.0, 4.0]
	for i: int in distances.size():
		_vector(
			EnemyMotor.arrive(_e, Vector2(0.0, -distances[i]), 4.0, 0.0), Vector2(0.0, -speeds[i])
		)
	_vector(EnemyMotor.arrive(_e, Vector2(3.0, 4.0), 5.0), Vector2(3.0, 4.0))
	_e.cover_ref = [Rect2(1.0, -1.0, 1.0, 2.0)]
	# The visible upper left corner is (0.3, -1.7), including the body and cover gap.
	var expected: Vector2 = Vector2(0.3, -1.7).normalized() * 4.0
	_vector(EnemyMotor.arrive(_e, Vector2(3.0, 0.0), 4.0, 10.0), expected)


func test_separation_adds_neighbours_and_rivet_using_both_body_radii() -> void:
	_e.arch.accel_mps2 = 6000.0
	var other: EnemyAgent = _agent(Vector2(0.6, 0.0))
	other.arch.body = &"robot"
	var human: EnemyAgent = _agent(Vector2(-0.5, 0.0))
	_pit.rivet_pos = Vector2(0.0, -0.8)
	EnemyMotor.move(_e, Vector2(0.2, 0.1), Vector2.RIGHT, [other, human], _pit)
	# Keep distances: robot 1.2, human 1.05, Rivet 1.12; overlap depths times gain 3.
	_vector(_e.vel, Vector2(0.05, 1.06))
	_vector(_e.pos, Vector2(0.05, 1.06) / 60.0)


func test_separation_ignores_self_dead_and_downed_but_includes_staggered() -> void:
	var dead: EnemyAgent = _agent(Vector2(0.2, 0.0))
	dead.state = EnemyAgent.State.DEAD
	var down: EnemyAgent = _agent(Vector2(0.0, 0.2))
	down.state = EnemyAgent.State.DOWN
	_vector(EnemyMotor._separation(_e, [_e, dead, down], _pit), Vector2.ZERO)
	down.state = EnemyAgent.State.STAGGER
	_vector(EnemyMotor._separation(_e, [down], _pit), Vector2(0.0, -2.55))


func test_repulsion_is_zero_at_overlap_and_outside_keep_distance() -> void:
	for distance: float in [0.0, 0.00009999, 2.0, 2.001]:
		assert_eq(EnemyMotor._repel(Vector2.ZERO, Vector2(distance, 0.0), 2.0), Vector2.ZERO)
	_vector(
		EnemyMotor._repel(Vector2.ZERO, Vector2(0.00010001, 0.0), 2.0), Vector2(-1.99989999, 0.0)
	)
	_vector(EnemyMotor._repel(Vector2(3.0, 4.0), Vector2.ZERO, 6.0), Vector2(0.6, 0.8))
	_vector(EnemyMotor._repel(Vector2.ZERO, Vector2(1.999, 0.0), 2.0), Vector2(-0.001, 0.0))


func test_dash_commits_exact_velocity_without_acceleration_speed_limit_or_turning() -> void:
	_e.pos = Vector2(2.0, 3.0)
	_e.vel = Vector2.LEFT
	_e.facing = Vector2.UP
	_pit.rivet_pos = _e.pos + Vector2(0.1, 0.0)
	EnemyMotor.dash(_e, Vector2(12.0, -6.0), _pit)
	_vector(_e.vel, Vector2(12.0, -6.0))
	_vector(_e.pos, Vector2(2.2, 2.9))
	assert_eq(_e.facing, Vector2.UP)
	EnemyMotor.dash(_e, Vector2.ZERO, _pit)
	assert_eq(_e.vel, Vector2.ZERO)
	_vector(_e.pos, Vector2(2.2, 2.9))


func test_move_and_dash_push_body_out_of_cover_without_zeroing_velocity() -> void:
	_pit.cover = [Rect2(-0.5, -1.0, 1.0, 2.0)]
	_e.arch.accel_mps2 = 6000.0
	_e.arch.turn_rad_per_tick = PI
	for dash: bool in [false, true]:
		_e.pos = Vector2(-0.8, 0.0)
		_advance(Vector2(6.0, 0.0), dash, Vector2(-0.85, 1.0))
		if not dash:
			_vector(_e.facing, Vector2.DOWN)
		_vector(_e.pos, Vector2(-0.85, 0.0))
		_vector(_e.vel, Vector2(6.0, 0.0))


func test_move_and_dash_clamp_body_centre_to_each_bound_after_cover_pushout() -> void:
	_pit.bounds = Rect2(-2.0, -3.0, 6.0, 8.0)
	_e.arch.speed_mps = 6000.0
	_e.arch.accel_mps2 = 600000.0
	for dash: bool in [false, true]:
		for direction: Vector2 in [Vector2(600.0, -600.0), Vector2(-600.0, 600.0)]:
			_e.pos = Vector2.ZERO
			_advance(direction, dash)
			_vector(_e.pos, Vector2(4.0, -3.0) if direction.x > 0.0 else Vector2(-2.0, 5.0))
			_vector(_e.vel, direction)
		_e.pos = Vector2(-1.9, 0.0)
		_pit.cover = [Rect2(-2.0, -1.0, 1.0, 2.0)]
		_e.vel = Vector2.ZERO
		_advance(Vector2.ZERO, dash)
		_vector(_e.pos, Vector2(-2.0, 0.0))
		_pit.cover.clear()
