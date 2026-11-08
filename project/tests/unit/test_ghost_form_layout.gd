extends GutTest
## features/souls GhostFormLayout: the desktop card keeps its authored sizes; the handheld rows
## (DeviceProfile.hud = compact) get the smaller card with the same legible text size.


func test_desktop_row_keeps_the_authored_card() -> void:
	var l: GhostFormLayout = GhostFormLayout.for_device(DeviceProfile.of(""))
	assert_eq(l.chip_r, GhostFormHud.CHIP_R)
	assert_eq(l.gap, GhostFormHud.GAP)
	assert_eq(l.margin, GhostFormHud.MARGIN)
	assert_eq(l.text_size, GhostFormHud.TEXT_SIZE)
	assert_eq(l.card_h, 158.0)
	assert_true(l.all_names)


func test_every_handheld_row_is_compact() -> void:
	var p: DeviceProfile = DeviceProfile.of("")
	for id: String in p.ids:
		var row: DeviceProfile = DeviceProfile.of(id)
		if id != "deck_hud_full":  # the study row: the before side of the A/B
			assert_eq(row.hud == &"compact", row.is_handheld(), id)


func test_compact_card_is_about_half_the_area_and_keeps_the_text() -> void:
	var full: GhostFormLayout = GhostFormLayout.new()
	var small: GhostFormLayout = GhostFormLayout.for_device(DeviceProfile.of("deck"))
	var a_full: float = full.card_w(5) * full.card_h
	var a_small: float = small.card_w(5) * small.card_h
	assert_lt(a_small, a_full * 0.5)
	assert_eq(small.text_size, full.text_size)  # 18 px: cap ~13 px, above Valve's 9 px floor
	assert_false(small.all_names)


func test_compact_names_only_the_selected_chip() -> void:
	var hud: GhostFormHud = autofree(GhostFormHud.new())
	hud.layout = GhostFormLayout.compact()
	hud.order = [&"tonnage", &"dent"]
	hud.selected = &"dent"
	assert_eq(hud.named_chip(hud.shown_chips()), &"dent")
	hud.selected = &""
	assert_eq(hud.named_chip(hud.shown_chips()), &"tonnage")
