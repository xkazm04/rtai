extends GutTest
## BloodStains (lane noir): blood on the bodies, following them.


func test_a_kill_stains_the_victim_and_a_hit_spots_the_player() -> void:
	var fx: NoirCombatFx = NoirCombatFx.new()
	var bus: EventBus = EventBus.new()
	var blood: BloodFx = BloodFx.new()
	var stains: BloodStains = BloodStains.new()
	var pos: Dictionary[int, Vector2] = {1: Vector2(10, 10), 2: Vector2(12, 10)}
	fx.player_id = 1
	fx.locate = func(id: int) -> Vector2: return pos.get(id, Vector2.INF)
	fx.bind(bus, blood, null)
	fx.set_stains(stains)
	bus.actor_killed.emit(1, 2, &"melee")
	bus.player_hit.emit(&"pistol")
	assert_eq(stains.count(2), 5, "a kill soaks the victim with 5 stains (stain.kill.spots)")
	assert_eq(stains.count(1), 2, "a hit leaves 2 spots on the player")
	var at: Vector2 = stains.locate.call(2)
	assert_eq(at, Vector2(12, 10) * fx.px_per_m, "stains follow the body in px")
	for n: Node in [fx, blood, stains]:
		n.free()


func test_stains_are_pooled() -> void:
	var stains: BloodStains = BloodStains.new()
	for i: int in 40:
		stains.mark(i, Vector2.RIGHT, "kill")
	var total: int = 0
	for i: int in 40:
		total += stains.count(i)
	assert_eq(total, 48, "the stain pool (stain.max_stains) evicts the oldest")
	assert_eq(stains.count(39), 5)
	stains.free()


func test_a_spray_into_a_wall_splats_on_the_wall() -> void:
	var blood: BloodFx = BloodFx.new()
	blood.solid = func(px: Vector2) -> bool: return px.x > 40.0
	blood.splash(Vector2.ZERO, Vector2.RIGHT, "kill")
	blood.step_ticks(60)
	assert_gt(blood.wall_hits, 10, "a kill sprayed at a wall 1.25 m away hits it")
	var at: Vector2 = BloodMarks.contact(blood.solid, Vector2(38, 0), Vector2(8, 0))
	assert_true(at.x <= 40.0, "the splat sits on the free side of the wall")
	var n: Vector2 = BloodMarks.wall_normal(blood.solid, Vector2(38, 0), Vector2(8, 3))
	assert_eq(n, Vector2.LEFT, "the wall faces back at the spray")
	blood.free()
