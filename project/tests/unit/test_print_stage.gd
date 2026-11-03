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
