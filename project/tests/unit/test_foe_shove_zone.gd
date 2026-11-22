extends GutTest

const CLEARANCE: float = 0.05
const START: Vector2 = Vector2(12.25, -4.5)
const RADIUS: float = 0.45


func test_body_grazes_both_rails_and_the_tip_at_full_extension() -> void:
	for aim: Vector2 in [Vector2.RIGHT, Vector2.UP, Vector2(-0.6, 0.8)]:
		for speed: float in [0.0, 1.6, 4.0]:
			for reach: float in [1.25, 1.8]:
				_check_edges(aim, speed, reach)


func _check_edges(aim: Vector2, speed: float, reach: float) -> void:
	var slab: PackedVector2Array = FoeShoveZone.polygon(START, aim, speed, reach)
	var end: Vector2 = START
	for tick: int in FoeShield.LUNGE_TICKS:
		end += aim * speed * SimClock.TICK_DT
	var side: Vector2 = aim.orthogonal()
	var half_width: Vector2 = side * FoeShield.SLAB_HALF_M
	assert_almost_eq(slab[0], START - half_width, Vector2.ONE * 0.0001)
	assert_almost_eq(slab[3], START + half_width, Vector2.ONE * 0.0001)
	var tip: Vector2 = slab[1].lerp(slab[2], 0.5)
	assert_almost_eq(slab[1], end + aim * reach - half_width, Vector2.ONE * 0.0001)
	assert_almost_eq(slab[2], end + aim * reach + half_width, Vector2.ONE * 0.0001)
	_check_contact(tip - end, aim, aim, reach)
	# Halfway down the damaging part of each rail, clear of its end corners.
	_check_contact(slab[1] - aim * reach * 0.5 - end, -side, aim, reach)
	_check_contact(slab[2] - aim * reach * 0.5 - end, side, aim, reach)


func _check_contact(edge: Vector2, outward: Vector2, aim: Vector2, reach: float) -> void:
	var outside: Vector2 = edge + outward * (RADIUS + CLEARANCE)
	var inside: Vector2 = edge + outward * (RADIUS - CLEARANCE)
	assert_false(FoeShoveZone.connects(outside, aim, reach, RADIUS))
	assert_true(FoeShoveZone.connects(inside, aim, reach, RADIUS))


func test_hit_uses_the_final_rear_plane_and_includes_square_corner_contact() -> void:
	# Binary fractions keep the inclusive equality exact at the front and rear.
	var reach: float = 2.0
	var radius: float = 0.5
	var side: float = FoeShield.SLAB_HALF_M + radius
	assert_false(FoeShoveZone.connects(Vector2(-CLEARANCE, 0), Vector2.RIGHT, reach, radius))
	assert_true(FoeShoveZone.connects(Vector2.ZERO, Vector2.RIGHT, reach, radius))
	assert_true(FoeShoveZone.connects(Vector2(reach + radius, 0), Vector2.RIGHT, reach, radius))
	assert_true(
		FoeShoveZone.connects(Vector2(reach + radius, side - 0.001), Vector2.RIGHT, reach, radius)
	)


func test_tell_stays_planted_when_lunge_steps_are_blocked() -> void:
	var arch: EnemyRoster.Archetype = EnemyRoster.shipped(EnemyRoster.TABLE, true).archetype(
		&"shield_robot"
	)
	var carrier: Fighter = Fighter.make(Fighter.Kind.GUARD, 2, START, arch.hp)
	var mind: SquadMind = SquadMind.new(carrier, arch)
	carrier.swing_tick = 30
	carrier.swing_left = arch.telegraph_ticks
	assert_eq(FoeShieldView._tell_start(carrier, mind), START)
	carrier.swing_left = 0
	for i: int in range(1, FoeShield.LUNGE_TICKS):
		mind.shield.lunge_left = FoeShield.LUNGE_TICKS - i
		if i <= 3:
			carrier.pos += mind.agent.aim * arch.speed_mps * SimClock.TICK_DT
		assert_eq(FoeShieldView._tell_start(carrier, mind), START)
	carrier.swing_tick += 200
	carrier.swing_left = arch.telegraph_ticks
	assert_eq(FoeShieldView._tell_start(carrier, mind), carrier.pos)
