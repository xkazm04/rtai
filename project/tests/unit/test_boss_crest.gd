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


## n8-hud BossBar.paper_of: the banner hangs from above the screen (its torn top and tape off it),
## the name's line sits on clear paper below its top band, and the torn bottom clears the bar.
func test_the_banner_paper_clears_the_name_and_the_bar() -> void:
	var bar: Rect2 = Rect2(Vector2(280.0, BossBar.TOP), Vector2(717.0, BossBar.BAR_H))
	var paper: Rect2 = BossBar.paper_of(bar)
	var name_top: float = BossBar.TOP - 8.0 - 16.0  # the 20 px name's cap line over its baseline
	assert_true(BossBar.PAPER)
	assert_lt(paper.position.y, 0.0, "the torn top hangs above the screen")
	assert_gte(name_top - paper.position.y, 40.0, "the name clears the top band (22 px + tape)")
	assert_gte(paper.end.y - bar.end.y, 28.0, "the torn bottom clears the bar")
	assert_gte(bar.position.x - paper.position.x, 24.0, "the left end under the crest")
	assert_gte(paper.end.x - bar.end.x, 24.0, "the right hatch clears the phase count")
