extends GutTest
## n15 combat: a card gib of a kind with drawn pieces flies them (GibCardPieces), not the cut.


func _pieces() -> Array:
	var out: Array = []
	for k: int in 6:
		var s: Sprite2D = autofree(Sprite2D.new())
		s.region_enabled = true
		s.region_rect = Rect2(1.0, 2.0, 3.0, 4.0)
		s.transform = Transform2D(0.3, Vector2(0.5, 0.5), 0.0, Vector2(10.0 * k, -4.0))
		out.append([k, s])
	return out


func test_every_grid_holds_six_square_pieces() -> void:
	for row: String in GibCardPieces.GRIDS:
		var tex: Texture2D = load(GibCardPieces.GRIDS[row]) as Texture2D
		assert_not_null(tex, row)
		if tex != null:
			assert_eq(tex.get_size(), Vector2(GibCardPieces.CELL * 6.0, GibCardPieces.CELL), row)


func test_a_kind_without_pieces_keeps_the_cut() -> void:
	var kps: Array = _pieces()
	assert_false(GibCardPieces.dress("ped/head_suit_none", kps, 256.0))
	var first: Sprite2D = kps[0][1]
	assert_eq(first.region_rect, Rect2(1.0, 2.0, 3.0, 4.0))


func test_each_piece_takes_its_drawn_cell_in_place() -> void:
	var kps: Array = _pieces()
	assert_true(GibCardPieces.dress("cop/head_helmet", kps, 256.0))
	var m: float = (GibCardCut.LEG_V - GibCardCut.HEAD_V) * 256.0 / GibCardPieces.TORSO_PX
	for kp: Array in kps:
		var s: Sprite2D = kp[1]
		var k: int = kp[0]
		var cell: float = GibCardPieces.CELL
		assert_eq(s.region_rect, Rect2(cell * k, 0.0, cell, cell))
		assert_eq(s.position, Vector2(10.0 * k, -4.0), "where the region was")
		assert_almost_eq(s.rotation, 0.3, 0.0001)
		assert_almost_eq(s.scale.x, 0.5 * m, 0.0001, "the torso band's height")
