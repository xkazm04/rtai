extends GutTest

const TIERS: Dictionary[StringName, int] = {
	&"rocket_trooper": 2, &"sentry_turret": 3, &"shield_robot": 4, &"war_machine": 5
}


func test_every_shipped_row_has_a_tier_and_declared_rounds_load() -> void:
	var roster: EnemyRoster = EnemyRoster.shipped(EnemyRoster.TABLE, true)
	assert_true(roster.ok(), str(roster.errors()))
	for id: StringName in roster.archetypes:
		assert_between(roster.archetype(id).tier, 1, 5, String(id))
	for id: StringName in TIERS:
		assert_eq(roster.archetype(id).tier, TIERS[id], String(id))
	var raw: DataTable = DataTable.open(EnemyRoster.TABLE, EnemyRoster.SCHEMA)
	var weapon_rows: Dictionary = raw.object(raw.raw, "weapons")
	for id: String in ["rocket", "turret_gun", "shove", "war_cannon", "stomp"]:
		assert_has(raw.object(weapon_rows, id), "round")
		assert_has([&"small", &"large"], roster.weapons[id].round)
	for id: StringName in [&"rocket", &"war_cannon"]:
		assert_eq(roster.weapons[id].round, &"large")
		assert_gt(roster.weapons[id].splash_damage, 0.0)
	assert_eq(roster.weapons[&"rocket"].splash_radius_m, 3.0)
	assert_eq(roster.archetype(&"war_machine").alt_weapon.id, &"stomp")


func test_pit_spawns_and_fights_with_each_new_row() -> void:
	for id: StringName in TIERS:
		var pit: EnemyPit = PitLayout.build(19, false)
		pit.rivet_pos = Vector2.ZERO
		var at: Vector2 = Vector2(1.4 if id == &"shield_robot" else 12.0, 0)
		var e: EnemyAgent = pit.spawn(id, at)
		assert_eq(e.arch.id, id)
		for tick: int in 360:
			pit.step()
			if id == &"sentry_turret" and tick == 119:
				assert_eq(e.pos, at)
		assert_gt(pit.stats["shots"] + pit.stats["swings"], 0.0, String(id))


func test_arena_spawns_and_fights_with_each_new_row() -> void:
	for id: StringName in TIERS:
		var arena: CombatArena = _arena()
		var at: Vector2 = Vector2(1.4 if id == &"shield_robot" else 12.0, 0)
		var h: Fighter = arena.squad_ai.spawn_member(arena, at, id)
		assert_eq(h.archetype, id)
		h.pos = at
		h.facing = Vector2.LEFT
		var fired: bool = false
		for tick: int in 360:
			arena.step(tick)
			for s: Shot in arena.shots:
				fired = fired or s.weapon == arena.squad_ai.pit.roster.archetype(id).weapon.id
			if id == &"sentry_turret" and tick == 119:
				assert_eq(h.pos, at)
		assert_true(fired or (id == &"shield_robot" and arena.rivet.hurt_tick >= 0), String(id))


func test_war_machine_stomps_at_close_range() -> void:
	var arena: CombatArena = _arena()
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2(2, 0), &"war_machine")
	h.pos = Vector2(2, 0)
	h.facing = Vector2.LEFT
	h.cooldown = 0
	var arch: EnemyRoster.Archetype = arena.squad_ai.pit.roster.archetype(h.archetype)
	for tick: int in 160:
		arena.step(tick)
		if arena.rivet.hurt_tick == tick:
			assert_eq(arena.rivet.hp, arena.rivet.max_hp - arch.alt_weapon.splash_damage)
			assert_eq(tick - h.swing_tick, arch.telegraph_ticks)
			return
	fail_test("no close-range stomp landed")


func test_shield_robot_protects_a_wider_front_than_the_riot_cop() -> void:
	var pit: EnemyPit = PitLayout.build(19, false)
	var shield: EnemyAgent = pit.spawn(&"shield_robot", Vector2.ZERO)
	var riot: EnemyAgent = pit.spawn(&"riot_cop", Vector2.ZERO)
	var from: Vector2 = Vector2.LEFT.rotated(deg_to_rad(75))
	for e: EnemyAgent in [shield, riot]:
		e.facing = Vector2.RIGHT
		pit.hurt(e, 1.0, from)
	assert_almost_eq(shield.hp, shield.arch.hp - 0.2, 0.001)
	assert_eq(riot.hp, riot.arch.hp - 1.0)


func _arena() -> CombatArena:
	var rng: RandomNumberGenerator = RngRegistry.new(19).stream(&"combat")
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	return arena
