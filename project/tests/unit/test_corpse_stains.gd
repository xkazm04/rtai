extends GutTest
## CorpseStains (lane d5-combat): blood on the city's dead, cached per body.


func _feed_with_dead(slot: int, at: Vector2) -> RigFeed:
	var feed: RigFeed = RigFeed.new(4)
	var i: int = feed.put(0, slot, BodyPlan.Kind.PED, at, Vector2.ZERO)
	feed.flags[i] = RigFeed.Flag.DEAD
	feed.count = 1
	return feed


func test_a_kill_soaks_the_nearest_dead_body_and_follows_it() -> void:
	var stains: CorpseStains = CorpseStains.new(4)
	var feed: RigFeed = _feed_with_dead(7, Vector2(100, 100))
	stains.on_bled(Vector2(104, 100), Vector2.RIGHT)
	stains.step(10, feed)
	assert_eq(stains.soaked, 1, "the death found its body")
	assert_eq(stains.active(), 1)
	feed.pos[0] = Vector2(110, 100)
	stains.step(40, feed)
	var soak: Node2D = stains.get_child(0)
	assert_eq(soak.position, Vector2(110, 100), "the stains slide with the body")
	assert_eq(soak.scale, Vector2.ONE, "grown after grow_ticks")
	stains.free()


func test_a_despawned_body_takes_its_stains_and_a_lost_death_is_dropped() -> void:
	var stains: CorpseStains = CorpseStains.new(4)
	var feed: RigFeed = _feed_with_dead(3, Vector2(50, 50))
	stains.on_bled(Vector2(50, 50), Vector2.UP)
	stains.step(1, feed)
	feed.count = 0
	stains.step(2, feed)
	assert_eq(stains.active(), 0, "the body left the feed: no floating stains")
	stains.on_bled(Vector2(900, 900), Vector2.UP)
	for t: int in range(3, 3 + CorpseStains.WAIT_TICKS + 1):
		stains.step(t, feed)
	assert_eq(stains.missed, 1, "a death with no body is dropped after WAIT_TICKS")
	stains.free()


func test_combat_blood_emits_bled_on_a_human_kill_only() -> void:
	var blood: CombatBlood = CombatBlood.new()
	var got: Array[Vector2] = []
	@warning_ignore("return_value_discarded")
	blood.bled.connect(func(at: Vector2, _dir: Vector2) -> void: got.append(at))
	blood.kill_human(Vector2(10, 20), Vector2.LEFT)
	blood.hit_robot(Vector2(30, 30))
	assert_eq(got, [Vector2(10, 20)] as Array[Vector2], "robots never bleed")
	blood.free()


func test_set_ground_recolours_the_splats() -> void:
	var fx: BloodFx = BloodFx.new()
	var mesh: BloodSplatMesh = fx.use_splat_mesh()
	fx.set_ground(Color(0.5, 0.0, 0.0))
	assert_eq(mesh.colour, Color(0.5, 0.0, 0.0))
	fx.free()


func test_any_host_can_hand_its_dead_as_a_map() -> void:
	var stains: CorpseStains = CorpseStains.new(2)
	var dead: Dictionary[int, Vector2] = {42: Vector2(320, 64)}
	stains.on_bled(Vector2(322, 66), Vector2.DOWN)
	stains.step_bodies(5, dead)
	assert_eq(stains.soaked, 1, "quest 1's dead guard (id 42) is soaked")
	assert_eq((stains.get_child(0) as Node2D).position, Vector2(320, 64))
	stains.free()


func test_a_named_victim_soaks_its_own_body_not_the_nearest() -> void:
	var stains: CorpseStains = CorpseStains.new(4)
	var dead: Dictionary[int, Vector2] = {1: Vector2(100, 100), 2: Vector2(110, 100)}
	stains.on_bled_body(2, Vector2.RIGHT)
	stains.step_bodies(3, dead)
	assert_eq(stains.soaked, 1)
	assert_eq((stains.get_child(0) as Node2D).position, Vector2(110, 100), "body 2, not body 1")
	stains.free()


func test_a_soak_fades_while_rivet_stands_on_the_body() -> void:
	var stains: CorpseStains = CorpseStains.new(2)
	var body: Vector2 = Vector2(320, 64)
	var dead: Dictionary[int, Vector2] = {7: body}
	stains.on_bled_body(7, Vector2.RIGHT)
	stains.step_bodies(1, dead)
	var soak: Node2D = stains.get_child(0) as Node2D
	assert_eq(soak.modulate.a, 1.0, "no walker: the soak is whole")
	stains.walkers = PackedVector2Array([body + Vector2(4, 0)])
	stains.step_bodies(2, dead)
	assert_eq(soak.modulate.a, 0.0, "Rivet on the corpse: the soak never draws over him")
	var clear_px: float = CorpseStains.CLEAR_M * SimConst.PX_PER_M + 1.0
	stains.walkers = PackedVector2Array([body + Vector2(clear_px, 0)])
	stains.step_bodies(3, dead)
	assert_eq(soak.modulate.a, 1.0, "Rivet stepped off: whole again")
	stains.free()
