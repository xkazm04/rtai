extends GutTest
## Ground layers and decals flagged to print over the i55 impression (n30).


class Call:
	extends RefCounted
	var layer: PrologueYardDressing.Ground
	var scorch: bool
	var pieces: Array[PrologueYardDressing.Piece]
	var wreck: bool


class Recorder:
	extends PrologueYardPaint
	var calls: Array[Call] = []

	func ground(_canvas: CanvasItem, layer: PrologueYardDressing.Ground) -> void:
		var call: Call = Call.new()
		call.layer = layer
		calls.append(call)

	func stamps(_canvas: CanvasItem, list: Array[PrologueYardDressing.Piece]) -> void:
		var call: Call = Call.new()
		call.pieces = list
		calls.append(call)

	func scorch(_canvas: CanvasItem, _plan: PrologueYard) -> void:
		var call: Call = Call.new()
		call.scorch = true
		calls.append(call)

	func wreck(
		_canvas: CanvasItem,
		_piece: PrologueYard.Wreck,
		_tint: Color,
		_skin: PrologueYardDressing.CoverArt
	) -> void:
		var call: Call = Call.new()
		call.wreck = true
		calls.append(call)


func _plan() -> PrologueYard:
	var stage: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	var plan: PrologueYard = PrologueYard.from_stage(stage)
	assert_eq(plan.dressing.id, "arched_line")
	return plan


func _drawn(plan: PrologueYard) -> Recorder:
	var rec: Recorder = Recorder.new()
	var node: Node2D = Node2D.new()
	add_child_autofree(node)
	PrologueYardOverprint._draw_part(node, plan, rec, PrologueYardOverprint.Part.ALL)
	return rec


func test_arched_line_flags_its_stain_layer_and_the_decals() -> void:
	var look: PrologueYardDressing = _plan().dressing
	assert_eq(look.ground.size(), 3)
	assert_false(look.ground[0].over_impression)
	assert_false(look.ground[1].over_impression)
	assert_eq(look.ground[1].tint, Color("ffffff00"))
	assert_eq(look.ground[1].wash, Color("f6dca880"))
	assert_true(look.ground[2].over_impression)
	assert_eq(look.ground[2].wash, Color("00000000"))
	assert_false(look.impression.over_impression)
	assert_true(look.decals_over_impression)
	assert_gt(look.decals_over.size(), 10)
	for piece: PrologueYardDressing.Piece in look.decals_over:
		assert_false(piece.ochre)
	for piece: PrologueYardDressing.Piece in look.decals:
		assert_true(piece.ochre)


func test_flagged_layer_draws_after_the_impression_and_before_the_pieces() -> void:
	var plan: PrologueYard = _plan()
	var rec: Recorder = _drawn(plan)
	assert_eq(rec.calls[0].layer, plan.dressing.impression)
	assert_eq(rec.calls[1].layer, plan.dressing.ground[2])
	assert_eq(rec.calls[2].pieces, plan.dressing.decals_over)
	assert_true(rec.calls[3].wreck)
	assert_eq(rec.calls.size(), PrologueYardOverprint.order(plan).size() + 3)


func test_key_absent_keeps_todays_order() -> void:
	var plan: PrologueYard = _plan()
	for layer: PrologueYardDressing.Ground in plan.dressing.ground:
		layer.over_impression = false
	plan.dressing.decals_over.clear()
	plan.dressing.decals_over_impression = false
	var rec: Recorder = _drawn(plan)
	assert_eq(rec.calls[0].layer, plan.dressing.impression)
	assert_null(rec.calls[1].layer)
	assert_true(rec.calls[1].pieces.is_empty())
	assert_eq(rec.calls.size(), PrologueYardOverprint.order(plan).size() + 2)


func test_row_without_the_key_keeps_every_decal_on_the_floor() -> void:
	var look: PrologueYardDressing = PrologueYardDressing.resolve("torn_line")
	assert_false(look.decals_over_impression)
	assert_true(look.decals_over.is_empty())
	assert_gt(look.decals.size(), 10)


func test_floor_skips_the_flagged_layer_and_the_stage_scorch() -> void:
	var plan: PrologueYard = _plan()
	var floor_view: PrologueFloor = PrologueFloor.new()
	var rec: Recorder = Recorder.new()
	floor_view.plan = plan
	floor_view._paint = rec
	floor_view._ground()
	floor_view._stage_decals()
	floor_view.free()
	var grounds: Array[PrologueYardDressing.Ground] = []
	for call: Call in rec.calls:
		assert_false(call.scorch)
		if call.layer != null:
			grounds.append(call.layer)
	assert_eq(grounds, [plan.dressing.ground[0], plan.dressing.ground[1]])


func _layers(plan: PrologueYard) -> Array[CanvasLayer]:
	var floor_view: PrologueFloor = PrologueFloor.new()
	floor_view.plan = plan
	add_child_autofree(floor_view)
	var out: Array[CanvasLayer] = []
	for child: Node in floor_view.get_children():
		if child is CanvasLayer:
			out.append(child as CanvasLayer)
	return out


func _node_of(layer: CanvasLayer) -> Node2D:
	return layer.get_child(0) as Node2D


func test_ochre_over_impression_parses_for_arched_line_only() -> void:
	assert_true(_plan().dressing.ochre_over_impression)
	assert_false(PrologueYardDressing.resolve("torn_line").ochre_over_impression)
	assert_false(PrologueYardDressing.resolve("raised_line").ochre_over_impression)


func test_with_the_key_layers_stack_impression_ochre_pieces() -> void:
	var plan: PrologueYard = _plan()
	var layers: Array[CanvasLayer] = _layers(plan)
	assert_eq(layers.size(), 3)
	var ground: Node2D = _node_of(layers[0])
	var ochre: Node2D = _node_of(layers[1])
	var pieces: Node2D = _node_of(layers[2])
	assert_not_null(ochre.material)
	assert_null(ground.material)
	assert_null(pieces.material)
	var rec: Recorder = Recorder.new()
	PrologueYardOverprint._draw_part(ground, plan, rec, PrologueYardOverprint.Part.GROUND)
	for call: Call in rec.calls:
		assert_false(call.wreck)
	var pieces_rec: Recorder = Recorder.new()
	PrologueYardOverprint._draw_part(pieces, plan, pieces_rec, PrologueYardOverprint.Part.PIECES)
	assert_eq(pieces_rec.calls.size(), PrologueYardOverprint.order(plan).size())
	for call: Call in pieces_rec.calls:
		assert_true(call.wreck)


func test_key_absent_keeps_ochre_then_one_overprint_node() -> void:
	var plan: PrologueYard = _plan()
	plan.dressing.ochre_over_impression = false
	var layers: Array[CanvasLayer] = _layers(plan)
	assert_eq(layers.size(), 2)
	assert_not_null(_node_of(layers[0]).material)
	assert_null(_node_of(layers[1]).material)


func test_decal_over_alpha_scales_only_the_tyre_stamps() -> void:
	var look: PrologueYardDressing = _plan().dressing
	assert_eq(look.decal_over_alpha, 1.4)
	var plain: PrologueYardDressing = PrologueYardDressing.resolve("torn_line")
	assert_eq(plain.decal_over_alpha, 1.0)
	var tyres: int = 0
	for piece: PrologueYardDressing.Piece in look.decals_over:
		if not piece.art.contains("/tyre_"):
			assert_lte(piece.tint.a, 1.0)
			continue
		tyres += 1
		var base: PrologueYardDressing.Piece = _same_piece(plain, piece)
		assert_almost_eq(piece.tint.a, minf(base.tint.a * 1.4, 1.0), 0.001)
	assert_eq(tyres, 2)


func _same_piece(
	plain: PrologueYardDressing, piece: PrologueYardDressing.Piece
) -> PrologueYardDressing.Piece:
	for base: PrologueYardDressing.Piece in plain.decals:
		if base.art == piece.art and base.at == piece.at:
			return base
	fail_test("no torn_line piece at %s" % piece.at)
	return piece
