extends GutTest

const SERGEANT: StringName = &"sergeant_mulroney"


func test_tell_shot_and_both_halves_of_the_pump() -> void:
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(22).stream(&"combat")
	)
	arena.guard_map = GuardRouteMap.new(Rect2(-20, -20, 40, 40), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2.ONE, SERGEANT)
	var mind: SquadMind = arena.squad_ai.mind_for(h)
	arena.tick = 23
	assert_eq(FoeCastView.attack_row(h, arena), -1)
	for left: int in [30, 1]:
		h.tell_left = left
		assert_eq(FoeCastView.attack_row(h, arena), 0)
	h.tell_left = 0
	mind.agent.shot_tick = arena.tick
	assert_eq(FoeCastView.attack_row(h, arena), 1)
	arena.tick += 1
	for progress: float in [0.0, 0.01, 0.49999]:
		FoeCastView.set_pump(h, progress)
		assert_eq(FoeCastView.attack_row(h, arena), 2)
	for progress: float in [0.5, 0.99, 1.0]:
		FoeCastView.set_pump(h, progress)
		assert_eq(FoeCastView.attack_row(h, arena), 3)
	FoeCastView.set_pump(h, -0.001)
	assert_eq(FoeCastView.attack_row(h, arena), -1)
	h.tell_left = 1
	assert_eq(FoeCastView.attack_row(h, arena), 0)


func test_pump_sample_belongs_to_one_fighter() -> void:
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(1).stream(&"combat")
	)
	var a: Fighter = arena.spawn_guard(Vector2.ZERO)
	var b: Fighter = arena.spawn_guard(Vector2.ONE)
	a.archetype = SERGEANT
	b.archetype = SERGEANT
	FoeCastView.set_pump(a, 0.8)
	assert_eq(FoeCastView.attack_row(a, arena), 3)
	assert_eq(FoeCastView.attack_row(b, arena), -1)
	FoeCastView.set_pump(a, -1.0)
	FoeCastView.set_pump(a, -1.0)
	assert_eq(FoeCastView.attack_row(a, arena), -1)
