extends GutTest
## n8-hud: each boss has a crest for the boss bar (its PortraitBook face), cut from the shipped
## approved p55 card; a boss without a row draws no crest.


func test_every_boss_has_a_crest() -> void:
	var book: PortraitBook = PortraitBook.new()
	for id: String in ["king", "servo"]:
		var face: Texture2D = book.face(id)
		assert_not_null(face, "%s has no crest" % id)
		if face != null:
			assert_gt(face.get_height(), 64, "%s crest is too small to read" % id)


func test_the_gang_has_no_crest() -> void:
	assert_null(PortraitBook.new().face("king_gang"))


func test_the_crest_sits_left_of_the_bar() -> void:
	var w: float = 1280.0 * BossBar.WIDTH_K
	var bar_x: float = (1280.0 - w) * 0.5
	assert_gt(bar_x - BossBar.CREST_GAP - BossBar.CREST_R * 2.0, 0.0, "the crest leaves the screen")
