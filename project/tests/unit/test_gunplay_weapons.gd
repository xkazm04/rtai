extends GutTest
## Lane gunplay: the weapon table loads, triggers bloom and reload, rounds sweep without
## tunnelling, cover stops rounds, splash falls off, the model is deterministic per seed.

var _table: WeaponTable


func before_all() -> void:
	_table = WeaponTable.shipped()


func _rng(seed_value: int) -> RandomNumberGenerator:
	return RngRegistry.new(seed_value).stream(&"gunplay")


func test_table_loads_the_core_six_and_gloria() -> void:
	assert_true(_table.ok())
	for id: StringName in [&"pistol", &"machine_pistol", &"flamethrower", &"rocket_launcher"]:
		assert_true(_table.playable().has(id), str(id))
	for id: StringName in [&"electro_gun", &"molotov", &"gloria"]:
		assert_true(_table.playable().has(id), str(id))
	assert_false(_table.playable().has(&"mini_nuke"), "unique rows wait")


func test_enemy_rounds_are_slower_than_the_players() -> void:
	assert_lt(_table.enemy_speed_scale, 0.6)
	assert_gt(_table.enemy_tell_ticks, 0)


func test_semi_fires_on_the_press_edge_only() -> void:
	var trig: Trigger = Trigger.new(_table.weapon(&"pistol"))
	assert_true(trig.pull(true))
	for i: int in 40:
		trig.step()
		assert_false(trig.pull(true), "held, no new press")


func test_bloom_grows_and_recovers() -> void:
	var sim: ProjectileSim = ProjectileSim.new(_rng(1), _table)
	var trig: Trigger = Trigger.new(_table.weapon(&"machine_pistol"))
	for i: int in 10:
		sim.fire(trig, Vector2.ZERO, Vector2(10, 0), Projectile.TEAM_PLAYER, 0)
	var hot: float = trig.cone_rad()
	assert_gt(hot, trig.spec.spread_rad)
	for i: int in 120:
		trig.step()
	assert_almost_eq(trig.cone_rad(), trig.spec.spread_rad, 1e-5)


func test_empty_magazine_reloads() -> void:
	var trig: Trigger = Trigger.new(_table.weapon(&"rocket_launcher"))
	assert_true(trig.pull(true))
	assert_true(trig.reloading())
	for i: int in trig.spec.reload_ticks:
		trig.step()
	assert_eq(trig.ammo, 1)


func test_a_fast_round_cannot_tunnel_through_a_thin_body() -> void:
	assert_almost_eq(Sweep.circle(Vector2.ZERO, Vector2(10, 0), Vector2(5, 0.2), 0.3), 0.47, 0.01)
	assert_eq(Sweep.circle(Vector2.ZERO, Vector2(10, 0), Vector2(5, 1.0), 0.3), -1.0)


func test_cover_stops_a_round() -> void:
	var sim: ProjectileSim = ProjectileSim.new(_rng(2), _table)
	var t: RangeTarget = RangeTarget.make(1, Vector2(10, 0), 100.0, 0.35)
	sim.targets.append(t)
	sim.cover.append(Rect2(Vector2(5, -1), Vector2(0.5, 2)))
	var trig: Trigger = Trigger.new(_table.weapon(&"gloria"))
	sim.fire(trig, Vector2.ZERO, t.pos, Projectile.TEAM_PLAYER, 0)
	for i: int in 60:
		sim.step(i)
	assert_eq(t.hp, 100.0)
	assert_eq(sim.projectiles.size(), 0)


func test_rocket_splash_falls_off_with_distance() -> void:
	var sim: ProjectileSim = ProjectileSim.new(_rng(3), _table)
	var near: RangeTarget = RangeTarget.make(1, Vector2(10, 0), 1000.0, 0.35)
	var mid: RangeTarget = RangeTarget.make(2, Vector2(10, 2.0), 1000.0, 0.35)
	var far: RangeTarget = RangeTarget.make(3, Vector2(10, 6.0), 1000.0, 0.35)
	sim.targets.append_array([near, mid, far])
	var trig: Trigger = Trigger.new(_table.weapon(&"rocket_launcher"))
	sim.fire(trig, Vector2.ZERO, near.pos, Projectile.TEAM_PLAYER, 0)
	for i: int in 60:
		sim.step(i)
	assert_lt(near.hp, mid.hp)
	assert_lt(mid.hp, 1000.0)
	assert_eq(far.hp, 1000.0)


func test_drill_is_deterministic_per_seed() -> void:
	var lane: RangeDrill.Lane = RangeDrill.Lane.new()
	lane.weapon = &"machine_pistol"
	lane.distance_m = 20.0
	lane.strafe_mps = 3.0
	var a: RangeDrill.Result = RangeDrill.run(_table, lane, _rng(7))
	var b: RangeDrill.Result = RangeDrill.run(_table, lane, _rng(7))
	assert_eq(a.digest, b.digest)
	assert_eq(a.shots, b.shots)


func test_planted_fault_is_caught() -> void:
	var lane: RangeDrill.Lane = RangeDrill.Lane.new()
	lane.weapon = &"machine_pistol"
	lane.distance_m = 20.0
	lane.strafe_mps = 3.0
	var a: RangeDrill.Result = RangeDrill.run(_table, lane, _rng(7))
	var b: RangeDrill.Result = RangeDrill.run(_table, lane, _rng(8))
	assert_ne(a.digest, b.digest, "a different spread stream must move the digest")


func test_a_rocket_bursts_at_the_aim_point_and_catches_a_strafer() -> void:
	var lane: RangeDrill.Lane = RangeDrill.Lane.new()
	lane.weapon = &"rocket_launcher"
	lane.distance_m = 5.0
	lane.strafe_mps = 3.2
	var res: RangeDrill.Result = RangeDrill.run(_table, lane, _rng(11))
	assert_true(res.killed, "splash at the aimed point covers a 0.8 m juke")


func test_pad_aim_assist_bends_toward_a_target_and_the_mouse_stays_raw() -> void:
	var assist: AimAssist = _table.aim_assist
	var t: RangeTarget = RangeTarget.make(1, Vector2(10, 1), 100.0, 0.35)
	var targets: Array[RangeTarget] = [t]
	var raw: Vector2 = Vector2.RIGHT
	var pad: Vector2 = assist.bend(raw, Vector2.ZERO, targets, true)
	assert_gt(pad.angle(), 0.0, "bent toward the target")
	assert_lt(pad.angle(), Vector2(10, 1).angle(), "only part of the way (light)")
	assert_eq(assist.bend(raw, Vector2.ZERO, targets, false), raw, "mouse untouched")
	var wide: Array[RangeTarget] = [RangeTarget.make(2, Vector2(5, 5), 100.0, 0.35)]
	assert_eq(assist.bend(raw, Vector2.ZERO, wide, true), raw, "outside the cone")


func test_held_scale_defaults_to_model_size() -> void:
	assert_eq(_table.weapon(&"pistol").held_scale, 1.0, "no held_scale row -> 1.0")
