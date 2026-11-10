extends GutTest
## The owner's note (2026-11-09): "the size gets increased comparing to original character sizes".
## Every lying pose, near rig, far crowd and quest 1 alike, is drawn at about the height the person
## stood: its longest side is measured against the standing card's height.

## A folded body (pose E) is a bundle: short on purpose.
const MIN_K: float = 0.55
const MAX_K: float = 1.08
## it19: a chest-down or lying in-between reaches its arms past the head, so its longest side may
## pass the standing height (tools/art/street_fall_between.py LONG_CAP 1.5).
const MAX_LANDED_K: float = 1.55
## it20: the riot cop's shield lies past his hands (street_fall_between.py LONG_CAP_OF 1.7).
const MAX_SHIELD_K: float = 1.75
## it20: a lying row's drawing scale against the knees cell: the riot side row was 0.55 (its shield
## hit the length cap); 0.6 is what half a riot cell allows that row.
const MIN_LYING_THICK: float = 0.6
## it19: the drawing scale (body thickness) of the chest-down cell against the knees cell above it.
const MIN_THICK: float = 0.8
const MAX_THICK: float = 1.15


func _longest_px(strip: Image, cell: Rect2i) -> int:
	var used: Vector2i = strip.get_region(cell).get_used_rect().size
	return maxi(used.x, used.y)


func _strip(path: String) -> Image:
	var tex: Texture2D = load(path) as Texture2D
	var img: Image = tex.get_image()
	if img.is_compressed():
		assert_eq(img.decompress(), OK)
	return img


func _assert_row(path: String, cols: int, rows: int) -> void:
	var img: Image = _strip(path)
	var cw: int = img.get_width() / cols
	var ch: int = img.get_height() / rows
	for r: int in rows:
		for c: int in cols:
			var px: int = _longest_px(img, Rect2i(c * cw, r * ch, cw, ch))
			if px == 0:
				continue
			var k: float = px * StreetDeadPlan.LYING_K / StreetWalkerFall.STILL_PX
			assert_true(
				k >= MIN_K and k <= MAX_K, "%s (%d,%d) lies %.2f x standing" % [path, c, r, k]
			)


func test_every_plan_pose_lies_at_about_the_standing_height() -> void:
	for row: String in StreetDeadPlan.CLASS_OF:
		_assert_row(StreetDeadPlan.path_of(row), StreetDeadPlan.POSES, 1)


func test_quest_contractors_lie_at_about_the_standing_height() -> void:
	_assert_row(StreetQuestDeadPlan.PATH, StreetDeadPlan.POSES, 1)


func test_poses_drawn_for_the_camera_lie_at_about_the_standing_height() -> void:
	for cls: String in StreetDead70.CLASSES:
		_assert_row(StreetDead70.DIR + cls + ".png", StreetDead70.COLS, StreetDead70.ROWS)


func _thickness(strip: Image, cell: Rect2i) -> float:
	# The drawing scale's proxy: the 95th percentile of a 3-4 chamfer distance to the outline, on
	# every second pixel of the figure's box.
	var img: Image = strip.get_region(cell)
	var box: Rect2i = img.get_used_rect()
	var w: int = box.size.x / 2 + 2
	var h: int = box.size.y / 2 + 2
	var d: PackedInt32Array = PackedInt32Array()
	assert_eq(d.resize(w * h), OK)
	for y: int in range(1, h - 1):
		for x: int in range(1, w - 1):
			var px: Vector2i = box.position + Vector2i(x - 1, y - 1) * 2
			if img.get_pixelv(px).a > 0.5:
				d[y * w + x] = 1 << 20
	for y: int in range(1, h - 1):
		for x: int in range(1, w - 1):
			var i: int = y * w + x
			if d[i] > 0:
				d[i] = mini(
					d[i],
					mini(mini(d[i - 1] + 3, d[i - w] + 3), mini(d[i - w - 1], d[i - w + 1]) + 4)
				)
	var vals: PackedInt32Array = PackedInt32Array()
	var n: int = 0
	assert_eq(vals.resize(w * h), OK)
	for y: int in range(h - 2, 0, -1):
		for x: int in range(w - 2, 0, -1):
			var i: int = y * w + x
			if d[i] > 0:
				d[i] = mini(
					d[i],
					mini(mini(d[i + 1] + 3, d[i + w] + 3), mini(d[i + w - 1], d[i + w + 1]) + 4)
				)
				vals[n] = d[i]
				n += 1
	vals = vals.slice(0, n)
	vals.sort()
	return vals[int(n * 0.95)] / 3.0 * 2.0


func test_the_in_between_grids_land_and_lie_at_about_the_standing_height() -> void:
	# n11 it18: the patrol cop's chest-down cell was drawn 1.9 x standing, its lying row 2.2 x, and
	# a body that fell through them lies in that row at the card's own scale (no LYING_K).
	for src: String in StreetFallBetween.GRIDS:
		var img: Image = _strip(StreetWalkerCards.DIR + StreetFallBetween.GRIDS[src])
		var cw: int = img.get_width() / 5
		var ch: int = img.get_height() / StreetFallBetween.FRAMES
		for r: int in [2, 3, 4]:
			for c: int in 5:
				var k: float = (
					_longest_px(img, Rect2i(c * cw, r * ch, cw, ch)) / StreetWalkerFall.STILL_PX
				)
				var top: float = MAX_K if r == 2 else MAX_LANDED_K
				top = MAX_SHIELD_K if r > 2 and src.contains("riot") else top
				assert_true(k >= MIN_K and k <= top, "(%d,%d) lies %.2f x standing" % [c, r, k])


func test_the_body_keeps_its_drawing_scale_as_it_lands() -> void:
	# n11 it19: the it18 length cap shrank the arms-forward chest-down cell to about 0.6 x the
	# knees cell's scale: the head and torso visibly smaller the moment the body landed.
	for src: String in StreetFallBetween.GRIDS:
		var path: String = StreetFallBetween.GRIDS[src]
		var img: Image = _strip(StreetWalkerCards.DIR + path)
		var cw: int = img.get_width() / 5
		var ch: int = img.get_height() / StreetFallBetween.FRAMES
		for c: int in 5:
			var knees: float = _thickness(img, Rect2i(c * cw, 2 * ch, cw, ch))
			var k: float = _thickness(img, Rect2i(c * cw, 3 * ch, cw, ch)) / knees
			assert_true(
				k >= MIN_THICK and k <= MAX_THICK, "%s col %d lands at %.2f x" % [path, c, k]
			)


func test_a_body_lies_at_most_a_little_smaller_than_he_knelt() -> void:
	for src: String in StreetFallBetween.GRIDS:
		var path: String = StreetFallBetween.GRIDS[src]
		var img: Image = _strip(StreetWalkerCards.DIR + path)
		var cw: int = img.get_width() / 5
		var ch: int = img.get_height() / StreetFallBetween.FRAMES
		for c: int in 5:
			var knees: float = _thickness(img, Rect2i(c * cw, 2 * ch, cw, ch))
			var k: float = _thickness(img, Rect2i(c * cw, 4 * ch, cw, ch)) / knees
			assert_true(
				k >= MIN_LYING_THICK and k <= MAX_THICK, "%s col %d lies at %.2f x" % [path, c, k]
			)


func test_no_fall_cell_is_cut_at_its_cell_edge() -> void:
	# n11 it20: the SWAT's head-to-camera lying row ran 5 px past the sheet's foot (gloves cut flat)
	for src: String in StreetFallBetween.GRIDS:
		var path: String = StreetFallBetween.GRIDS[src]
		var img: Image = _strip(StreetWalkerCards.DIR + path)
		var cw: int = img.get_width() / 5
		var ch: int = img.get_height() / StreetFallBetween.FRAMES
		for r: int in [2, 3, 4]:
			for c: int in 5:
				var used: Rect2i = img.get_region(Rect2i(c * cw, r * ch, cw, ch)).get_used_rect()
				var gap: int = mini(mini(used.position.x, used.position.y), cw - used.end.x)
				gap = mini(gap, ch - used.end.y)
				assert_gt(gap, 0, "%s (%d,%d) touches its cell edge" % [path, c, r])
