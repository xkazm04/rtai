extends GutTest
## n8-hud: the dialogue box's face (PortraitBook) and its non-blocking enter/exit (HudDialogue).


func test_book_gives_the_mood_bust_only_on_named_lines() -> void:
	var book: PortraitBook = PortraitBook.new()
	var plain: Texture2D = book.face("nurse", "juno-load-bearing")
	var mood: Texture2D = book.face("nurse", "juno-real-name")
	assert_not_null(plain)
	assert_not_null(mood)
	assert_ne(plain, mood)


func test_voice_only_callers_get_the_device_not_a_face() -> void:
	var book: PortraitBook = PortraitBook.new()
	assert_true(book.is_device("don-fax"))
	assert_true(book.is_device("patch"))
	assert_eq(book.face("don-fax"), book.face("patch"))
	assert_false(book.is_device("gunsmith"))


func test_no_row_means_no_face() -> void:
	var book: PortraitBook = PortraitBook.new()
	assert_null(book.face("rivet"))
	assert_null(book.face("lady-cathode"))


func test_every_row_art_loads() -> void:
	var t: DataTable = DataTable.open(PortraitBook.TABLE, PortraitBook.SCHEMA)
	assert_true(t.ok())
	for row: Variant in t.array(t.raw, "speakers"):
		var r: Dictionary = row
		for key: String in ["art", "mood_art"]:
			var path: String = r[key]
			if path != "":
				assert_true(ResourceLoader.exists(path), path)


func test_the_face_rises_in_and_the_box_fades_out_without_waiting() -> void:
	var state: HudState = HudState.new()
	var box: HudDialogue = HudDialogue.new()
	box.state = state
	assert_false(box.showing())
	state.say("Juno", "Sit.")
	state.portrait_key = "nurse"
	box.step(0.0)
	assert_true(box.showing())
	state.silent()
	box.step(HudDialogue.EXIT_S * 0.5)
	assert_true(box.showing(), "fading out")
	box.step(HudDialogue.EXIT_S)
	assert_false(box.showing())
	box.free()


func test_the_feed_fills_the_face_from_the_speaker() -> void:
	var feed: HudFeed = HudFeed.new()
	var state: HudState = HudState.new()
	feed.face(state, "gunsmith", "brass-someday")
	assert_not_null(state.portrait)
	assert_false(state.portrait_device)
	assert_eq(state.portrait_key, "gunsmith")
	feed.face(state, "rivet", "rivet-line-stopped")
	assert_null(state.portrait)


func test_the_box_paper_clears_the_folded_ghost_card() -> void:
	var card_right: float = GhostFormHud.MARGIN + GhostFormHud.GAP + 24.0 + 4.0  # one chip + rim
	for screen: Vector2 in [Vector2(1920, 1080), Vector2(1728, 1080)]:
		var paper_left: float = HudDialogue.box_of(screen).position.x - 10.0
		assert_gt(paper_left, card_right, "the paper starts right of the card at %s" % screen)
		assert_almost_eq(HudDialogue.box_of(screen).get_center().x, screen.x * 0.5, 0.01)
