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
		var h: Fighter = arena.spawn_guard(Vector2(-4, 0), &"patrol_cop")
		if i % SquadMind.PLAN_TICKS != 0:
			h.hp = 0
	var map: GuardRouteMap = arena.guard_map
	for tick: int in range(SquadMind.PLAN_TICKS + 4):
		var before: int = map.cover_searches
		arena.step(tick)
		assert_lte(map.cover_searches - before, 1)
	assert_eq(map.cover_searches, 4, "every overdue guard gets its turn")


func test_blocked_routes_queue_by_id_and_drop_dead_requests() -> void:
	var arena: CombatArena = _arena()
	for i: int in 7:
		var h: Fighter = arena.spawn_guard(Vector2.ZERO)
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
	var h: Fighter = arena.spawn_guard(Vector2(-4, 0), &"patrol_cop")
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
		var h: Fighter = arena.spawn_guard(arena.rivet.pos, id)
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
