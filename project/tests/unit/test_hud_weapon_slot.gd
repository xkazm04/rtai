extends GutTest
## n17 rivet-strike: the bottom-right weapon slot (HudWeaponSlot): where it sits, that it clears
## the subtitle paper while a line is up, its count and its name size.

const SCREEN: Vector2 = Vector2(1280.0, 800.0)


func test_slot_sits_in_the_bottom_right_corner() -> void:
	var box: Rect2 = HudWeaponSlot.box_of(SCREEN, false)
	assert_almost_eq(box.end.x, SCREEN.x - HudView.MARGIN, 0.01)
	assert_almost_eq(box.end.y, SCREEN.y - HudView.MARGIN, 0.01)
	assert_eq(box.size.x, HudWeaponSlot.W)


func test_slot_paper_clears_the_subtitle_paper_while_a_line_is_up() -> void:
	var paper: Rect2 = HudView.paper_of(HudWeaponSlot.box_of(SCREEN, true))
	var sub_top: float = HudView.subtitle_top(SCREEN.y)
	assert_true(paper.end.y <= sub_top - HudWeaponSlot.GAP + 0.01, "paper %s" % paper)
	var line: Rect2 = HudDialogue.box_of(SCREEN)
	assert_false(paper.intersects(HudView.paper_of(line)), "slot over the subtitle")


func test_slot_paper_stays_on_screen_at_both_sizes() -> void:
	for screen: Vector2 in [SCREEN, Vector2(1422.0, 800.0)]:
		for up: bool in [false, true]:
			var paper: Rect2 = HudView.paper_of(HudWeaponSlot.box_of(screen, up))
			assert_true(Rect2(Vector2.ZERO, screen).encloses(paper), "%s %s" % [screen, paper])


func test_count_only_where_the_weapon_has_a_magazine() -> void:
	assert_eq(HudWeaponSlot.count_text(12), "x12")
	assert_eq(HudWeaponSlot.count_text(0), "x0")
	assert_eq(HudWeaponSlot.count_text(-1), "")


func test_long_name_steps_down_to_fit() -> void:
	var big: int = HudWeaponSlot.NAME_SIZES[0]
	assert_eq(HudWeaponSlot.name_size("PISTOL", 200.0), big)
	var long_size: int = HudWeaponSlot.name_size("ROCKET LAUNCHER", 150.0)
	assert_lt(long_size, big)


func test_icon_fits_its_band_with_aspect_kept() -> void:
	var img: Image = Image.create(400, 100, false, Image.FORMAT_RGBA8)
	var t: ImageTexture = ImageTexture.create_from_image(img)
	var box: Rect2 = HudWeaponSlot.box_of(SCREEN, false)
	var r: Rect2 = HudWeaponSlot.icon_rect(box, t)
	assert_almost_eq(r.size.x / r.size.y, 4.0, 0.01)
	assert_true(box.encloses(r), "icon %s in %s" % [r, box])


func test_off_flag_is_a_known_launch_flag() -> void:
	assert_true(LaunchArgs.KNOWN_FLAGS.has("--hud-weapon"))
