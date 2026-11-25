extends GutTest


class Call:
	extends RefCounted
	var layer: PrologueYardDressing.Ground
	var piece: PrologueYard.Wreck
	var tint: Color
	var skin: PrologueYardDressing.CoverArt
	var skin_tint: Color


class Recorder:
	extends PrologueYardPaint
	var calls: Array[Call] = []

	func ground(_canvas: CanvasItem, layer: PrologueYardDressing.Ground) -> void:
		var call: Call = Call.new()
		call.layer = layer
		calls.append(call)

	func stamps(_canvas: CanvasItem, _list: Array[PrologueYardDressing.Piece]) -> void:
		calls.append(Call.new())

	func scorch(_canvas: CanvasItem, _plan: PrologueYard) -> void:
		calls.append(Call.new())

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
		call.skin_tint = skin_tint
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
	PrologueYardOverprint._draw_part(node, plan, rec, PrologueYardOverprint.Part.ALL)
	var order: Array[PrologueYard.Wreck] = PrologueYardOverprint.order(plan)
	assert_eq(rec.calls.size(), order.size() + 3)
	assert_null(rec.calls[0].piece)
	assert_eq(rec.calls[0].layer, plan.dressing.impression)
	for i: int in order.size():
		var call: Call = rec.calls[i + 3]
		var piece: PrologueYard.Wreck = order[i]
		assert_eq(call.piece, piece, piece.id)
		if plan.wrecks.has(piece):
			var shaded: Color = Color(0.5, 0.5, 0.5)
			assert_eq(call.tint, shaded, piece.id)
			assert_eq(call.skin_tint, shaded, piece.id)
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


func _draw_shaded(plan: PrologueYard, shade: float) -> Array[Call]:
	plan.dressing.over_print_shade = shade
	var rec: Recorder = Recorder.new()
	var node: Node2D = Node2D.new()
	add_child_autofree(node)
	PrologueYardOverprint._draw_part(node, plan, rec, PrologueYardOverprint.Part.ALL)
	return rec.calls


func test_arched_line_pins_the_shade_at_half_and_one_leaves_wrecks_white() -> void:
	assert_eq(_plan().dressing.over_print_shade, 0.5)
	for call: Call in _draw_shaded(_plan(), 1.0):
		if call.piece != null and call.skin != null:
			assert_eq(call.tint, Color.WHITE)


func test_shade_reaches_skinned_and_unskinned_wrecks() -> void:
	var plan: PrologueYard = _plan()
	var grey: Color = Color(0.5, 0.5, 0.5)
	var skinned: int = 0
	var plain: int = 0
	var first: PrologueYard.Wreck = plan.wrecks[0]
	for piece: PrologueYard.Wreck in plan.wrecks:
		if plan.dressing.over_print.has(piece.id):
			first = piece
			break
	plan.dressing.cover[first.id] = PrologueYardDressing.CoverArt.new()
	for call: Call in _draw_shaded(plan, 0.5):
		if call.piece == null or not plan.wrecks.has(call.piece):
			continue
		assert_eq(call.tint, grey, call.piece.id)
		assert_eq(call.skin_tint, grey, call.piece.id)
		if call.skin != null:
			skinned += 1
		else:
			plain += 1
	assert_eq(skinned, 1)
	assert_gt(plain, 0)


func test_shade_spares_spans_and_the_impression() -> void:
	var plan: PrologueYard = _plan()
	var calls: Array[Call] = _draw_shaded(plan, 0.5)
	assert_not_null(calls[0].layer)
	for call: Call in calls:
		if call.piece != null and not plan.wrecks.has(call.piece):
			assert_eq(call.tint, call.piece.tint, call.piece.id)
			assert_eq(call.skin_tint, Color.WHITE, call.piece.id)


func test_dressing_reads_the_shade_key_and_the_schema_bounds_it() -> void:
	var raw: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(PrologueYardDressing.TABLE)
	)
	raw["dressings"]["arched_line"]["over_print_shade"] = 0.6
	var table: DataTable = DataTable.parse(JSON.stringify(raw), PrologueYardDressing.SCHEMA, "t")
	var dressing: PrologueYardDressing = PrologueYardDressing.resolve("arched_line", "", table)
	assert_almost_eq(dressing.over_print_shade, 0.6, 0.0001)
	var schema: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/schemas/prologue_yard_dressings.schema.json")
	)
	var text: String = JSON.stringify(schema)
	var key: int = text.find('"over_print_shade":{')
	assert_gt(key, -1)
	var spec: String = text.substr(key, 120)
	assert_true(spec.contains('"maximum":1'), spec)
	assert_true(spec.contains('"minimum":0'), spec)
