extends GutTest

var arena: CombatArena
var guard: PlayerGuard
var foe: Fighter


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	arena = CombatArena.new(CombatTuning.shipped(), bus, RngRegistry.new(22).stream(&"combat"))
	guard = PlayerGuard.new()
	arena.guard = guard
	DeflectRule.of(arena).pass_ratio_k = 0.0
	arena.rivet.facing = Vector2.RIGHT
	foe = arena.spawn_guard(Vector2.RIGHT * 8.0)
	guard.step(true, true)


func _shot(direction: Vector2, id: StringName = &"pistol") -> Shot:
	var s: Shot = Shot.new()
	s.from_rivet = false
	s.pos = arena.rivet.pos + direction
	s.vel = -direction * 120.0
	s.weapon = id
	s.shooter_id = foe.id
	s.damage = 3.0
	arena.shots.append(s)
	return s


func test_front_crossing_returns_one_round_and_emits_one_spark() -> void:
	var hp: float = arena.rivet.hp
	var s: Shot = _shot(Vector2.RIGHT)
	var speed: float = s.vel.length()
	watch_signals(arena)
	ArenaProjectiles.step_shots(arena)
	assert_eq(arena.rivet.hp, hp)
	assert_true(arena.shots.has(s))
	assert_true(s.from_rivet)
	assert_eq(s.shooter_id, arena.rivet.id)
	assert_almost_eq(s.pos.x, arena.rivet.radius_m, 0.00001)
	assert_almost_eq(s.vel.length(), speed, 0.0001)
	# A guard return stays inside the configured half-angle about the line back to the shooter.
	var offset_deg: float = absf(rad_to_deg(s.vel.angle_to(s.pos.direction_to(foe.pos))))
	assert_lte(offset_deg, DeflectRule.of(arena).spread_deg + 0.0001)
	assert_eq(guard.deflects, 1)
	assert_almost_eq(
		guard.meter(), 1.0 - guard.tuning.drain_per_round / guard.tuning.meter_max, 0.0001
	)
	assert_signal_emit_count(arena, "deflected", 1)
	assert_eq(arena.areas.chain_arcs.size(), 2)
	ArenaProjectiles.step_shots(arena)
	assert_eq(guard.deflects, 1)


func test_side_rear_and_large_front_rounds_deal_damage() -> void:
	for dir: Vector2 in [Vector2.UP, Vector2.LEFT, Vector2.RIGHT]:
		var s: Shot = _shot(dir, &"cannon" if dir == Vector2.RIGHT else &"pistol")
		var hp: float = arena.rivet.hp
		ArenaProjectiles.step_shots(arena)
		assert_eq(arena.rivet.hp, hp - s.damage)
		assert_false(arena.shots.has(s))
	assert_eq(guard.deflects, 0)
	assert_eq(guard.meter(), 1.0)


func test_arc_uses_incoming_velocity_and_includes_both_edges() -> void:
	var edge: float = guard.tuning.arc_deg * 0.5
	for angle: float in [-edge, edge, edge + 0.1, -edge - 0.1]:
		var s: Shot = _shot(Vector2.RIGHT.rotated(deg_to_rad(angle)))
		ArenaProjectiles.step_shots(arena)
		assert_eq(s.from_rivet, absf(angle) <= edge)
		arena.shots.clear()
	var near: Shot = _shot(Vector2.RIGHT)
	near.vel = Vector2.RIGHT
	ArenaProjectiles.step_shots(arena)
	assert_false(near.from_rivet)
	assert_eq(guard.deflects, 2)


func test_explicit_large_size_survives_a_missing_enemy_weapon_id() -> void:
	var s: Shot = _shot(Vector2.RIGHT, &"")
	s.size = Shot.LARGE
	var hp: float = arena.rivet.hp
	ArenaProjectiles.step_shots(arena)
	assert_eq(s.size, Shot.LARGE)
	assert_eq(arena.rivet.hp, hp - s.damage)


func test_front_melee_drains_but_rear_blast_and_unknown_attacker_hurt() -> void:
	var hp: float = arena.rivet.hp
	foe.pos = Vector2.RIGHT
	for id: StringName in [&"claw", &"baton"]:
		arena.damage(arena.rivet, 1.0, foe.id, id, &"melee")
	assert_eq(arena.rivet.hp, hp)
	assert_eq(guard.melee_blocks, 2)
	assert_almost_eq(
		guard.meter(), 1.0 - 2.0 * guard.tuning.melee_drain / guard.tuning.meter_max, 0.0001
	)
	arena.damage(arena.rivet, 1.0, foe.id, &"claw", &"blown")
	arena.damage(arena.rivet, 1.0, -50, &"baton", &"melee")
	foe.pos = Vector2.LEFT
	arena.damage(arena.rivet, 1.0, foe.id, &"baton", &"melee")
	assert_eq(arena.rivet.hp, hp - 3.0)
	assert_eq(guard.melee_blocks, 2)


func test_plasma_sword_still_returns_a_large_round() -> void:
	var s: Shot = _shot(Vector2.RIGHT, &"cannon")
	s.size = Shot.LARGE
	assert_eq(PlayerDeflect.bat(arena, Vector2.RIGHT, 2.0), 1)
	assert_true(s.from_rivet)
	assert_eq(guard.meter(), 1.0)


func test_melee_arc_is_relative_to_rivet_and_needs_an_incoming_direction() -> void:
	arena.rivet.pos = Vector2(10, 8)
	var hp: float = arena.rivet.hp
	for offset: Vector2 in [Vector2.LEFT, Vector2.ZERO]:
		foe.pos = arena.rivet.pos + offset
		arena.damage(arena.rivet, 1.0, foe.id, &"baton", &"melee")
	assert_eq(guard.melee_blocks, 0)
	assert_eq(arena.rivet.hp, hp - 2.0)
	foe.pos = arena.rivet.pos + Vector2.RIGHT
	arena.damage(arena.rivet, 1.0, foe.id, &"baton", &"melee")
	assert_eq(guard.melee_blocks, 1)
	assert_eq(arena.rivet.hp, hp - 2.0)


func test_lowered_guard_and_another_victim_take_front_melee_damage() -> void:
	foe.pos = arena.rivet.pos + Vector2.RIGHT
	var other: Fighter = arena.spawn_guard(foe.pos)
	var hp: float = other.hp
	arena.damage(other, 0.5, foe.id, &"baton", &"melee")
	assert_eq(other.hp, hp - 0.5)
	guard.lower()
	hp = arena.rivet.hp
	arena.damage(arena.rivet, 1.0, foe.id, &"baton", &"melee")
	assert_eq(arena.rivet.hp, hp - 1.0)
	assert_eq(guard.melee_blocks, 0)
