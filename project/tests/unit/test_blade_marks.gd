extends GutTest
## n31-melee 04b: the katana and the plasma sword print their own mark (melee_marks.json rows with a
## style, read by ClawMarks), on the victim as it moves; a repeat hit refreshes one mark; a seared
## cut sheds no blood.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _guard(arena: CombatArena, at: Vector2, hp: float) -> Fighter:
	var f: Fighter = Fighter.make(Fighter.Kind.GUARD, 7, at, hp)
	arena.hostiles.append(f)
	return f


func test_the_shipped_blade_rows_are_read() -> void:
	var m: ClawMarks = ClawMarks.attach(_arena())
	assert_eq(m.blades[&"katana"].style, &"cut")
	assert_eq(m.blades[&"plasma_sword"].style, &"sear")
	assert_gt(m.ticks_of(&"plasma_sword"), m.ticks_of(&"katana"), "the sear outlasts the cut")
	assert_gt(m.blades[&"katana"].blood_m, 0.0, "a red bead line on a human")
	assert_eq(m.blades[&"plasma_sword"].blood_m, 0.0, "the plasma cauterises")
	assert_gt(m.blades[&"plasma_sword"].core_px, m.blades[&"katana"].core_px)


func test_a_katana_hit_prints_one_mark_on_the_hit_tick() -> void:
	var arena: CombatArena = _arena()
	var m: ClawMarks = ClawMarks.attach(arena)
	arena.tick = 12
	arena.damage(_guard(arena, Vector2(0.0, 1.0), 2.0), 1.0, arena.rivet.id, &"katana")
	assert_eq(m.marks.size(), 1)
	assert_almost_eq(m.marks[0].z, PI * 0.5, 0.001, "Rivet -> victim")
	assert_eq(int(m.marks[0].w), 12)


func test_a_repeat_hit_on_one_victim_refreshes_its_mark() -> void:
	var arena: CombatArena = _arena()
	var m: ClawMarks = ClawMarks.attach(arena)
	var g: Fighter = _guard(arena, Vector2(1.0, 0.0), 5.0)
	arena.damage(g, 1.0, arena.rivet.id, &"plasma_sword")
	arena.tick = 5
	arena.damage(g, 1.0, arena.rivet.id, &"plasma_sword")
	assert_eq(m.marks.size(), 1)
	assert_eq(int(m.marks[0].w), 5)


func test_a_chainsaw_bite_holds_a_kerf_through_the_grind() -> void:
	var arena: CombatArena = _arena()
	var m: ClawMarks = ClawMarks.attach(arena)
	assert_eq(m.blades[&"chainsaw"].style, &"bite")
	assert_gt(m.ticks_of(&"chainsaw"), 16, "outlasts grind_min_ticks")
	arena.wounded.emit(_guard(arena, Vector2(1.0, 0.0), 5.0), &"chainsaw")
	assert_eq(m.marks.size(), 1, "the GRIND contact's wound prints the bite")
