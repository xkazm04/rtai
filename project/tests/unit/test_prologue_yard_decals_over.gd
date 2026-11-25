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
	PrologueYardOverprint._draw_pieces(node, plan, rec)
	return rec


func test_arched_line_flags_its_stain_layer_and_the_decals() -> void:
	var look: PrologueYardDressing = _plan().dressing
	assert_eq(look.ground.size(), 2)
	assert_false(look.ground[0].over_impression)
	assert_true(look.ground[1].over_impression)
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
	assert_eq(rec.calls[1].layer, plan.dressing.ground[1])
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
	assert_eq(grounds, [plan.dressing.ground[0]])
