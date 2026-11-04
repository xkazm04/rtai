extends GutTest
## The default D4/D5 blood (lane d5-combat): FX cues in, blood on the ground out.


func _blood(mode: String) -> CombatBlood:
	var b: CombatBlood = CombatBlood.new()
	b.mode = mode
	add_child_autofree(b)
	return b


func test_death_bleeds_and_mutes_the_ink_splat() -> void:
	var t: FxTriggers = FxTriggers.new()
	var b: CombatBlood = _blood("noir")
	b.attach(t)
	var death: Array = t.rows[&"death"]["fx"]
	assert_false(death.has("ink_splat"), "noir mode mutes the D4 ink splat")
	t.fire(&"death", Vector2(320, 320), 0.0, 10)
	b.step(10, Vector2.ZERO)
	b.step(80, Vector2.ZERO)
	assert_eq(b.kills, 1)
	assert_gt(b.blood.live_decals(), 1, "a spurt and a pool")
	# the city's dead slide 0.54 m along the blow (heading 0 = +x): the pool spreads under them
	var rest: Vector2 = Vector2(320.0 + 0.54 * SimConst.PX_PER_M, 320.0)
	assert_true(b.blood.has_pool_at(rest, 6.0), "a pool under the body where it slid to")
	assert_false(b.blood.has_pool_at(Vector2(320, 320), 6.0), "not where it was hit")


func test_ink_mode_keeps_the_splat_and_draws_no_blood() -> void:
	var t: FxTriggers = FxTriggers.new()
	var b: CombatBlood = _blood("ink")
	b.attach(t)
	var death: Array = t.rows[&"death"]["fx"]
	assert_true(death.has("ink_splat"), "the fallback keeps the D4 splat")
	t.fire(&"death", Vector2(320, 320), 0.0, 10)
	b.step(10, Vector2.ZERO)
	assert_eq(b.kills, 0)
	assert_eq(b.blood.live_decals(), 0)


func test_death_sprays_along_the_round_that_killed() -> void:
	var t: FxTriggers = FxTriggers.new()
	var b: CombatBlood = _blood("noir")
	b.attach(t)
	# the round travelled +y (heading PI/2): projectile_end is thrown back, at heading + PI
	t.fire(&"death", Vector2(320, 320), 0.0, 10)
	t.fire(&"projectile_end", Vector2(320, 312), PI / 2.0 + PI, 10)
	b.step(10, Vector2.ZERO)
	assert_eq(b.aimed, 1)


func test_a_far_round_does_not_aim_the_spray() -> void:
	var t: FxTriggers = FxTriggers.new()
	var b: CombatBlood = _blood("noir")
	b.attach(t)
	t.fire(&"death", Vector2(320, 320), 0.0, 10)
	t.fire(&"projectile_end", Vector2(900, 320), 0.0, 10)
	b.step(10, Vector2.ZERO)
	assert_eq(b.aimed, 0)
	assert_eq(b.kills, 1)


func test_rivet_leaks_oil_not_blood() -> void:
	var t: FxTriggers = FxTriggers.new()
	var b: CombatBlood = _blood("noir")
	b.attach(t)
	t.fire(&"player_hit", Vector2(320, 320), 0.0, 10)
	b.step(10, Vector2.ZERO)
	b.step(60, Vector2.ZERO)
	assert_eq(b.hits, 1)
	assert_eq(b.blood.live_decals(), 0, "a robot never bleeds red")
	assert_gt(b.oil.live_decals(), 0, "black oil on the ground")


func test_splats_land_on_the_gpu_mesh_once() -> void:
	var b: CombatBlood = _blood("noir")
	b.kill_human(Vector2(320, 320), Vector2.RIGHT)
	b.step(1, Vector2.ZERO)
	b.step(60, Vector2.ZERO)
	var mesh: BloodSplatMesh = b.blood.use_splat_mesh()
	assert_gt(mesh.written, 0)
	var w: int = mesh.written
	b.step(64, Vector2.ZERO)
	assert_eq(mesh.written, w, "a settled frame writes no instance")


func test_quest_events_bleed_guards_and_oil_rivet() -> void:
	var bus: EventBus = EventBus.new()
	var b: CombatBlood = _blood("noir")
	var where: Dictionary[int, Vector2] = {1: Vector2(5, 5), 2: Vector2(8, 5)}
	b.listen(bus, func(id: int) -> Vector2: return where.get(id, Vector2.INF), 1)
	bus.actor_killed.emit(1, 2, &"shot")
	bus.player_hit.emit(&"robo-tazer")
	bus.actor_killed.emit(1, 99, &"shot")
	b.step(1, Vector2.ZERO)
	b.step(80, Vector2.ZERO)
	assert_eq(b.kills, 1, "the guard bleeds; an unknown victim does not")
	assert_eq(b.hits, 1)
	assert_true(b.blood.has_pool_at(Vector2(8, 5) * SimConst.PX_PER_M, 16.0))
	bus.free()


func test_a_body_burned_to_death_leaves_no_red() -> void:
	var bus: EventBus = EventBus.new()
	var b: CombatBlood = _blood("noir")
	var where: Dictionary[int, Vector2] = {1: Vector2(5, 5), 2: Vector2(8, 5)}
	b.listen(bus, func(id: int) -> Vector2: return where.get(id, Vector2.INF), 1)
	bus.actor_killed.emit(1, 2, &"burned")
	b.step(1, Vector2.ZERO)
	b.step(80, Vector2.ZERO)
	assert_eq(b.kills, 0, "charred, not sprayed")
	assert_false(b.blood.has_pool_at(Vector2(8, 5) * SimConst.PX_PER_M, 16.0), "no pool")
	bus.free()


func test_a_hit_robot_leaves_an_oil_trail_where_it_walks() -> void:
	var b: CombatBlood = _blood("noir")
	var at: Array[Vector2] = [Vector2(320, 320)]
	b.player_px = func() -> Vector2: return at[0]
	b.hit_robot(at[0])
	for t: int in range(1, 120):
		at[0] += Vector2(1.5, 0.0)
		b.step(t, Vector2.ZERO)
	assert_gt(b.leak.drips, 5, "a drop every few px walked")
	assert_eq(b.blood.live_decals(), 0, "the trail is oil, not blood")


func test_both_keeps_the_ink_splat_under_the_blood() -> void:
	var t: FxTriggers = FxTriggers.new()
	var b: CombatBlood = _blood("both")
	b.attach(t)
	var death: Array = t.rows[&"death"]["fx"]
	assert_true(death.has("ink_splat"))
	t.fire(&"death", Vector2(320, 320), 0.0, 10)
	b.step(10, Vector2.ZERO)
	assert_eq(b.kills, 1)


func test_quest_kills_keep_the_pool_at_the_hit() -> void:
	var b: CombatBlood = _blood("noir")
	b.kill_human(Vector2(320, 320), Vector2.RIGHT)
	b.step(80, Vector2.ZERO)
	assert_true(b.blood.has_pool_at(Vector2(324, 320), 6.0), "events path: 4 px lead, no slide")


func test_a_game_pool_size_overrides_the_table() -> void:
	var b: CombatBlood = _blood("noir")
	b.blood.pool_r1_px = 12.0
	b.kill_human(Vector2(320, 320), Vector2.RIGHT)
	var r1: PackedFloat32Array = b.blood._ring._r1
	assert_true(r1.has(12.0), "game.pool_radius_px wins over pool.radius_px")
	assert_false(r1.has(22.0), "the table radius is not used")


func test_pool_body_is_the_doctrine_blood_dark() -> void:
	var b: CombatBlood = CombatBlood.new()
	var want: Color = Color8(0x54, 0x00, 0x05)
	var dark: Color = b.blood._fluid.dark
	var gap: float = Vector3(dark.r - want.r, dark.g - want.g, dark.b - want.b).length()
	assert_lt(gap, 0.005, "palette blood_dark #540005 (d5-city doctrine), got %s" % dark)
	var noir: BloodFx = BloodFx.new()
	assert_gt(noir._fluid.dark.r, 0.4, "noir's own body stays over the noir blood gate")
	noir.free()
	b.blood.set_dark(Color(0.2, 0.0, 0.0))
	assert_eq(b.blood._fluid.dark, Color(0.2, 0.0, 0.0), "set_dark recolours the pool body")
	b.free()
