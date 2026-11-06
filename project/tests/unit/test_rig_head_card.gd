extends GutTest
## View lab (features/characters/rig_head_card.gd): the upright facing cards. Only a tilted row
## with `cards` draws them; the default and the plain tilt rows never do.


func test_cards_only_on_card_rows() -> void:
	assert_false(ViewMode.of("").cards, "the shipped view draws no cards")
	assert_false(ViewMode.of("top_lift").cards)
	assert_false(ViewMode.of("tilt55").cards, "the plain tilt keeps the top-down head")
	assert_true(ViewMode.of("tilt55_cards").cards)


func test_face_toward_the_camera_draws_the_front() -> void:
	assert_eq(RigHeadCard.frame_of(PI * 0.5), Vector2i(0, 0), "facing screen down = the face")
	assert_eq(RigHeadCard.frame_of(-PI * 0.5), Vector2i(4, 0), "facing screen up = the back")


func test_left_facings_mirror_the_right() -> void:
	assert_eq(RigHeadCard.frame_of(0.0), Vector2i(2, 0))
	assert_eq(RigHeadCard.frame_of(PI), Vector2i(2, 1))
	assert_eq(RigHeadCard.frame_of(PI * 0.75), Vector2i(1, 1))
	assert_eq(RigHeadCard.frame_of(-PI * 0.75), Vector2i(3, 1))


func test_every_card_strip_loads() -> void:
	for dir: String in RigHeadCard.CARDS:
		var row: Array = RigHeadCard.CARDS[dir]
		var path: String = row[0]
		var t: Texture2D = load(path) as Texture2D
		assert_not_null(t, path)
		assert_eq(t.get_width() % RigHeadCard.FRAMES, 0, "%s splits into equal frames" % path)
