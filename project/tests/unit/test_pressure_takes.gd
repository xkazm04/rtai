extends GutTest
## The n27 dev takes: two rocket troopers against a steady circle and a circle with dashes, and
## the 6 m rifle takes against the guard and the plasma sword. Seed 1, fixed 60 Hz ticks.

var _takes: Array[PressureTake] = []
var _fates: Dictionary[String, PressureFates] = {}


func after_each() -> void:
	for take: PressureTake in _takes:
		take.session.close()
	_takes.clear()
	_fates.clear()


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
	assert_gte(pair.direct, 1, "at least one rocket bursts on his body")
	assert_almost_eq(pair.hp_lost, take.arena.rivet.max_hp, 0.01, "the split sums to his health")


func test_dash_across_each_line_takes_far_less() -> void:
	var circle: PressureTake = _run("pair_circle")
	var dash: PressureTake = PressureTake.new()
	assert_true(dash.open("pair_dash", 1))
	_takes.append(dash)
	var hp_at_600: float = 0.0
	while dash.tick < dash.length:
		dash.advance()
		if dash.tick == 10 * SimClock.TICK_RATE:
			hp_at_600 = dash.arena.rivet.hp
	var pair: PressurePair = dash.pair
	assert_eq(pair.hp_at_10s, hp_at_600, "the summary reads his HP at exactly 10 s")
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


## A 6 m sword take run to its end with every round's fate and arrival tick recorded.
func _fated(id: String) -> PressureTake:
	var take: PressureTake = PressureTake.new()
	assert_true(take.open(id, 1), "%s opens" % id)
	_takes.append(take)
	var fates: PressureFates = PressureFates.new(MeleeTable.weapon(&"plasma_sword").deflect_m)
	while take.tick < take.length:
		take.advance()
		fates.observe(take.arena, take.session.pilot.melee.combo.hit_index, take.tick)
	_fates[id] = fates
	return take


func _closest_arrivals(id: String) -> int:
	var ticks: Array[int] = _fates[id].arrivals.duplicate()
	ticks.sort()
	var closest: int = 1_000_000
	for i: int in range(1, ticks.size()):
		closest = mini(closest, ticks[i] - ticks[i - 1])
	return closest


func test_spaced_sword_rounds_reach_rivet_a_swing_apart() -> void:
	var spaced: PressureTake = _fated("blade6_spaced")
	var shipped: PressureTake = _fated("blade6")
	assert_gte(_fates["blade6_spaced"].arrivals.size(), 60, "about one round per 36 ticks")
	assert_gte(_closest_arrivals("blade6_spaced"), 34, "no two rounds within 34 ticks at Rivet")
	assert_lt(_closest_arrivals("blade6"), 34, "the shipped pairs are 18 ticks apart")
	assert_eq(spaced.rifles.fired, _fates["blade6_spaced"].arrivals.size(), "every round counted")
	var back_spaced: float = float(spaced.rifles.returned) / float(spaced.rifles.fired)
	var back_shipped: float = float(shipped.rifles.returned) / float(shipped.rifles.fired)
	assert_gt(back_spaced, back_shipped, "a fresh swing for every round turns back more of them")
	assert_eq(spaced.arena.kills, 0, "no shooter fell, so every return was counted")


func test_spaced_sword_is_never_hit_mid_swing() -> void:
	var spaced: PressureTake = _fated("blade6_spaced")
	var fates: PressureFates = _fates["blade6_spaced"]
	assert_eq(fates.unswung_busy, 0, "no round arrives while the blade is mid-swing")
	assert_eq(fates.missed, 0, "every round reaches Rivet")
	assert_eq(fates.returned, spaced.rifles.returned, "the fate count agrees with the take")


func test_rifle_takes_fire_their_pinned_counts_and_spacing() -> void:
	var guard: PressureTake = _fated("guard6")
	var sword: PressureTake = _fated("blade6")
	assert_eq(guard.rifles.fired, 78, "guard take, seed 1: salvos of six, a beat of 180 ticks")
	assert_eq(sword.rifles.fired, 130, "sword take, seed 1: pairs on a 36 tick beat")
	assert_eq(_closest_arrivals("guard6"), 9, "guard rounds arrive 9 ticks apart")
	assert_eq(_closest_arrivals("blade6"), 18, "sword rounds arrive 18 ticks apart")
