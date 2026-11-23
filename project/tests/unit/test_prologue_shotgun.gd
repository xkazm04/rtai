extends GutTest


func test_player_can_draw_and_fire_the_explicit_shotgun() -> void:
	var table: WeaponTable = WeaponTable.shipped()
	assert_true(table.ok())
	assert_false(table.playable().has(&"shotgun"))
	var gun: GunHand = GunHand.make(table, &"shotgun", RngRegistry.new(7).stream(&"gunplay"))
	var spec: WeaponSpec = gun.trigger.spec
	assert_eq(spec.pellets, 8)
	assert_almost_eq(rad_to_deg(spec.spread_rad), 13.0, 0.001)
	assert_eq(spec.magazine, 5)
	assert_eq(spec.interval_ticks, 48)
	assert_eq(spec.reload_ticks, 108)
	assert_eq(spec.shot_cue, &"shotgun")
	var arsenal: ArsenalTable = ArsenalTable.shipped()
	assert_eq(arsenal.weapon_grip[spec.id], &"two_hand_long")
	assert_true(WeaponArt.new().has(arsenal.art_id(spec.id)))
	var held: WeaponHold = WeaponHold.new(arsenal)
	assert_true(held.equip(spec.id))
	for tick: int in arsenal.grip_of(spec.id).draw_ticks:
		held.step()
	assert_true(held.can_fire())
	var rounds: Array[Shot] = gun.pull(Fighter.new(), Vector2.RIGHT)
	assert_eq(rounds.size(), spec.pellets)
	for round: Shot in rounds:
		assert_eq(round.weapon, held.held)
		assert_eq(StageAudio.shot_cue(round), &"shotgun")
		assert_lte(absf(round.vel.angle()), spec.spread_rad)


func test_mulroney_alone_reads_the_enemy_pellet_profile() -> void:
	var roster: EnemyRoster = EnemyRoster.shipped(EnemyRoster.TABLE, true)
	assert_true(roster.ok())
	var gun: EnemyWeapon = roster.weapons[&"shotgun"]
	assert_same(roster.archetype(&"sergeant_mulroney").weapon, gun)
	for foe: EnemyRoster.Archetype in roster.archetypes.values():
		if foe.id != &"sergeant_mulroney":
			assert_ne(foe.weapon, gun, String(foe.id))
	var rifle: EnemyWeapon = roster.weapons[&"rifle"]
	assert_eq(rifle.pellets, 1)
	assert_eq(rifle.spread_rad, 0.0)
	assert_eq(gun.pellets, 8)
	assert_eq(gun.reach_m, 9.0)
	assert_eq(gun.cooldown_ticks, 48)
	assert_almost_eq(rad_to_deg(gun.spread_rad), 13.0, 0.001)
	assert_gt(gun.damage * gun.pellets, rifle.damage * rifle.burst)
	var audio: AudioTables = AudioTables.shipped()
	assert_not_null(audio.cue(&"shotgun"))
	assert_not_null(audio.cue(&"shotgun_pump"))


func _arena(at: Vector2, walls: Array[Rect2] = []) -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var rng: RngRegistry = RngRegistry.new(7)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, rng.stream(&"combat"))
	arena.guard_map = GuardRouteMap.new(Rect2(-20, -20, 40, 40), walls, null, 0.45)
	arena.rivet.pos = at
	return arena


func test_discharge_uses_one_muzzle_and_spans_the_authored_cone() -> void:
	var gun: EnemyWeapon = EnemyRoster.shipped().archetype(&"sergeant_mulroney").weapon
	var boss: Fighter = Fighter.make(Fighter.Kind.GUARD, 8, Vector2.ZERO, 2.0)
	var aim: Vector2 = Vector2(3, -4).normalized()
	var arena: CombatArena = _arena(aim * gun.reach_m)
	var cycle: PrologueShotgun = PrologueShotgun.new()
	cycle.step(arena, boss, gun, 100)
	assert_eq(arena.shots.size(), gun.pellets)
	assert_almost_eq(boss.facing.angle_to(aim), 0.0, 0.00001)
	for i: int in arena.shots.size():
		var shot: Shot = arena.shots[i]
		var angle: float = lerpf(-gun.spread_rad, gun.spread_rad, i / float(gun.pellets - 1))
		assert_almost_eq(aim.angle_to(shot.vel), angle, 0.00001)
		assert_almost_eq(shot.vel.length(), gun.speed_mps, 0.00001)
		assert_eq(shot.origin, arena.shots[0].origin)
		assert_eq(shot.left_m, gun.reach_m)
		assert_eq(shot.damage, gun.damage)
		assert_eq(shot.weapon, gun.id)
		assert_eq(shot.shooter_id, boss.id)
		assert_false(shot.from_rivet)


func test_pellets_damage_rivet_at_two_eight_and_beyond_reach() -> void:
	var gun: EnemyWeapon = EnemyRoster.shipped().weapons[&"shotgun"]
	var boss: Fighter = Fighter.new()
	var arena: CombatArena = _arena(Vector2.ZERO)
	for distance: float in [2.0, 8.0, 11.0]:
		var cycle: PrologueShotgun = PrologueShotgun.new()
		arena.rivet.pos = Vector2.RIGHT * minf(distance, gun.reach_m)
		cycle.step(arena, boss, gun, 1)
		assert_eq(arena.shots.size(), gun.pellets)
		# Move the last target after the shot so zero hits also proves projectile expiry.
		arena.rivet.pos = Vector2.RIGHT * distance
		var before: float = arena.rivet.hp
		for tick: int in SimClock.TICK_RATE:
			ArenaProjectiles.step_shots(arena)
		assert_true(arena.shots.is_empty())
		var hits: int = roundi((before - arena.rivet.hp) / gun.damage)
		var expected: int = {2.0: 8, 8.0: 2, 11.0: 0}[distance]
		assert_eq(hits, expected, "%s metres" % distance)


func test_pump_locks_every_tick_until_the_next_shot_and_resets_at_checkpoint() -> void:
	var gun: EnemyWeapon = EnemyRoster.shipped().weapons[&"shotgun"]
	var arena: CombatArena = _arena(Vector2.RIGHT * 4.0)
	var boss: Fighter = Fighter.new()
	var cycle: PrologueShotgun = PrologueShotgun.new()
	var start: int = 18
	assert_eq(cycle.pump_progress(start), -1.0)
	cycle.step(arena, boss, gun, start)
	for elapsed: int in gun.cooldown_ticks:
		var tick: int = start + elapsed
		cycle.step(arena, boss, gun, tick)
		assert_eq(cycle.pump_progress(tick), float(elapsed) / gun.cooldown_ticks)
	assert_eq(arena.shots.size(), gun.pellets)
	var due: int = start + gun.cooldown_ticks
	assert_eq(cycle.pump_progress(due), -1.0)
	cycle.step(arena, boss, gun, due)
	assert_eq(arena.shots.size(), 2 * gun.pellets)
	assert_eq(cycle.shot_ticks, [start, due])
	cycle.reset()
	assert_eq(cycle.pump_progress(start), -1.0)
	cycle.step(arena, boss, gun, start)
	assert_eq(cycle.shot_ticks, [start])


func test_range_and_cover_gate_the_first_shot() -> void:
	var gun: EnemyWeapon = EnemyRoster.shipped().weapons[&"shotgun"]
	var boss: Fighter = Fighter.new()
	var cycle: PrologueShotgun = PrologueShotgun.new()
	var arena: CombatArena = _arena(Vector2.RIGHT * (gun.reach_m + 0.01))
	cycle.step(arena, boss, gun, 1)
	assert_true(arena.shots.is_empty())
	arena = _arena(Vector2.RIGHT * 4.0, [Rect2(2, -1, 1, 2)])
	cycle.step(arena, boss, gun, 2)
	assert_true(arena.shots.is_empty())
	assert_true(cycle.shot_ticks.is_empty())
