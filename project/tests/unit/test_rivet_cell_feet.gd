extends GutTest
## n17 rivet-strike: RivetCellFeet seats a strike cell whose swing hangs below the boots on the
## boots (the katana's side strike), every other cell on the strip's pad; off = the before.

const KATANA: String = "res://features/characters/art/view/p70/rivet_eq_katana.png"


func after_each() -> void:
	RivetCellFeet.enabled = true


func _card() -> Sprite2D:
	var card: Sprite2D = autofree(Sprite2D.new())
	card.texture = load(KATANA) as Texture2D
	card.hframes = RivetFrames.EQ_CELLS
	card.set_meta(RivetFrames.ON, KATANA)
	return card


func test_side_strike_stands_on_its_boots() -> void:
	var card: Sprite2D = _card()
	var h: float = card.texture.get_height()
	RivetCellFeet.show(card, RivetFrames.Eq.FIRE_SIDE)
	assert_eq(card.frame, RivetFrames.Eq.FIRE_SIDE)
	assert_almost_eq(card.offset.y, 31.0 - h, 0.01, "the boots on the foot line, not the arc")
	RivetCellFeet.show(card, 2)
	var pad: float = RivetStrips.foot_px(KATANA)
	assert_almost_eq(card.offset.y, pad - h, 0.01, "a facing cell back on the strip's pad")


func test_off_keeps_the_strip_pad() -> void:
	RivetCellFeet.enabled = false
	var card: Sprite2D = _card()
	RivetCellFeet.show(card, RivetFrames.Eq.FIRE_SIDE)
	var pad: float = RivetStrips.foot_px(KATANA)
	assert_almost_eq(card.offset.y, pad - card.texture.get_height(), 0.01)
	assert_almost_eq(RivetCellFeet.foot_of(KATANA, RivetFrames.Eq.FIRE_SIDE), pad, 0.01)


func test_listed_cells_sit_above_the_pad_inside_the_cell() -> void:
	for key: String in RivetCellFeet.FEET:
		var tex: Texture2D = load(RivetStrips.DIR + key.get_slice(":", 0)) as Texture2D
		assert_not_null(tex, key)
		var cell: int = key.get_slice(":", 1).to_int()
		assert_between(cell, 5, 6, "%s: a strike cell" % key)
		assert_between(RivetCellFeet.FEET[key], 2.0, tex.get_height() * 0.5, key)


func test_the_boots_measure_is_the_drawn_one() -> void:
	# the katana side strike's lower boot: its lowest opaque pixel left of the swing arc (x < 230)
	var img: Image = (load(KATANA) as Texture2D).get_image()
	if img.is_compressed():
		assert_eq(img.decompress(), OK)
	var cw: int = img.get_width() / RivetFrames.EQ_CELLS
	var low: int = 0
	for y: int in 235:
		for x: int in range(180, 230):
			if img.get_pixel(cw * 5 + x, y).a > 0.5:
				low = maxi(low, y)
	var foot: float = RivetCellFeet.FEET["p70/rivet_eq_katana.png:5"]
	assert_almost_eq(float(img.get_height() - 1 - low), foot, 1.0)


func test_a_gun_camera_fire_cell_stands_on_its_boots_not_its_flash() -> void:
	# n17 DEFECTS #14: the pistol's camera fire cell had its painted flash on the foot line
	var path: String = RivetStrips.DIR + "p70/rivet_eq_pistol.png"
	var card: Sprite2D = autofree(Sprite2D.new())
	card.texture = load(path) as Texture2D
	card.hframes = RivetFrames.EQ_CELLS
	card.set_meta(RivetFrames.ON, path)
	var h: float = card.texture.get_height()
	RivetCellFeet.show(card, RivetFrames.Eq.FIRE_CAM)
	assert_almost_eq(card.offset.y, 38.0 - h, 0.01, "the boots on the foot line")
	RivetCellFeet.show(card, RivetFrames.Eq.FIRE_SIDE)
	assert_almost_eq(card.offset.y, RivetStrips.foot_px(path) - h, 0.01, "the side cell: the pad")
