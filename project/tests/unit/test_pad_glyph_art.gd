extends GutTest
## features/pad_glyphs PadGlyphArt: the bracketed pad names in a prompt become atlas regions;
## anything else stays text, and the BBCode escapes the words' brackets.


func test_every_pad_label_has_a_cell_in_the_atlas() -> void:
	for pad_label: String in PadGlyphArt.CELL:
		assert_true(PadGlyphArt.region(pad_label).has_area(), pad_label)


func test_runs_split_text_and_glyphs() -> void:
	var r: Array = PadGlyphArt.runs("Hide: [A] now [mouse]")
	assert_eq(r.size(), 3)
	assert_eq(str(r[0]), "Hide: ")
	assert_true(r[1] is Rect2)
	assert_eq(str(r[2]), " now [mouse]")


func test_bbcode_escapes_plain_brackets() -> void:
	var b: String = PadGlyphArt.bbcode("[RT] fires [x2]", 30)
	assert_true(b.begins_with("[img region="))
	assert_true(b.contains("[lb]x2]"))


func test_desktop_draws_no_glyphs() -> void:
	assert_false(DeviceProfile.of("").is_handheld())
	assert_true(DeviceProfile.of("deck").is_handheld())


func test_the_atlas_loads() -> void:
	assert_not_null(PadGlyphArt.texture())


func test_action_hint_names_the_bound_pad_button() -> void:
	PlayerActions.shipped().install()
	assert_eq(PadGlyphArt.action_hint(&"power_hauler", "Q"), "[LB]")
	assert_eq(PadGlyphArt.action_hint(&"no_such_action", "Q"), "Q")


func test_a_shoulder_bar_draws_wider_not_shorter() -> void:
	var g: float = 30.0
	var face: Vector2 = PadGlyphArt.fit(PadGlyphArt.region("A"), g)
	var bar: Vector2 = PadGlyphArt.fit(PadGlyphArt.region("LB"), g)
	assert_almost_eq(face.y, g, 0.5)
	assert_almost_eq(bar.x, g * PadGlyphArt.WIDE_K, 0.5)
	assert_gt(bar.y, g * 0.75)  # was 0.48 g inside the square cell


## n9 it4: every family's own menu marks (the asset lane's appendix, it127): the Nintendo-layout
## "+" / "-" and the PlayStation Create draw their own cells, never the Xbox View / Menu.
func test_each_family_draws_its_own_menu_marks() -> void:
	var own: Dictionary[String, String] = {
		"+": "pad_plus", "-": "pad_minus", "Create": "pad_create"
	}
	for pad_label: String in own:
		assert_eq(GlyphCells.PAD_CELL[pad_label], own[pad_label], pad_label)
		var r: Rect2 = PadGlyphArt.region(pad_label, GlyphCells.PAD)
		assert_true(r.has_area(), pad_label)
		assert_ne(
			r, PadGlyphArt.region("Start", GlyphCells.PAD), pad_label + " is not the Menu mark"
		)
		assert_ne(
			r, PadGlyphArt.region("Back", GlyphCells.PAD), pad_label + " is not the View mark"
		)
