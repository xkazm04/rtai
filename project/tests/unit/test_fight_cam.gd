extends GutTest
## FightCam (lane gunplay, dev capture): frames Rivet and the hostile he fights.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func test_the_camera_leans_half_way_to_the_foe_and_holds_on_his_body() -> void:
	var arena: CombatArena = _arena()
	var g: Fighter = arena.spawn_guard(arena.rivet.pos + Vector2(6.0, 0.0))
	g.pos = arena.rivet.pos + Vector2(6.0, 0.0)
	var cam: FightCam = FightCam.new()
	var at: Vector2 = Vector2.ZERO
	for t: int in 200:
		at = cam.step(arena, t)
	assert_eq(cam.subject, g)
	assert_almost_eq(at.x - arena.rivet.pos.x, 3.0, 0.05, "half way to a foe 6 m off")
	g.hp = 0.0
	for t: int in range(200, 300):
		at = cam.step(arena, t)
	assert_eq(cam.subject, g, "a fresh corpse stays framed")
	for t: int in range(300, 600):
		at = cam.step(arena, t)
	assert_null(cam.subject, "then the camera lets him go")
	assert_almost_eq(at.x, arena.rivet.pos.x, 0.05, "and comes back to Rivet")


func test_a_far_foe_never_pushes_rivet_out_of_frame() -> void:
	var arena: CombatArena = _arena()
	var g: Fighter = arena.spawn_guard(arena.rivet.pos + Vector2(0.0, 13.0))
	g.pos = arena.rivet.pos + Vector2(0.0, 13.0)
	var cam: FightCam = FightCam.new()
	var at: Vector2 = Vector2.ZERO
	for t: int in 400:
		at = cam.step(arena, t)
	assert_almost_eq(at.distance_to(arena.rivet.pos), FightCam.MAX_LEAN_M, 0.05)
