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
	assert_null(book.face("lady-cathode"))
	assert_null(book.face("nobody"))


func test_rivet_speaks_with_his_approved_bust() -> void:
	var book: PortraitBook = PortraitBook.new()
	assert_not_null(book.face("rivet"))
	assert_false(book.is_device("rivet"))
	var mood: Texture2D = book.face("rivet", "rivet-feels-good")
	assert_not_null(mood)
	assert_ne(book.face("rivet", "rivet-who-is-this"), mood)


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
	feed.face(state, "lady-cathode", "")
	assert_null(state.portrait)


func test_the_box_paper_clears_the_folded_ghost_card() -> void:
	var one_chip: Rect2 = Rect2(GhostFormHud.MARGIN, 0.0, GhostFormHud.GAP + 24.0, 158.0)
	var card_right: float = GhostFormHud.paper_of(one_chip).end.x  # the folded card's paper
	for screen: Vector2 in [Vector2(1920, 1080), Vector2(1728, 1080)]:
		var paper_left: float = HudDialogue.box_of(screen).position.x - 10.0
		assert_gt(paper_left, card_right, "the paper starts right of the card at %s" % screen)
		assert_almost_eq(HudDialogue.box_of(screen).get_center().x, screen.x * 0.5, 0.01)


func test_the_box_fits_its_line_between_the_min_and_the_full_height() -> void:
	var font: Font = ThemeDB.fallback_font
	var w: float = 1000.0
	var short: String = "Bring her back."
	var size: int = HudDialogue.fit_size(font, short, w, HudDialogue.BOX_H - HudDialogue.WORDS_TOP)
	assert_eq(size, HudDialogue.FIT_SIZES[0], "a short line keeps the largest size")
	var low: float = HudDialogue.fit_height(font, short, w, size)
	assert_between(low, HudDialogue.BOX_MIN_H, 170.0, "a one-line bark gets the short box")
	var bit: String = "Patch only connects calm customers. Thanks for not being on fire. "
	var long: String = bit.repeat(4)
	size = HudDialogue.fit_size(font, long, w, HudDialogue.BOX_H - HudDialogue.WORDS_TOP)
	var high: float = HudDialogue.fit_height(font, long, w, size)
	assert_eq(high, HudDialogue.BOX_H, "a long line gets the full box")
	assert_lt(HudDialogue.box_of(Vector2(1920, 1080), low).position.y, 1080.0)
	assert_eq(HudDialogue.box_of(Vector2(1920, 1080), low).end.y, 1080.0 - HudView.MARGIN)


func test_the_nurse_wears_no_vermilion() -> void:
	# n8-hud it11: the 1540 cut showed a vermilion chest stripe (reserved: danger, objectives,
	# Rivet's collar, the King's cape); the v3 sheet's stripe is muted plum
	var book: PortraitBook = PortraitBook.new()
	for line: String in ["juno-load-bearing", "juno-real-name"]:
		var img: Image = book.face("nurse", line).get_image()
		if img.is_compressed():
			@warning_ignore("return_value_discarded")
			img.decompress()
		var hot: int = 0
		for y: int in range(0, img.get_height(), 2):
			for x: int in range(0, img.get_width(), 2):
				var c: Color = img.get_pixel(x, y)
				if c.a > 0.5 and c.s > 0.6 and c.v > 0.5 and (c.h < 0.055 or c.h > 0.97):
					hot += 1
		assert_lt(hot, 60, "%s: %d vermilion px (sampled)" % [line, hot])
