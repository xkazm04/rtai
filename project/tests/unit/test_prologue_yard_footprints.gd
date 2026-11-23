extends GutTest


func test_factory_faces_stay_south_and_free_standing_cover_can_turn() -> void:
	var box: Rect2 = PrologueYardPaint.pixels(Rect2(-9, 7, 12, 5))
	var source: Vector2 = Vector2(100, 200)
	var fit: Transform2D = PrologueYardPaint.cover_transform(box, source, false)
	assert_eq(fit.origin, box.get_center())
	assert_almost_eq(fit.get_rotation(), PI * 0.5, 0.00001)
	var shell: Transform2D = PrologueYardPaint.cover_transform(box, source, true)
	assert_eq(shell.origin, box.get_center())
	assert_eq(shell.get_rotation(), 0.0)


func test_every_torn_line_collision_box_is_visible_in_the_opaque_art() -> void:
	_assert_coverage("torn_line")


func test_every_line_fire_collision_box_is_visible_in_the_opaque_art() -> void:
	_assert_coverage("line_fire")


func _assert_coverage(dressing_id: String) -> void:
	var data: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	data.raw["yard"]["dressing"] = dressing_id
	var yard: PrologueYard = PrologueYard.from_stage(data)
	for wreck: PrologueYard.Wreck in yard.wrecks:
		var box: Rect2 = PrologueYardPaint.pixels(wreck.footprint)
		var skin: PrologueYardDressing.CoverArt = yard.dressing.cover.get(wreck.id)
		var art: Rect2 = _drawn_ink(wreck, skin)
		var coverage: float = box.intersection(art).get_area() / box.get_area()
		var axis: int = box.size.max_axis_index()
		assert_gte(coverage, 0.85, wreck.id)
		assert_lte(art.position[axis], box.position[axis] + 0.001, wreck.id)
		assert_gte(art.end[axis], box.end[axis] - 0.001, wreck.id)
		assert_true(box.grow(0.3 * Ink.PX_PER_M + 0.001).encloses(art), wreck.id)
		Log.info("yard-coverage", "%s %.2f%%" % [wreck.id, 100.0 * coverage])


func _drawn_ink(wreck: PrologueYard.Wreck, skin: PrologueYardDressing.CoverArt) -> Rect2:
	var path: String = wreck.art if skin == null else skin.art
	var image: Image = Image.new()
	var read: Error = image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
	assert_eq(read, OK, path)
	if read != OK:
		return Rect2()
	var crop: Rect2 = wreck.crop if skin == null else skin.crop
	var size: Vector2 = Vector2(image.get_size())
	var region: Rect2i = Rect2i(Rect2(crop.position * size, crop.size * size))
	var ink: Rect2 = _opaque_box(image.get_region(region))
	var box: Rect2 = PrologueYardPaint.pixels(wreck.footprint)
	size = Vector2(region.size)
	if skin == null:
		var scale_xy: Vector2 = box.size / size
		return Rect2(box.position + ink.position * scale_xy, ink.size * scale_xy)
	ink.position -= size * 0.5
	return PrologueYardPaint.cover_transform(box, size, wreck.shell) * ink


func _opaque_box(image: Image) -> Rect2:
	# Ignore all translucent pixels, including the soft ink shadow.
	var low: Vector2i = image.get_size()
	var high: Vector2i = Vector2i(-1, -1)
	for y: int in image.get_height():
		for x: int in image.get_width():
			if image.get_pixel(x, y).a == 1.0:
				low = low.min(Vector2i(x, y))
				high = high.max(Vector2i(x, y))
	return Rect2(low, high - low + Vector2i.ONE)
