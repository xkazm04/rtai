extends GutTest


func _label(text: String, px: int) -> Label:
	var l: Label = Label.new()
	l.text = text
	l.add_theme_font_size_override(&"font_size", px)
	return l


func test_glyph_heights_grow_with_the_size_and_cap_is_taller_than_x() -> void:
	var font: Font = ThemeDB.fallback_font
	var small: Dictionary = TextProbe.size_row(font, 16)
	var big: Dictionary = TextProbe.size_row(font, 32)
	var cap: float = small["cap_px"]
	var xh: float = small["x_px"]
	var big_x: float = big["x_px"]
	assert_gt(cap, xh, "cap above x-height")
	assert_gt(big_x, xh * 1.6, "x-height scales with the size")
	assert_between(cap, 16.0 * 0.55, 16.0 * 0.85, "cap of a 16 px sans")


func test_probe_flags_small_text_and_skips_hidden() -> void:
	var root: Control = Control.new()
	add_child_autofree(root)
	root.add_child(_label("Tiny print", 10))
	root.add_child(_label("Headline", 30))
	var hidden: Label = _label("Hidden", 8)
	hidden.visible = false
	root.add_child(hidden)
	root.add_child(_label("  ", 8))
	var rows: Array[Dictionary] = TextProbe.probe(root, 1.0)
	assert_eq(rows.size(), 2, "the hidden and the blank label are skipped")
	assert_eq(str(rows[0]["text"]), "Tiny print", "smallest first")
	assert_eq(str(rows[0]["verdict"]), "below_9")
	assert_eq(str(rows[1]["verdict"]), "ok")


func test_probe_scales_by_the_canvas_transform() -> void:
	var root: Control = Control.new()
	add_child_autofree(root)
	root.scale = Vector2(2.0, 2.0)
	root.add_child(_label("Scaled", 12))
	var rows: Array[Dictionary] = TextProbe.probe(root, 1.0)
	var px: int = rows[0]["font_px"]
	assert_eq(px, 24, "12 px drawn at 2x is 24 window px")
