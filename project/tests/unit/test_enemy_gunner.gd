extends GutTest


func _gunner() -> EnemyGunner:
	var table: WeaponTable = WeaponTable.shipped()
	return EnemyGunner.make(2, Vector2.ZERO, &"pistol", table)


func test_tell_precedes_the_volley_and_locks_the_aim() -> void:
	var table: WeaponTable = WeaponTable.shipped()
	var g: EnemyGunner = _gunner()
	var sim: ProjectileSim = ProjectileSim.new(RngRegistry.new(1).stream(&"t"), table)
	var target: Vector2 = Vector2(10, 0)
	var first_shot_tick: int = -1
	var tell_start: int = -1
	var lock_aim: Vector2 = Vector2.INF
	for tick: int in 180:
		target.y = float(tick) * 0.05
		g.step(sim, target)
		if g.telling() and tell_start < 0:
			tell_start = tick
		if g.locked() and lock_aim == Vector2.INF:
			lock_aim = g.aim_point
		if sim.shots_fired > 0 and first_shot_tick < 0:
			first_shot_tick = tick
			assert_eq(g.aim_point, lock_aim, "the volley goes where the aim locked")
		sim.step(tick)
	assert_gt(tell_start, 0)
	assert_eq(first_shot_tick - tell_start, table.enemy_tell_ticks, "the tell is tell_s long")
	assert_eq(sim.shots_fired, table.enemy_volley)


func test_planted_no_lock_keeps_tracking() -> void:
	var g: EnemyGunner = _gunner()
	g.track_through_lock = true
	var sim: ProjectileSim = ProjectileSim.new(
		RngRegistry.new(1).stream(&"t"), WeaponTable.shipped()
	)
	var last: Vector2 = Vector2.ZERO
	for tick: int in 120:
		last = Vector2(10, float(tick))
		g.step(sim, last)
		if sim.shots_fired > 0:
			break
	assert_eq(g.aim_point.y, last.y, "tracked up to the volley tick")
