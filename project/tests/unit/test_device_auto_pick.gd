extends GutTest
## n10-handheld: the auto-pick's checks: Steam hardware first, then the variable, then the firmware
## model (DeviceProfile.auto_pick, devices.json `models`, LEDGER section 9).


func test_steam_hardware_is_the_first_check() -> void:
	# n10: Platform.hardware() answers before the SteamDeck variable
	var deck: PlatformBackend.Hardware = PlatformBackend.Hardware.STEAM_DECK
	var other: PlatformBackend.Hardware = PlatformBackend.Hardware.STEAM_HARDWARE
	var panel: Vector2i = DeviceProfile.DECK_PANEL
	assert_eq(DeviceProfile.auto_pick("", panel, "", deck), "deck", "no variable needed")
	assert_eq(DeviceProfile.auto_pick("0", panel, "", deck), "", "SteamDeck=0 still opts out")
	assert_eq(DeviceProfile.auto_pick("", Vector2i(1920, 1080), "", deck), "", "docked")
	assert_eq(DeviceProfile.auto_pick("1", panel, "", other), "", "a Steam Machine or Frame")
	assert_eq(DeviceProfile.auto_pick("", panel, "Jupiter", other), "", "beats the model too")


func test_steam_hardware_types_map_to_the_interface() -> void:
	assert_eq(SteamBackend.hardware_of(0), PlatformBackend.Hardware.DESKTOP)
	assert_eq(SteamBackend.hardware_of(1), PlatformBackend.Hardware.STEAM_DECK)
	assert_eq(SteamBackend.hardware_of(2), PlatformBackend.Hardware.STEAM_HARDWARE, "Machine")
	assert_eq(SteamBackend.hardware_of(3), PlatformBackend.Hardware.STEAM_HARDWARE, "Frame")
	assert_eq(SteamBackend.new().hardware(), PlatformBackend.Hardware.DESKTOP, "not vendored")
	assert_eq(SteamBackend.new().action_glyph_path("A"), "", "the drawn set until vendored")


func test_a_windows_handheld_picks_its_row_by_its_firmware_model() -> void:
	# n10: strings from the kernel's DMI tables (LEDGER); on Windows the model is SystemProductName
	var fhd: Vector2i = Vector2i(1920, 1080)
	assert_eq(DeviceProfile.auto_pick("", fhd, "ROG Ally X RC72LA_RC72LA"), "handheld_1080")
	assert_eq(DeviceProfile.auto_pick("", Vector2i(1920, 1200), "AYANEO 2S"), "handheld_1080")
	assert_eq(DeviceProfile.auto_pick("", Vector2i(2560, 1600), "G1618-03"), "handheld_1080")
	assert_eq(
		DeviceProfile.auto_pick("", Vector2i(3840, 2160), "G1618-03"), "", "docked on a 4K TV"
	)
	assert_eq(DeviceProfile.auto_pick("0", fhd, "G1618-03"), "", "SteamDeck=0 opts out here too")


func test_the_rog_ally_and_the_legion_go_family_pick_their_row() -> void:
	# n10 it5: the ROG Ally's product name from a DMI dump and HandyGCCS; Lenovo's type numbers
	# from InputPlumber's DMI matches (LEDGER section 9)
	var fhd: Vector2i = Vector2i(1920, 1080)
	assert_eq(DeviceProfile.auto_pick("", fhd, "ROG Ally RC71L_RC71L"), "handheld_1080")
	assert_eq(DeviceProfile.auto_pick("", fhd, "ROG Ally RC71L"), "handheld_1080")
	assert_eq(DeviceProfile.auto_pick("", Vector2i(2560, 1600), "83E1"), "handheld_1080")
	assert_eq(DeviceProfile.auto_pick("", Vector2i(1920, 1200), "83L3"), "handheld_1080", "Go S")
	assert_eq(DeviceProfile.auto_pick("", Vector2i(1920, 1200), "83N1"), "handheld_1080", "Go 2")


func test_the_rog_xbox_ally_family_picks_its_row() -> void:
	# n10 it13: full product names from HHD's comments on its DMI match (LEDGER section 9)
	var fhd: Vector2i = Vector2i(1920, 1080)
	assert_eq(DeviceProfile.auto_pick("", fhd, "ROG Xbox Ally RC73YA_RC73YA"), "handheld_1080")
	assert_eq(DeviceProfile.auto_pick("", fhd, "ROG Xbox Ally X RC73XA_RC73XA"), "handheld_1080")
	assert_eq(DeviceProfile.auto_pick("", fhd, "ROG XBOX Ally X RC74XA RC74XA"), "handheld_1080")


func test_a_type_number_only_matches_the_whole_name() -> void:
	for model: String in ["83E1ABCDEF", "X83E1", "83e1", "83E"]:
		assert_eq(DeviceProfile.model_row(model), "", model)


func test_a_deck_running_windows_is_the_deck_row_only_on_its_panel() -> void:
	var panel: Vector2i = DeviceProfile.DECK_PANEL
	assert_eq(DeviceProfile.auto_pick("", panel, "Jupiter"), "deck")
	assert_eq(DeviceProfile.auto_pick("", panel, "Galileo"), "deck")
	assert_eq(DeviceProfile.auto_pick("", Vector2i(1920, 1080), "Jupiter"), "", "docked")


func test_an_ordinary_pc_names_no_row() -> void:
	for model: String in ["X670 AORUS ELITE AX", "System Product Name", "", "rog ally x rc72la"]:
		assert_eq(DeviceProfile.model_row(model), "", model)
		assert_eq(DeviceProfile.auto_pick("", Vector2i(1920, 1080), model), "", model)


func test_every_listed_model_picks_a_handheld_row() -> void:
	var table: JSON = JSON.new()
	assert_eq(table.parse(FileAccess.get_file_as_string(DeviceProfile.TABLE)), OK)
	var data: Dictionary = table.data
	var seen: int = 0
	for row: Dictionary in data["devices"]:
		for model: Variant in row.get("models", []) + row.get("models_exact", []):
			seen += 1
			assert_true(
				DeviceProfile.of(DeviceProfile.model_row(str(model))).is_handheld(), str(model)
			)
	assert_gt(seen, 16, "both models lists are read")


func test_the_backend_is_up_before_launch_args_ask_it() -> void:
	# n10: LaunchArgs._init asks Platform.hardware(), so Platform must come first in the autoloads
	var order: Array[String] = []
	for p: Dictionary in ProjectSettings.get_property_list():
		var key: String = str(p["name"])
		if key.begins_with("autoload/"):
			order.append(key.trim_prefix("autoload/"))
	assert_lt(order.find("Platform"), order.find("LaunchArgs"))
	assert_ne(Platform.backend_name(), &"none")
