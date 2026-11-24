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
