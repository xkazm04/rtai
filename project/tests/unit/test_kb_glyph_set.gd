extends GutTest
## features/pad_glyphs: the keyboard twin (ui_kb_glyphs_v1) draws only on a `glyphs: kb` row; the
## shipped desktop draws none and a handheld row keeps the pad set.

var _saved: DeviceProfile = null


func before_each() -> void:
	_saved = DeviceProfile.shared()


func after_each() -> void:
	DeviceProfile._shared = _saved


func test_the_desktop_draws_no_glyphs() -> void:
	DeviceProfile._shared = DeviceProfile.of("desktop")
	assert_false(PadGlyphArt.active())
	assert_eq(PadGlyphArt.glyph_set(), &"")


func test_the_study_row_is_a_desktop_row_with_kb_glyphs() -> void:
	var p: DeviceProfile = DeviceProfile.of("desktop_kb_glyphs")
	assert_true(p.is_desktop())
	assert_eq(p.glyphs, GlyphCells.KB)
	DeviceProfile._shared = p
	assert_eq(PadGlyphArt.glyph_set(), GlyphCells.KB)


func test_a_handheld_row_keeps_the_pad_set() -> void:
	DeviceProfile._shared = DeviceProfile.of("deck")
	assert_eq(PadGlyphArt.glyph_set(), GlyphCells.PAD)


func test_the_same_label_maps_per_set() -> void:
	var kb: Rect2 = PadGlyphArt.region("A", GlyphCells.KB)
	var pad: Rect2 = PadGlyphArt.region("A", GlyphCells.PAD)
	assert_true(kb.has_area())
	assert_true(pad.has_area())
	assert_ne(kb, pad)


func test_every_key_label_has_a_cell_in_the_atlas() -> void:
	for key_label: String in GlyphCells.KB_CELL:
		assert_true(PadGlyphArt.region(key_label, GlyphCells.KB).has_area(), key_label)


func test_the_shipped_binds_resolve_to_kb_glyphs() -> void:
	PlayerActions.shipped().install()
	DeviceProfile._shared = DeviceProfile.of("desktop_kb_glyphs")
	var line: String = ObjectiveHint.with_keys("[move] [aim] [fire] [melee] [use] [pause]", false)
	for run: Variant in PadGlyphArt.runs(line):
		assert_true(run is Rect2 or str(run).strip_edges() == "", "no glyph for '%s'" % str(run))
	assert_eq(PadGlyphArt.action_hint(&"power_hauler", "Q"), "[Q]")


func test_the_kb_atlas_loads() -> void:
	DeviceProfile._shared = DeviceProfile.of("desktop_kb_glyphs")
	var tex: Texture2D = PadGlyphArt.texture()
	assert_not_null(tex)
	assert_eq(tex.get_width(), 1024)


func test_the_space_bar_draws_near_full_height() -> void:
	DeviceProfile._shared = DeviceProfile.of("desktop_kb_glyphs")
	var g: float = 30.0
	var space: Vector2 = PadGlyphArt.fit(PadGlyphArt.region("Space"), g)
	assert_almost_eq(space.x, g * PadGlyphArt.KB_WIDE_K, 0.5)
	assert_gt(space.y, g * 0.8)  # was 0.55 g at the pad set's 1.5 cap
