extends GutTest


func test_mounted_dent_builds_only_the_belt_up_rig() -> void:
	var flight: GhostFlight = GhostFlight.make(&"dent")
	add_child_autofree(flight)
	var body: DentBody = DentBody.new()
	body.drawn.flight = flight
	flight.mount(body)
	body.setup(null)
	assert_null(body._rig)
	var names: Array[StringName] = []
	for part: Node in body._top.get_children():
		names.append(part.name)
	assert_eq(
		names,
		[
			&"tail_root",
			&"left_upperarm",
			&"left_forearm",
			&"right_upperarm",
			&"right_forearm",
			&"torso",
			&"head"
		]
	)


func test_lean_sweeps_both_hands_behind_the_shoulders() -> void:
	var top: DentSpectralTop = DentSpectralTop.new()
	add_child_autofree(top)
	var h: GhostHover = GhostHover.new(GhostHoverRow.of(&"dent"))
	h.reset(Vector2.ZERO, 0.0)
	top.pose(h, DentSpectralDrawn.Pose.HOVER, -1, Vector2.ZERO, 1)
	var rest_x: float = top._head.position.x
	for upper: Sprite2D in top._upper:
		assert_almost_eq(absf(upper.scale.y), upper.scale.x, 0.0001)
	for fore: Sprite2D in top._fore:
		assert_almost_eq(absf(fore.scale.y), fore.scale.x, 0.0001)
		assert_gt(_tip(fore).x, 0.0)
	h.step(Vector2.RIGHT * 7.0 * SimClock.TICK_DT * SimConst.PX_PER_M, 0.0, 1)
	top.pose(h, DentSpectralDrawn.Pose.DIVE, -1, Vector2.ZERO, 1)
	assert_gt(top._head.position.x, rest_x)
	for fore: Sprite2D in top._fore:
		assert_lt(_tip(fore).x, 0.0)


func test_strike_tick_reaches_and_recoils_in_world_metres() -> void:
	var top: DentSpectralTop = DentSpectralTop.new()
	add_child_autofree(top)
	top.scale = Vector2.ONE * PlayerScale.k()
	top.rotation = PI / 3.0
	var h: GhostHover = GhostHover.new(GhostHoverRow.of(&"dent"))
	top.pose(h, DentSpectralDrawn.Pose.JAB, 0, Vector2.ZERO, 1)
	var fist: Sprite2D = top._fore[1]
	assert_eq(fist.texture.resource_path.get_file(), "forearm_fist.png")
	assert_almost_eq(top.global_position.distance_to(_tip(fist)) / SimConst.PX_PER_M, 1.4, 0.01)
	top.pose(h, DentSpectralDrawn.Pose.JAB, 14, Vector2.ZERO, 1)
	assert_lt(top.global_position.distance_to(_tip(fist)) / SimConst.PX_PER_M, 1.1)
	top.pose(h, DentSpectralDrawn.Pose.STEER, -1, Vector2.UP * 100.0, 1)
	assert_eq(fist.texture.resource_path.get_file(), "forearm_open.png")
	top.pose(h, DentSpectralDrawn.Pose.STEER, -1, Vector2.UP * 100.0, 3)
	assert_eq(fist.texture.resource_path.get_file(), "forearm_fist.png")
	assert_lt(_tip(fist).y, top.global_position.y)


func _tip(fore: Sprite2D) -> Vector2:
	var id: String = fore.texture.resource_path.get_file().get_basename()
	var parts: PartLibrary = PartLibrary.of("dent/spectral")
	return fore.to_global(parts.pivots_b[id] - parts.pivots_a[id])
