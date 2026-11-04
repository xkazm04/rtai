extends GutTest
## Lane gunplay: a table rocket bursts on the arena prop it hits (blast + splash) instead of
## vanishing; a lobbed molotov flies over the props and lands at its aim point.


func _arena(weapon: StringName) -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.gun = GunHand.make(WeaponTable.shipped(), weapon, reg.stream(&"gunplay"))
	return arena


func _walls() -> ArenaWalls:
	var w: ArenaWalls = ArenaWalls.new()
	w.boxes.append(Rect2(Vector2(4.0, -1.0), Vector2(1.0, 2.0)))
	return w


func _run(arena: CombatArena, ticks: int) -> ArenaDodges:
	var d: ArenaDodges = ArenaDodges.new()
	var walls: ArenaWalls = _walls()
	for i: int in ticks:
		d.cull(arena, walls)
		arena.step(i + 1)
	return d


func test_a_rocket_bursts_on_the_crate_it_hits() -> void:
	var arena: CombatArena = _arena(&"rocket_launcher")
	var g: Fighter = arena.spawn_guard(Vector2(5.5, 1.0))
	g.pos = Vector2(5.5, 1.0)
	g.cooldown = 9999
	assert_true(arena.rivet_fire(Vector2(12.0, 0.0)))
	var d: ArenaDodges = _run(arena, 30)
	assert_eq(d.blocked, 1, "the crate stops the rocket")
	assert_eq(arena.areas.blasts.size(), 1, "and it bursts there")
	assert_almost_eq(arena.areas.blasts[0].x, 4.0, 0.6)
	assert_false(g.alive(), "a guard 1.5 m from the crate dies in the splash")


func test_a_bottle_flies_over_the_crate() -> void:
	var arena: CombatArena = _arena(&"molotov")
	assert_true(arena.rivet_fire(Vector2(9.0, 0.0)))
	var d: ArenaDodges = _run(arena, 90)
	assert_eq(d.blocked, 0)
	assert_eq(arena.areas.patches.size(), 1, "the bottle lands past the crate")
	assert_gt(arena.areas.patches[0].x, 6.0)
