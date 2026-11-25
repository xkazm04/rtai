extends GutTest

const BOX: Rect2 = Rect2(-4, -1, 1, 2)


func _arena(boxes: Array[Rect2] = []) -> CombatArena:
	var rng: RandomNumberGenerator = RngRegistry.new(12).stream(&"combat")
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), boxes, null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	arena.rivet.hp = 10000
	arena.rivet.max_hp = 10000
	return arena


func _spawn(arena: CombatArena, at: Vector2, id: StringName = &"") -> Fighter:
	var g: Fighter = arena.squad_ai.spawn_member(arena, at, id)
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
	var g: Fighter = _spawn(arena, Vector2(-6.5, 1), &"patrol_cop")
	var covered: int = 0
	for tick: int in 150:
		arena.step(tick)
		var mind: SquadMind = arena.squad_ai.minds[g.id]
		covered += int(mind.motion == EnemyAgent.State.COVER)
		assert_ne(mind.motion, EnemyAgent.State.FLANK)
	assert_gt(covered, 90)
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
	for tick: int in 300:
		arena.step(tick)
		var bursts: int = 0
		for g: Fighter in arena.hostiles:
			var e: EnemyAgent = arena.squad_ai.minds[g.id].agent
			bursts += int(g.burst_left > 0)
			if e.shot_tick == tick:
				for id: int in bearings:
					if id != g.id:
						spread = maxf(spread, absf(g.pos.angle_to(bearings[id])))
				bearings[g.id] = g.pos
		peak = maxi(peak, bursts)
	assert_gt(rad_to_deg(spread), 60.0)
	assert_gt(peak, 0)
	# n31 foes lever 1: the cap is the share of the ranged squad, not the fixed max_shooters.
	assert_lte(peak, EnemySquad.shooter_slots(arena.squad_ai.pit.roster, arena.hostiles.size()))


func test_local_query_deduplicates_large_boxes_and_filters_by_distance() -> void:
	var boxes: Array[Rect2] = [Rect2(-12, -3, 24, 2), Rect2(13, 8, 1, 1)]
	assert_eq(_arena(boxes).guard_map.boxes_near(Vector2.ZERO, 9), [boxes[0]])


func test_panic_ends_and_the_next_wave_starts_with_full_morale() -> void:
	var arena: CombatArena = _arena()
	var wave: Array[Fighter] = []
	for i: int in 6:
		wave.append(_spawn(arena, Vector2(24, i)))
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
	arena.squad_ai.clear_wave()
	var next: Fighter = _spawn(arena, Vector2(12, 0))
	arena.step(200)
	assert_false(arena.squad_ai.minds[next.id].agent.broke)


func test_a_waiter_pushes_out_of_blind_cover() -> void:
	var arena: CombatArena = _arena([BOX])
	arena.squad_ai.pit.roster.max_shooters = 0
	arena.rivet.pos = Vector2(8, 0)
	var g: Fighter = _spawn(arena, Vector2(-5, 0))
	arena.squad_ai.pit.roster.archetype(g.archetype).cover_bias = 1.0
	var regained: bool = false
	for tick: int in SquadMind.BLIND_LIMIT:
		arena.step(tick)
		if arena.squad_ai.minds[g.id].agent.sees:
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


func test_swat_reaches_flank_with_a_holder_and_cover_available() -> void:
	var arena: CombatArena = _arena([BOX])
	arena.squad_ai.pit.roster.max_shooters = 1
	var holder: Fighter = _spawn(arena, Vector2(-6, 4), &"patrol_cop")
	var swat: Fighter = _spawn(arena, Vector2(-2, -8), &"swat")
	var patrol: Fighter = _spawn(arena, Vector2(25, 0), &"patrol_cop")
	swat.cooldown = 10000
	for tick: int in 300:
		arena.step(tick)
		assert_ne(arena.squad_ai.minds[patrol.id].motion, EnemyAgent.State.FLANK)
		var e: EnemyAgent = arena.squad_ai.minds[swat.id].agent
		if e.state == EnemyAgent.State.FLANK and swat.pos.distance_to(e.goal) < 1:
			assert_true(arena.squad_ai.minds[holder.id].agent.token)
			return
	fail_test("SWAT never reached its flank goal in five seconds")


func test_aggression_moves_the_waiting_ring_inward() -> void:
	var arena: CombatArena = _arena()
	arena.squad_ai.pit.roster.max_shooters = 0
	var g: Fighter = _spawn(arena, Vector2(14, 0), &"robot_gunner")
	var a: EnemyRoster.Archetype = arena.squad_ai.pit.roster.archetype(g.archetype)
	for aggression: float in [0.0, 1.0]:
		a.aggression = aggression
		for tick: int in 960:
			arena.step(tick)
		assert_almost_eq(g.pos.length(), lerpf(a.attack_m, a.preferred_m, aggression), 0.25)


func test_melee_windup_can_land_or_be_dodged() -> void:
	for dodge: bool in [false, true]:
		var arena: CombatArena = _arena()
		arena.guard_tell = GuardTell.new()
		var h: Fighter = _spawn(arena, Vector2(5, 0), &"riot_cop")
		var a: EnemyRoster.Archetype = arena.squad_ai.pit.roster.archetype(h.archetype)
		for tick: int in 240:
			arena.step(tick)
			if h.swing_left == a.telegraph_ticks:
				arena.rivet.pos.x -= 2.0 if dodge else 0.0
				for dt: int in a.telegraph_ticks:
					assert_eq(arena.rivet.hp, arena.rivet.max_hp)
					arena.step(tick + dt + 1)
				break
		assert_eq(arena.squad_ai.minds[h.id].agent.state, EnemyAgent.State.FIRE)
		var lost: float = arena.rivet.max_hp - arena.rivet.hp
		assert_almost_eq(lost, 0.0 if dodge else a.production_damage, 0.001)


func test_thug_survives_five_rifle_hits() -> void:
	var arena: CombatArena = _arena()
	var h: Fighter = _spawn(arena, Vector2.ZERO, &"robot_thug")
	for hit: int in 6:
		assert_true(h.alive())
		arena.damage(h, arena.tuning.weapon(&"assault-rifle").damage, 0, &"assault-rifle")
	assert_false(h.alive())
