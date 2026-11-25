extends GutTest

## On the door-feed span's beam (alpha 1 in a 13 px window of the art) and its footprint centre,
## which lies inside the span's bounding rect but under the open arch (alpha 0).
const ON_BEAM: Vector2 = Vector2(30.8, -1.45)
const UNDER_ARCH: Vector2 = Vector2(31.675, 0.297)
## Feet on the floor a metre below that beam: his drawn body covers it.
const BELOW_BEAM: Vector2 = Vector2(30.8, -0.45)
## Inside the span's rect, feet and body both clear of the beam and the arch's legs.
const BODY_CLEAR: Vector2 = Vector2(30.8, 1.2)


func _plan() -> PrologueYard:
	var stage: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	var plan: PrologueYard = PrologueYard.from_stage(stage)
	assert_eq(plan.dressing.id, "arched_line")
	return plan


func _shadow(plan: PrologueYard) -> PrologueSpanShadow:
	var spans: Array[PrologueYard.Wreck] = PrologueSpanShadow.spans(plan)
	var node: PrologueSpanShadow = PrologueSpanShadow.build(
		plan.dressing.span_shadow, spans, PrologueYardPaint.new()
	)
	autofree(node)
	return node


func _door_feed(plan: PrologueYard) -> PrologueYard.Wreck:
	for piece: PrologueYard.Wreck in PrologueSpanShadow.spans(plan):
		if piece.id == "span_door_feed":
			return piece
	return null


func test_arched_line_reads_the_row() -> void:
	var spec: Dictionary = _plan().dressing.span_shadow
	var alpha: float = spec["alpha"]
	var fade_ticks: int = spec["fade_ticks"]
	var size_m: Vector2 = spec["size_m"]
	assert_almost_eq(alpha, 0.75, 0.0001)
	assert_eq(fade_ticks, 6)
	assert_eq(size_m, Vector2(1.9, 2.3))
	var offset_m: Vector2 = spec["offset_m"]
	var body_m: Vector2 = spec["body_m"]
	assert_eq(offset_m, Vector2(0.55, -0.6))
	assert_eq(body_m, Vector2(0.9, 1.9))
	assert_eq(PrologueSpanShadow.spans(_plan()).size(), 6)


func test_a_dressing_without_spans_gets_no_node() -> void:
	var plan: PrologueYard = _plan()
	plan.dressing.over_print = PackedStringArray()
	var parent: Node2D = Node2D.new()
	add_child_autofree(parent)
	PrologueSpanShadow.attach(parent, plan, PrologueYardPaint.new())
	assert_eq(parent.get_child_count(), 0)


func test_a_point_on_the_beam_is_on() -> void:
	var node: PrologueSpanShadow = _shadow(_plan())
	assert_true(node.on_span(ON_BEAM))


func test_a_point_in_the_rect_off_the_beam_is_off() -> void:
	var plan: PrologueYard = _plan()
	var piece: PrologueYard.Wreck = _door_feed(plan)
	assert_not_null(piece)
	assert_true(piece.footprint.has_point(UNDER_ARCH))
	assert_true(piece.footprint.has_point(ON_BEAM))
	var node: PrologueSpanShadow = _shadow(plan)
	assert_false(node.on_span(UNDER_ARCH))
	assert_false(node.on_span(Vector2(-50.0, -50.0)))


func test_a_rotated_span_turns_its_mask() -> void:
	var plan: PrologueYard = _plan()
	var piece: PrologueYard.Wreck = _door_feed(plan)
	var turned: PrologueYard.Wreck = PrologueYard.Wreck.new()
	turned.art = piece.art
	turned.footprint = piece.footprint
	turned.rotation = PI
	var spans: Array[PrologueYard.Wreck] = [turned]
	var node: PrologueSpanShadow = PrologueSpanShadow.build(
		plan.dressing.span_shadow, spans, PrologueYardPaint.new()
	)
	autofree(node)
	var mirrored: Vector2 = piece.footprint.get_center() * 2.0 - ON_BEAM
	assert_true(node.on_span(mirrored))
	assert_false(node.on_span(ON_BEAM))


func test_fade_reaches_full_in_fade_ticks_and_back() -> void:
	var node: PrologueSpanShadow = _shadow(_plan())
	assert_eq(node.strength(), 0.0)
	for tick: int in range(1, 6):
		node.step(tick, BELOW_BEAM)
		assert_almost_eq(node.strength(), 0.75 * tick / 6.0, 0.0001)
	node.step(5, BELOW_BEAM)
	assert_almost_eq(node.strength(), 0.75 * 5.0 / 6.0, 0.0001, "same tick = no step")
	node.step(6, BELOW_BEAM)
	node.step(7, BELOW_BEAM)
	assert_almost_eq(node.strength(), 0.75, 0.0001)
	node.step(8, BODY_CLEAR)
	assert_almost_eq(node.strength(), 0.625, 0.0001)
	for tick: int in range(9, 15):
		node.step(tick, BODY_CLEAR)
	assert_eq(node.strength(), 0.0)


func test_the_body_on_a_beam_is_on_with_the_feet_on_the_floor() -> void:
	var node: PrologueSpanShadow = _shadow(_plan())
	assert_false(node.on_span(BELOW_BEAM), "the feet are on the floor")
	assert_true(node.on_body(BELOW_BEAM), "the body covers the beam")
	assert_true(node.on_body(ON_BEAM))


func test_a_body_clear_of_the_art_is_off() -> void:
	var plan: PrologueYard = _plan()
	assert_true(_door_feed(plan).footprint.has_point(BODY_CLEAR))
	var node: PrologueSpanShadow = _shadow(plan)
	assert_false(node.on_body(BODY_CLEAR))
	assert_false(node.on_body(Vector2(-50.0, -50.0)))


func test_the_blot_is_clipped_to_the_span_art() -> void:
	var node: PrologueSpanShadow = _shadow(_plan())
	assert_eq(node.clip_children, CanvasItem.CLIP_CHILDREN_ONLY, "the spans are only a mask")
	assert_eq(node.get_child_count(), 1, "the blot is the only clipped child")
	var blot: Node2D = node.get_child(0) as Node2D
	assert_not_null(blot)
	node.step(1, BELOW_BEAM)
	var rect: Rect2 = node.blot_rect()
	assert_eq(rect.size, Ink.px(Vector2(1.9, 2.3)))
	assert_almost_eq(
		rect.get_center(), Ink.px(BELOW_BEAM + Vector2(0.55, -0.6)), Vector2(0.01, 0.01)
	)


func test_key_absent_means_no_node() -> void:
	var plan: PrologueYard = _plan()
	var parent: Node2D = Node2D.new()
	add_child_autofree(parent)
	PrologueSpanShadow.attach(parent, plan, PrologueYardPaint.new())
	assert_not_null(parent.find_child(PrologueSpanShadow.NODE_NAME, true, false))
	var bare: Node2D = Node2D.new()
	add_child_autofree(bare)
	plan.dressing.span_shadow = {}
	PrologueSpanShadow.attach(bare, plan, PrologueYardPaint.new())
	assert_eq(bare.get_child_count(), 0)


func test_the_over_print_pieces_node_carries_the_shadow_last() -> void:
	var plan: PrologueYard = _plan()
	var floor_view: Node2D = Node2D.new()
	add_child_autofree(floor_view)
	PrologueYardOverprint.attach_ochre_first(floor_view, plan, PrologueYardPaint.new())
	var node: Node = floor_view.find_child(PrologueSpanShadow.NODE_NAME, true, false)
	assert_not_null(node)
	if node != null:
		assert_eq(node.get_index(), node.get_parent().get_child_count() - 1)
		assert_eq(node.get_parent().get_parent().get_index(), floor_view.get_child_count() - 1)
	var sim_free: PrologueYard = _plan()
	sim_free.dressing.span_shadow = {}
	var bare: Node2D = Node2D.new()
	add_child_autofree(bare)
	PrologueYardOverprint.attach_ochre_first(bare, sim_free, PrologueYardPaint.new())
	assert_null(bare.find_child(PrologueSpanShadow.NODE_NAME, true, false))
