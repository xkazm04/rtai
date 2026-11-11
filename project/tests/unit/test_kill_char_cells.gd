extends GutTest
## n15 combat item 2: a burn kill of the patrol cop stands as the drawn charred man (KillCharCells).

const ROW: String = "cop/head_cap"


func _group(tagged: bool, frame: int) -> Node2D:
	var body: Node2D = autofree(Node2D.new())
	var card: Sprite2D = Sprite2D.new()
	card.name = KillCharCells.CARD
	card.texture = load(KillCharCells.GRIDS[ROW]) as Texture2D
	card.hframes = RigHeadCard.FRAMES
	card.frame = frame
	card.position = Vector2(12.0, -3.0)
	card.rotation = 0.4
	card.material = ShaderMaterial.new()
	body.add_child(card)
	if tagged:
		body.set_meta(KillCharCells.META, ROW)
	return body


func test_the_char_grid_has_five_whole_facings() -> void:
	var tex: Texture2D = load(KillCharCells.GRIDS[ROW]) as Texture2D
	assert_not_null(tex)
	if tex != null:
		assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, "five facings")
	assert_true(StreetWalkerHit.FILL.has(KillCharCells.FILL_OF[ROW]), "sized as the burning man")


func test_every_char_grid_is_sized_as_its_burning_man() -> void:
	for row: String in KillCharCells.GRIDS:
		var tex: Texture2D = load(KillCharCells.GRIDS[row]) as Texture2D
		assert_not_null(tex, row)
		if tex != null:
			assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, row + ": five facings")
		assert_true(KillCharCells.FILL_OF.has(row), row + ": has a burn FILL")
		var fill: String = KillCharCells.FILL_OF.get(row, "")
		assert_true(StreetWalkerHit.FILL.has(fill), row + ": " + fill)


func test_every_burning_kind_has_a_drawn_char_cell() -> void:
	# it363: the cap, jogger, punk and SWAT sets closed the list (no burn kill falls back to the print)
	for row: String in StreetWalkerHit.BURN_GRIDS:
		assert_true(KillCharCells.GRIDS.has(row), row + ": a drawn char cell")
		var fill: String = KillCharCells.FILL_OF.get(row, "")
		assert_eq(fill, StreetWalkerHit.BURN_GRIDS[row].get_file(), row)


func test_a_rig_without_a_head_card_is_not_tagged() -> void:
	# the top view's reel (gate 65acf2e8e): a burn kill of a rig with no card crashed in row_of
	var rig: CutRig = autofree(CutRig.new())
	var body: Node2D = autofree(Node2D.new())
	KillCharCells.tag(body, rig)
	assert_false(body.has_meta(KillCharCells.META), "no card, no drawn char cell")


func test_an_untagged_body_keeps_its_char_print() -> void:
	assert_null(KillCharCells.swap(_group(false, 2)), "no drawn cell for this kind")
	assert_null(KillCharCells.swap(null))


func test_a_tagged_card_stands_as_the_drawn_cell_for_its_facing() -> void:
	var card: Sprite2D = KillCharCells.swap(_group(true, 3))
	assert_not_null(card)
	if card == null:
		return
	assert_eq(card.frame, 3, "the card's facing")
	assert_eq(card.vframes, 1)
	assert_null(card.material, "its own colours, no char shader")
	assert_almost_eq(card.rotation, 0.0, 0.0001, "upright")
	assert_eq(card.position, Vector2(12.0, -3.0), "feet on the card's point")
	var s: float = KillCharCells.scale_of(ROW, card.texture.get_height())
	assert_almost_eq(card.scale.x, s, 0.0001)
	var want: float = StreetWalkerCards.HEIGHT_M * CharacterRigs.PX_PER_M * 1.14 / 256.0
	if not StreetWalkerCards.HEIGHT_BY_ART.has(ViewMode.shared().art):
		assert_almost_eq(s, want, 0.0001, "1.7 m x the burn FILL over the cell")
