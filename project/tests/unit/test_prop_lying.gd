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


func _dead_rig() -> CutRig:
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.dead = true
	rig.head = Node2D.new()
	rig.add_child(rig.head)
	rig.head.position = Vector2(-2, -5)
	rig.head_card = Sprite2D.new()
	rig.head.add_child(rig.head_card)
	return rig


func _lying_card(rig: CutRig) -> Sprite2D:
	var lying: Sprite2D = Sprite2D.new()
	lying.name = StreetDeadPlan.NODE
	lying.texture = GradientTexture2D.new()
	rig.head_card.add_child(lying)
	lying.position = Vector2(0, 40)
	return lying


func test_lying_card_reaching_the_kerb_is_occluded_when_its_head_socket_stays_north() -> void:
	var po: Node2D = add_child_autofree(Node2D.new())
	var rig: CutRig = _dead_rig()
	var lying: Sprite2D = _lying_card(rig)
	var barrier: Rect2 = Rect2(-100, 48, 200, 32)
	var drawn: Rect2 = lying.global_transform * lying.get_rect()
	assert_true(drawn.intersects(barrier))
	var patch: Rect2 = PropLying.patch(po, rig, Vector2.ZERO, Vector2.UP * 5, barrier)
	assert_eq(patch, drawn.intersection(barrier))


func test_card_cell_and_socket_box_merge_in_prop_local_pixels() -> void:
	var po: Node2D = add_child_autofree(Node2D.new())
	po.transform = Transform2D(0.4, Vector2(2, 3), 0.0, Vector2(160, -90))
	var rig: CutRig = _dead_rig()
	rig.transform = po.transform
	var lying: Sprite2D = _lying_card(rig)
	lying.hframes = 4
	lying.frame = 2
	lying.rotation = PI * 0.5
	lying.offset = Vector2(8, -3)
	var socket: Rect2 = PropLying.lying_box(Vector2.ZERO, rig.head.position)
	var drawn: Rect2 = (rig.head.transform * lying.transform) * lying.get_rect()
	var area: Rect2 = Rect2(-100, -100, 200, 200)
	var patch: Rect2 = PropLying.patch(po, rig, Vector2.ZERO, Vector2.UP * 5, area)
	assert_true(patch.is_equal_approx(socket.merge(drawn)))


func test_hidden_or_missing_lying_card_keeps_socket_box_and_live_rig_keeps_standing_box() -> void:
	var po: Node2D = add_child_autofree(Node2D.new())
	var rig: CutRig = _dead_rig()
	var area: Rect2 = Rect2(-100, -100, 200, 200)
	var head: Vector2 = Vector2.UP * 80
	var socket: Rect2 = PropLying.lying_box(Vector2.ZERO, rig.head.position)
	assert_eq(PropLying.patch(po, rig, Vector2.ZERO, head, area), socket)
	var lying: Sprite2D = _lying_card(rig)
	lying.hide()
	assert_eq(PropLying.patch(po, rig, Vector2.ZERO, head, area), socket)
	lying.show()
	rig.head_card.hide()
	assert_eq(PropLying.patch(po, rig, Vector2.ZERO, head, area), socket)
	rig.head_card.show()
	rig.dead = false
	var standing: Rect2 = PropOcclusion.body_patch(Vector2.ZERO, head, area)
	assert_eq(PropLying.patch(po, rig, Vector2.ZERO, head, area), standing)
