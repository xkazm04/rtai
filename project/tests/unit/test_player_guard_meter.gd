extends GutTest

var arena: CombatArena
var guard: PlayerGuard
var tuning: GuardTuning
var foe: Fighter


func before_each() -> void:
	tuning = GuardTuning.load_table()
	guard = PlayerGuard.new(tuning)
	var bus: EventBus = autofree(EventBus.new())
	arena = CombatArena.new(CombatTuning.shipped(), bus, RngRegistry.new(22).stream(&"combat"))
	arena.guard = guard
	DeflectRule.of(arena).pass_ratio_k = 0.0
	arena.rivet.facing = Vector2.RIGHT
	foe = arena.spawn_guard(Vector2.RIGHT)
	foe.pos = arena.rivet.pos + Vector2.RIGHT
	guard.step(true, true)


func _incoming() -> Shot:
	var s: Shot = Shot.new()
	s.from_rivet = false
	s.weapon = &"pistol"
	s.pos = Vector2.RIGHT
	s.vel = Vector2.LEFT * 60.0
	s.damage = 1.0
	arena.shots.append(s)
	return s


func test_break_on_last_round_allows_next_hit_in_same_tick() -> void:
	var count: int = ceili(tuning.meter_max / tuning.drain_per_round)
	for hit: int in count:
		var s: Shot = _incoming()
		ArenaProjectiles.step_shots(arena)
		assert_true(s.from_rivet)
		assert_almost_eq(
			guard.meter(),
			maxf(0.0, 1.0 - (hit + 1) * tuning.drain_per_round / tuning.meter_max),
			0.00001
		)
		assert_eq(guard.broken(), hit + 1 == count)
		arena.shots.clear()
	assert_eq(guard.breaks, 1)
	assert_eq(guard.deflects, count)
	var hp: float = arena.rivet.hp
	var next: Shot = _incoming()
	ArenaProjectiles.step_shots(arena)
	assert_eq(arena.rivet.hp, hp - next.damage)
	assert_eq(guard.breaks, 1)


func test_exact_stagger_then_lowered_refill_delay_and_rate() -> void:
	var hits: int = ceili(tuning.meter_max / tuning.melee_drain)
	for hit: int in hits:
		arena.damage(arena.rivet, 1.0, foe.id, &"baton", &"melee")
	assert_eq(guard.melee_blocks, hits)
	assert_eq(guard.breaks, 1)
	var stagger_ticks: int = CombatTuning.ticks(tuning.stagger_s)
	for tick: int in stagger_ticks:
		assert_true(guard.broken())
		guard.step(true, true)
		assert_false(guard.up())
		assert_eq(guard.meter(), 0.0)
	assert_false(guard.broken())
	for tick: int in CombatTuning.ticks(tuning.refill_delay_s):
		guard.step(false, true)
		assert_eq(guard.meter(), 0.0)
	var per_tick: float = tuning.refill_per_s * SimClock.TICK_DT / tuning.meter_max
	for tick: int in ceili(1.0 / per_tick) + 5:
		guard.step(false, true)
		assert_almost_eq(guard.meter(), minf(1.0, (tick + 1) * per_tick), 0.00001)
	assert_eq(guard.meter(), 1.0)


func test_capacity_multiplier_and_lowering_without_breaking() -> void:
	guard.meter_k = 1.5
	var cap: float = tuning.meter_max * guard.meter_k
	assert_eq(guard.meter(), 1.0)
	arena.damage(arena.rivet, 1.0, foe.id, &"claw")
	var drained: float = 1.0 - tuning.melee_drain / cap
	for tick: int in 120:
		guard.step(true, true)
	assert_almost_eq(guard.meter(), drained, 0.00001)
	for tick: int in CombatTuning.ticks(tuning.refill_delay_s):
		guard.step(true, false)
		assert_false(guard.up())
		assert_almost_eq(guard.meter(), drained, 0.00001)
	guard.step(false, true)
	assert_almost_eq(guard.meter(), drained + tuning.refill_per_s * SimClock.TICK_DT / cap, 0.00001)
	for tick: int in 240:
		guard.step(false, true)
	assert_eq(guard.meter(), 1.0)


func test_zero_capacity_lowers_guard_and_reports_an_empty_meter() -> void:
	guard.meter_k = 0.0
	assert_false(guard.up())
	assert_false(guard.broken())
	assert_eq(guard.meter(), 0.0)
	guard.step(true, true)
	assert_false(guard.up())
	assert_eq(guard.meter(), 0.0)


func test_serialized_guard_distinguishes_up_from_just_lowered() -> void:
	var raised: StreamPeerBuffer = StreamPeerBuffer.new()
	guard.write_state(raised)
	guard.lower()
	var lowered: StreamPeerBuffer = StreamPeerBuffer.new()
	guard.write_state(lowered)
	assert_ne(raised.data_array, lowered.data_array)
