extends GutTest
## n7-melee: Rivet's melee hits reach the shared hit feel (FeelCam) through MeleeFeel: a kill and a
## non-lethal hit each kick once along Rivet -> victim, the chainsaw grind kicks once per strike,
## guns are left to `struck`, and --feel=off (HitFeel.enabled false) keeps the camera still.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _guard(arena: CombatArena, at: Vector2, hp: float) -> Fighter:
	var f: Fighter = Fighter.make(Fighter.Kind.GUARD, 7, at, hp)
	arena.hostiles.append(f)
	return f


func _feel(arena: CombatArena) -> MeleeFeel:
	return MeleeFeel.attach(FeelCam.attach(arena, null), arena)


func test_a_claw_kill_kicks_the_camera_along_the_blow() -> void:
	var arena: CombatArena = _arena()
	var m: MeleeFeel = _feel(arena)
	arena.damage(_guard(arena, Vector2(1.0, 0.0), 1.0), 9.0, arena.rivet.id, &"claw")
	assert_eq(m.hits, 1)
	assert_eq(m.cam.kicks, 1, "the kill kicks")
	var off: Vector2 = m.cam.offset_px(arena.tick, 1.0)
	assert_gt(off.x, 0.0, "the kick runs along Rivet -> victim")


func test_a_non_lethal_jab_kicks_once() -> void:
	var arena: CombatArena = _arena()
	var m: MeleeFeel = _feel(arena)
	arena.damage(_guard(arena, Vector2(1.0, 0.0), 2.0), 1.0, arena.rivet.id, &"claw")
	assert_eq(m.hits, 1)
	assert_eq(m.cam.kicks, 1)


func test_the_chainsaw_grind_kicks_once_per_strike() -> void:
	var arena: CombatArena = _arena()
	var m: MeleeFeel = _feel(arena)
	var f: Fighter = _guard(arena, Vector2(1.0, 0.0), 100.0)
	for t: int in 30:
		arena.tick = t
		arena.damage(f, 0.34, arena.rivet.id, &"chainsaw")
	assert_between(m.hits, 1, 3, "30 grind ticks: 1 to 3 feel hits, not 30")


func test_a_gun_hit_is_left_to_struck() -> void:
	var arena: CombatArena = _arena()
	var m: MeleeFeel = _feel(arena)
	arena.damage(_guard(arena, Vector2(3.0, 0.0), 1.0), 9.0, arena.rivet.id, &"pistol")
	assert_eq(m.hits, 0)


func test_planted_feel_off_keeps_the_camera_still() -> void:
	var arena: CombatArena = _arena()
	var m: MeleeFeel = _feel(arena)
	m.cam.feel.enabled = false
	arena.damage(_guard(arena, Vector2(1.0, 0.0), 1.0), 9.0, arena.rivet.id, &"claw")
	assert_eq(m.cam.kicks, 0, "--feel=off: no kick")
	assert_eq(m.cam.offset_px(arena.tick, 1.0), Vector2.ZERO)


func test_a_kerf_cut_rides_its_weapons_row_class() -> void:
	var arena: CombatArena = _arena()
	var m: MeleeFeel = _feel(arena)
	assert_eq(m.class_of(&"kerf_slice"), &"slice", "hit_feel.json kerf_slice row: class slice")
	arena.damage(_guard(arena, Vector2(0.0, 2.0), 1.0), 99.0, arena.rivet.id, &"kerf_slice")
	assert_eq(m.hits, 1)
	assert_eq(m.cam.kicks, 1, "the cut kicks")
	assert_gt(m.cam.offset_px(arena.tick, 1.0).y, 0.0, "along Rivet -> victim")


func test_planted_a_ghost_weapon_without_a_class_row_is_not_felt() -> void:
	var arena: CombatArena = _arena()
	var m: MeleeFeel = _feel(arena)
	assert_eq(m.class_of(&"no_such_ghost_hit"), &"")
	arena.damage(_guard(arena, Vector2(1.0, 0.0), 1.0), 9.0, arena.rivet.id, &"no_such_ghost_hit")
	assert_eq(m.hits, 0)
