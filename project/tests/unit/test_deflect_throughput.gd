extends GutTest
## The same 1,000 pistol contacts exercise the shipped odds, equipment multiplier and spread.

const COUNT: int = 1000
const SEED: int = 90210


func _arena(seed_value: int) -> CombatArena:
	var reg: RngRegistry = RngRegistry.new(seed_value)
	var bus: EventBus = autofree(EventBus.new())
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	DeflectRule.bind(arena, reg)
	var shooter: Fighter = arena.spawn_guard(Vector2.RIGHT * 7.0)
	shooter.pos = Vector2(7.0, 2.0)
	return arena


func _incoming(arena: CombatArena, size: StringName = Shot.SMALL) -> Shot:
	var s: Shot = Shot.new()
	s.from_rivet = false
	s.pos = Vector2.RIGHT
	s.vel = Vector2.LEFT * 18.0
	s.size = size
	s.weapon = &"pistol"
	s.shooter_id = arena.hostiles[0].id
	arena.shots.assign([s])
	return s


func _sample(seed_value: int, multiplier: float) -> Array[float]:
	var arena: CombatArena = _arena(seed_value)
	var rule: DeflectRule = DeflectRule.of(arena)
	rule.pass_ratio_k = multiplier
	var angles: Array[float] = []
	for i: int in COUNT:
		var s: Shot = _incoming(arena)
		var aim: Vector2 = s.pos.direction_to(arena.hostiles[0].pos)
		if PlayerDeflect.bat(arena, Vector2.RIGHT, 1.6) == 1:
			angles.append(rad_to_deg(aim.angle_to(s.vel)))
		else:
			angles.append(INF)
	return angles


func test_seeded_pass_share_and_spread_in_both_directions() -> void:
	var angles: Array[float] = _sample(SEED, 1.0)
	var backed: Array[float] = []
	for angle: float in angles:
		if is_finite(angle):
			backed.append(angle)
	assert_between(angles.count(INF), 450, 550, "50% +/- 5 percentage points")
	backed.sort()
	if not backed.is_empty():
		assert_between(backed[0], -12.0001, -10.0)
		assert_between(backed[-1], 10.0, 12.0001)
	assert_eq(angles, _sample(SEED, 1.0), "pass decisions and return angles replay identically")
	assert_ne(angles, _sample(SEED + 1, 1.0))


func test_halving_multiplier_halves_pass_share() -> void:
	assert_between(_sample(SEED, 0.5).count(INF), 200, 300, "25% +/- 5 percentage points")


func test_passed_bat_keeps_course_and_cannot_roll_again() -> void:
	var arena: CombatArena = _arena(SEED)
	var rule: DeflectRule = DeflectRule.of(arena)
	rule.pass_ratio_k = 3.0
	var s: Shot = _incoming(arena)
	assert_eq(PlayerDeflect.bat(arena, Vector2.RIGHT, 1.6), 0)
	rule.pass_ratio_k = 0.0
	assert_eq(PlayerDeflect.bat(arena, Vector2.RIGHT, 1.6), 0)
	assert_false(s.from_rivet)
	assert_eq(s.vel, Vector2.LEFT * 18.0)
	assert_eq(s.pos, Vector2.RIGHT)
	assert_eq(s.shooter_id, arena.hostiles[0].id)


func test_large_bat_skips_both_pass_and_spread() -> void:
	var arena: CombatArena = _arena(SEED)
	DeflectRule.of(arena).pass_ratio_k = 3.0
	for i: int in 10:
		var s: Shot = _incoming(arena, Shot.LARGE)
		var aim: Vector2 = s.pos.direction_to(arena.hostiles[0].pos)
		assert_eq(PlayerDeflect.bat(arena, Vector2.RIGHT, 1.6), 1)
		assert_almost_eq(s.vel, aim * 18.0, Vector2.ONE * 0.00001)


func test_guard_pass_reaches_normal_damage_and_hit_signal_at_half_meter_cost() -> void:
	var arena: CombatArena = _arena(SEED)
	var guard: PlayerGuard = PlayerGuard.new()
	arena.guard = guard
	guard.step(true, true)
	arena.rivet.facing = Vector2.RIGHT
	DeflectRule.of(arena).pass_ratio_k = 2.0
	var s: Shot = _incoming(arena)
	s.vel = Vector2.LEFT * 120.0
	s.damage = 12.0
	var hp: float = arena.rivet.hp
	watch_signals(arena)
	ArenaProjectiles.step_shots(arena)
	assert_false(arena.shots.has(s))
	assert_eq(arena.rivet.hp, hp - 12.0)
	assert_eq(arena.rivet.hurt_tick, arena.tick)
	assert_signal_emit_count(arena, "struck", 1)
	assert_signal_not_emitted(arena.deflected)
	assert_eq(guard.deflects, 0)
	assert_almost_eq(
		guard.meter(), 1.0 - 0.5 * guard.tuning.drain_per_round / guard.tuning.meter_max, 0.00001
	)


func test_idle_guard_and_heavy_contacts_leave_the_deflect_stream_unopened() -> void:
	var reg: RngRegistry = RngRegistry.new(SEED)
	var arena: CombatArena = _arena(SEED)
	DeflectRule.bind(arena, reg)
	var before: StreamPeerBuffer = StreamPeerBuffer.new()
	reg.write_state(before)
	assert_eq(PlayerDeflect.bat(arena, Vector2.RIGHT, 1.6), 0)
	var s: Shot = _incoming(arena)
	s.spec = WeaponSpec.new()
	s.spec.splash_radius_m = 2.0
	assert_eq(PlayerDeflect.bat(arena, Vector2.RIGHT, 1.6), 1)
	var after: StreamPeerBuffer = StreamPeerBuffer.new()
	reg.write_state(after)
	assert_eq(after.data_array, before.data_array)
	assert_false(reg.names().has(&"deflect"))
	@warning_ignore("return_value_discarded")
	_incoming(arena, Shot.SMALL)
	@warning_ignore("return_value_discarded")
	PlayerDeflect.bat(arena, Vector2.RIGHT, 1.6)
	assert_true(reg.names().has(&"deflect"))


func test_standalone_and_world_arena_draw_the_same_named_stream() -> void:
	var world: CombatArena = _arena(SEED)
	var reg: RngRegistry = RngRegistry.new(SEED)
	var solo: CombatArena = CombatArena.new(world.tuning, Events, reg.stream(&"combat"))
	solo.hostiles.assign(world.hostiles)
	for i: int in 32:
		var a: Shot = _incoming(world)
		var b: Shot = _incoming(solo)
		assert_eq(
			PlayerDeflect.bat(world, Vector2.RIGHT, 1.6),
			PlayerDeflect.bat(solo, Vector2.RIGHT, 1.6)
		)
		assert_eq(b.vel, a.vel)
