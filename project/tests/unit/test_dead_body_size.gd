extends GutTest
## The owner's note (2026-11-09): "the size gets increased comparing to original character sizes".
## Every lying pose, near rig, far crowd and quest 1 alike, is drawn at about the height the person
## stood: its longest side is measured against the standing card's height.

## A folded body (pose E) is a bundle: short on purpose.
const MIN_K: float = 0.55
const MAX_K: float = 1.08


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
				assert_true(k >= MIN_K and k <= MAX_K, "(%d,%d) lies %.2f x standing" % [c, r, k])
