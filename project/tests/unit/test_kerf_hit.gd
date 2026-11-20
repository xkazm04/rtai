extends GutTest

var _previous_view: StringName
var _stage: CollectCallStage
var _rig: KerfRig


func before_each() -> void:
	_previous_view = ViewMode.shared().id
	GhostLook.override_for_test(&"spectral")
	_stage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_stage.setup(World.build_context(bus, data, 1))
	_stage.pilot = StagePilot.new(PlayerActions.shipped())
	_rig = KerfRig.new()
	_rig.stage = _stage
	_rig.position = Vector2(133, 27)
	add_child_autofree(_rig)


func after_each() -> void:
	ViewMode.select(_previous_view)
	GhostLook.reset_for_test()


func test_blow_tips_body_and_beams_together_in_screen_space_and_closes_the_lens() -> void:
	var body: KerfSpectral = _rig._spectral
	_stage.arena.tick = 40
	_stage.arena.hit_dir = Vector2.RIGHT
	_stage.arena.damage(_stage.arena.rivet, 0.5, 1, &"rifle")
	for view: String in ["top", "tilt70", "tilt"]:
		ViewMode.select(view)
		var flat: bool = ViewMode.shared().is_flat()
		var sprite: Node2D = body._top if flat else body._tilted
		var projection: Vector2 = Vector2(1.0, ViewMode.shared().ground_k())
		for age: int in [-1, 0, 3, 5, 6, 8, 10, 15]:
			_stage.arena.tick = 40 + age
			_rig.pose()
			_rig.pose()  # Hitstop can render the same tick twice.
			var k: float = 1.0 - age / 10.0
			var angle: float = deg_to_rad(12.0) * k * k if age >= 0 and age < 10 else 0.0
			for part: Node2D in [sprite, body.beams]:
				assert_almost_eq((part.global_transform.x * projection).angle(), angle, 0.0001)
			assert_almost_eq(sprite.global_position, _rig.global_position, Vector2.ONE * 0.001)
			var closed: bool = age >= 0 and age < 6
			if flat:
				var eye: String = "lens_slit.png" if closed else "lens_open.png"
				assert_eq(body._lens.texture.resource_path.get_file(), eye)
			else:
				assert_eq(body._tilted_eye.visible, closed)
				if closed:
					assert_eq(body._tilted_eye.texture.resource_path.get_file(), "lens_slit.png")


func test_beams_and_body_follow_unfold_in_both_directions() -> void:
	var body: KerfSpectral = _rig._spectral
	for k: float in [0.0, 0.25, 1.0, 0.5, 0.0]:
		_rig.unfold = k
		_rig.pose()
		assert_almost_eq(body.modulate.a, k, 0.0001)
		for i: int in KerfBeams.COUNT:
			assert_almost_eq(body.beams.length_m(i), k * 0.9, 0.0001)
