extends GutTest
## n8-hud ObjectiveView.prompt_paper: quest 1's control prompt sits on the HUD's memo paper with
## room round its words for the torn hatch (left, right, bottom) and the tape (top), on screen.


func test_the_paper_clears_the_words() -> void:
	var font: Font = ThemeDB.fallback_font
	var words: String = "Stay hidden. Let the sirens pass. [Escape] pauses."
	var size: Vector2 = font.get_string_size(
		words, HORIZONTAL_ALIGNMENT_LEFT, -1, ObjectiveView.TEXT_SIZE
	)
	var at: Vector2 = Vector2(48.0, 186.0)
	var paper: Rect2 = ObjectiveView.prompt_paper(at, size)
	var top: float = at.y - size.y * 0.75
	assert_gte(at.x - paper.position.x, 24.0, "the left hatch clears the first letter")
	assert_gte(paper.end.x - (at.x + size.x), 40.0, "the right hatch clears the last letter")
	assert_gte(top - paper.position.y, 28.0, "the tape sits above the words")
	assert_gte(paper.end.y - (top + size.y), 20.0, "the bottom hatch clears the descenders")
	assert_gte(paper.position.x, 0.0, "on screen")
	assert_true(ObjectiveView.PAPER, "the paper is the default")
