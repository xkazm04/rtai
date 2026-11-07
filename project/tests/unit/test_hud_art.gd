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


func test_the_beat_panel_fits_its_words_and_pips() -> void:
	var short: float = HudView.beat_width("4/6  Get Gloria back", 3)
	var long: float = HudView.beat_width("5/6  Rated for Appliances, then the docks and home", 3)
	assert_lt(short, 420.0, "a short head leaves the field: %.0f" % short)
	assert_gt(long, short, "a longer head widens the paper")
	assert_lte(long, HudView.BEAT_MAX_W)
	var pips_only: float = HudView.beat_width("", 5)
	assert_gte(pips_only, 110.0 + 4 * 46.0 + 38.0, "five pips fit on the paper")


func test_the_cash_frame_fits_its_sum() -> void:
	var art: HudArt = HudArt.new()
	var small: float = HudCash.width(art, "$12,450", "")
	var big: float = HudCash.width(art, "$1,234,567", "")
	assert_between(small, HudCash.MIN_W, 320.0, "a five-digit sum leaves the field: %.0f" % small)
	assert_gt(big, small, "a longer sum widens the frame")
	assert_lte(big, HudCash.W)
	var digits: float = HudCash.digits_w(art, "$1,234,567", 32.0)
	assert_gte(big, HudCash.TEXT_X + digits, "the sum stays on the paper")


func test_the_icon_shadow_stays_off_the_ticket() -> void:
	# the icon's box ends 8 px left of the ticket: a wider offset would print ink on the paper
	assert_between(HudView.ICON_SHADOW.x, 0.0, 8.0)
	assert_between(HudView.ICON_SHADOW_A, 0.0, 1.0)


func test_the_icon_sits_on_the_ticket_clear_of_the_words() -> void:
	# view's quest 1 note: the bare icon on the street read as a floor pickup; on the paper it is HUD
	var art: HudArt = HudArt.new()
	var showcase: WeaponShowcase = WeaponShowcase.new()
	for id: StringName in [&"gloria", &"rocket_launcher", &"molotov"]:
		var icon: Texture2D = showcase.texture(id, WeaponShowcase.ICON)
		assert_not_null(icon, "%s has an icon" % id)
		var state: HudState = HudState.new()
		state.weapon = String(id).replace("_", " ")
		state.ammo = 12
		var words: float = HudTicket.words_w(art, state, HudView.WEAPON_SIZE)
		var w: float = HudTicket.width(art, words, icon)
		assert_gte(w, HudTicket.W, "%s: never narrower than the drawn ticket" % id)
		var box: Rect2 = Rect2(1000.0 - w, 140.0, w, HudTicket.H)
		var r: Rect2 = HudTicket.icon_rect(box, icon)
		assert_true(box.encloses(r), "%s: the icon on the paper" % id)
		var words_end: float = box.position.x + HudTicket.text_x(art) + words
		assert_gte(r.position.x, words_end + HudTicket.GAP - 0.5, "%s: clear of the name" % id)
		assert_lte(r.end.x, box.end.x - 20.0, "%s: clear of the torn end's hatch" % id)
