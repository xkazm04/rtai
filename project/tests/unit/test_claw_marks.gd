extends GutTest
## n7-melee: the claw's hit (a wound or a kill) prints one rake mark at the victim, along Rivet ->
## victim, on the hit tick; other weapons print none; the shipped row is on.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _guard(arena: CombatArena, at: Vector2, hp: float) -> Fighter:
	var f: Fighter = Fighter.make(Fighter.Kind.GUARD, 7, at, hp)
	arena.hostiles.append(f)
	return f


func test_the_shipped_row_is_on() -> void:
	var m: ClawMarks = ClawMarks.attach(_arena())
	assert_gt(m.flash_ticks, 0)
	assert_gt(m.rake_m, 0.0)


func test_a_claw_jab_prints_a_rake_along_the_blow() -> void:
	var arena: CombatArena = _arena()
	var m: ClawMarks = ClawMarks.attach(arena)
	arena.tick = 40
	arena.damage(_guard(arena, Vector2(0.0, 1.0), 2.0), 1.0, arena.rivet.id, &"claw")
	assert_eq(m.marks.size(), 1)
	assert_almost_eq(m.marks[0].z, PI * 0.5, 0.001, "Rivet -> victim")
	assert_eq(int(m.marks[0].w), 40, "on the hit tick")


func test_a_claw_kill_prints_one_too() -> void:
	var arena: CombatArena = _arena()
	var m: ClawMarks = ClawMarks.attach(arena)
	arena.damage(_guard(arena, Vector2(1.0, 0.0), 1.0), 9.0, arena.rivet.id, &"claw")
	assert_eq(m.marks.size(), 1)


func test_another_weapon_prints_none() -> void:
	var arena: CombatArena = _arena()
	var m: ClawMarks = ClawMarks.attach(arena)
	arena.damage(_guard(arena, Vector2(1.0, 0.0), 2.0), 1.0, arena.rivet.id, &"katana")
	assert_eq(m.marks.size(), 0)
