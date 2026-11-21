extends GutTest


func _session() -> GauntletSession:
	var run: GauntletRun = GauntletRun.new()
	run.seed = 7
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	return GauntletSession.open_street(bus, data, run, GauntletPilot.new())


func test_cop_and_war_machine_rest_on_the_road_side_after_a_wall_hit() -> void:
	var s: GauntletSession = _session()
	var arena: CombatArena = s.stage.arena
	var block: GauntletSegment = s.street.current()
	var wall: ArenaStation.Prop = block.station.props[1]
	assert_eq(wall.kind, "wall_high")
	var hit: Vector2 = Vector2(block.start_x + 3.0, wall.at.y)
	var foe: Fighter = arena.squad_ai.spawn_member(arena, hit, &"patrol_cop")
	foe.pos = hit
	arena.damage(foe, foe.max_hp, arena.rivet.id, &"claw", &"melee")
	assert_false(foe.alive())
	var expected: float = wall.at.y - wall.size.y * 0.5 - 1.65
	assert_almost_eq(foe.pos.y, expected, 0.001)
	foe.pos.y = wall.at.y + 5.0
	s.step()
	assert_almost_eq(foe.pos.y, expected, 0.001)
	assert_almost_eq(foe.pos.x, hit.x, 0.001)
	var boss: Fighter = arena.squad_ai.spawn_member(arena, hit, &"war_machine")
	boss.pos = hit
	arena.damage(boss, boss.max_hp * 2.0, arena.rivet.id, &"claw", &"melee")
	assert_false(boss.alive())
	assert_almost_eq(boss.pos.y, wall.at.y - wall.size.y * 0.5 - 2.35, 0.001)
	s.close()


func test_corpse_and_blood_bounds_cover_the_entire_resident_window() -> void:
	var s: GauntletSession = _session()
	s.stage.arena.rivet.pos.x = s.street.current().end_x() + 0.1
	s.step()
	var first: GauntletSegment = s.street.window[0]
	var last: GauntletSegment = s.street.window[-1]
	for x: float in [first.start_x + 1.0, last.end_x() - 1.0]:
		assert_false(s.street.solid_px(Vector2(x, 5.8) * SimConst.PX_PER_M))
		assert_true(s.street.solid_px(Vector2(x, 6.5) * SimConst.PX_PER_M))
		assert_true(s.street.pose_solid_px(Vector2(x, 5.8) * SimConst.PX_PER_M))
	s.close()


func test_rest_chooses_the_nearest_free_face_when_cover_meets_a_wall() -> void:
	var boxes: Array[Rect2] = [Rect2(4, 0, 4, 2), Rect2(7, 2, 2, 3)]
	var rest: GauntletRest = GauntletRest.new(Rect2(0, 0, 20, 12), boxes)
	assert_eq(rest.nearest(Vector2(7, 2), 0.5), Vector2(6.5, 2.5))
	assert_eq(rest.nearest(Vector2(7, 6), 0.5), Vector2(7, 6))
	assert_eq(rest.nearest(Vector2(5, -3), 0.5), Vector2(3.5, 0.5))
	assert_true(rest.solid_px(Vector2(8, 3) * SimConst.PX_PER_M))
	assert_false(rest.solid_px(Vector2(10, 3) * SimConst.PX_PER_M))
	# Blood can land here but there's no room for the drawn body's half-width.
	var near: Vector2 = Vector2(9.5, 3) * SimConst.PX_PER_M
	assert_false(rest.solid_px(near))
	assert_true(rest.pose_solid_px(near))
	assert_true(rest.pose_solid_px(Vector2(12, 0.5) * SimConst.PX_PER_M))
	assert_false(rest.pose_solid_px(Vector2(12, 3) * SimConst.PX_PER_M))
