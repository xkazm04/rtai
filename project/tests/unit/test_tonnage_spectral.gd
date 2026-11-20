extends GutTest
## Exercise the custom drawer through both sheet pitches and a mounted flight body.

var _saved: ViewMode


func before_each() -> void:
	_saved = ViewMode._shared
	GhostLook.override_for_test(GhostLook.SPECTRAL)


func after_each() -> void:
	GhostLook.reset_for_test()
	ViewMode._shared = _saved


func _mount(view: String) -> TonnageRig:
	ViewMode._shared = ViewMode.of(view)
	var rig: TonnageRig = TonnageRig.new()
	var flight: GhostFlight = GhostFlight.make(&"tonnage")
	rig.drawn.flight = flight
	rig.drawn.hover = true
	flight.mount(rig)
	add_child_autofree(flight)
	flight.step(Vector2(400, 100), 0.0, 1)
	rig.advance(SimClock.TICK_DT)
	return rig


func test_column_starts_inside_the_painted_belly_at_both_tilts() -> void:
	for view: String in ["tilt", "tilt70"]:
		var rig: TonnageRig = _mount(view)
		var ink: Sprite2D = rig._spectral._cell
		var flight: GhostFlight = rig.drawn.flight
		var waist: Vector2 = ink.to_local(flight.tail.points()[0])
		assert_almost_eq(waist, Vector2(-44, -91), Vector2.ONE * 0.01, view)
		ViewMode._shared = ViewMode.of("top")
		flight.step(Vector2(400, 100), 0.0, 1)
		rig.advance(SimClock.TICK_DT)
		var row: GhostHoverRow = GhostHoverRow.of(&"tonnage")
		var root_px: Vector2 = flight.shadow.global_position + flight.hover.lag_px
		root_px += row.tail.anchor_m * SimConst.PX_PER_M * flight.body_scale()
		assert_almost_eq(flight.tail.points()[0], root_px, Vector2.ONE * 0.01, "overhead socket")


func test_eight_headings_use_their_painted_row_on_each_pose_and_act_sheet() -> void:
	for view: String in ["tilt", "tilt70"]:
		var rig: TonnageRig = _mount(view)
		var body: TonnageSpectral = rig._spectral
		for oct: int in 8:
			rig.rotation = oct * PI / 4.0
			for acting: bool in [false, true]:
				body.pose.act = acting
				var sheet: String = "spectral_act" if acting else "spectral_pose"
				var path: String = GhostDrawn.path_of(ViewMode.shared().art, "tonnage", sheet)
				for col: int in 3 if acting else 4:
					body.pose.column = col
					body._present()
					var ink: Sprite2D = body._cell
					assert_eq(ink.texture.resource_path, path)
					assert_eq(ink.frame_coords, Vector2i(col, RigHeadCard.OCT_FRAME[oct]))
					assert_eq(ink.flip_h, RigHeadCard.OCT_FLIP[oct] == 1)
					assert_eq(ink.offset, Vector2(-192.0, -315.0))


func test_morph_body_and_fists_retrace_the_same_path() -> void:
	for view: String in ["top", "tilt70"]:
		var rig: TonnageRig = _mount(view)
		var body: TonnageSpectral = rig._spectral
		assert_eq(body.scale, Vector2.ONE)
		if view == "top":
			assert_eq(body._parts._fists[0].position, Vector2(1.0, -0.8) * SimConst.PX_PER_M)
		var forward: Array[Transform2D] = []
		for k: float in [0.0, 0.5, 0.8, 1.0, 0.8, 0.5, 0.0]:
			rig.unfold = k
			rig.advance(0.0)
			var hand: Vector2 = body._parts._fists[1].position
			if k == 0.0:
				assert_eq(body.modulate.a, 0.0)
				assert_almost_eq(body.scale.x, 1.0 / 3.0, 0.00001)
			if k == 0.5:
				assert_almost_eq(body.modulate.a, smoothstep(0.0, 0.78, k), 0.00001)
				assert_almost_eq(body.scale.x, 2.0 / 3.0, 0.00001)
				if view == "top":
					assert_almost_eq(
						hand, Vector2(-0.05, 0.48) * SimConst.PX_PER_M, Vector2.ONE * 0.001
					)
			if k == 1.0:
				assert_eq(body.scale, Vector2.ONE)
				assert_eq(body.modulate.a, 1.0)
				assert_null(body._cell.material)
				assert_eq(body._cell.frame_coords.x, TonnagePose.Pose.CARRY)
				if view == "top":
					assert_eq(hand, Vector2(1.0, 0.8) * SimConst.PX_PER_M)
			var ink: Node2D = body._parts._fists[1] if view == "top" else body._cell
			forward.append(ink.global_transform)
		for i: int in 3:
			assert_true(forward[i].is_equal_approx(forward[6 - i]), view)


func test_tilted_reveal_tracks_the_tucked_and_unfolding_press_fists() -> void:
	var rig: TonnageRig = _mount("tilt70")
	var body: TonnageSpectral = rig._spectral
	for k: float in [0.5, 2.0 / 3.0, 0.81, 0.95]:
		rig.unfold = k
		rig.advance(0.0)
		var mat: ShaderMaterial = body._cell.material as ShaderMaterial
		assert_not_null(mat)
		var reach: float = mat.get_shader_parameter(&"reach")
		assert_almost_eq(float(mat.get_shader_parameter(&"emerge")), k, 0.00001)
		assert_almost_eq(reach, smoothstep(2.0 / 3.0, 0.95, k), 0.00001)
		assert_eq(body._cell_light.self_modulate.a, 0.0)
	rig.unfold = 0.975
	rig.advance(0.0)
	assert_almost_eq(body._cell_light.self_modulate.a, TonnageGlow.GLOW_FILL_ALPHA * 0.5, 0.00001)
	rig.unfold = 1.0
	rig.advance(0.0)
	assert_almost_eq(body._cell_light.self_modulate.a, TonnageGlow.GLOW_FILL_ALPHA, 0.00001)


func test_incoming_hit_rolls_the_custom_cell_once_and_the_armed_fist_holds() -> void:
	var rig: TonnageRig = _mount("tilt70")
	var body: TonnageSpectral = rig._spectral
	rig.drawn.blow = Vector2.LEFT
	body._sample.hurt_age = 0
	body.pose.step(body._sample, 1)
	body._present()
	body._hit_lean(0.0, 0.0)
	assert_almost_eq(body._cell.global_rotation, -deg_to_rad(4.0), 0.0001)
	body._sample.ramming = true
	body.pose.step(body._sample, 1)
	body._present()
	body._hit_lean(0.0, 0.0)
	assert_almost_eq(body._cell.global_rotation, 0.0, 0.0001)
