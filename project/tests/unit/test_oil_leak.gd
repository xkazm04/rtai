extends GutTest
## A wounded robot leaves a trail by distance while moving and by time while standing.
## Synthetic tuning keeps these boundaries independent of the shipped visual settings.

const EVERY_PX: float = 10.0
const STILL_TICKS: int = 6
const BLEED_TICKS: int = 30
const ORIGIN: Vector2 = Vector2(100.0, 200.0)

var _leak: OilLeak
var _fx: DripRecorder


class DripRecorder:
	extends BloodFx

	var positions: Array[Vector2] = []
	var velocities: Array[Vector2] = []

	func drip(at: Vector2, move: Vector2) -> void:
		positions.append(at)
		velocities.append(move)


func before_each() -> void:
	_leak = OilLeak.new(
		{"every_px": EVERY_PX, "still_ticks": STILL_TICKS, "bleed_ticks": BLEED_TICKS}
	)
	_fx = autofree(DripRecorder.new())


func test_no_trail_until_a_hit_starts_the_leak() -> void:
	_leak.step(STILL_TICKS, ORIGIN, _fx)
	_leak.step(STILL_TICKS, ORIGIN + Vector2(EVERY_PX, 0.0), _fx)
	assert_eq(_leak.left, 0)
	assert_eq(_leak.drips, 0)
	assert_eq(_fx.positions.size(), 0)
	_leak.start()
	assert_eq(_leak.left, BLEED_TICKS, "a hit grants the configured bleeding duration")


func test_first_known_position_anchors_the_trail_without_a_spurious_move() -> void:
	_leak.start()
	_leak.step(1, ORIGIN, _fx)
	assert_eq(_fx.positions.size(), 0, "the first position is not movement from world zero")
	assert_eq(_leak.drips, 0)
	assert_eq(_leak.left, BLEED_TICKS - 1)


func test_moving_drips_at_the_distance_boundary_in_any_direction() -> void:
	_leak.start()
	_leak.step(1, ORIGIN, _fx)
	_leak.step(1, ORIGIN + Vector2(0.0, EVERY_PX - 1.0), _fx)
	assert_eq(_fx.positions.size(), 0, "below the distance threshold leaves no drop")
	var move: Vector2 = Vector2(-0.6, 0.8) * EVERY_PX
	_leak.step(1, ORIGIN + move, _fx)
	assert_eq(_fx.positions, [ORIGIN + move], "Euclidean distance includes the exact boundary")
	assert_eq(_leak.drips, 1)
	assert_eq(_fx.velocities, [move / 3.0], "stretch uses motion per elapsed tick")
	assert_eq(_leak.left, BLEED_TICKS - 3)


func test_each_moving_drop_starts_a_new_distance_and_time_interval() -> void:
	_leak.start()
	_leak.step(1, ORIGIN, _fx)
	var next: Vector2 = ORIGIN + Vector2(EVERY_PX, 0.0)
	_leak.step(1, next, _fx)
	_leak.step(1, next + Vector2(EVERY_PX - 1.0, 0.0), _fx)
	assert_eq(_fx.positions.size(), 1, "distance is measured from the last drop")
	_leak.step(1, next + Vector2(EVERY_PX, 0.0), _fx)
	assert_eq(_fx.positions, [next, next + Vector2(EVERY_PX, 0.0)])
	assert_eq(_fx.velocities, [Vector2(EVERY_PX / 2.0, 0.0), Vector2(EVERY_PX / 2.0, 0.0)])
	assert_eq(_leak.drips, 2)


func test_standing_drips_at_the_tick_boundary_and_repeats_after_a_full_interval() -> void:
	_leak.start()
	_leak.step(STILL_TICKS - 1, ORIGIN, _fx)
	assert_eq(_fx.positions.size(), 0)
	_leak.step(1, ORIGIN, _fx)
	assert_eq(_fx.positions, [ORIGIN])
	assert_eq(_fx.velocities, [Vector2.ZERO], "standing drops have no directional stretch")
	_leak.step(STILL_TICKS - 1, ORIGIN, _fx)
	assert_eq(_fx.positions.size(), 1, "a drop resets the standing timer")
	_leak.step(1, ORIGIN, _fx)
	assert_eq(_fx.positions, [ORIGIN, ORIGIN])
	assert_eq(_leak.drips, 2)
	assert_eq(_leak.left, BLEED_TICKS - 2 * STILL_TICKS)


func test_timed_drop_includes_slow_motion_and_becomes_the_next_trail_anchor() -> void:
	_leak.start()
	_leak.step(1, ORIGIN, _fx)
	var slow: Vector2 = Vector2(0.0, EVERY_PX / 2.0)
	_leak.step(STILL_TICKS - 1, ORIGIN + slow, _fx)
	assert_eq(_fx.positions, [ORIGIN + slow])
	assert_eq(_fx.velocities, [slow / float(STILL_TICKS)])
	_leak.step(1, ORIGIN + slow * 2.0, _fx)
	assert_eq(_fx.positions.size(), 1, "a timed drop also resets the distance anchor")
	_leak.step(1, ORIGIN + slow + Vector2(EVERY_PX, 0.0), _fx)
	assert_eq(_fx.positions.size(), 2)
	assert_eq(_fx.velocities[1], Vector2(EVERY_PX / 2.0, 0.0))


func test_simultaneous_distance_and_time_thresholds_produce_one_drop() -> void:
	_leak.start()
	_leak.step(1, ORIGIN, _fx)
	_leak.step(STILL_TICKS - 1, ORIGIN + Vector2(EVERY_PX, 0.0), _fx)
	assert_eq(_fx.positions, [ORIGIN + Vector2(EVERY_PX, 0.0)])
	assert_eq(_leak.drips, 1)


func test_bleeding_includes_the_last_tick_then_stops() -> void:
	_leak.start()
	_leak.step(BLEED_TICKS - 1, ORIGIN, _fx)
	assert_eq(_leak.left, 1)
	var last: Vector2 = ORIGIN + Vector2(EVERY_PX, 0.0)
	_leak.step(1, last, _fx)
	assert_eq(_leak.left, 0)
	assert_eq(_fx.positions[-1], last, "the final active tick can still leave a drop")
	var count: int = _fx.positions.size()
	_leak.step(STILL_TICKS, last + Vector2(EVERY_PX, 0.0), _fx)
	assert_eq(_leak.left, 0)
	assert_eq(_fx.positions.size(), count, "the leak has ended")
	assert_eq(_leak.drips, count)


func test_an_expired_leak_ignores_further_steps_even_after_a_large_tick_batch() -> void:
	_leak.start()
	_leak.step(BLEED_TICKS + 1, ORIGIN, _fx)
	var remaining: int = _leak.left
	var count: int = _fx.positions.size()
	_leak.step(1, ORIGIN + Vector2(EVERY_PX, 0.0), _fx)
	assert_eq(_leak.left, remaining)
	assert_eq(_fx.positions.size(), count)


func test_a_new_hit_refreshes_duration_and_restarts_the_standing_timer() -> void:
	_leak.start()
	_leak.step(STILL_TICKS, ORIGIN, _fx)
	_leak.step(STILL_TICKS - 1, ORIGIN, _fx)
	_leak.start()
	assert_eq(_leak.left, BLEED_TICKS, "a new hit refreshes rather than adds duration")
	assert_eq(_leak.drips, 1, "the trail's cumulative count survives another hit")
	_leak.step(1, ORIGIN, _fx)
	assert_eq(_fx.positions.size(), 1, "the previous hit's timer does not cause an early drip")
	_leak.step(STILL_TICKS - 1, ORIGIN, _fx)
	assert_eq(_fx.positions.size(), 2)
	assert_eq(_leak.left, BLEED_TICKS - STILL_TICKS)


func test_unknown_position_and_missing_renderer_leave_no_drop_and_no_anchor() -> void:
	_leak.start()
	_leak.step(STILL_TICKS, Vector2.INF, _fx)
	_leak.step(STILL_TICKS, ORIGIN + Vector2(500.0, 0.0), null)
	assert_eq(_fx.positions.size(), 0)
	assert_eq(_leak.drips, 0)
	_leak.step(1, ORIGIN, _fx)
	assert_eq(_fx.positions.size(), 0, "rejected positions do not become trail anchors")
	_leak.step(1, ORIGIN + Vector2(EVERY_PX, 0.0), _fx)
	assert_eq(_fx.velocities, [Vector2(EVERY_PX / 2.0, 0.0)])
