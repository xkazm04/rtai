extends GutTest

const BOX: Rect2 = Rect2(-4, -1, 1, 2)


func _arena(boxes: Array[Rect2] = []) -> CombatArena:
	var streams: RngRegistry = RngRegistry.new(12)
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, streams.stream(&"combat")
	)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), boxes, null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	arena.rivet.hp = 10000
	arena.rivet.max_hp = 10000
	return arena


func _spawn(arena: CombatArena, at: Vector2) -> Fighter:
	var g: Fighter = arena.spawn_guard(at)
	g.pos = at
	g.cooldown = 0
	return g


func test_exact_overlap_separates_within_a_second() -> void:
	var arena: CombatArena = _arena()
	var a: Fighter = _spawn(arena, Vector2(-8, 0))
	var b: Fighter = _spawn(arena, a.pos)
	for tick: int in 60:
		arena.step(tick)
	assert_gt(a.pos.distance_to(b.pos), 0.9)


func test_guard_claims_and_reaches_cover_behind_box() -> void:
	var arena: CombatArena = _arena([BOX])
	arena.squad_ai.pit.roster.max_shooters = 0
	arena.rivet.pos = Vector2(8, 0)
	var g: Fighter = _spawn(arena, Vector2(-6.5, 1))
	for tick: int in 150:
		arena.step(tick)
	var e: EnemyAgent = arena.squad_ai.minds[g.id].agent
	assert_eq(e.state, EnemyAgent.State.COVER)
	assert_false(arena.guard_map.clear_line(g.pos, arena.rivet.pos))
	assert_lt(g.pos.distance_to(EnemySenses.cover_spot(BOX, arena.rivet.pos, e.radius())), 0.5)


func test_firing_bearings_spread_and_bursts_obey_token_limit() -> void:
	var arena: CombatArena = _arena()
	for i: int in 4:
		@warning_ignore("return_value_discarded")
		_spawn(arena, Vector2(-7.0, i - 1.5))
	var bearings: Dictionary[int, Vector2] = {}
	var spread: float = 0.0
	var peak: int = 0
	var flank: bool = false
	for tick: int in 300:
		arena.step(tick)
		var bursts: int = 0
		for g: Fighter in arena.hostiles:
			var e: EnemyAgent = arena.squad_ai.minds[g.id].agent
			flank = flank or e.state == EnemyAgent.State.FLANK
			bursts += int(g.burst_left > 0)
			if e.shot_tick == tick:
				for id: int in bearings:
					if id != g.id:
						spread = maxf(spread, absf(g.pos.angle_to(bearings[id])))
				bearings[g.id] = g.pos
		peak = maxi(peak, bursts)
	assert_true(flank)
	assert_gt(rad_to_deg(spread), 60.0)
	assert_gt(peak, 0)
	assert_lte(peak, arena.squad_ai.pit.roster.max_shooters)


func test_default_stage_uses_guard_approach() -> void:
	var session: ArenaSession = ArenaSession.open(Events, Data)
	var arena: CombatArena = session.stage.arena
	assert_null(arena.squad_ai)
	var g: Fighter = _spawn(arena, arena.rivet.pos + Vector2(0, -18))
	g.pursuit = null
	var at: Vector2 = g.pos
	arena.step(1)
	assert_almost_eq(at.distance_to(g.pos), float(arena.tuning.human["walk_mps"]) / 60, 0.0001)
	session.world.free()


func test_local_query_deduplicates_large_boxes_and_filters_by_distance() -> void:
	var huge: Rect2 = Rect2(-12, -3, 24, 2)
	var map: GuardRouteMap = _arena([huge, Rect2(13, 8, 1, 1)]).guard_map
	assert_eq(map.boxes_near(Vector2.ZERO, 9), [huge])


func test_panic_ends_and_the_next_wave_starts_with_full_morale() -> void:
	var arena: CombatArena = _arena()
	var wave: Array[Fighter] = []
	for i: int in 6:
		wave.append(_spawn(arena, Vector2(24, i)))
	arena.squad_ai.begin_wave(wave)
	var survivor: Fighter = wave.back()
	for h: Fighter in wave:
		if h != survivor:
			h.hp = 0.0
	arena.step(0)
	var e: EnemyAgent = arena.squad_ai.minds[survivor.id].agent
	assert_eq(e.state, EnemyAgent.State.PANIC)
	for tick: int in range(1, arena.squad_ai.pit.roster.panic_ticks + 2):
		arena.step(tick)
	assert_true(arena.guard_map.region().has_point(e.pos))
	assert_ne(e.state, EnemyAgent.State.PANIC)
	var next: Fighter = _spawn(arena, Vector2(12, 0))
	arena.squad_ai.begin_wave([next])
	arena.step(200)
	assert_false(arena.squad_ai.minds[next.id].agent.broke)


func test_a_waiter_leaves_cover_after_six_seconds_without_sight() -> void:
	var arena: CombatArena = _arena([BOX])
	arena.squad_ai.pit.roster.max_shooters = 0
	arena.rivet.pos = Vector2(8, 0)
	var g: Fighter = _spawn(arena, Vector2(-5, 0))
	var regained: bool = false
	for tick: int in 500:
		arena.step(tick)
		if tick > SquadMind.BLIND_LIMIT and arena.squad_ai.minds[g.id].agent.sees:
			regained = true
	assert_true(regained, "guard rounded the box to regain sight")
	assert_gt(arena.guard_map.searches, 0)


func test_area_hold_and_external_brain_do_not_take_attack_slots() -> void:
	var arena: CombatArena = _arena()
	var owner: Fighter = _spawn(arena, Vector2(-6, 0))
	owner.brain_owned = true
	var held: Fighter = _spawn(arena, Vector2(6, 0))
	arena.areas = FightAreas.new()
	var fx: FighterFx = FighterFx.new()
	fx.stun_ticks = 3
	arena.areas.fx[held.id] = fx
	arena.step(1)
	assert_false(arena.squad_ai.minds.has(owner.id))
	assert_false(arena.squad_ai.minds[held.id].agent.token)
	assert_eq(held.pos, Vector2(6, 0))
	assert_eq(owner.pos, Vector2(-6, 0))
