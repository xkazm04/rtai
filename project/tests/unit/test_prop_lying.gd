extends GutTest


func test_a_lying_box_spans_ground_point_to_head_grown_by_half_a_body() -> void:
	var feet: Vector2 = Vector2(100.0, 100.0)
	var head: Vector2 = Vector2(100.0, 180.0)  # fallen south: the head lower on the screen
	var box: Rect2 = PropLying.lying_box(feet, head)
	var pad: float = PropLying.HALF_W_M * Ink.PX_PER_M + Ink.LINE_PX
	assert_almost_eq(box.position.y, feet.y - pad, 0.001)
	assert_almost_eq(box.end.y, head.y + pad, 0.001)
	assert_almost_eq(box.size.x, pad * 2.0, 0.001)


func test_a_corpse_fallen_onto_a_barrier_meets_its_drawn_area() -> void:
	var area: Rect2 = Rect2(Vector2(0.0, 150.0), Vector2(400.0, 60.0))  # the barrier, south of feet
	var box: Rect2 = PropLying.lying_box(Vector2(100.0, 100.0), Vector2(100.0, 180.0))
	assert_true(box.intersection(area).has_area(), "the head on the barrier is hidden")
	var standing: Rect2 = PropOcclusion.body_patch(
		Vector2(100.0, 100.0), Vector2(100.0, 20.0), area
	)
	assert_false(standing.has_area(), "the n8 standing box never reached the barrier")


func test_the_city_occluder_is_found_by_type_under_the_layer() -> void:
	var layer: Node2D = Node2D.new()
	layer.add_child(Node2D.new())
	assert_null(PropCrowdOccluders.find(layer))
	var occ: CityOcclusion = CityOcclusion.new()
	layer.add_child(occ)
	assert_same(PropCrowdOccluders.find(layer), occ)
	layer.free()
