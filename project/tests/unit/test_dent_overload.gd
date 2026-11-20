extends GutTest


class RingProbe:
	extends DentOverload
	# Keep the road ring's centre, radius and opacity separate from the shock disc and heat wash.
	var rings: Array[Vector4] = []

	func _dashes(c: Vector2, r: float, _weight: float, alpha: float) -> void:
		rings.append(Vector4(c.x, c.y, r, alpha))


class BeltProbe:
	extends DentStrap
	var fill_color: Color

	func paint(_canvas: DentStrapCanvas, fill: Color, _stripe: Color) -> void:
		fill_color = fill


var stage: CollectCallStage
var dent: DentStage


func before_each() -> void:
	stage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	stage.arena = CombatArena.new(CombatTuning.shipped(), bus, RngRegistry.new(3).stream(&"combat"))
	dent = DentStage.shipped()


func test_spokes_recover_pre_shove_contact_for_killed_and_wounded_bodies() -> void:
	var view: DentOverload = DentOverload.new()
	add_child_autofree(view)
	view.bind(stage, dent)
	dent.blast_at = Vector2(6, 2)
	dent.blast_tick = 40
	var radius: float = dent.num(&"blast_radius_m")
	var contact: Vector2 = dent.blast_at + Vector2.RIGHT * radius * 0.5
	var after: Vector2 = contact + Vector2.RIGHT * dent.num(&"car_knock_m") * 0.5
	var guard: Fighter = Fighter.make(Fighter.Kind.GUARD, 11, after, 1.0)
	stage.arena.kill_landed.emit(guard, &"dent_car", Vector2.RIGHT, after, &"shot")
	assert_true(view._contact_m.is_empty())
	stage.arena.kill_landed.emit(guard, &"dent_blast", Vector2.RIGHT, after, &"shot")
	guard.pos = dent.blast_at + Vector2.UP * radius
	stage.arena.wounded.emit(guard, &"dent_blast")
	assert_eq(view._contact_m.size(), 2)
	assert_almost_eq(view._contact_m[0], contact, Vector2.ONE * 0.0001)
	assert_eq(view._landed_m[0], after)
	assert_eq(view._contact_m[1], guard.pos)
	dent.blast_tick = 100
	guard.pos = dent.blast_at + Vector2.LEFT * dent.num(&"car_knock_m")
	stage.arena.wounded.emit(guard, &"dent_blast")
	assert_eq(view._contact_m.size(), 1)
	assert_almost_eq(view._contact_m[0], dent.blast_at, Vector2.ONE * 0.0001)


func test_shock_reaches_preview_at_eight_ticks_and_ring_outlives_disc() -> void:
	assert_almost_eq(DentOverload.shock_extent(0, false), 0.32, 0.001)
	assert_almost_eq(DentOverload.shock_extent(4, false), 0.83, 0.001)
	assert_eq(DentOverload.shock_extent(8, false), 1.0)
	assert_eq(DentOverload.shock_extent(18, false), 1.0)
	assert_eq(DentOverload.shock_extent(0, true), 1.0)
	assert_almost_eq(DentOverload.shock_alpha(0, false), 0.55, 0.001)
	assert_almost_eq(DentOverload.shock_alpha(9, false), 0.275, 0.001)
	assert_eq(DentOverload.shock_alpha(17, true), 0.3)
	assert_eq(DentOverload.shock_alpha(18, true), 0.0)
	assert_eq(DentOverload.shock_alpha(18, false), 0.0)
	assert_eq(DentOverload.ring_alpha(18), 1.0)
	assert_almost_eq(DentOverload.ring_alpha(24), 1.0 / 3.0, 0.001)
	assert_eq(DentOverload.ring_alpha(27), 0.0)


func test_road_ring_tracks_the_seized_car_then_the_blast_until_tick_27() -> void:
	var view: RingProbe = autofree(RingProbe.new())
	view.bind(stage, dent)
	dent.car = VehicleBody.new(1, null, Vector2(6, -2), Vector2.LEFT)
	for ppm: float in [32.0, 64.0]:
		view.sync(ppm, false)
		view.rings.clear()
		view._draw()
		var c: Vector2 = dent.car.pos * ppm
		var radius: float = dent.num(&"blast_radius_m") * ppm
		assert_eq(view.rings, [Vector4(c.x, c.y, radius, 1.0)], "preview at %s px/m" % ppm)
	dent.blast_at = dent.car.pos
	dent.car = null
	dent.blast_tick = 40
	var centre: Vector2 = dent.blast_at * view.ppm
	var r: float = dent.num(&"blast_radius_m") * view.ppm
	for age: int in [-1, 0, 8, 18, 24, 26, 27]:
		stage.tick = dent.blast_tick + age
		view.rings.clear()
		view._draw()
		if age < 0 or age >= 27:
			assert_true(view.rings.is_empty(), "no road ring at %+d" % age)
		else:
			var alpha: float = minf(1.0, (27.0 - age) / 9.0)
			assert_eq(view.rings, [Vector4(centre.x, centre.y, r, alpha)], "ring at +%d" % age)


func test_shock_mesh_first_touches_the_ring_at_tick_eight() -> void:
	var view: DentOverload = autofree(DentOverload.new())
	var canvas: Node2D = autofree(Node2D.new())
	var item: RID = canvas.get_canvas_item()
	var centre: Vector2 = Vector2(96, -128)
	var ring: float = dent.num(&"blast_radius_m") * 32.0
	var previous: float = 0.0
	for age: int in range(9):
		RenderingServer.canvas_item_clear(item)
		view.shock(canvas, centre, ring, age)
		var bounds: Rect2 = RenderingServer.debug_canvas_item_get_rect(item)
		var r: float = bounds.size.x * 0.5
		assert_almost_eq(bounds.get_center(), centre, Vector2.ONE * 0.001)
		assert_almost_eq(bounds.size.y, r * 2.0, 0.001)
		assert_gt(r, previous, "outward shock at +%d" % age)
		if age < 8:
			assert_lt(r, ring, "inside the road ring at +%d" % age)
		else:
			assert_almost_eq(r, ring, 0.001)
		previous = r
	RenderingServer.canvas_item_clear(item)
	view.shock(canvas, centre, ring, 18)
	assert_eq(RenderingServer.debug_canvas_item_get_rect(item), Rect2(), "expired disc")


func test_spokes_reach_each_struck_body_on_the_hit_tick() -> void:
	var view: DentOverload = DentOverload.new()
	add_child_autofree(view)
	view.bind(stage, dent)
	view.sync(32.0, false)
	assert_gt(view._spokes.z_index, RenderLayers.z(&"fx"), "spokes above the wreck")
	dent.blast_tick = 40
	stage.tick = 40
	dent.blast_at = Vector2(6, 2)
	var east: Vector2 = dent.blast_at + Vector2.RIGHT * 3.75
	var north: Vector2 = dent.blast_at + Vector2.UP * 4.0
	var guard: Fighter = Fighter.make(Fighter.Kind.GUARD, 11, east, 1.0)
	stage.arena.kill_landed.emit(guard, &"dent_blast", Vector2.RIGHT, east, &"shot")
	var other: Fighter = Fighter.make(Fighter.Kind.GUARD, 12, north, 1.0)
	stage.arena.wounded.emit(other, &"dent_blast")
	var item: RID = view._spokes.get_canvas_item()
	await wait_process_frames(2)
	var bounds: Rect2 = RenderingServer.debug_canvas_item_get_rect(item)
	# The amber and ink strokes end at the displaced bodies, past the white contact dots.
	assert_almost_eq(bounds.end.x, east.x * view.ppm, 2.0, "killed guard")
	assert_almost_eq(bounds.position.y, north.y * view.ppm, 2.0, "wounded guard")
	for age: int in [-1, 14, 15]:
		stage.tick = dent.blast_tick + age
		view.sync(32.0, false)
		await wait_process_frames(2)
		assert_eq(RenderingServer.debug_canvas_item_get_rect(item).has_area(), age == 14)
	stage.tick = dent.blast_tick
	view.sync(32.0, true)
	await wait_process_frames(2)
	assert_eq(RenderingServer.debug_canvas_item_get_rect(item), Rect2(), "reduced motion")


func test_the_held_belt_warms_to_amber_with_overload_heat() -> void:
	var view: DentView = DentView.new()
	add_child_autofree(view)
	view.set_process(false)
	view.stage = stage
	view.stage.pilot = StagePilot.new(PlayerActions.shipped())
	view.dent = view.stage.pilot.dent
	view.dent.car = VehicleBody.new(1, null, Vector2(4, 2), Vector2.DOWN)
	view.reduced_motion = true  # Hold the pulse still to isolate heat.
	var tether: DentTether = DentTether.new(view)
	var belt: BeltProbe = BeltProbe.new(HaulerLook.TEAL, VehicleView.CAR_H_M)
	tether.strap = belt
	tether.strings = null
	belt.advance(view.dent.car, 40, 0.0, -1)
	var amber: Color = Color("#E9A23B")
	var arm: float = view.dent.num(&"arm_k")
	for heat: float in [0.0, arm * 0.5, 1.0]:
		view.dent.heat = heat
		tether.paint(view)
		var base: Color = HaulerLook.TEAL.lerp(amber, heat)
		var expected: Color = base.lerp(amber, smoothstep(0.0, arm, heat) * 0.55)
		assert_true(belt.fill_color.is_equal_approx(expected), "belt fill at heat %s" % heat)


func test_amber_wash_sweeps_from_the_nose_with_heat() -> void:
	dent.car = VehicleBody.new(1, null, Vector2(-3, 6), Vector2.RIGHT)
	var view: RingProbe = RingProbe.new()
	add_child_autofree(view)
	view.bind(stage, dent)
	var c: Vector2 = dent.car.pos * 32.0
	var r: float = dent.num(&"blast_radius_m") * 32.0
	for heat: float in [0.0, 0.25, 0.5]:
		dent.heat = heat
		view.sync(32.0, false)
		await wait_process_frames(2)
		var wash: Rect2 = RenderingServer.debug_canvas_item_get_rect(view.get_canvas_item())
		if heat == 0.0:
			assert_eq(wash, Rect2())
		else:
			# The moving edge has a stroke and antialias fringe outside the filled sector.
			var start: Vector2 = c if heat == 0.25 else c - Vector2.RIGHT * r
			assert_almost_eq(wash.position, start, Vector2.ONE * 3.0)
			assert_almost_eq(wash.end, c + Vector2.ONE * r, Vector2.ONE * 3.0)
