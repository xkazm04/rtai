extends GutTest
## GunFx: a table bullet gun's presentation in the real fight (shells, smoke, the muzzle's
## tick, a magazine on reload, impacts by surface), stepped on the stage tick, never the sim's.


func _arena(weapon: StringName) -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.gun = GunHand.make(WeaponTable.shipped(), weapon, reg.stream(&"gunplay"))
	return arena


func _run(arena: CombatArena, fx: GunFx, from: int, ticks: int) -> void:
	for i: int in ticks:
		arena.step(from + i)
		fx.step(arena, from + i)


func test_every_shot_ejects_a_shell_and_a_puff() -> void:
	var arena: CombatArena = _arena(&"machine_pistol")
	var fx: GunFx = GunFx.new()
	arena.gun.tap = true
	for i: int in 30:
		@warning_ignore("return_value_discarded")
		arena.rivet_fire(Vector2(20.0, 0.0))
		arena.step(i + 1)
		fx.step(arena, i + 1)
	assert_gt(arena.gun.shots_fired, 3)
	assert_eq(fx.fired_count, arena.gun.shots_fired)
	assert_eq(fx.bits.size(), mini(arena.gun.shots_fired, GunFx.MAX_BITS))
	assert_gt(fx.smoke.size(), 0)


func test_a_round_on_the_ground_leaves_a_scuff_and_on_a_body_a_burst() -> void:
	var arena: CombatArena = _arena(&"pistol")
	var fx: GunFx = GunFx.new()
	var g: Fighter = arena.spawn_guard(Vector2(6.0, 0.0))
	g.pos = Vector2(6.0, 0.0)
	g.cooldown = 9999
	assert_true(arena.rivet_fire(g.pos))
	_run(arena, fx, 1, 20)
	assert_false(g.alive(), "a pistol hit drops a human")
	assert_eq(fx.impacts.size(), 1)
	assert_eq(int(fx.impacts[0].z), GunFx.Hit.BODY)
	assert_true(arena.rivet_fire(Vector2(0.0, 30.0)))
	_run(arena, fx, 30, 60)
	assert_eq(fx.impacts.size(), 2)
	assert_eq(int(fx.impacts[1].z), GunFx.Hit.GROUND)


func test_a_reload_drops_the_magazine_and_rows_differ() -> void:
	var arena: CombatArena = _arena(&"pistol")
	var fx: GunFx = GunFx.new()
	assert_true(arena.rivet_fire(Vector2(10.0, 0.0)))
	_run(arena, fx, 1, 2)
	arena.gun.trigger.start_reload()
	_run(arena, fx, 3, 2)
	var mags: int = 0
	for b: Vector4 in fx.bits:
		mags += 1 if b.w < 0.0 else 0
	assert_eq(mags, 1)
	var heavy: int = fx.look(&"pistol")["spikes"]
	var auto: int = fx.look(&"machine_pistol")["spikes"]
	assert_ne(heavy, auto, "a single shot and an automatic flash differently")
