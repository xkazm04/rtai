extends GutTest
## features/hud: art by id from data/tables/hud_art.json, a placeholder for an unknown id (a later
## art landing must not break the HUD), and the HUD's number formatting.


func test_every_row_loads_at_its_authored_size() -> void:
	var art: HudArt = HudArt.new()
	for id: StringName in [&"ammo_ticket", &"cash_frame", &"hud_digits", &"memo_frame"]:
		assert_true(art.has(id), "table has %s" % id)
		var tex: Texture2D = art.texture(id)
		assert_eq(Vector2(tex.get_size()), art.size_px(id), "%s size" % id)


func test_the_pips_are_police_and_empty() -> void:
	var art: HudArt = HudArt.new()
	assert_true(art.has(&"wanted_pip_police"))
	assert_true(art.has(&"wanted_pip_empty"))
	assert_gt(art.texture(&"wanted_pip_police").get_width(), 4)


func test_unknown_id_draws_a_placeholder() -> void:
	var art: HudArt = HudArt.new()
	var tex: Texture2D = art.texture(&"no_such_frame")
	assert_not_null(tex)
	assert_eq(tex.get_size(), Vector2(4, 4))


func test_digit_metrics_match_the_strip() -> void:
	var art: HudArt = HudArt.new()
	assert_eq(art.advance_px.size(), art.glyphs.length())
	var strip: Vector2 = art.size_px(art.digits_art)
	assert_eq(strip.x, art.cell_px.x * art.glyphs.length())
	assert_eq(strip.y, art.cell_px.y)


func test_cash_is_grouped_in_thousands() -> void:
	assert_eq(HudView.thousands(0), "0")
	assert_eq(HudView.thousands(1500), "1,500")
	assert_eq(HudView.thousands(1234567), "1,234,567")


func test_state_silent_hides_the_subtitle() -> void:
	var s: HudState = HudState.new()
	s.say("Patch", "Line one.")
	assert_eq(s.speaker, "Patch")
	s.silent()
	assert_eq(s.speaker, "")
	assert_eq(s.words, "")


## n8-hud: red is only for blood. The panels HudView draws carry no signal red (the ammo ticket's
## bullet was red until it was re-hued to brass by tools/art/hud_recolor.py).
func test_the_drawn_panels_carry_no_red() -> void:
	var art: HudArt = HudArt.new()
	for id: StringName in [&"ammo_ticket", &"cash_frame", &"memo_frame", &"wanted_pip_police"]:
		var img: Image = art.texture(id).get_image()
		if img.is_compressed():
			@warning_ignore("return_value_discarded")
			img.decompress()
		var red: int = 0
		for y: int in range(0, img.get_height(), 2):
			for x: int in range(0, img.get_width(), 2):
				var c: Color = img.get_pixel(x, y)
				var hue_off: float = minf(c.h, 1.0 - c.h)
				if c.a > 0.5 and c.s > 0.45 and c.v > 0.35 and hue_off < 0.04:
					red += 1
		assert_lt(red, 40, "%s has %d red px (sampled)" % [id, red])
