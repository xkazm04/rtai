extends GutTest
## n7-melee: the plasma sword's deflect reads: CombatArena.deflected (view only) leaves a mark
## (DeflectMarks, melee_marks.json) and a parry beat on FeelCam (MeleeFeel, row plasma_deflect);
## flash_ticks 0 (and --feel=off) leaves none.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func test_the_shipped_table_loads() -> void:
	var m: DeflectMarks = DeflectMarks.attach(_arena())
	assert_gt(m.flash_ticks, 0)
	assert_gt(m.burst_m, 0.0)
	assert_gt(m.streak_m, 0.0)


func test_a_bat_leaves_a_mark_along_the_return() -> void:
	var arena: CombatArena = _arena()
	var m: DeflectMarks = DeflectMarks.attach(arena)
	arena.tick = 40
	arena.deflected.emit(Vector2(1.0, 0.0), Vector2.LEFT)
	assert_eq(m.marks.size(), 1)
	assert_eq(int(m.marks[0].w), 40)
	assert_almost_eq(Vector2.from_angle(m.marks[0].z).x, -1.0, 0.001)


func test_planted_flash_zero_leaves_no_mark() -> void:
	var arena: CombatArena = _arena()
	var m: DeflectMarks = DeflectMarks.attach(arena)
	m.flash_ticks = 0
	arena.deflected.emit(Vector2(1.0, 0.0), Vector2.LEFT)
	assert_eq(m.marks.size(), 0)


func test_the_bat_kicks_the_camera_toward_the_shooter() -> void:
	var arena: CombatArena = _arena()
	var feel: MeleeFeel = MeleeFeel.attach(FeelCam.attach(arena, null), arena)
	arena.deflected.emit(Vector2(1.0, 0.0), Vector2.LEFT)
	assert_eq(feel.hits, 1)
	assert_eq(feel.cam.kicks, 1)
	assert_lt(feel.cam.offset_px(arena.tick, 1.0).x, 0.0, "along the return")


func test_a_real_deflect_emits() -> void:
	var arena: CombatArena = _arena()
	var m: DeflectMarks = DeflectMarks.attach(arena)
	var s: Shot = Shot.new()
	s.pos = arena.rivet.pos + Vector2(1.0, 0.0)
	s.vel = Vector2(-20.0, 0.0)
	s.from_rivet = false
	s.shooter_id = 99
	arena.shots.append(s)
	assert_eq(PlayerDeflect.bat(arena, Vector2.RIGHT, 1.6), 1)
	assert_eq(m.marks.size(), 1, "PlayerDeflect.bat -> deflected -> a mark")
