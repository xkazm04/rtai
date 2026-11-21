extends GutTest


func _order(seed_value: int) -> Array[StringName]:
	var street: GauntletStreet = GauntletStreet.new(RngRegistry.new(seed_value))
	var ids: Array[StringName] = []
	for _i: int in 50:
		ids.append(street.current().id)
		assert_true(street.advance_to(street.current().end_x()))
	return ids


func test_seed_selects_the_order() -> void:
	var first: Array[StringName] = _order(7)
	assert_eq(first, _order(7))
	assert_ne(first, _order(8))


func test_window_keeps_previous_current_next_over_fifty_advances() -> void:
	var street: GauntletStreet = GauntletStreet.new(RngRegistry.new(42))
	assert_eq(street.window.size(), 2)
	for i: int in range(1, 51):
		var behind: GauntletSegment = street.current()
		var ahead: GauntletSegment = street.window[-1]
		assert_false(street.advance_to(behind.end_x() - 0.01))
		assert_true(street.advance_to(behind.end_x()))
		assert_eq(street.index, i)
		assert_eq(street.window.size(), 3)
		assert_same(street.window[0], behind)
		assert_same(street.current(), ahead)
		assert_eq(street.window[2].start_x, ahead.end_x())
		assert_false(street.advance_to(behind.start_x))


func test_every_template_has_cover_clear_spawns_and_clear_crossings() -> void:
	var t: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	var crossings: int = 0
	var ids: Array[StringName] = []
	for row: Dictionary in t.array(t.raw, "segments"):
		var block: GauntletSegment = GauntletSegment.new(t, row, 90.0)
		assert_false(ids.has(block.id), String(block.id))
		ids.append(block.id)
		assert_gte(block.spawns.size(), 3, String(block.id))
		var north: bool = false
		var south: bool = false
		var ahead: bool = false
		for at: Vector2 in block.spawns:
			north = north or at.y < -2.0
			south = south or at.y > 2.0
			ahead = ahead or (absf(at.y) < 1.0 and at.x > block.start_x + block.length_m * 0.5)
		assert_true(north and south and ahead, "%s needs front and flank spawns" % block.id)
		var has_cover: bool = false
		for p: ArenaStation.Prop in block.station.props:
			var rect: Rect2 = Rect2(p.at - p.size * 0.5, p.size)
			has_cover = has_cover or p.kind == "cover_high"
			if block.crossing.has_area():
				assert_false(rect.intersects(block.crossing), "%s %s" % [block.id, p.at])
			for at: Vector2 in block.spawns:
				assert_true(block.bounds.has_point(at), "%s spawn %s" % [block.id, at])
				assert_false(rect.grow(0.5).has_point(at), "%s spawn %s" % [block.id, at])
		assert_true(has_cover, String(block.id))
		crossings += 1 if block.crossing.has_area() else 0
	assert_gte(ids.size(), 8)
	assert_gt(crossings, 0)
	assert_true(t.ok())


func _session(bot: GauntletPilot, run: GauntletRun = null) -> GauntletSession:
	if run == null:
		run = GauntletRun.new()
	run.seed = 7
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var s: GauntletSession = GauntletSession.open_street(bus, data, run, bot)
	bot.bind(run, s)
	return s


func test_walker_crosses_blocks_on_the_sim_clock_starting_with_only_hands() -> void:
	var s: GauntletSession = _session(GauntletWalker.new())
	var arena: CombatArena = s.stage.arena
	assert_eq(arena.rivet.weapon, &"")
	assert_null(arena.gun)
	assert_null(s.pilot.carry)
	assert_true(s.street.current().bounds.has_point(arena.rivet.pos))
	var forms: GhostForms = s.pilot.ghosts.forms
	for id: StringName in forms.table.order:
		forms.selected = id
		assert_false(forms.locks.allows(forms.table, id))
		assert_eq(forms.press_transform(), GhostLocks.LOCKED)
	for _tick: int in 900:
		s.step()
	assert_gte(s.street.index, 2)
	assert_eq(s.street.window.size(), 3)
	assert_true(s.street.current().bounds.has_point(arena.rivet.pos))
	assert_false(s.stage.walls.blocks(Vector2(12, -9), Vector2(12, 9)))
	s.close()


func test_fallback_clears_three_waves_through_player_input() -> void:
	var run: GauntletRun = GauntletRun.new()
	run.seed = 7
	var walker: GauntletWalker = GauntletWalker.new()
	walker.configure(&"average", &"random", run.seed)
	var s: GauntletSession = _session(walker, run)
	var waves: GauntletWaves = GauntletWaves.attach(s, run, walker, 3)
	while not waves.done and s.tick() < 3 * (GauntletWaves.TIMEOUT_TICKS + 600):
		s.step()
	assert_true(waves.done)
	assert_true(run.alive)
	assert_eq(run.picks.size(), 3)
	assert_eq(run.wave, 3)
	assert_gt(s.pilot.melee.landed, 0)
	s.close()


func test_arena_culls_hostile_and_player_rounds_at_a_street_cover_face() -> void:
	var s: GauntletSession = _session(GauntletWalker.new())
	for p: ArenaStation.Prop in s.street.current().station.props:
		if p.kind != "cover_high":
			continue
		for from_rivet: bool in [true, false]:
			var shot: Shot = Shot.new()
			shot.from_rivet = from_rivet
			shot.pos = p.at - Vector2(p.size.x * 0.5 + 0.1, 0)
			shot.vel = Vector2(24, 0)
			s.stage.arena.shots.append(shot)
		break
	assert_eq(s.stage.arena.shots.size(), 2)
	s.step()
	assert_eq(s.stage.dodges.blocked, 2)
	assert_eq(s.stage.arena.shots.size(), 0)
	s.close()


func test_arena_replaces_retired_collision_and_routes_over_fifty_advances() -> void:
	var s: GauntletSession = _session(GauntletWalker.new())
	var arena: CombatArena = s.stage.arena
	var walls: ArenaWalls = s.stage.walls
	for _i: int in 50:
		var next: Vector2 = Vector2(s.street.current().end_x() + 0.5, 0.0)
		arena.rivet.pos = next
		s.step()
		assert_eq(s.street.window.size(), 3)
		var count: int = 1  # back wall
		for segment: GauntletSegment in s.street.window:
			count += segment.station.props.size()
		assert_same(s.stage.walls, walls)
		assert_same(arena.walls, walls)
		assert_eq(walls.kinds.size(), count)
		assert_eq(walls.boxes.size(), count)
		assert_true(arena.guard_map.region().has_point(next))
		var retired: Vector2 = Vector2(s.street.window[0].start_x - 8.0, 0.0)
		assert_false(s.stage.walls.blocks(retired, retired + Vector2(0.0, 9.0)))
		assert_false(arena.guard_map.region().has_point(retired))
	s.close()


func test_a_closed_seam_constrains_only_its_enrolled_fighters() -> void:
	var s: GauntletSession = _session(GauntletWalker.new())
	var arena: CombatArena = s.stage.arena
	var block: GauntletSegment = s.street.current()
	var beyond: Vector2 = Vector2(block.end_x() + 2.0, 0.0)
	var guest: Fighter = arena.spawn_guard(beyond)
	var member: Fighter = arena.squad_ai.spawn_member(arena, block.spawns[0], &"patrol_cop")
	var limits: Rect2 = block.road_bounds(member.radius_m)
	guest.pos = beyond
	member.pos = beyond
	arena.squad_ai.pit.bounds = limits
	s.street.forward_limit = limits.end.x
	s.street.step(s.stage, s.tick())
	assert_false(arena.squad_ai.owns(guest))
	assert_eq(guest.pos, beyond)
	assert_almost_eq(member.pos.x, limits.end.x, 0.001)
	s.close()
