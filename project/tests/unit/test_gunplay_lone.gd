extends GutTest
## GunplayHook.lone: the lone-victim capture makes every pit wave exactly one guard.


func test_lone_makes_every_wave_one_guard() -> void:
	var pit: ArenaPit = ArenaPit.new()
	GunplayHook.lone(pit)
	for wave: int in [1, 2, 5]:
		assert_eq(mini(pit.first_wave + pit.grow * (wave - 1), pit.max_wave), 1)


func test_the_default_pit_is_not_lone() -> void:
	var pit: ArenaPit = ArenaPit.new()
	assert_gt(pit.max_wave, 1, "only --lone thins the waves")


func test_the_lone_camera_leans_toward_the_victim_and_keeps_rivet_in_frame() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	var g: Fighter = arena.spawn_guard(arena.rivet.pos + Vector2(8.0, 0.0))
	g.pos = arena.rivet.pos + Vector2(8.0, 0.0)
	var cam: FightCam = FightCam.new()
	cam.lean = FightCam.LONE_LEAN
	cam.max_lean_m = FightCam.LONE_MAX_LEAN_M
	var at: Vector2 = Vector2.ZERO
	for t: int in 300:
		at = cam.step(arena, t)
	assert_almost_eq(at.x - arena.rivet.pos.x, 8.0 * FightCam.LONE_LEAN, 0.05, "nearer the victim")
	g.pos = arena.rivet.pos + Vector2(0.0, 13.0)  # a burning run carries him far off
	for t: int in range(300, 700):
		at = cam.step(arena, t)
	assert_almost_eq(at.distance_to(arena.rivet.pos), FightCam.LONE_MAX_LEAN_M, 0.05)
