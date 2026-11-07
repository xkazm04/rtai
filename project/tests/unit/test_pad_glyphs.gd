extends GutTest


func test_family_reads_the_vendor_then_the_name() -> void:
	assert_eq(PadGlyphs.family({"vendor_id": 0x054C}, "Wireless Controller"), &"playstation")
	assert_eq(PadGlyphs.family({}, "PS5 Controller"), &"playstation")
	assert_eq(PadGlyphs.family({"vendor_id": 0x057E}, "Pro Controller"), &"nintendo")
	assert_eq(PadGlyphs.family({"vendor_id": 0x045E}, "Xbox Series Controller"), &"xbox")
	assert_eq(PadGlyphs.family({}, "Unknown pad"), &"xbox")
	var sony_string: Dictionary = {"vendor_id": "1356"}
	assert_eq(
		PadGlyphs.family(sony_string, "Wireless Controller"), &"playstation", "a decimal string"
	)


func test_steam_input_virtual_pad_is_xbox_style_whatever_its_vendor() -> void:
	var info: Dictionary = {"vendor_id": 0x054C, "steam_input_index": 0}
	assert_eq(PadGlyphs.family(info, "PS5 Controller"), &"xbox")


func test_relabel_names_the_same_position() -> void:
	assert_eq(PadGlyphs.relabel("A", &"playstation"), "Cross")
	assert_eq(PadGlyphs.relabel("RT", &"playstation"), "R2")
	assert_eq(
		PadGlyphs.relabel("A", &"nintendo"), "B", "the bottom face button is B on that layout"
	)
	assert_eq(PadGlyphs.relabel("L3", &"playstation"), "L3")
	assert_eq(PadGlyphs.relabel("A", &"xbox"), "A")


func test_desktop_profile_keeps_xbox_labels() -> void:
	@warning_ignore("return_value_discarded")
	DeviceProfile.select("")
	assert_eq(PadGlyphs.active_family(), &"xbox")
	assert_eq(PadGlyphs.label("A"), "A")
