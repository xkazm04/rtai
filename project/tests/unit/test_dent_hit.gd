extends GutTest

var _previous: String
var _view: GhostFormView
var _body: DentBody


func before_each() -> void:
	_previous = ViewMode.shared().id
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	var stage: CollectCallStage = CollectCallPlay.begin().stage
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	_view = GhostFormView.make(stage, null, null)
	add_child_autofree(_view)
	_view.set_process(false)
	_body = _view._bodies.dent
	_body.drawn.flight.show()
	_body.drawn.flight.step(Vector2(330, 140), 0.0, 1)


func after_each() -> void:
	ViewMode.select(_previous)
	GhostLook.reset_for_test()


func test_hit_draws_the_spectral_cell_in_every_facing_with_either_hand_state() -> void:
	var rows: Array[int] = [2, 1, 0, 1, 2, 3, 4, 3]
	_view.arena.rivet.take(1.0, 100, Vector2.LEFT)
	for view: String in ["tilt70", "tilt"]:
		ViewMode.select(view)
		for held: bool in [false, true]:
			for oct: int in 8:
				var facing: float = oct * TAU / 8.0
				_hold(held, facing)
				for tick: int in [100, 109]:
					_body.step(true, Vector2.ZERO, facing, 1, tick)
					var spr: Sprite2D = _body._spectral.sprite
					assert_true(spr.is_visible_in_tree())
					assert_eq(
						spr.texture.resource_path,
						GhostDrawn.path_of(ViewMode.shared().art, "dent", "sp_fly")
					)
					assert_eq(spr.frame_coords, Vector2i(3, rows[oct]))
					assert_eq(spr.flip_h, oct in [3, 4, 5])
					assert_eq(_body._spectral._rim.frame, spr.frame)
					assert_false(_body._top.visible)
				_body.step(true, Vector2.ZERO, facing, 1, 110)
				assert_eq(_body._spectral.sprite.frame_coords.x, 2 if held else 0)


func test_hit_leans_away_from_the_blow_about_the_belt_and_pulses_only_the_tail() -> void:
	for view: String in ["tilt70", "tilt", "top"]:
		ViewMode.select(view)
		for held: bool in [false, true]:
			_hold(held, 0.0)
			for direction: Vector2 in [Vector2.LEFT, Vector2.RIGHT]:
				_check_blow(direction)


func _check_blow(direction: Vector2) -> void:
	_view.arena.rivet.take(1.0, 100, direction)
	var flight: GhostFlight = _body.drawn.flight
	var projection: Vector2 = Vector2(1.0, ViewMode.shared().ground_k())
	_body.step(true, Vector2.ZERO, 0.0, 1, 99)
	var belt: Vector2 = _body.global_position
	var root: Vector2 = flight.tail.points()[0]
	for age: int in range(-1, 21):
		_body.step(true, Vector2.ZERO, 0.0, 1, 100 + age)
		_body.step(true, Vector2.ZERO, 0.0, 0, 100 + age)
		var k: float = (1.0 - age / 10.0) if age >= 0 and age < 10 else 0.0
		var angle: float = (deg_to_rad(12.0) * direction.x) * k * k
		var shown: Node2D = _body._top if ViewMode.shared().is_flat() else _body._spectral.sprite
		assert_true(shown.is_visible_in_tree())
		assert_almost_eq((shown.global_transform.x * projection).angle(), angle, 0.0001)
		assert_almost_eq(_body.global_position, belt, Vector2.ONE * 0.001)
		assert_almost_eq(flight.tail.points()[0], root, Vector2.ONE * 0.001)
		var alpha: float = 0.45 if age in [0, 1, 4, 5] else 1.0
		assert_eq(flight.tail.modulate, Color(1.0, 1.0, 1.0, alpha))
		if shown == _body._top and k > 0.0:
			assert_eq(_body._top._hands[1], Vector2(0.64, 0.73))


func test_reduced_motion_keeps_the_tail_steady() -> void:
	_body.reduced_motion = true
	_view.arena.rivet.take(1.0, 100, Vector2.RIGHT)
	_body.step(true, Vector2.ZERO, 0.0, 1, 100)
	assert_eq(_body.drawn.flight.tail.modulate, Color.WHITE)


func test_tether_follows_the_open_palms_on_both_profile_hit_cards() -> void:
	_view.arena.rivet.take(1.0, 100, Vector2.RIGHT)
	for view: String in ["tilt70", "tilt"]:
		ViewMode.select(view)
		var left: Vector2 = Vector2(193, 63) if view == "tilt70" else Vector2(163, 56)
		var right: Vector2 = Vector2(196, 116) if view == "tilt70" else Vector2(195, 96)
		for facing: float in [0.0, PI]:
			_hold(true, facing)
			_body.step(true, Vector2.ZERO, facing, 1, 100)
			var spr: Sprite2D = _body._spectral.sprite
			var palms: Array[Vector2] = [left, right]
			if facing == PI:
				palms.reverse()
			for i: int in 2:
				var expected: Vector2 = palms[i]
				if facing == PI:
					expected.x = spr.get_rect().size.x - expected.x
				var world: Vector2 = spr.to_global(spr.offset + expected)
				assert_almost_eq(_body.string_grip(i), world, Vector2.ONE * 0.001)
				if i == 1:
					assert_almost_eq(_body.grip_world(), world, Vector2.ONE * 0.001)


func _hold(held: bool, facing: float) -> void:
	var at: Vector2 = _view.arena.rivet.pos + Vector2.from_angle(facing) * 5.0
	_view.pilot.dent.car = VehicleBody.new(7, null, at, Vector2.RIGHT) if held else null
