extends GutTest

const ID: StringName = &"shield_robot"

var arena: CombatArena
var robot: Fighter
var arch: EnemyRoster.Archetype
var now: int


func before_each() -> void:
	var rng: RandomNumberGenerator = RngRegistry.new(22).stream(&"combat")
	arena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-20, -20, 40, 40), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	robot = arena.squad_ai.spawn_member(arena, Vector2.ZERO, ID)
	robot.pos = Vector2.ZERO
	robot.facing = Vector2.RIGHT
	arch = arena.squad_ai.pit.roster.archetype(ID)
	arena.rivet.pos = Vector2(8, 0)
	now = 0


func _tick() -> void:
	now += 1
	arena.step(now)


func _hit(h: Fighter, dir: Vector2, kind: StringName, killer: int = 0) -> float:
	var before: float = h.hp
	arena.hit_dir = dir
	arena.damage(h, 1.0, killer, &"gloria", kind)
	return before - h.hp


func test_frontal_plate_spans_the_row_arc_and_blasts_bypass_it() -> void:
	assert_almost_eq(_hit(robot, Vector2.LEFT, &"shot"), 0.2, 0.0001)
	assert_almost_eq(_hit(robot, Vector2.LEFT.rotated(deg_to_rad(84)), &"shot"), 0.2, 0.0001)
	assert_almost_eq(_hit(robot, Vector2.LEFT.rotated(deg_to_rad(86)), &"shot"), 1.0, 0.0001)
	assert_almost_eq(_hit(robot, Vector2.RIGHT, &"shot"), 1.0, 0.0001)
	assert_almost_eq(_hit(robot, Vector2.LEFT, &"blown"), 1.0, 0.0001)


func _await_tell() -> void:
	for i: int in 400:
		_tick()
		if robot.swing_left > 0:
			break
	assert_eq(robot.swing_left, arch.telegraph_ticks)
	assert_gte(robot.swing_left, 20)


func test_readable_locked_shove_can_be_sidestepped() -> void:
	arena.rivet.pos = Vector2(1.6, 0)
	watch_signals(Events)
	_await_tell()
	assert_signal_emitted_with_parameters(Events, "attack_telegraphed", [arch.weapon.id])
	var plant: Vector2 = robot.pos
	var aim: Vector2 = robot.facing
	arena.rivet.pos += aim.orthogonal() * 1.35
	var mind: SquadMind = arena.squad_ai.minds[robot.id]
	for i: int in arch.telegraph_ticks:
		_tick()
		assert_eq(robot.pos, plant)
		assert_eq(robot.facing, aim)
		assert_eq(robot.swing_left, arch.telegraph_ticks - i - 1)
		if robot.swing_left > 0:
			assert_eq(mind.agent.state, EnemyAgent.State.WINDUP)
			assert_eq(mind.agent.state_ticks, i + 1)
	assert_eq(mind.shield.lunge_left, FoeShield.LUNGE_TICKS)
	assert_eq(mind.agent.state, EnemyAgent.State.FIRE)
	for i: int in FoeShield.LUNGE_TICKS:
		_tick()
		assert_eq(robot.facing, aim)
		assert_eq(mind.shield.lunge_left, FoeShield.LUNGE_TICKS - i - 1)
	var travel: Vector2 = aim * arch.speed_mps * SimClock.TICK_DT * FoeShield.LUNGE_TICKS
	assert_almost_eq(robot.pos, plant + travel, Vector2.ONE * 0.0001)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)


func test_slow_advance_and_lunge_hit_once_with_row_knockback() -> void:
	var start: Vector2 = arena.rivet.pos
	var peak: float = 0.0
	for i: int in 420:
		var previous: Vector2 = robot.pos
		_tick()
		peak = maxf(peak, previous.distance_to(robot.pos) / SimClock.TICK_DT)
		if arena.rivet.hp < arena.rivet.max_hp:
			break
	assert_gt(robot.pos.x, 6.0)
	assert_almost_eq(peak, arch.speed_mps, 0.0001)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp - arch.production_damage)
	assert_almost_eq(
		arena.rivet.pos, start + Vector2.RIGHT * arch.weapon.knockback_m, Vector2.ONE * 0.001
	)
	var mind: SquadMind = arena.squad_ai.minds[robot.id]
	assert_eq(mind.agent.state, EnemyAgent.State.RECOVER)
	assert_eq(mind.agent.cooldown, arch.weapon.cooldown_ticks)
	assert_eq(mind.agent.shot_tick, now)
	assert_false(mind.agent.token)
	arena.rivet.pos = robot.pos + Vector2.RIGHT * arch.preferred_m
	for left: int in range(arch.weapon.cooldown_ticks - 1, -1, -1):
		_tick()
		assert_eq(mind.agent.cooldown, left)
		assert_eq(robot.swing_left, 0)
	_tick()
	assert_eq(robot.swing_left, arch.telegraph_ticks)


func test_carrier_turns_at_the_rows_rate_when_rivet_crosses_behind() -> void:
	arena.rivet.pos = Vector2(-2, 0)
	var old: Vector2 = robot.facing
	_tick()
	assert_eq(robot.pos, Vector2.ZERO, "Plants its feet while turning away from its old heading")
	assert_almost_eq(absf(old.angle_to(robot.facing)), arch.turn_rad_per_tick, 0.0001)
	assert_eq(robot.swing_left, 0)


func test_a_wall_in_the_lunge_path_stops_the_carrier_and_the_shove() -> void:
	arena.rivet.pos = Vector2(1.6, 0)
	_await_tell()
	var plant: Vector2 = robot.pos
	var wall: Rect2 = Rect2(plant + Vector2(0.55, -2), Vector2(1, 4))
	var map: GuardRouteMap = GuardRouteMap.new(Rect2(-20, -20, 40, 40), [wall], null, 0.45)
	arena.squad_ai.set_route_map(map)
	for i: int in arch.telegraph_ticks + FoeShield.LUNGE_TICKS:
		_tick()
	assert_gt(robot.pos.x, plant.x)
	assert_true(map.clear_line(plant, robot.pos), "A locked lunge still respects the wall")
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)


func test_shove_connects_when_rivets_near_edge_just_touches_its_reach() -> void:
	arena.rivet.pos = Vector2(1.6, 0)
	_await_tell()
	for i: int in arch.telegraph_ticks + FoeShield.LUNGE_TICKS - 1:
		_tick()
	# Make contact at exactly 2.5 m, representable in both Vector2 and the row's floats.
	arena.rivet.radius_m = 2.5 - arch.weapon.reach_m
	robot.pos = -Vector2.RIGHT * arch.speed_mps * SimClock.TICK_DT
	arena.rivet.pos = Vector2(2.5, 0)
	_tick()
	assert_eq(robot.pos, Vector2.ZERO)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp - arch.production_damage)


func test_small_detonation_bypasses_both_plates_through_the_real_area_damage_path() -> void:
	var mate: Fighter = arena.squad_ai.spawn_member(arena, Vector2.ZERO, &"swat")
	mate.pos = Vector2(-1.1, 0.2)
	var shard: Shot = Shot.new()
	shard.spec = WeaponTable.shipped().weapon(&"homing_shard")
	shard.shooter_id = arena.rivet.id
	var centre: Vector2 = Vector2(0.2, 0)
	arena.areas = FightAreas.new()
	var before: float = mate.hp
	arena.areas.land(arena, shard, null, centre)
	var full: float = shard.spec.splash_damage * arena.areas.hp_scale
	var metres: float = mate.pos.distance_to(centre) - mate.radius_m
	assert_almost_eq(robot.max_hp - robot.hp, full, 0.0001)
	assert_almost_eq(before - mate.hp, full * (1.0 - metres / shard.spec.splash_radius_m), 0.0001)
	shard.shooter_id = 99
	before = robot.hp
	arena.areas.land(arena, shard, null, centre)
	assert_almost_eq(before - robot.hp, full, 0.0001)


func test_live_shadow_tracks_the_shot_and_disappears_with_the_carrier() -> void:
	var mate: Fighter = arena.squad_ai.spawn_member(arena, Vector2.ZERO, &"swat")
	mate.pos = Vector2(-1.2, 0.4)
	mate.hp = 10
	assert_almost_eq(_hit(mate, Vector2.LEFT, &"shot"), 0.2, 0.0001)
	assert_almost_eq(_hit(mate, Vector2.LEFT, &"blown"), 1.0, 0.0001)
	assert_almost_eq(_hit(mate, Vector2.LEFT, &"shot", 99), 1.0, 0.0001)
	assert_almost_eq(_hit(mate, Vector2.UP, &"shot"), 1.0, 0.0001)
	mate.pos.y = 0.9
	assert_almost_eq(_hit(mate, Vector2.LEFT, &"shot"), 1.0, 0.0001)
	mate.pos = Vector2(-1.6, 0)
	assert_almost_eq(_hit(mate, Vector2.LEFT, &"shot"), 1.0, 0.0001)
	mate.pos.x = -1.1
	robot.hp = 0.0
	assert_almost_eq(_hit(mate, Vector2.LEFT, &"shot"), 1.0, 0.0001)


func test_swat_chooses_and_follows_a_moving_shield() -> void:
	var mate: Fighter = arena.squad_ai.spawn_member(arena, Vector2(-3, 2), &"swat")
	for tick: int in 180:
		_tick()
	var mind: SquadMind = arena.squad_ai.minds[mate.id]
	assert_true(mind.mobile_goal.is_finite())
	assert_gt(robot.pos.x, 3.0)
	assert_gt(mate.pos.x, 2.0)
	assert_almost_eq(_hit(mate, arena.rivet.pos.direction_to(mate.pos), &"shot"), 0.2, 0.0001)
