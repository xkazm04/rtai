extends GutTest
## Read the submitted sprites after the same advance/feed pair used by the form host.

## Width multiplier and opacity at the start, midpoint and end of the 30-tick wind-up.
const WINDUP_INK: Dictionary[int, Vector2] = {
	3: Vector2(1.495, 0.25696), 15: Vector2(1.275, 0.85), 30: Vector2(1.0, 1.0)
}

var _saved: ViewMode
var _rig: TonnageRig
var _body: TonnageSpectral
var _flight: GhostFlight
var _press: HaulerStage


func before_each() -> void:
	_saved = ViewMode._shared
	ViewMode.select("tilt70")
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	var host: Node2D = add_child_autofree(Node2D.new())
	_rig = TonnageRig.new()
	_press = HaulerStage.shipped()
	_press.form.on = true
	_rig.hauler = _press
	GhostFormBodies.mount_rig(host, _rig, &"tonnage")
	_flight = _rig.drawn.flight
	_flight.show()
	_rig.show()
	_flight.step(Vector2(400, 100), 0.0, 1)
	_body = _rig._spectral


func after_each() -> void:
	GhostLook.reset_for_test()
	ViewMode._shared = _saved


func _frame(tick: int) -> void:
	_rig.advance(SimClock.TICK_DT)
	_rig.drawn.feed(0, -1, tick)


func test_the_windup_inks_two_radial_marks_at_the_rotated_landing_points() -> void:
	_rig.rotation = PI / 2.0
	assert_true(_press.form.arm())
	for tick: int in range(1, 31):
		_press.form.step(Vector2.ZERO)
		_frame(tick)
		if WINDUP_INK.has(tick):
			var stroke: Vector2 = WINDUP_INK[tick]
			for i: int in 2:
				var mark: Sprite2D = _body._shadows[i]
				assert_same(mark.get_parent(), _body)
				assert_false(mark.z_as_relative)
				assert_eq(mark.z_index, RenderLayers.z(&"actors") - 1)
				var pos: Vector2 = Vector2(422.4 if i == 0 else 377.6, 138.4)
				assert_almost_eq(mark.global_position, pos, Vector2.ONE * 0.001)
				assert_almost_eq(mark.global_rotation, PI / 2.0, 0.001)
				var size_px: Vector2 = Vector2(46.4, 27.2) * stroke.x
				assert_almost_eq(mark.global_scale * 64.0, size_px, Vector2.ONE * 0.001)
				assert_almost_eq(mark.self_modulate.a, stroke.y, 0.001)
	assert_eq(_body._cell.frame_coords.x, TonnagePose.Act.RAISE)
	var disc: GradientTexture2D = _body._shadows[0].texture as GradientTexture2D
	assert_eq(disc.fill, GradientTexture2D.FILL_RADIAL)
	assert_almost_eq(disc.gradient.get_offset(1), 0.55, 0.001)
	assert_eq(disc.gradient.get_color(1), Color(GhostShadow.INK, 0.8))


func test_strike_and_lift_keep_the_marks_at_the_contact_after_a_turn() -> void:
	_press.stomp_at = Vector2(4, -2)
	_press.stomp_tick = 123
	_rig.rotation = PI / 2.0
	_frame(123)
	_rig.rotation = 0.0
	_frame(124)
	var left: Sprite2D = _body._shadows[0]
	var right: Sprite2D = _body._shadows[1]
	assert_almost_eq(left.global_position, Vector2(150.4, -54.4), Vector2.ONE * 0.001)
	assert_almost_eq(right.global_position, Vector2(105.6, -54.4), Vector2.ONE * 0.001)
	assert_almost_eq(right.global_scale, Vector2(0.725, 0.425), Vector2.ONE * 0.001)
	assert_almost_eq(right.self_modulate.a, 0.88, 0.001)
	assert_almost_eq(_body._cell.modulate.a, 0.55, 0.001)
	_frame(133)
	assert_eq(_body._cell.frame_coords.x, TonnagePose.Act.LIFT)
	assert_almost_eq(right.global_position, Vector2(105.6, -54.4), Vector2.ONE * 0.001)
	var raised: float = 0.21 + 0.59 * smoothstep(0, 9, 5)
	assert_almost_eq(right.self_modulate.a, (0.88 - 0.2 * raised) * 0.5, 0.001)
	assert_almost_eq(right.global_scale.x, 0.725 * (1.0 + 0.55 * raised / 2.6), 0.001)
	_frame(148)
	assert_almost_eq(right.global_position, Vector2(268.8, 35.56709), Vector2.ONE * 0.001)


func test_roll_stretch_and_lift_follow_the_play_pitch_and_load_the_matching_sheets() -> void:
	var vm: ViewMode = ViewMode.shared()
	vm.art = ""
	vm.set_pitch(62.5)
	_flight.step(Vector2(400, 100), PI / 4.0, 1)
	_press.stomp_at = Vector2(4, -2)
	_press.stomp_tick = 123
	_frame(123)
	var cell: Sprite2D = _body._cell
	assert_eq(cell.texture.resource_path, GhostDrawn.path_of("p70", "tonnage", "spectral_act"))
	assert_almost_eq(cell.global_rotation, 0.07047, 0.001)
	assert_almost_eq(cell.global_scale, Vector2(0.48986, 0.55246), Vector2.ONE * 0.001)
	assert_almost_eq(cell.global_position, Vector2(411.61066, 86.98779), Vector2.ONE * 0.001)
	var socket: Vector2 = cell.to_local(_body._vapour.global_position)
	assert_almost_eq(socket, Vector2(-28 * cos(_body.global_rotation), -82), Vector2.ONE * 0.001)
	vm.set_pitch(62.49)
	_frame(124)
	assert_eq(cell.texture.resource_path, GhostDrawn.path_of("p55", "tonnage", "spectral_act"))


func test_overhead_fists_keep_their_carry_width_then_fit_the_landing_contact() -> void:
	ViewMode.select("top")
	_flight.step(Vector2(400, 100), 0.0, 1)
	_frame(100)
	var fist: Sprite2D = _body._parts._fists[1]
	var across: float = fist.texture.get_width()
	var carry_px: float = 0.95 * 32.0 * (1.0 + 0.06 * _body.pose.right.z)
	assert_almost_eq(fist.scale.x * across, carry_px, 0.001)
	_press.stomp_at = Vector2(4, -2)
	_press.stomp_tick = 123
	_frame(123)
	assert_almost_eq(absf(fist.global_scale.x) * across, 30.4, 0.001)
	assert_almost_eq(fist.global_position, Vector2(137.6, -41.6), Vector2.ONE * 0.001)
