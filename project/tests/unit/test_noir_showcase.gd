extends GutTest
## Lane noir: the showcase fight is the same every run, and the silhouette flash (impact mode 4)
## hides the world for its ticks only, then restores what it hid.


func _run_fight() -> Array[String]:
	var fight: NoirFightScript = NoirFightScript.new()
	var feed: RigFeed = RigFeed.new(4)
	var log_lines: Array[String] = []
	for t: int in range(1, 700):
		for cue: Array in fight.step(t, feed):
			log_lines.append("%d %s %d" % [t, cue[0], cue[1]])
	return log_lines


func test_fight_kills_both_cops_once() -> void:
	var lines: Array[String] = _run_fight()
	var kills: Array[String] = lines.filter(func(s: String) -> bool: return s.contains("kill"))
	assert_eq(kills.size(), 2)
	assert_true(kills[0].ends_with(str(NoirFightScript.COP_A)))
	assert_true(kills[1].ends_with(str(NoirFightScript.COP_B)))


func test_fight_is_deterministic() -> void:
	assert_eq(_run_fight(), _run_fight())


func test_silhouette_flash_hides_then_restores() -> void:
	var impact: ImpactFrame = ImpactFrame.new()
	add_child_autofree(impact)
	impact.sequence = PackedInt32Array([4, 1])
	impact.panel_ticks = 0
	var world: Node2D = Node2D.new()
	add_child_autofree(world)
	impact.hide_on_flash = [world]
	impact.fire(Vector2(0.5, 0.5))
	assert_false(world.visible, "mode 4 hides the world")
	impact.step_ticks(1)
	assert_true(world.visible, "mode 1 shows it again")
	impact.step_ticks(1)
	assert_false(impact.active())
	assert_true(world.visible)


func test_held_panel_follows_the_sequence() -> void:
	var impact: ImpactFrame = ImpactFrame.new()
	add_child_autofree(impact)
	impact.sequence = PackedInt32Array([4, 4, 1])
	impact.panel_ticks = 8
	impact.fire(Vector2(0.9, 0.1))
	impact.step_ticks(10)
	assert_true(impact.active(), "the panel holds 8 ticks after the 3 flash ticks")
	impact.step_ticks(1)
	assert_false(impact.active())


func test_coat_swings_within_bounds_then_settles() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var rigs: CharacterRigs = CharacterRigs.new()
	add_child_autofree(rigs)
	rigs.setup(World.build_context(bus, data, 7))
	var cop: int = 101
	var i: int = rigs.feed.put(0, cop, BodyPlan.Kind.COP, Vector2.ZERO, Vector2(0.0, 120.0))
	rigs.feed.face[i] = 0.0
	var coats: NoirCoats = NoirCoats.new()
	var ids: PackedInt32Array = PackedInt32Array([cop])
	var peak: float = 0.0
	for t: int in 60:
		rigs.step_ticks(1)
		coats.step(rigs, ids)
		peak = maxf(peak, absf(_coat(rigs, cop).rotation))
	assert_gt(peak, 0.05, "sideways motion swings the coat")
	assert_lte(peak, NoirCoats.MAX_ANGLE)
	rigs.feed.vel[i] = Vector2.ZERO
	for t: int in 400:
		rigs.step_ticks(1)
		coats.step(rigs, ids)
	assert_almost_eq(_coat(rigs, cop).rotation, 0.0, 0.02, "at rest it hangs straight")


func _coat(rigs: CharacterRigs, id: int) -> Sprite2D:
	var torso: Node2D = rigs.rig_for(id).torso
	for c: Node in torso.get_children():
		if c is Sprite2D and (c as Sprite2D).texture != null:
			if (c as Sprite2D).texture.resource_path.ends_with("coat_tail.png"):
				return c as Sprite2D
	return null


func test_scripted_car_stops_short_of_every_fighter() -> void:
	var fight: NoirFightScript = NoirFightScript.new()
	var car: NoirCarPass = NoirCarPass.new()
	var feed: RigFeed = RigFeed.new(4)
	var nearest: float = INF
	for t: int in range(1, 700):
		@warning_ignore("return_value_discarded")
		fight.step(t, feed)
		var c: Vector4 = car.at(t)
		var h: Vector2 = Vector2(c.z, c.w)
		for k: int in 9:
			var body: Vector2 = Vector2(c.x, c.y) - h * (0.55 * k)
			for id: int in fight.pos:
				nearest = minf(nearest, body.distance_to(fight.pos[id]))
	assert_gt(nearest, 2.0, "the car's body keeps 2 m from every fighter (half width ~0.9 m)")
	assert_eq(car.at(500), car.at(96), "parked after braking")
