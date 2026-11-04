extends GutTest
## combat-notes (owner note 2026-11-04, "animation of melee weapons"): Rivet's melee kills land
## through CombatArena.damage (kill_landed, no struck), so ReactLink played no death for them and
## a claw victim lay where he stood, under Rivet. Now a melee kill queues the melee death on the
## kill tick, along Rivet -> victim; --soft-swing (melee_deaths off) is the night's: nothing.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _guard(arena: CombatArena, at: Vector2) -> Fighter:
	var f: Fighter = Fighter.make(Fighter.Kind.GUARD, 7, at, 1.0)
	arena.hostiles.append(f)
	return f


func after_each() -> void:
	ReactLink.melee_deaths = true


func test_a_claw_kill_queues_the_melee_death_along_the_blow() -> void:
	var arena: CombatArena = _arena()
	arena.rivet.pos = Vector2.ZERO
	var link: ReactLink = ReactLink.make(arena)
	var f: Fighter = _guard(arena, Vector2(0.0, 1.2))
	arena.damage(f, 9.0, arena.rivet.id, &"claw")
	assert_false(f.alive())
	assert_eq(link._pending.size(), 1, "the kill is queued on the kill tick")
	var h: Array = link._pending[0]
	var id: int = h[0]
	var lethal: bool = h[2]
	var hit_class: StringName = h[3]
	assert_eq(id, 7)
	assert_true(lethal, "lethal")
	assert_eq(hit_class, &"melee")
	var dir: Vector2 = h[1]
	assert_almost_eq(dir.y, 1.0, 0.001, "thrown away from Rivet, not toward him")


func test_the_melee_death_folds_and_carries_the_body() -> void:
	var link: ReactLink = ReactLink.make(_arena())
	var rig: CutRig = CutRig.new()
	rig.variant = RigVariant.crowd(5)
	var kind: StringName = link.pipe.kill(rig, &"melee", Vector2.LEFT, &"claw")
	assert_eq(kind, &"death_melee")
	assert_gt(link.pipe.table.travel(&"death_melee"), 0.8, "thrown clear of Rivet (was 0.5)")
	rig.free()


func test_a_gun_kill_still_waits_for_its_struck() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	arena.damage(_guard(arena, Vector2(3.0, 0.0)), 9.0, arena.rivet.id, &"pistol")
	assert_eq(link._pending.size(), 0, "a round's death comes with its struck")


func test_planted_night_path_plays_no_melee_death() -> void:
	ReactLink.melee_deaths = false
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	arena.damage(_guard(arena, Vector2(0.0, 1.2)), 9.0, arena.rivet.id, &"claw")
	assert_eq(link._pending.size(), 0, "the night's: the claw victim gets no death")
