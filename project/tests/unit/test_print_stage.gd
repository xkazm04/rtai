extends GutTest
## The visual engine as one node (core/render/print_stage.gd): a view that drops it in gets every
## pass on a declared render layer, the look by zoom, and the world lock (zoom-anchored with a rig).


func _stage() -> PrintStage:
	var stage: PrintStage = PrintStage.new()
	add_child_autofree(stage)
	return stage


func test_every_pass_sits_on_a_declared_layer() -> void:
	var stage: PrintStage = _stage()
	var props: Node2D = Node2D.new()
	props.z_index = RenderLayers.z(&"props")
	stage.add_child(props)
	var person: Node2D = Node2D.new()
	person.z_index = RenderLayers.z(&"actors")
	person.material = stage.item_material()
	stage.actor_layer().add_child(person)
	stage.place(Vector2(10.0, 20.0))
	assert_eq(RenderLayers.shared().audit(stage), [] as Array[String])
	assert_eq(stage.actor_layer().layer, RenderLayers.canvas(&"actors"))


func test_the_look_follows_the_zoom_and_off_hides_the_print() -> void:
	var stage: PrintStage = _stage()
	stage.zoom = 1.0
	stage.place(Vector2.ZERO)
	assert_true(stage.look_params.printed)
	stage.look_id = LookProfiles.OFF
	stage.place(Vector2.ZERO)
	assert_false(stage.look_params.printed)
	assert_null(stage.item_material().shader)
	stage.look_id = &"d4"
	stage.place(Vector2.ZERO)
	assert_not_null(stage.item_material().shader, "back on: the item print returns")


func test_without_a_rig_world_px_is_the_camera_at_the_zoom() -> void:
	var stage: PrintStage = _stage()
	stage.zoom = 1.5
	stage.place(Vector2(100.0, 50.0))
	var half: Vector2 = stage.get_viewport_rect().size * 0.5
	var want: Vector2 = (Vector2(100.0, 50.0) * SimConst.PX_PER_M * 1.5).round() - half
	assert_eq(stage.world_px, want)


func test_a_rig_zoom_keeps_the_centre_print_still() -> void:
	var stage: PrintStage = _stage()
	stage.rig = CameraRig.new()
	var clock: SimClock = SimClock.new()
	stage.clock = clock
	stage.place(Vector2(500.0, 500.0))
	var before: Vector2 = stage.world_px + stage.get_viewport_rect().size * 0.5
	stage.rig.set_mode(&"car", 0)
	for i: int in 40:
		clock.complete_tick()
		stage.place(Vector2(500.0, 500.0))
	var after: Vector2 = stage.world_px + stage.get_viewport_rect().size * 0.5
	assert_eq(stage.zoom, 1.5)
	assert_almost_eq(after.x, before.x, 1.0, "the centre's print coordinate holds through the ease")


func test_listen_wires_the_boss_zoom_and_the_hit_stop() -> void:
	var stage: PrintStage = _stage()
	var bus: EventBus = autofree(EventBus.new())
	var clock: SimClock = SimClock.new()
	stage.listen(bus, clock, 7, Callable())
	bus.boss_engaged.emit(&"quartermaster-mertz")
	assert_eq(stage.rig.mode, &"arena")
	bus.actor_killed.emit(7, 9, &"shot")
	assert_gt(clock.held(), 0.0, "Rivet's kill holds the clock")
	bus.player_hit.emit(&"robo-tazer")
	assert_eq(stage.fx_triggers.fired[&"player_hit_robo_tazer"], 1)


## n31-12: under a window stretch s the floor moves s x the camera in render px (FRAGCOORD's
## unit); the lock must move the same, else the print slides at 1 - 1/s of the floor's speed.
func test_the_lock_holds_the_print_on_the_floor_under_the_stretch() -> void:
	var was: bool = PrintStage.in_render_px
	PrintStage.in_render_px = true  # headless runs the logical lock (no render target)
	for s: float in [1.0, 1.35, 1.8]:
		var xf: Transform2D = Transform2D(0.0, Vector2(s, s), 0.0, Vector2(0.0, 3.0))
		var zv: Vector2 = Vector2(1.0, 0.9397)
		var half: Vector2 = Vector2(711.1, 400.0)
		var p: Vector2 = Vector2(900.0, 700.0)
		var first: Vector2 = Vector2.INF
		for i: int in 120:
			var raw: Vector2 = Vector2(640.0 + i * 3.37, 512.0 - i * 1.13)
			var cam: Vector2 = PrintStage.snap_cam(raw, zv, xf, 1.0)
			var floor_px: Vector2 = cam * zv * s
			assert_almost_eq(floor_px.x, roundf(floor_px.x), 0.001, "camera on whole render px")
			var frag: Vector2 = (zv * (p - cam) + half) * s + xf.origin
			var locked: Vector2 = frag + PrintStage.lock_px(cam * zv, half, xf)
			if first == Vector2.INF:
				first = locked
			assert_almost_eq(locked.x, first.x, 0.001, "s %.2f: print x holds on the floor" % s)
			assert_almost_eq(locked.y, first.y, 0.001, "s %.2f: print y holds on the floor" % s)
	PrintStage.in_render_px = was


func test_the_old_logical_lock_slides_under_the_stretch() -> void:
	var was: bool = PrintStage.in_render_px
	PrintStage.in_render_px = false
	var xf: Transform2D = Transform2D(0.0, Vector2(1.35, 1.35), 0.0, Vector2.ZERO)
	var half: Vector2 = Vector2(640.0, 400.0)
	var a: Vector2 = PrintStage.lock_px(Vector2(1000.0, 0.0), half, xf)
	var b: Vector2 = PrintStage.lock_px(Vector2(1100.0, 0.0), half, xf)
	PrintStage.in_render_px = was
	assert_eq(b.x - a.x, 100.0, "logical: the print moves 100 px where the floor moves 135")


func test_at_stretch_one_the_lock_is_the_old_logical_lock() -> void:
	var cam_screen: Vector2 = Vector2(1234.0, -56.0)
	var half: Vector2 = Vector2(640.0, 400.0)
	var got: Vector2 = PrintStage.lock_px(cam_screen, half, Transform2D.IDENTITY)
	assert_eq(got, cam_screen.round() - half)
