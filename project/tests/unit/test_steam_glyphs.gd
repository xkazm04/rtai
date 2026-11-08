extends GutTest
## n10-handheld: the swap is one call: a backend that returns a PNG path replaces the drawn glyph,
## and a backend with no path (or a bad one) keeps the drawn set.


class FakeSteam:
	extends NullBackend
	var path: String = ""

	func action_glyph_path(_xbox_label: String) -> String:
		return path


var _fake: FakeSteam
var _png: String = ""


func before_each() -> void:
	_fake = FakeSteam.new()
	_png = TestTmp.dir("steam_glyph").path_join("glyph_a.png")
	assert_eq(Image.create_empty(32, 16, false, Image.FORMAT_RGBA8).save_png(_png), OK)
	assert_true(Platform.use_backend(_fake))


func after_each() -> void:
	assert_true(Platform.use_backend(NullBackend.new()))


func test_no_path_keeps_the_drawn_cell() -> void:
	var out: Array = PadGlyphArt.runs("[A] go")
	assert_true(out[0] is Rect2, "the drawn atlas cell")
	assert_eq(str(out[1]), " go")


func test_a_path_swaps_the_glyph_for_steams_image() -> void:
	_fake.path = _png
	var out: Array = PadGlyphArt.runs("[A] go")
	assert_true(out[0] is Texture2D, "Steam's own glyph")
	var glyph: Texture2D = out[0]
	assert_eq(glyph.get_size(), Vector2(32.0, 16.0))
	assert_gt(PadGlyphArt.line_size("[A]", 24).x, 0.0, "the prompt measures it")


func test_a_label_steam_has_no_cell_for_is_still_its_image() -> void:
	_fake.path = _png
	assert_true(PadGlyphArt.runs("[Paddle]")[0] is Texture2D)


func test_an_unreadable_path_keeps_the_drawn_cell() -> void:
	_fake.path = _png + ".missing"
	assert_true(PadGlyphArt.runs("[A]")[0] is Rect2)


func test_the_rich_text_card_keeps_the_drawn_set() -> void:
	_fake.path = _png
	assert_string_contains(PadGlyphArt.bbcode("[A]", 30), GlyphCells.ATLAS_PNG[GlyphCells.PAD])
