extends GutTest

const WEAPON: StringName = &"test_enemy_rocket"
const RADIUS: float = 4.0
const DAMAGE: float = 20.0

var arena: CombatArena
var dodges: ArenaDodges


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	arena = CombatArena.new(CombatTuning.shipped(), bus, RngRegistry.new(22).stream(&"combat"))
	arena.walls = ArenaWalls.new()
	arena.rivet.radius_m = 0.5
	arena.rivet.hp = 100.0
	dodges = ArenaDodges.new()
	EnemyRounds.override_for_test(WEAPON, Shot.LARGE, RADIUS, DAMAGE)


func after_each() -> void:
	EnemyRounds.reset()


func _fire(from: Vector2, step: Vector2, reach: float = 20.0) -> Shot:
	var s: Shot = Shot.new()
	s.weapon = WEAPON
	s.from_rivet = false
	s.damage = 71.0
	s.shooter_id = 8
	s.pos = from
	s.vel = step / SimClock.TICK_DT
	s.left_m = reach
	arena.shots.append(s)
	return s


func _tick() -> void:
	dodges.cull(arena, arena.walls)
	ArenaProjectiles.step_shots(arena)


func test_guarded_rivet_takes_full_burst_once_and_large_round_disappears() -> void:
	arena.guard = PlayerGuard.new()
	arena.guard.step(true, true)
	arena.rivet.facing = Vector2.LEFT
	var s: Shot = _fire(Vector2(-1.5, 0), Vector2.RIGHT * 5)
	watch_signals(arena)
	ArenaProjectiles.step_shots(arena)
	assert_true(arena.guard.up())
	assert_eq(s.size, Shot.LARGE)
	assert_eq(arena.rivet.hp, 100.0 - DAMAGE)
	assert_eq(arena.shots.size(), 0)
	assert_eq(arena.guard.deflects, 0)
	assert_eq(arena.guard.meter(), 1.0)
	assert_eq(arena.areas.blasts.size(), 1)
	assert_almost_eq(arena.areas.blasts[0], Vector3(-0.5, 0.0, RADIUS), Vector3.ONE * 0.00001)
	assert_signal_emit_count(arena, "struck", 1)
	ArenaProjectiles.step_shots(arena)
	assert_eq(arena.rivet.hp, 100.0 - DAMAGE)


func test_a_small_explosive_round_also_bypasses_guard() -> void:
	EnemyRounds.override_for_test(WEAPON, Shot.SMALL, RADIUS, DAMAGE)
	arena.guard = PlayerGuard.new()
	arena.guard.step(true, true)
	arena.rivet.facing = Vector2.LEFT
	var s: Shot = _fire(Vector2.LEFT, Vector2.RIGHT)
	_tick()
	assert_eq(s.size, Shot.SMALL)
	assert_eq(arena.shots.size(), 0)
	assert_eq(arena.guard.deflects, 0)
	assert_eq(arena.rivet.hp, 100.0 - DAMAGE)


func test_wall_impact_bursts_at_first_face_and_shields_the_far_side() -> void:
	arena.rivet.pos = Vector2(2, 0)
	# Deliberately put the farther box first.
	arena.walls.boxes.assign([Rect2(3, -1, 1, 2), Rect2(0, -1, 0.5, 2)])
	arena.walls.kinds.assign(["cover_high", "wall_high"])
	var s: Shot = _fire(Vector2(-1, 0), Vector2.RIGHT * 6)
	_tick()
	assert_false(arena.shots.has(s))
	assert_eq(arena.rivet.hp, 100.0)
	assert_eq(dodges.blocked, 1)
	assert_eq(arena.areas.blasts, [Vector3(0, 0, RADIUS)])
	arena.walls = ArenaWalls.new()
	s = _fire(Vector2(-1, 0), Vector2.RIGHT * 6)
	_tick()
	assert_false(arena.shots.has(s))
	assert_eq(arena.rivet.hp, 100.0 - DAMAGE)
	assert_eq(dodges.blocked, 1)


func test_wall_face_exposes_a_near_side_bystander_beside_the_flight_path() -> void:
	arena.walls.boxes.append(Rect2(0, -1, 0.5, 2))
	arena.walls.kinds.append("wall_high")
	arena.rivet.pos = Vector2(-1.5, -1)
	var s: Shot = _fire(Vector2.LEFT * 2, Vector2.RIGHT * 5)
	_tick()
	assert_false(arena.shots.has(s))
	assert_eq(dodges.blocked, 1)
	var dist: float = arena.rivet.pos.length() - arena.rivet.radius_m
	assert_almost_eq(arena.rivet.hp, 100.0 - DAMAGE * (1.0 - dist / RADIUS), 0.00001)


func test_rivet_in_front_of_the_wall_is_hit_at_his_body() -> void:
	arena.walls.boxes.append(Rect2(1, -1, 0.5, 2))
	arena.walls.kinds.append("wall_high")
	var s: Shot = _fire(Vector2.LEFT * 2, Vector2.RIGHT * 6)
	_tick()
	assert_false(arena.shots.has(s))
	assert_eq(dodges.blocked, 0)
	assert_eq(arena.rivet.hp, 100.0 - DAMAGE)
	assert_eq(arena.areas.blasts.size(), 1)
	assert_almost_eq(arena.areas.blasts[0], Vector3(-0.5, 0.0, RADIUS), Vector3.ONE * 0.00001)


func test_range_end_bursts_in_the_open_before_a_wall_or_body_past_range() -> void:
	arena.rivet.pos = Vector2(3.5, 0)
	arena.walls.boxes.append(Rect2(4.5, -1, 0.5, 2))
	arena.walls.kinds.append("wall_high")
	var s: Shot = _fire(Vector2.ZERO, Vector2.RIGHT * 2.5, 3.0)
	_tick()
	assert_true(arena.shots.has(s))
	assert_null(arena.areas)
	_tick()
	assert_false(arena.shots.has(s))
	assert_eq(dodges.blocked, 0)
	assert_eq(arena.areas.blasts, [Vector3(3.0, 0.0, RADIUS)])
	assert_eq(arena.rivet.hp, 100.0 - DAMAGE)


func test_spent_rocket_hurts_a_nearby_body_without_crossing_it() -> void:
	arena.rivet.pos = Vector2(3, 2.5)
	var s: Shot = _fire(Vector2.ZERO, Vector2.RIGHT * 5, 3.0)
	_tick()
	assert_false(arena.shots.has(s))
	assert_eq(arena.rivet.hp, 100.0 - DAMAGE * 0.5)
	assert_eq(arena.areas.blasts, [Vector3(3, 0, RADIUS)])


func test_round_spawned_after_culling_cannot_cross_a_wall_on_its_first_tick() -> void:
	arena.walls.boxes.append(Rect2(0, -1, 0.5, 2))
	arena.walls.kinds.append("wall_high")
	arena.rivet.pos = Vector2(2, 0)
	dodges.cull(arena, arena.walls)
	var s: Shot = _fire(Vector2.LEFT, Vector2.RIGHT * 5)
	ArenaProjectiles.step_shots(arena)
	assert_false(arena.shots.has(s))
	assert_eq(arena.rivet.hp, 100.0)
	assert_eq(arena.areas.blasts, [Vector3(0.0, 0.0, RADIUS)])
