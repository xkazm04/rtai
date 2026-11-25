extends GutTest


class Call:
	extends RefCounted
	var layer: PrologueYardDressing.Ground
	var piece: PrologueYard.Wreck
	var tint: Color
	var skin: PrologueYardDressing.CoverArt


class Recorder:
	extends PrologueYardPaint
	var calls: Array[Call] = []

	func ground(_canvas: CanvasItem, layer: PrologueYardDressing.Ground) -> void:
		var call: Call = Call.new()
		call.layer = layer
		calls.append(call)

	func wreck(
		_canvas: CanvasItem,
		piece: PrologueYard.Wreck,
		tint: Color,
		skin: PrologueYardDressing.CoverArt
	) -> void:
		var call: Call = Call.new()
		call.piece = piece
		call.tint = tint
		call.skin = skin
		calls.append(call)


func _plan() -> PrologueYard:
	var stage: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	var plan: PrologueYard = PrologueYard.from_stage(stage)
	assert_eq(plan.dressing.id, "arched_line")
	return plan


func _is_span(piece: PrologueYard.Wreck) -> bool:
	return piece.id.begins_with(PrologueYardOverprint.OVERHEAD_PREFIX)


func test_order_puts_every_span_after_every_wreck() -> void:
	var plan: PrologueYard = _plan()
	var order: Array[PrologueYard.Wreck] = PrologueYardOverprint.order(plan)
	var first_span: int = order.size()
	var last_other: int = -1
	var spans: int = 0
	for i: int in order.size():
		if _is_span(order[i]):
			first_span = mini(first_span, i)
			spans += 1
		else:
			last_other = i
	assert_eq(spans, 5)
	assert_gt(first_span, last_other)
	for wreck: PrologueYard.Wreck in plan.wrecks:
		if plan.dressing.over_print.has(wreck.id):
			assert_gt(first_span, order.find(wreck), wreck.id)


func test_only_over_print_ids_are_drawn() -> void:
	var plan: PrologueYard = _plan()
	var ids: Array[String] = []
	for piece: PrologueYard.Wreck in PrologueYardOverprint.order(plan):
		ids.append(piece.id)
		assert_true(plan.dressing.over_print.has(piece.id), piece.id)
	for id: String in plan.dressing.over_print:
		assert_true(ids.has(id), id)
	assert_eq(ids.size(), plan.dressing.over_print.size())


func test_draw_runs_ground_then_wrecks_in_skin_then_debris_then_spans() -> void:
	var plan: PrologueYard = _plan()
	var rec: Recorder = Recorder.new()
	var node: Node2D = Node2D.new()
	add_child_autofree(node)
	PrologueYardOverprint._draw_pieces(node, plan, rec)
	var order: Array[PrologueYard.Wreck] = PrologueYardOverprint.order(plan)
	assert_eq(rec.calls.size(), order.size() + 1)
	assert_null(rec.calls[0].piece)
	assert_eq(rec.calls[0].layer, plan.dressing.impression)
	for i: int in order.size():
		var call: Call = rec.calls[i + 1]
		var piece: PrologueYard.Wreck = order[i]
		assert_eq(call.piece, piece, piece.id)
		if plan.wrecks.has(piece):
			assert_eq(call.tint, Color.WHITE, piece.id)
			var want: PrologueYardDressing.CoverArt = plan.dressing.cover.get(piece.id)
			assert_eq(call.skin, want, piece.id)
		else:
			assert_eq(call.tint, piece.tint, piece.id)
			assert_null(call.skin, piece.id)
	assert_true(_is_span(rec.calls[rec.calls.size() - 1].piece))


func test_attach_adds_one_actor_layer_holding_one_blood_node_with_the_floor_transform() -> void:
	var floor_view: Node2D = Node2D.new()
	add_child_autofree(floor_view)
	floor_view.position = Vector2(12, 34)
	floor_view.scale = Vector2(2, 2)
	PrologueYardOverprint.attach(floor_view, _plan(), Recorder.new())
	assert_eq(floor_view.get_child_count(), 1)
	var layer: CanvasLayer = floor_view.get_child(0) as CanvasLayer
	assert_not_null(layer)
	assert_eq(layer.layer, RenderLayers.canvas(&"actors"))
	assert_true(layer.follow_viewport_enabled)
	assert_eq(layer.get_child_count(), 1)
	var node: Node2D = layer.get_child(0) as Node2D
	assert_eq(node.z_index, RenderLayers.z(&"blood"))
	assert_eq(node.transform, floor_view.global_transform)
