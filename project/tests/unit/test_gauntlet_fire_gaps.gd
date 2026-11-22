extends GutTest


func _trial(id: StringName, motion: String, rifle_lead: float = -1.0) -> FireGapArena:
	var bus: EventBus = autofree(EventBus.new())
	var registry: RngRegistry = RngRegistry.new(1)
	var arena: FireGapArena = FireGapArena.new(
		CombatTuning.shipped(), bus, registry.stream(&"combat")
	)
	arena.prepare(id, motion, 9.3)
	if rifle_lead >= 0.0:
		(arena.squad_ai as GauntletStreet.StreetSquad).rifle_lead = rifle_lead
	assert_true(arena.measure())
	return arena


func test_street_rifle_gaps_partition_the_interval_between_muzzle_events() -> void:
	var arena: FireGapArena = _trial(&"patrol_cop", "standing")
	var r: Dictionary = arena.result()
	var weapon: StringName = r.weapon
	var rounds: int = r.rounds
	var hits: int = r.hits
	assert_eq(weapon, &"assault-rifle")
	assert_eq(arena.phases.size(), FireGapArena.TICKS)
	assert_gt(rounds, 2)
	assert_eq(rounds, arena.fire_ticks.size())
	var parts: Dictionary[String, int] = r.gap_parts_ticks
	var ticks: int = 0
	for count: int in parts.values():
		ticks += count
	assert_eq(ticks, arena.fire_ticks[-1] - arena.fire_ticks[0])
	assert_eq(parts.muzzle, arena.fire_ticks.size() - 1)
	assert_gt(parts.cooldown, 0)
	assert_gt(parts.burst_gap, 0)
	assert_eq(parts.volley_rest, 0)
	assert_eq(parts.aim_lock, 0)
	assert_eq(hits, arena.hit_ticks.size())
	assert_gt(hits, 0)


func test_hit_flights_overlap_once_and_misses_contribute_no_ticks() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var registry: RngRegistry = RngRegistry.new(1)
	var arena: FireGapArena = FireGapArena.new(
		CombatTuning.shipped(), bus, registry.stream(&"combat")
	)
	arena.prepare(&"patrol_cop", "standing", 9.3)
	arena.rivet.pos = Vector2(5, 0)
	for tick: int in range(1, 10):
		arena.tick = tick
		if tick <= 3:
			var shot: Shot = Shot.new()
			shot.weapon = &"assault-rifle"
			shot.from_rivet = false
			shot.vel = Vector2(60, 0) if tick < 3 else Vector2(0, 60)
			arena.shots.append(shot)
			arena._birth[shot] = tick
		arena._step_shots()
	assert_eq(arena.hit_ticks, [5, 6])
	assert_eq(arena.under_fire.count(1), 6)
	assert_eq(arena.under_fire[6], 0)


func test_rocket_uses_a_real_lock_and_circle_preserves_sprint_speed() -> void:
	var arena: FireGapArena = _trial(&"rocket_trooper", "circle")
	var still: FireGapArena = _trial(&"rocket_trooper", "standing")
	assert_gte(still.fire_ticks.size(), 15)
	assert_gte(arena.fire_ticks.size(), 15)
	assert_gt(arena.hit_ticks.size(), 0)
	assert_gt(still.hit_ticks.size(), arena.hit_ticks.size())
	var parts: Dictionary[String, int] = arena.result().gap_parts_ticks
	assert_gt(parts.tell, 0)
	assert_gt(parts.aim_lock, 0)
	assert_gt(parts.reposition, 0)
	assert_eq(parts.volley_rest, 0)
	for i: int in 90:
		var prev: Vector2 = arena.rivet.pos
		arena._move_target(i + 1)
		assert_almost_eq(arena.rivet.pos.distance_to(prev), 9.3 * SimClock.TICK_DT, 0.0001)
		assert_almost_eq(arena.rivet.pos.distance_to(arena.foe.pos), 10.0, 0.00001)


func test_patrol_rifle_hits_a_circling_runner_with_lead_enabled() -> void:
	var led: FireGapArena = _trial(&"patrol_cop", "circle")
	var flat: FireGapArena = _trial(&"patrol_cop", "circle", 0.0)
	assert_gte(led.hit_ticks.size(), 10)
	assert_eq(flat.hit_ticks.size(), 0)
	assert_eq(led.fire_ticks, flat.fire_ticks)
	var last_hit: int = 0
	for tick: int in led.hit_ticks:
		if tick <= FireGapArena.TICKS:
			assert_lte(tick - last_hit, 3 * SimClock.TICK_RATE)
			last_hit = tick
	assert_lte(FireGapArena.TICKS - last_hit, 3 * SimClock.TICK_RATE)
