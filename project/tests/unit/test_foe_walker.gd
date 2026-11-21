extends GutTest

const S := EnemyAgent.State

var arena: CombatArena
var squad: ArenaSquad
var h: Fighter
var mind: SquadMind
var arch: EnemyRoster.Archetype
var impacts: Array[Vector3]
var rivet_at_impact: Vector2
var now: int


func before_each() -> void:
	var rng: RandomNumberGenerator = RngRegistry.new(22).stream(&"combat")
	arena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	h = squad.spawn_member(arena, Vector2.ZERO, &"war_machine")
	h.pos = Vector2(12, 0)
	h.facing = Vector2.LEFT
	h.cooldown = 0
	arch = squad.pit.roster.archetype(h.archetype)
	now = 0
	impacts = []
	@warning_ignore("return_value_discarded")
	squad.rockets.burst.connect(_impact)


func _impact(at: Vector2, radius: float, _shot: Shot) -> void:
	impacts.append(Vector3(at.x, at.y, radius))
	rivet_at_impact = arena.rivet.pos


func _step() -> void:
	now += 1
	arena.step(now)
	mind = squad.minds[h.id]


func _tell() -> void:
	for i: int in 180:
		_step()
		if mind.agent.state == S.WINDUP:
			return
	fail_test("no attack tell in three seconds")


func _recovery() -> void:
	var fired: int = now
	var facing: Vector2 = h.facing
	var at: Vector2 = h.pos
	arena.rivet.pos = at + Vector2.UP * 10.0
	assert_eq(h.cooldown, mind.walker.attack.cooldown_ticks)
	assert_gte(h.cooldown, 60)
	for i: int in h.cooldown:
		assert_eq(mind.agent.state, S.RECOVER)
		assert_eq(mind.walker.ring_radius(mind.agent), 0.0)
		_step()
		assert_eq(h.facing, facing)
		assert_eq(h.pos, at)
		assert_eq(mind.agent.shot_tick, fired)
		assert_eq(h.tell_left + h.swing_left, 0)
	assert_eq(mind.agent.state, S.ENGAGE)
	_step()
	assert_ne(h.facing, facing)


func test_cannon_tracks_then_locks_and_a_late_sidestep_clears_its_burst() -> void:
	_tell()
	var start: int = now
	assert_true(GuardTell.telling(h))
	assert_eq(h.tell_left, arch.telegraph_ticks)
	assert_gte(h.tell_left, 60)
	var walk: Vector2 = Vector2.UP * 5.0 * SimClock.TICK_DT
	for i: int in arch.telegraph_ticks:
		assert_eq(mind.walker.ring_radius(mind.agent), arch.weapon.splash_radius_m)
		assert_true(arena.shots.is_empty())
		if arena.guard_tell.locked(h):
			arena.rivet.pos += walk
		_step()
		assert_eq(mind.walker.landing, arena.rivet.pos)
	assert_eq(now - start, arch.telegraph_ticks)
	assert_eq(mind.agent.shot_tick, now)
	assert_eq(arena.shots.size(), 1)
	var shell: FoeRocketFlight.Round = arena.shots[0]
	assert_eq(shell.weapon, arch.weapon.id)
	assert_eq(shell.size, Shot.LARGE)
	var locked: Vector2 = arena.rivet.pos
	assert_eq(shell.target, locked)
	assert_almost_eq(shell.vel.length(), arch.weapon.speed_mps, 0.001)
	assert_eq(shell.target, mind.walker.landing)
	for i: int in 70:
		arena.rivet.pos += walk
		_step()
	assert_gt(locked.distance_to(rivet_at_impact), arch.weapon.splash_radius_m)
	assert_eq(impacts, [Vector3(locked.x, locked.y, arch.weapon.splash_radius_m)])
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)


func test_cannon_recovery_locks_the_chassis_and_trigger() -> void:
	_tell()
	for i: int in h.tell_left:
		_step()
	_recovery()


func test_hits_and_stun_during_cannon_tell_do_not_cancel_or_delay_the_shell() -> void:
	_tell()
	arena.areas = FightAreas.new()
	var fx: FighterFx = FighterFx.new()
	fx.stun_ticks = arch.telegraph_ticks + 10
	arena.areas.fx[h.id] = fx
	var start: int = now
	for i: int in arch.telegraph_ticks:
		if i % 12 == 0:
			arena.hit_dir = -h.facing
			arena.damage(h, 1.0, arena.rivet.id, &"gloria")
		_step()
	assert_eq(mind.agent.shot_tick, start + arch.telegraph_ticks)
	assert_lt(h.hp, h.max_hp)
	for i: int in 70:
		_step()
	assert_eq(arena.rivet.hp, arena.rivet.max_hp - arch.weapon.damage)
	assert_eq(impacts.size(), 1)
	assert_eq(impacts[0].z, arch.weapon.splash_radius_m)


func test_first_wall_intercepts_the_locked_shell() -> void:
	_tell()
	var blocks: Array[Rect2] = [Rect2(4, -5, 1, 10), Rect2(8, -5, 1, 10)]
	squad.set_route_map(GuardRouteMap.new(Rect2(-30, -30, 60, 60), blocks, null, 0.45))
	for i: int in arch.telegraph_ticks + 40:
		_step()
	assert_eq(impacts, [Vector3(9, 0, arch.weapon.splash_radius_m)])
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)


func test_stomp_grows_to_its_full_footprint_then_recovers() -> void:
	h.pos = Vector2(2, 0)
	_tell()
	assert_eq(h.swing_left, arch.alt_telegraph_ticks)
	assert_gte(h.swing_left, 45)
	assert_eq(mind.agent.timer, h.swing_left)
	var previous: float = 0.0
	for i: int in arch.alt_telegraph_ticks:
		var radius: float = mind.walker.ring_radius(mind.agent)
		assert_gt(radius, previous)
		previous = radius
		assert_eq(mind.walker.landing, h.pos)
		assert_true(impacts.is_empty())
		_step()
	assert_eq(previous, arch.alt_weapon.splash_radius_m)
	assert_eq(impacts, [Vector3(h.pos.x, h.pos.y, previous)])
	assert_eq(arena.rivet.hp, arena.rivet.max_hp - arch.alt_weapon.splash_damage)
	assert_true(arena.shots.is_empty())
	_recovery()


func test_walking_out_during_stomp_tell_avoids_damage() -> void:
	h.pos = Vector2(2, 0)
	_tell()
	for i: int in h.swing_left:
		arena.rivet.pos += Vector2.LEFT * 5.0 * SimClock.TICK_DT
		_step()
	assert_eq(impacts, [Vector3(h.pos.x, h.pos.y, arch.alt_weapon.splash_radius_m)])
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)


func test_front_rear_flank_and_blast_at_the_damage_chokepoint() -> void:
	var directions: Array[Vector2] = [-h.facing, h.facing, Vector2.UP, -h.facing, h.facing]
	var amounts: Array[float] = [0.5, 1.5, 1.0, 1.0, 1.0]
	for i: int in directions.size():
		var hp: float = h.hp
		arena.hit_dir = directions[i]
		var weapon: StringName = &"homing_shard" if i == 4 else &"gloria"
		arena.damage(h, 1.0, 0, weapon, &"blown" if i == 3 else &"shot")
		assert_eq(hp - h.hp, amounts[i])
	assert_eq(FoeArmor.k(h, h.facing.rotated(deg_to_rad(44)), &"shot", squad), 1.5)
	assert_eq(FoeArmor.k(h, h.facing.rotated(deg_to_rad(46)), &"shot", squad), 1.0)


func test_walks_into_the_band_from_both_sides_at_row_speed_and_turn_rate() -> void:
	squad.pit.roster.max_shooters = 0
	for start_m: float in [17.0, 5.0]:
		h.pos = Vector2(start_m, 0)
		h.facing = Vector2.UP
		squad.minds.clear()
		for i: int in 150:
			var at: Vector2 = h.pos
			var facing: Vector2 = h.facing
			_step()
			assert_lte(h.pos.distance_to(at), arch.speed_mps * SimClock.TICK_DT + 0.00001)
			assert_lte(absf(facing.angle_to(h.facing)), arch.turn_rad_per_tick + 0.00001)
		assert_eq(h.cooldown, 0)
		assert_between(h.pos.x, 8.0, 14.0)
		assert_null(mind.walker.attack)
