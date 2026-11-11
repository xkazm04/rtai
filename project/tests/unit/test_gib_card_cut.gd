extends GutTest
## n15 combat (item 4, "the rocket gib flies as one tumbling body at combo"): a drawn card is cut
## into six regions of its own frame that tile the frame and sit where the card drew them.


func _card(flip: bool) -> Sprite2D:
	var img: Image = Image.create(160, 100, false, Image.FORMAT_RGBA8)
	var spr: Sprite2D = Sprite2D.new()
	autofree(spr)
	spr.texture = ImageTexture.create_from_image(img)
	spr.hframes = 2
	spr.frame = 1
	spr.offset = Vector2(0.0, -50.0)
	spr.flip_h = flip
	spr.name = "card"
	return spr


func _rects(spr: Sprite2D, xf: Transform2D) -> Array[Rect2]:
	var out: Array[Rect2] = []
	for kp: Array in GibCardCut.split(spr, xf):
		var piece: Sprite2D = kp[1]
		autofree(piece)
		var size: Vector2 = piece.region_rect.size
		out.append(Rect2(piece.transform.origin - size * 0.5, size))
	return out


func test_six_pieces_tile_the_frame_in_its_own_texture_cell() -> void:
	var spr: Sprite2D = _card(false)
	var area: float = 0.0
	var ids: Array[int] = []
	for kp: Array in GibCardCut.split(spr, Transform2D.IDENTITY):
		var piece: Sprite2D = kp[1]
		autofree(piece)
		ids.append(kp[0])
		assert_true(Rect2(80, 0, 80, 100).encloses(piece.region_rect), "inside frame 1's cell")
		area += piece.region_rect.get_area()
	assert_eq(ids, [0, 1, 2, 3, 4, 5])
	assert_almost_eq(area, 8000.0, 0.5, "they tile the 80 x 100 cell")


func test_the_pieces_sit_where_the_card_drew_them_flipped_or_not() -> void:
	var xf: Transform2D = Transform2D(0.0, Vector2(2.0, 2.0), 0.0, Vector2(30.0, 40.0))
	for flip: bool in [false, true]:
		var spr: Sprite2D = _card(flip)
		var rects: Array[Rect2] = _rects(spr, Transform2D(0.0, Vector2.ONE, 0.0, Vector2.ZERO))
		var drawn: Rect2 = Rect2(Vector2(-40.0, -100.0), Vector2(80.0, 100.0))
		var head: Rect2 = rects[0]
		assert_almost_eq(head.position.y, -100.0, 0.01, "the head band at the top")
		var union: Rect2 = rects[0]
		for r: Rect2 in rects:
			union = union.merge(r)
		assert_eq(union, drawn, "flip %s" % flip)
		var arm_l: Rect2 = rects[2]
		assert_eq(arm_l.position.x < 0.0, not flip, "an arm strip mirrors with the card")
	var head_piece: Sprite2D = GibCardCut.split(_card(false), xf)[0][1]
	autofree(head_piece)
	assert_eq(head_piece.transform.origin, Vector2(30.0, -130.0), "the card's transform carries it")
