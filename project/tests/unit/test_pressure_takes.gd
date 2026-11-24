extends GutTest
## The n27 dev takes: two rocket troopers against a steady circle and a circle with dashes, and
## the 6 m rifle takes against the guard and the plasma sword. Seed 1, fixed 60 Hz ticks.

var _takes: Array[PressureTake] = []


func after_each() -> void:
	for take: PressureTake in _takes:
		take.session.close()
	_takes.clear()


func _run(id: String) -> PressureTake:
	var take: PressureTake = PressureTake.new()
	assert_true(take.open(id, 1), "%s opens" % id)
	_takes.append(take)
	while take.tick < take.length:
		take.advance()
	return take


func _hit_share(take: PressureTake) -> float:
	return float(take.pair.hits) / maxf(float(take.pair.launches), 1.0)


func test_steady_circle_is_hit_and_goes_down() -> void:
	var take: PressureTake = _run("pair_circle")
	assert_gt(take.pair.launches, 4, "both troopers keep firing")
	assert_gt(_hit_share(take), 0.6, "a steady circle is hit by most rockets")
	assert_gt(take.pair.death_tick, 0, "and goes down")
	assert_lt(take.pair.death_tick, 15 * SimClock.TICK_RATE)


func test_dash_across_each_line_takes_far_less() -> void:
	var circle: PressureTake = _run("pair_circle")
	var dash: PressureTake = _run("pair_dash")
	assert_gt(dash.session.pilot.motion.dashes, 5, "he dashes on the rocket lines")
	assert_eq(dash.pair.death_tick, 0, "and survives the whole take")
	assert_lt(_hit_share(dash), _hit_share(circle) * 0.5, "far fewer rockets land")
	assert_gt(dash.arena.rivet.hp, 50.0)


func test_guard_at_6m_returns_enough_rounds_to_read_a_share() -> void:
	var take: PressureTake = _run("guard6")
	_assert_share(take, 0.05, 0.5)


func test_sword_at_6m_returns_enough_rounds_to_read_a_share() -> void:
	var take: PressureTake = _run("blade6")
	_assert_share(take, 0.05, 0.55)


func _assert_share(take: PressureTake, low: float, high: float) -> void:
	var rifles: PressureRifles = take.rifles
	assert_gte(rifles.returned, 30, "at least 30 returned rounds")
	assert_eq(take.arena.kills, 0, "no shooter fell, so every return was counted")
	var share: float = float(rifles.struck) / float(rifles.returned)
	assert_between(share, low, high, "share of returns that hit a shooter, curve 24 to 31 %")
