extends GutTest
## n8-hud BossTaunt: the boss's taunt strip under the boss bar (fade, fit, placement).

const SCREEN: Vector2 = Vector2(1280, 800)


func test_fades_in_over_enter_and_out_over_exit() -> void:
	var t: BossTaunt = BossTaunt.new()
	t.words = "Bow."
	t.step(BossTaunt.ENTER_S * 0.5)
	assert_almost_eq(t.alpha(), 0.5, 0.01)
	t.step(BossTaunt.ENTER_S)
	assert_eq(t.alpha(), 1.0)
	t.words = ""
	t.step(BossTaunt.EXIT_S * 0.5)
	assert_almost_eq(t.alpha(), 0.5, 0.01)
	t.step(BossTaunt.EXIT_S)
	assert_eq(t.alpha(), 0.0)
	t.free()


func test_a_new_line_keeps_the_strip_up() -> void:
	var t: BossTaunt = BossTaunt.new()
	t.words = "Hear ye."
	t.step(1.0)
	t.words = "Bow."
	t.step(SimClock.TICK_DT)
	assert_eq(t.alpha(), 1.0, "a second line swaps the words, no blink")
	t.free()


func test_strip_hangs_under_the_bar_as_wide_as_it() -> void:
	var r: Rect2 = BossTaunt.strip_rect(SCREEN, 2, 22)
	assert_gt(r.position.y, BossBar.TOP + BossBar.BAR_H)
	assert_almost_eq(r.size.x, SCREEN.x * BossBar.WIDTH_K, 0.01)
	assert_almost_eq(r.get_center().x, SCREEN.x * 0.5, 0.01)
	assert_lt(r.end.y, SCREEN.y * 0.25, "the strip keeps to the top quarter: the field stays clear")


func test_fit_takes_the_largest_size_within_two_lines() -> void:
	var font: Font = ThemeDB.fallback_font
	var short: Vector2i = BossTaunt.fit(font, "Bow.", 600.0)
	assert_eq(short, Vector2i(BossTaunt.FIT_SIZES[0], 1))
	var long: String = "Hear ye. The Crown has decreed that this street is royal. ".repeat(3)
	var f: Vector2i = BossTaunt.fit(font, long, 600.0)
	assert_lte(f.y, BossTaunt.MAX_LINES)
	assert_lt(f.x, BossTaunt.FIT_SIZES[0])
