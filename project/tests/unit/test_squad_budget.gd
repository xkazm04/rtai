extends GutTest

const WALL: Rect2 = Rect2(-1, -24, 2, 48)


func _arena() -> CombatArena:
	var rng: RandomNumberGenerator = RngRegistry.new(12).stream(&"combat")
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [WALL], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	arena.rivet.pos = Vector2(6, 0)
	return arena


func test_sparse_ids_that_share_a_slot_spread_their_cover_searches() -> void:
	var arena: CombatArena = _arena()
	arena.squad_ai.pit.roster.max_shooters = 0
	for i: int in range(3 * SquadMind.PLAN_TICKS + 1):
		if i % SquadMind.PLAN_TICKS == 0:
			@warning_ignore("return_value_discarded")
			arena.squad_ai.spawn_member(arena, Vector2(-4, 0), &"patrol_cop")
		else:
			arena.spawn_guard(Vector2.ZERO).hp = 0
	var map: GuardRouteMap = arena.guard_map
	for tick: int in range(SquadMind.PLAN_TICKS + 4):
		var before: int = map.cover_searches
		arena.step(tick)
		assert_lte(map.cover_searches - before, 1)
	assert_eq(map.cover_searches, 4, "every overdue guard gets its turn")


func test_blocked_routes_queue_by_id_and_drop_dead_requests() -> void:
	var arena: CombatArena = _arena()
	for i: int in 7:
		var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2.ZERO)
		h.pos = Vector2(-4, -9 + 3 * i)
	# Simultaneous blocked goals, as when a wave breaks morale together.
	var squad: ArenaSquad = arena.squad_ai
	var ordered: Array[Fighter] = squad.assign(arena)
	for h: Fighter in ordered:
		squad.minds[h.id]._set_goal(arena.rivet.pos, arena.guard_map)
	assert_eq(arena.guard_map.searches, 2)
	for h: Fighter in ordered.slice(2):
		var mind: SquadMind = squad.minds[h.id]
		assert_true(mind.route_pending)
		assert_gt(mind._walk().dot(h.pos.direction_to(arena.rivet.pos)), 0.0)
	ordered[2].hp = 0
	for turn: int in [1, 2]:
		var before: int = arena.guard_map.searches
		arena.tick = turn
		@warning_ignore("return_value_discarded")
		squad.assign(arena)
		assert_eq(arena.guard_map.searches - before, 2)
		for i: int in range(3, 7):
			assert_eq(squad.minds[ordered[i].id].route_pending, i >= 3 + turn * 2)
	assert_false(squad.minds.has(ordered[2].id))


func test_queued_cover_request_keeps_the_previous_motion() -> void:
	var arena: CombatArena = _arena()
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2(-4, 0), &"patrol_cop")
	var squad: ArenaSquad = arena.squad_ai
	squad.pit.roster.max_shooters = 0
	@warning_ignore("return_value_discarded")
	squad.assign(arena)
	var mind: SquadMind = squad.minds[h.id]
	mind._set_goal(h.pos + Vector2.UP * 5.0, arena.guard_map)
	var expected: Vector2 = mind._walk()
	squad.pit.tick = SquadMind.PLAN_TICKS - h.id
	mind.cover_ceiling = arena.guard_map.cover_searches
	assert_gt(expected.length(), 0.0)
	assert_eq(mind.velocity(squad.pit, arena.guard_map, 0.0), expected)
	assert_true(mind.plan_pending)
	squad.pit.tick += 1
	mind.cover_ceiling += 1
	@warning_ignore("return_value_discarded")
	mind.velocity(squad.pit, arena.guard_map, 0.0)
	assert_false(mind.plan_pending)
	var granted: int = arena.guard_map.cover_searches
	mind.cover_ceiling += 1
	squad.pit.tick += SquadMind.PLAN_TICKS - 1
	@warning_ignore("return_value_discarded")
	mind.velocity(squad.pit, arena.guard_map, 0.0)
	assert_eq(arena.guard_map.cover_searches, granted, "leave the contested slot free")
	squad.pit.tick += 1
	@warning_ignore("return_value_discarded")
	mind.velocity(squad.pit, arena.guard_map, 0.0)
	assert_eq(arena.guard_map.cover_searches, granted + 1, "reuse the granted slot")


func test_each_hostile_checks_sight_at_most_twice_even_when_firing_or_swinging() -> void:
	var arena: CombatArena = _arena()
	var rng: RandomNumberGenerator = RngRegistry.new(11).stream(&"combat")
	for id: StringName in [&"contractor", &"riot_cop"]:
		var h: Fighter = arena.squad_ai.spawn_member(arena, arena.rivet.pos, id)
		h.pos = arena.rivet.pos + Vector2.RIGHT
	var peak: int = 0
	for tick: int in 160:
		arena.tick = tick
		for h: Fighter in arena.squad_ai.assign(arena):
			var before: int = arena.guard_map.sight_checks
			@warning_ignore("return_value_discarded")
			arena.squad_ai.step(h, arena, rng)
			var checks: int = arena.guard_map.sight_checks - before
			assert_between(checks, 1, 2)
			peak = maxi(peak, checks)
	assert_eq(peak, 2)


func test_only_wave_members_plan_and_station_guards_keep_their_approach() -> void:
	var arena: CombatArena = _arena()
	var control: CombatArena = _arena()
	control.squad_ai = null
	var station: Fighter = arena.spawn_guard(Vector2(25, 0))
	var reference: Fighter = control.spawn_guard(Vector2(25, 0))
	var wave: Fighter = arena.squad_ai.spawn_member(arena, Vector2(11, 0), &"robot_thug")
	for tick: int in 20:
		control.step(tick)
		arena.step(tick)
		assert_eq(station.pos, reference.pos)
		assert_eq(station.facing, reference.facing)
		assert_eq(station.cooldown, reference.cooldown)
	assert_eq(station.archetype, &"")
	assert_false(arena.squad_ai.owns(station))
	assert_false(arena.squad_ai.minds.has(station.id))
	assert_true(arena.squad_ai.owns(wave))
	assert_eq(arena.squad_ai.pit.agents.size(), 1)
	assert_eq(arena.squad_ai.pit.agents[0].id, wave.id)
	arena.squad_ai.clear_wave()
	assert_false(arena.squad_ai.owns(wave))


func test_a_cover_holder_spends_its_peek_only_in_firing_range() -> void:
	var arena: CombatArena = _arena()
	var squad: ArenaSquad = arena.squad_ai
	var h: Fighter = squad.spawn_member(arena, Vector2.ZERO, &"patrol_cop")
	@warning_ignore("return_value_discarded")
	squad.assign(arena)
	var mind: SquadMind = squad.minds[h.id]
	var e: EnemyAgent = mind.agent
	mind.motion = EnemyAgent.State.COVER
	e.arch.peek_ticks = 2
	e.pos = Vector2.ZERO
	e.sees = true
	e.token = true
	for tick: int in 3:
		mind._update_peek(tick, Vector2.RIGHT * (e.arch.attack_m + 1.0))
		assert_true(e.token)
	mind._update_peek(3, Vector2.RIGHT * e.arch.attack_m)
	assert_true(e.token)
	mind._update_peek(4, Vector2.RIGHT * e.arch.attack_m)
	assert_false(e.token)
	arena.tick = 5
	assert_false(mind.available(h, arena), "the holder must return to cover before its next peek")
