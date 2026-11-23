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


class StampTexture:
	extends Texture2D
	var repeats: Array[bool] = []

	func _draw_rect(item: RID, rect: Rect2, tile: bool, tint: Color, _transpose: bool) -> void:
		repeats.append(tile)
		RenderingServer.canvas_item_add_rect(item, rect, tint)


class SamplePaint:
	extends PrologueYardPaint
	var swatch: Texture2D
	var paths: Array[String] = []

	func texture(path: String) -> Texture2D:
		paths.append(path)
		return swatch


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


func _draw_bounds(draw_on: Callable) -> Rect2:
	var canvas: Node2D = add_child_autofree(Node2D.new())
	@warning_ignore("return_value_discarded")
	canvas.draw.connect(draw_on.bind(canvas), CONNECT_ONE_SHOT)
	await get_tree().process_frame
	await get_tree().process_frame
	return RenderingServer.debug_canvas_item_get_rect(canvas.get_canvas_item())


func _assert_box(actual: Rect2, expected: Rect2) -> void:
	assert_almost_eq(actual.position, expected.position, Vector2.ONE * 0.001)
	assert_almost_eq(actual.size, expected.size, Vector2.ONE * 0.001)


## A 100-by-100 logical image with ink only at (10, 20) to (40, 60).
## AtlasTexture clips draw commands to that patch even in the headless renderer.
func _margin_swatch() -> AtlasTexture:
	var bitmap: GradientTexture2D = GradientTexture2D.new()
	bitmap.width = 30
	bitmap.height = 40
	var sample: AtlasTexture = AtlasTexture.new()
	sample.atlas = bitmap
	sample.region = Rect2(0, 0, 30, 40)
	sample.margin = Rect2(10, 20, 70, 60)
	return sample


func test_stamp_centres_the_rotated_door_and_draws_it_once_without_repeating() -> void:
	var door: PrologueYardDressing.Piece = (
		PrologueYardDressing.resolve("torn_line").factory_front[0]
	)
	var pieces: Array[PrologueYardDressing.Piece] = [door]
	var paint: SamplePaint = SamplePaint.new()
	var stamp: StampTexture = StampTexture.new()
	paint.swatch = stamp
	var box: Rect2 = await _draw_bounds(paint.stamps.bind(pieces))
	var expected: Transform2D = Transform2D(deg_to_rad(-16.0), Ink.px(Vector2(16.32, 1.72)))
	_assert_box(box, expected * PrologueYardPaint.pixels(Rect2(-2.3, -1.03, 4.6, 2.06)))
	assert_eq(stamp.repeats, [false])


func test_swatch_steps_from_the_layer_origin_and_crops_the_partial_edge_tiles() -> void:
	var layer: PrologueYardDressing.Ground = PrologueYardDressing.Ground.new()
	layer.rect = Rect2(2, 5, 10, 7)
	layer.tile_size = Vector2(4, 3)
	layer.tiled = true
	layer.wash = Color.TRANSPARENT
	var paint: SamplePaint = SamplePaint.new()
	paint.swatch = _margin_swatch()
	var box: Rect2 = await _draw_bounds(paint.ground.bind(layer))
	# Three columns and rows. Only the first metre of the last row fits.
	_assert_box(box, PrologueYardPaint.pixels(Rect2(2.4, 5.6, 9.2, 6.4)))


func test_single_swatch_ignores_the_tile_size_and_stretches_across_the_layer() -> void:
	var layer: PrologueYardDressing.Ground = PrologueYardDressing.Ground.new()
	layer.rect = Rect2(-2, 3, 8, 5)
	layer.tile_size = Vector2(4, 3)
	layer.tiled = false
	layer.wash = Color.TRANSPARENT
	var paint: SamplePaint = SamplePaint.new()
	var stamp: StampTexture = StampTexture.new()
	paint.swatch = stamp
	var box: Rect2 = await _draw_bounds(paint.ground.bind(layer))
	_assert_box(box, PrologueYardPaint.pixels(layer.rect))
	assert_eq(stamp.repeats, [false])


func test_press_draws_the_table_crop_in_plain_and_the_welding_arm_in_torn_line() -> void:
	var data: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	var plan: PrologueYard = PrologueYard.from_stage(data)
	var paint: SamplePaint = SamplePaint.new()
	paint.swatch = _margin_swatch()
	for wreck: PrologueYard.Wreck in plan.wrecks:
		if wreck.id != "press_carcass":
			continue
		var plain: Rect2 = await _draw_bounds(paint.wreck.bind(wreck, Color.WHITE, null))
		# The 51-by-60 source crop begins at (6, 12). The ink starts 4 px right, 8 px down.
		var fraction: Vector2 = Vector2(51, 60)
		var offset: Vector2 = Vector2(4, 8) / fraction * wreck.footprint.size
		var size: Vector2 = Vector2(30, 40) / fraction * wreck.footprint.size
		_assert_box(plain, PrologueYardPaint.pixels(Rect2(wreck.footprint.position + offset, size)))
		var skin: PrologueYardDressing.CoverArt = plan.dressing.cover[wreck.id]
		var torn: Rect2 = await _draw_bounds(paint.wreck.bind(wreck, Color.WHITE, skin))
		_assert_box(torn, PrologueYardPaint.pixels(Rect2(27.72, 16.62, 0.96, 1.84)))
	assert_eq(
		paint.paths,
		[
			"res://features/city/art/roofs/roof_charging.png",
			"res://boot/prologue/art/torn_line/welding_arm.png"
		]
	)
