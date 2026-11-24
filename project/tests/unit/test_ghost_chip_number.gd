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
