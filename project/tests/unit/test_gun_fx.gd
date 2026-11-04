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
	fx.art_mags = {}  # the fallback: no weapon-art magazine (showcase REQUEST 19)
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


func test_an_enemy_round_on_rivet_sparks_off_his_plating() -> void:
	var arena: CombatArena = _arena(&"pistol")
	var fx: GunFx = GunFx.new()
	var s: Shot = Shot.new()
	s.from_rivet = false
	s.pos = Vector2(-4.0, 0.0)
	s.vel = Vector2(20.0, 0.0)
	s.left_m = 10.0
	arena.shots.append(s)
	_run(arena, fx, 1, 30)
	assert_eq(fx.impacts.size(), 1)
	assert_eq(int(fx.impacts[0].z), GunFx.Hit.PLATING)


func test_a_hostile_round_flashes_at_its_gun_and_drops_a_shell() -> void:
	var arena: CombatArena = _arena(&"pistol")
	var fx: GunFx = GunFx.new()
	var g: Fighter = arena.spawn_guard(Vector2(8.0, 0.0))
	g.pos = Vector2(8.0, 0.0)
	var s: Shot = Shot.new()
	s.from_rivet = false
	s.shooter_id = g.id
	s.pos = g.pos + Vector2(-0.5, 0.0)
	s.vel = Vector2(-20.0, 0.0)
	s.left_m = 20.0
	arena.shots.append(s)
	fx.step(arena, 1)
	assert_eq(fx.enemy_flashes.size(), 1)
	assert_eq(fx.bits.size(), 1)


func test_the_hand_cannon_dumps_six_shells_on_reload_and_drops_an_armored_human() -> void:
	var arena: CombatArena = _arena(&"hand_cannon")
	var fx: GunFx = GunFx.new()
	assert_true(arena.gun.trigger.spec.enabled, "the hand cannon is in the arsenal")
	var g: Fighter = arena.spawn_guard(Vector2(6.0, 0.0))
	g.pos = Vector2(6.0, 0.0)
	g.cooldown = 9999
	assert_true(arena.rivet_fire(g.pos))
	_run(arena, fx, 1, 20)
	assert_false(g.alive(), "one hand cannon round drops a human")
	assert_eq(fx.bits.size(), 0, "a revolver keeps its shells until the reload")
	arena.gun.trigger.start_reload()
	_run(arena, fx, 21, 2)
	assert_eq(fx.bits.size(), 6, "the reload dumps six spent shells")
	var ring_m: float = fx.look(&"hand_cannon").get("ring_m", 0.0)
	assert_gt(ring_m, 0.0)


func test_a_plasma_bolt_scorches_where_it_stops_and_ejects_no_shell() -> void:
	var arena: CombatArena = _arena(&"plasma_rifle")
	var fx: GunFx = GunFx.new()
	var g: Fighter = arena.spawn_guard(Vector2(6.0, 0.0))
	g.pos = Vector2(6.0, 0.0)
	g.cooldown = 9999
	assert_true(arena.rivet_fire(g.pos))
	_run(arena, fx, 1, 30)
	assert_false(g.alive(), "one plasma bolt drops a human")
	assert_eq(fx.impacts.size(), 1)
	assert_eq(int(fx.impacts[0].z), GunFx.Hit.BODY + GunFx.SCORCH, "a bolt's impact scorches")
	assert_eq(fx.bits.size(), 0, "an energy gun ejects no shell")


func test_one_ray_drops_a_human() -> void:
	var arena: CombatArena = _arena(&"ray_gun")
	var fx: GunFx = GunFx.new()
	assert_true(arena.gun.trigger.spec.enabled, "the ray gun is in the arsenal")
	assert_eq(arena.gun.trigger.spec.chain_hops, 0, "a ray never chains (drawn as a beam)")
	var g: Fighter = arena.spawn_guard(Vector2(6.0, 0.0))
	g.pos = Vector2(6.0, 0.0)
	g.cooldown = 9999
	assert_true(arena.rivet_fire(g.pos))
	_run(arena, fx, 1, 20)
	assert_false(g.alive(), "one ray drops a human")
	assert_eq(fx.impacts.size(), 1, "a ray marks where it stopped")
	assert_eq(int(fx.impacts[0].z), GunFx.Hit.BODY + GunFx.SCORCH, "a ray sizzles")
