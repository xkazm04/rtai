extends GutTest


func test_existing_member_replans_around_the_replacement_maps_wall() -> void:
	var rng: RandomNumberGenerator = RngRegistry.new(22).stream(&"combat")
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	var bounds: Rect2 = Rect2(-20, -20, 40, 40)
	arena.guard_map = GuardRouteMap.new(bounds, [], null, 0.45)
	var squad: ArenaSquad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	var guard: Fighter = squad.spawn_member(arena, Vector2(6, 0), &"robot_thug")
	for tick: int in range(1, 15):
		arena.step(tick)
	var mind: SquadMind = squad.minds[guard.id]
	assert_true(mind.agent.sees)
	var wall: Rect2 = Rect2(2, -2, 1, 4)
	var replacement: GuardRouteMap = GuardRouteMap.new(bounds.grow(3), [wall], null, 0.45)
	squad.set_route_map(replacement)
	arena.step(15)
	assert_same(squad.minds[guard.id], mind)
	assert_false(mind.agent.sees)
	assert_eq(mind.destination(), arena.rivet.pos)
	assert_gt(replacement.searches, 0)
	assert_eq(squad.pit.bounds, replacement.region().grow(-GuardRouteMap.WALL_MARGIN_M))
	assert_true(guard.pursuit.advance(guard, arena.rivet.pos, 0.0))
	var later: Fighter = squad.spawn_member(arena, guard.pos, &"robot_thug")
	assert_true(later.pursuit.advance(later, arena.rivet.pos, 0.0))
