extends GutTest
## The Robo-tazer (mechanic robo-tazer, beat "Rated for Appliances"): a 1.5 s telegraph, a 2 s
## vent window in which Mertz stands still and is open to a nail, two hits leave Rivet near
## death (never dead), the ball bends toward metal and chains, and the weapon dies with him.

var _bus: EventBus
var _tuning: CombatTuning
var _arena: CombatArena


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_tuning = CombatTuning.shipped()
	var rng: RandomNumberGenerator = RngRegistry.new(7).stream(&"combat")
	_arena = CombatArena.new(_tuning, _bus, rng)
	_arena.rivet.pos = Vector2(0.0, 20.0)


func test_the_telegraph_is_one_and_a_half_seconds() -> void:
	var tazer: RoboTazer = RoboTazer.new(_tuning)
	while tazer.state != RoboTazer.State.CHARGING:
		assert_false(tazer.step())
	var charge: int = 0
	var fracs: Array[float] = []
	while not tazer.step():
		charge += 1
		fracs.append(tazer.charge_frac())
	assert_eq(charge + 1, 90, "1.5 s at 60 Hz, the firing tick included")
	assert_eq(tazer.charge_ticks, roundi(1.5 * SimClock.TICK_RATE))
	assert_true(fracs[0] < fracs[44] and fracs[44] < fracs[-1], "the whine rises")


func test_after_each_shot_mertz_stands_still_and_exposed_for_two_seconds() -> void:
	var boss: Fighter = _arena.spawn_boss(Vector2(0.0, 0.0))
	_step_until(func() -> bool: return _arena.tazer.state == RoboTazer.State.VENTING)
	assert_eq(_arena.balls.size(), 1, "the shot is out")
	var at: Vector2 = boss.pos
	var vent: int = 0
	while _arena.tazer.state == RoboTazer.State.VENTING:
		assert_true(boss.exposed)
		assert_eq(boss.pos, at, "he stands still while the pack vents")
		_arena.step(0)
		vent += 1
	assert_eq(vent, 120, "2 s window")
	assert_false(boss.exposed, "charging again: back in cover")


func test_a_nail_in_cover_is_stopped_and_one_in_the_window_kills() -> void:
	var boss: Fighter = _arena.spawn_boss(Vector2(0.0, 0.0))
	_arena.rivet.weapon = &"gloria"
	_step_until(func() -> bool: return _arena.tazer.state == RoboTazer.State.CHARGING)
	assert_true(_arena.rivet_fire(boss.pos))
	_step(40)
	assert_true(boss.alive(), "in cover: the nail hits the crates")
	_step_until(func() -> bool: return _arena.tazer.vulnerable())
	_arena.rivet.cooldown = 0
	assert_true(_arena.rivet_fire(boss.pos))
	_step(30)
	assert_false(boss.alive(), "one nail, one human")


func test_two_hits_nearly_kill_rivet() -> void:
	var boss: Fighter = _arena.spawn_boss(Vector2(0.0, 0.0))
	_arena.rivet.pos = Vector2(0.0, 8.0)
	_step_until(func() -> bool: return _arena.tazer_hits == 2, 60 * 30)
	var hp: float = _arena.rivet.hp
	assert_true(boss.alive())
	assert_true(_arena.rivet.alive(), "two hits never kill")
	assert_lt(hp, _tuning.rivet["near_death_frac"] * _arena.rivet.max_hp, "near death")
	assert_eq(_tuning.tazer["damage"] * 2.0, 92.0)


func test_the_ball_bends_toward_rivet_and_chains_through_metal() -> void:
	var ball: ArcBall = ArcBall.launch(Vector2.ZERO, Vector2(10.0, 0.0), _tuning)
	var rivet: Vector2 = Vector2(10.0, 4.0)
	var metal: PackedVector2Array = PackedVector2Array([Vector2(11.0, 5.5), Vector2(30.0, 30.0)])
	while not ball.burst:
		ball.step(rivet, 0.6, metal)
	assert_true(ball.pos.y > 1.0, "it bent off the straight line toward the metal robot")
	assert_true(ball.hit_rivet)
	assert_true(ball.arcs.has(Vector2(11.0, 5.5)), "the arc jumped to the nearby crate")
	assert_false(ball.arcs.has(Vector2(30.0, 30.0)), "not to far metal")


func test_the_weapon_dies_with_him_and_is_never_dropped() -> void:
	var boss: Fighter = _arena.spawn_boss(Vector2(0.0, 0.0))
	_step_until(func() -> bool: return _arena.tazer.vulnerable())
	_arena.damage(boss, 1.0, 0, &"gloria")
	assert_false(boss.alive())
	assert_eq(_arena.tazer.state, RoboTazer.State.SHORTED)
	assert_eq(_arena.rifle_drops.size(), 0, "no pickup: the player never holds one")
	assert_eq(_arena.balls.size(), 0)
	for _i: int in 600:
		assert_false(_arena.tazer.step(), "a shorted tazer never fires")


func _step(n: int) -> void:
	for _i: int in n:
		_arena.step(_arena.tick + 1)


func _step_until(done: Callable, limit: int = 60 * 10) -> void:
	var guard: int = 0
	while not done.call() and guard < limit:
		_step(1)
		guard += 1
	var reached: bool = done.call()
	assert_true(reached, "reached within %d ticks" % limit)
