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


func _damaging_share(take: PressureTake) -> float:
	var pair: PressurePair = take.pair
	return float(pair.direct + pair.splash) / maxf(float(pair.launches), 1.0)


func test_steady_circle_is_hit_and_goes_down() -> void:
	var take: PressureTake = _run("pair_circle")
	var pair: PressurePair = take.pair
	assert_gt(pair.launches, 4, "both troopers keep firing")
	assert_gt(_damaging_share(take), 0.6, "a steady circle takes damage from most rockets")
	assert_gt(pair.death_tick, 0, "and goes down")
	assert_lt(pair.death_tick, 10 * SimClock.TICK_RATE)
	assert_eq(pair.hp_at_10s, 0.0, "he is already down when the 10 s mark passes")
	assert_eq(pair.other, 0, "every HP lost came from a rocket")
	assert_almost_eq(pair.hp_lost, take.arena.rivet.max_hp, 0.01, "the split sums to his health")


func test_dash_across_each_line_takes_far_less() -> void:
	var circle: PressureTake = _run("pair_circle")
	var dash: PressureTake = _run("pair_dash")
	var pair: PressurePair = dash.pair
	assert_gt(dash.session.pilot.motion.dashes, 5, "he dashes on the rocket lines")
	assert_gt(pair.dash_presses, dash.session.pilot.motion.dashes, "some presses fall in cooldown")
	assert_eq(pair.death_tick, 0, "and survives the whole take")
	assert_lt(_damaging_share(dash), _damaging_share(circle) * 0.5, "far fewer rockets land")
	assert_gt(dash.arena.rivet.hp, 50.0)
	assert_between(pair.hp_at_10s, 90.0, 100.0, "nearly untouched at 10 s")
	assert_almost_eq(pair.hp_lost, 100.0 - dash.arena.rivet.hp, 0.01, "the split sums to HP lost")
	assert_gt(pair.splash, 0, "rockets that miss still graze him with their blast")


func test_circle_pulls_back_to_the_radius_from_either_side() -> void:
	var take: PressureTake = PressureTake.new()
	assert_true(take.open("pair_circle", 1))
	_takes.append(take)
	for gap: float in [20.0, 9.0, 4.0]:
		take.arena.rivet.pos = take.pair.centre + Vector2(gap, 0)
		var input: TickInput = TickInput.new()
		@warning_ignore("return_value_discarded")
		take.pair.drive(input, 1)
		var pull: float = clampf((PressurePair.RADIUS_M - gap) * 0.5, -0.6, 0.6)
		var along: float = pull / sqrt(1.0 + pull * pull)
		assert_almost_eq(
			float(input.move_x), along * TickInput.AXIS_MAX, 1.5, "inward pull at %.0f m" % gap
		)


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
