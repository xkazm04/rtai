extends GutTest


class InkRecorder:
	extends PrologueYardPaint
	var marks: Array[PrologueYardDressing.Piece] = []
	var covers: Array[PrologueYard.Wreck] = []
	var skins: Array[PrologueYardDressing.CoverArt] = []

	func stamps(_canvas: CanvasItem, pieces: Array[PrologueYardDressing.Piece]) -> void:
		marks.append_array(pieces)

	func wreck(
		_canvas: CanvasItem,
		piece: PrologueYard.Wreck,
		_tint: Color,
		skin: PrologueYardDressing.CoverArt
	) -> void:
		covers.append(piece)
		skins.append(skin)


func _draw_ink(paint: InkRecorder, plan: PrologueYard) -> void:
	var host: Node2D = add_child_autofree(Node2D.new())
	paint.attach_ochre(host, plan)
	var layer: CanvasLayer = host.get_child(0) as CanvasLayer
	var ink: Node2D = layer.get_child(0) as Node2D
	ink.draw.emit()


func _mark(warm: bool) -> PrologueYardDressing.Piece:
	var piece: PrologueYardDressing.Piece = PrologueYardDressing.Piece.new()
	piece.ochre = warm
	return piece


func test_draw_signal_prints_only_marked_pieces_in_floor_order() -> void:
	var plan: PrologueYard = PrologueYard.new()
	plan.dressing = PrologueYardDressing.new()
	var hall: PrologueYardDressing.Piece = _mark(true)
	var stripe: PrologueYardDressing.Piece = _mark(true)
	var door: PrologueYardDressing.Piece = _mark(true)
	var neutral: PrologueYardDressing.Piece = _mark(false)
	plan.dressing.outside = [hall, neutral]
	plan.dressing.decals = [neutral, stripe]
	plan.dressing.factory_front = [door, neutral]
	var paint: InkRecorder = InkRecorder.new()
	_draw_ink(paint, plan)
	assert_eq(paint.marks, [hall, stripe, door])


func test_draw_signal_reprints_each_overridden_cover_once_with_its_own_skin() -> void:
	var data: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	data.raw["yard"]["dressing"] = "torn_line"
	var plan: PrologueYard = PrologueYard.from_stage(data)
	var paint: InkRecorder = InkRecorder.new()
	_draw_ink(paint, plan)
	var covers: Array[PrologueYard.Wreck] = []
	var skins: Array[PrologueYardDressing.CoverArt] = []
	for wreck: PrologueYard.Wreck in plan.wrecks:
		if wreck.id != "broken_impeller":
			covers.append(wreck)
			skins.append(plan.dressing.cover[wreck.id])
	assert_eq(paint.covers, covers)
	assert_eq(paint.skins, skins)
