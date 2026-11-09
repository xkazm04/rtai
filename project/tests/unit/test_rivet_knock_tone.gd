extends GutTest
## n10 rivet: the lying cells of one throw row keep one tone. The p70 left row's down cell drew
## L 93 beside 80-82, a pale Rivet for all of his lying time (combo, a left throw, t270-276).

const STRIPS: Array[String] = ["p70/rivet_knock.png", "p55/rivet_knock.png"]
const MAX_SPREAD: float = 8.0  # opaque mean luminance, 0-255, across tumble / slide / down


func _mean_l(img: Image, rect: Rect2i) -> float:
	var sum: float = 0.0
	var n: int = 0
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			var c: Color = img.get_pixel(x, y)
			if c.a > 0.78:
				sum += 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
				n += 1
	return 255.0 * sum / maxf(1.0, n)


func test_a_throw_rows_lying_cells_keep_one_tone() -> void:
	for rel: String in STRIPS:
		var path: String = ProjectSettings.globalize_path(RivetStrips.DIR + rel)
		var img: Image = Image.load_from_file(path)
		img.convert(Image.FORMAT_RGBA8)
		@warning_ignore("integer_division")
		var cell: int = img.get_width() / RivetKnock.COLS
		for row: int in RivetKnock.CELLS:
			var ls: Array[float] = []
			for col: int in range(1, RivetKnock.CELLS):
				ls.append(_mean_l(img, Rect2i(col * cell, row * cell, cell, cell)))
			var spread: float = ls.max() - ls.min()
			assert_lt(spread, MAX_SPREAD, "%s row %d: %s" % [rel, row, str(ls)])
