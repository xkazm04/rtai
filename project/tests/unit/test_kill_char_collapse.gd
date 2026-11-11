extends GutTest
## n16 kills-polish item 3 (asset lane A8): a burnt man of a kind with the drawn collapse plays its
## three cells over the crumble (crumbling, on his knees with the skull, the ash heap) instead of
## fading; a kind still being drawn keeps the fade.


func _body(row: String) -> Node2D:
	var body: Node2D = Node2D.new()
	var card: Sprite2D = Sprite2D.new()
	card.name = String(KillCharCells.CARD)
	card.texture = KillCharCells.COLLAPSE["ped/head_hood"]
	card.hframes = RigHeadCard.FRAMES
	body.add_child(card)
	body.set_meta(KillCharCells.META, row)
	return body


func test_the_frames_follow_the_crumble() -> void:
	assert_eq(KillCharCells.collapse_frame(0.0), -1, "standing: the char cell")
	assert_eq(KillCharCells.collapse_frame(0.1), 0)
	assert_eq(KillCharCells.collapse_frame(0.5), 1)
	assert_eq(KillCharCells.collapse_frame(1.0), 2, "the heap stays")


func test_a_drawn_kind_collapses_and_holds_the_heap() -> void:
	var body: Node2D = _body("ped/head_hood")
	assert_true(KillCharCells.collapse(body, 1.0))
	var card: Sprite2D = body.get_node(NodePath(String(KillCharCells.CARD)))
	assert_eq(card.hframes, KillCharCells.COLLAPSE_FRAMES)
	assert_eq(card.frame, 2)
	body.free()


func test_every_kind_with_a_char_cell_collapses() -> void:
	for row: String in KillCharCells.GRIDS:
		assert_true(KillCharCells.COLLAPSE.has(row), row)


func test_a_kind_without_the_drawing_keeps_the_fade() -> void:
	var body: Node2D = _body("ped/head_shopper")
	assert_false(KillCharCells.collapse(body, 0.5))
	body.free()


func test_every_strip_is_three_char_cells() -> void:
	for row: String in KillCharCells.COLLAPSE:
		var tex: Texture2D = KillCharCells.COLLAPSE[row]
		assert_eq(tex.get_width(), 344 * KillCharCells.COLLAPSE_FRAMES, row)
		assert_eq(tex.get_height(), 256, row)
