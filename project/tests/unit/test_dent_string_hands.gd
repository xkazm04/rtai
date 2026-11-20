extends GutTest


func test_fourth_column_and_both_printed_palms_follow_the_tether_through_mirrors_and_turns(
) -> void:
	var saved: ViewMode = ViewMode.shared()
	var drawn: GhostDrawn = GhostDrawn.new("dent", 1.8, 163.0, 176.5)
	drawn.flight = GhostFlight.make(&"dent")
	add_child_autofree(drawn.flight)
	var card: DentSpectralDrawn = DentSpectralDrawn.new()
	drawn.flight.mount(card)
	for view: String in ["tilt", "tilt70"]:
		ViewMode.select(view)
		for octant: int in 8:
			var yaw: float = octant * PI / 4.0
			card.show_pose(drawn, yaw, DentSpectralDrawn.Pose.STEER, true)
			assert_eq(card.sprite.frame_coords.x, 3)
			card.steer_hands(0.0, yaw)
			var gap: Vector2 = card.string_grip(1) - card.string_grip(0)
			gap.y *= ViewMode.shared().ground_k()
			assert_gte(gap.length(), 0.479 * SimConst.PX_PER_M)
			for turn: float in [-1.0, 1.0]:
				card.steer_hands(turn, yaw)
				_assert_palm_vertices(card)
			card.show_pose(drawn, yaw, DentSpectralDrawn.Pose.STEER)
			assert_eq(card.sprite.frame_coords.x, 2)
			card.steer_hands(0.0, yaw)
			assert_false(card._bend.visible)
	ViewMode._shared = saved


func _assert_palm_vertices(card: DentSpectralDrawn) -> void:
	var rest: PackedVector2Array = card._steer_palms()
	for i: int in 2:
		var vertex: int = card._bend._rest.find(rest[i])
		assert_gte(vertex, 0)
		if vertex >= 0:
			var palm: Vector2 = card._bend.to_global(card._bend.polygon[vertex])
			assert_almost_eq(palm, card.string_grip(i), Vector2.ONE * 0.001)
