extends GutTest
## features/souls GhostChipNumber and the layout's number_size: the key number on a deploy chip.


func test_chip_number_is_much_larger_than_the_old_label_and_fits_the_chip_cell() -> void:
	var full: GhostFormLayout = GhostFormLayout.new()
	var small: GhostFormLayout = GhostFormLayout.compact()
	assert_gte(full.number_size, 28, "desktop chip number is well above the old 18 px label")
	assert_gte(small.number_size, 22)
	assert_lt(small.number_size, full.number_size)
	var font: Font = ThemeDB.fallback_font
	var plate: Rect2 = GhostChipNumber.plate(font, Vector2.ZERO, "4", full.number_size)
	assert_lt(plate.size.y, full.chip_r * 2.0, "the plate is shorter than the avatar is tall")
	assert_lt(plate.size.x, full.gap * 0.6, "the plate stays inside the chip's cell")


func test_plate_size_and_centre_follow_the_label_exactly() -> void:
	var font: Font = ThemeDB.fallback_font
	var size: int = 28
	var at: Vector2 = Vector2(100.0, 50.0)
	var h: float = font.get_height(size)
	var w: float = font.get_string_size("4", HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var plate: Rect2 = GhostChipNumber.plate(font, at, "4", size)
	assert_almost_eq(plate.size.x, maxf(w, h * 0.62) + GhostChipNumber.PAD * 2.0, 0.01)
	assert_almost_eq(plate.size.y, h * 0.62 + GhostChipNumber.PAD * 2.0, 0.01)
	assert_almost_eq(plate.get_center().x, at.x, 0.01)
	assert_almost_eq(plate.get_center().y, at.y, 0.01)
	var wide: Rect2 = GhostChipNumber.plate(font, at, "BACKSPACE", size)
	assert_gt(wide.size.x, plate.size.x, "a long key name widens the plate")
	assert_almost_eq(wide.size.y, plate.size.y, 0.01, "height does not depend on the label")


func test_every_number_plate_lies_inside_the_strip_and_off_the_screen_edge() -> void:
	var font: Font = ThemeDB.fallback_font
	var full: GhostFormLayout = GhostFormLayout.new()
	full.gap = 72.0  # GhostFormHud._ready's desktop gap
	for l: GhostFormLayout in [full, GhostFormLayout.compact()]:
		var view_h: float = 1080.0
		var top: Vector2 = Vector2(l.margin, view_h - l.margin - l.card_h)
		var strip: Rect2 = Rect2(top, Vector2(l.card_w(4), l.card_h))
		strip = strip.grow(GhostChipNumber.STRIP_GROW)
		for slot: int in 4:
			var label: String = str(slot + 1)
			var at: Vector2 = GhostChipNumber.anchor(l, view_h, slot, label)
			var rect: Rect2 = GhostChipNumber.plate(font, at, label, l.number_size)
			assert_gte(rect.position.x, 8.0, "slot %d: 8 px off the screen edge" % slot)
			assert_true(strip.encloses(rect), "slot %d: %s inside %s" % [slot, rect, strip])


func _layouts() -> Array[GhostFormLayout]:
	var full: GhostFormLayout = GhostFormLayout.new()
	full.gap = 72.0
	return [full, GhostFormLayout.compact()]


func test_unclamped_plate_sits_at_the_chip_centre_plus_the_rim_offset() -> void:
	for l: GhostFormLayout in _layouts():
		for slot: int in [1, 2, 3]:
			var c: Vector2 = l.chip_center(1080.0, slot)
			var at: Vector2 = GhostChipNumber.anchor(l, 1080.0, slot, str(slot + 1))
			var want: Vector2 = c + Vector2(-1.2, 1.15) * l.chip_r
			assert_almost_eq(at.x, want.x, 0.01, "slot %d x" % slot)
			assert_almost_eq(at.y, want.y, 0.01, "slot %d y" % slot)
			assert_gt(at.y, c.y, "slot %d: plate below the chip centre" % slot)
			assert_lt(at.x, c.x, "slot %d: plate left of the chip centre" % slot)


func test_first_slot_plate_is_pushed_right_to_the_minimum_x_only() -> void:
	var font: Font = ThemeDB.fallback_font
	for l: GhostFormLayout in _layouts():
		var c: Vector2 = l.chip_center(1080.0, 0)
		var at: Vector2 = GhostChipNumber.anchor(l, 1080.0, 0, "1")
		var rect: Rect2 = GhostChipNumber.plate(font, at, "1", l.number_size)
		assert_almost_eq(rect.position.x, l.number_min_x(), 0.5, "left edge on the minimum")
		assert_almost_eq(at.y, c.y + 1.15 * l.chip_r, 0.01, "y is not clamped")


func test_adjacent_number_plates_keep_a_gap_and_the_first_clears_the_minimum() -> void:
	var font: Font = ThemeDB.fallback_font
	for l: GhostFormLayout in _layouts():
		for slot: int in 3:
			var a: String = str(slot + 1)
			var b: String = str(slot + 2)
			var ra: Rect2 = GhostChipNumber.plate(
				font, GhostChipNumber.anchor(l, 1080.0, slot, a), a, l.number_size
			)
			var rb: Rect2 = GhostChipNumber.plate(
				font, GhostChipNumber.anchor(l, 1080.0, slot + 1, b), b, l.number_size
			)
			var space: float = rb.position.x - ra.end.x
			assert_gte(
				space, 8.0, "gap %d: plates %s and %s are %.1f px apart" % [slot, a, b, space]
			)
		var first: Rect2 = GhostChipNumber.plate(
			font, GhostChipNumber.anchor(l, 1080.0, 0, "1"), "1", l.number_size
		)
		assert_gte(first.position.x, l.number_min_x() - 0.01, "plate 1 clears the minimum x")
