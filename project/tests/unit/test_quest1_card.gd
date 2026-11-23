extends GutTest

var _args: PackedStringArray
var _device: StringName


func before_each() -> void:
	_device = DeviceProfile.shared().id
	_args = LaunchArgs.unknown()
	for flag: String in LaunchArgs.KNOWN_FLAGS:
		if LaunchArgs.has(flag):
			@warning_ignore("return_value_discarded")
			_args.append("%s=%s" % [flag, LaunchArgs.value(flag)])


func after_each() -> void:
	LaunchArgs.parse(_args)
	@warning_ignore("return_value_discarded")
	DeviceProfile.select(String(_device))
	PlayerActions.shipped().install()


func _card(args: PackedStringArray, device: String) -> Quest1Card:
	LaunchArgs.parse(args)
	@warning_ignore("return_value_discarded")
	DeviceProfile.select(device)
	PlayerActions.shipped().install()
	var card: Quest1Card = add_child_autofree(Quest1Card.new())
	card.show_title()
	return card


func test_wheel_title_and_pause_show_the_mouse_bindings_and_quick_claw() -> void:
	var card: Quest1Card = _card([], "desktop")
	for expected: String in [
		"WASD / arrows move",
		"mouse aims",
		"Left mouse: swing or fire",
		"Right mouse: guard",
		"Mouse wheel: change weapon",
		"[F]: quick claw",
		"E: use (phones, hiding, allies, torch)",
		"Esc: pause",
		"Gamepad: left stick move, right stick aim, RT swing or fire, LT guard",
		"Back change weapon, X quick claw, A use"
	]:
		assert_string_contains(card.controls_text(), expected)
	var title: String = card.controls_text()
	assert_lte(title.split("\n").size(), 4)
	assert_eq((card._box.get_child(2) as Label).text, title)
	card.show_pause()
	assert_eq((card._box.get_child(1) as Label).text, title)


func test_legacy_desktop_keeps_the_original_electroshock_copy() -> void:
	var card: Quest1Card = _card(["--controls=legacy"], "desktop")
	var shown: String = (card._box.get_child(2) as Label).text
	assert_string_contains(shown, "[1]: car")
	assert_string_contains(shown, "[F] / right click: electroshock")


func test_handheld_uses_the_bound_triggers_and_buttons_for_each_mode() -> void:
	var card: Quest1Card = _card(["--controls=wheel"], "deck")
	var pad: String = card.controls_text()
	for expected: String in [
		"[L-stick] move",
		"[R-stick] aims",
		"[RT]: swing or fire",
		"[LT]: guard",
		"[Back]: change weapon",
		"[X]: quick claw",
		"[A]: use (phones, hiding, allies, torch)",
		"[Start]: pause"
	]:
		assert_string_contains(pad, expected)
	assert_lte(pad.split("\n").size(), 4)
	card = _card(["--controls=legacy"], "deck")
	assert_string_contains(card.controls_text(), "[X]: electroshock")


func test_keyboard_glyph_profile_shows_keyboard_bindings_for_wheel() -> void:
	var card: Quest1Card = _card(["--controls=wheel"], "desktop_kb_glyphs")
	assert_string_contains(card.controls_text(), "[RMB]: guard")
	assert_string_contains(card.controls_text(), "[F]: quick claw")
	assert_string_contains(card.controls_text(), "Mouse wheel: change weapon")


func test_wheel_and_legacy_use_separate_translation_keys() -> void:
	var translation: Translation = Translation.new()
	translation.locale = TranslationServer.get_locale()
	translation.add_message(&"SLICE__CONTROLS_WHEEL", &"wheel translation")
	translation.add_message(&"SLICE__CONTROLS", &"legacy translation")
	TranslationServer.add_translation(translation)
	var card: Quest1Card = _card(["--controls=wheel"], "desktop")
	assert_eq(card.controls_text(), "wheel translation")
	LaunchArgs.parse(["--controls=legacy"])
	assert_eq(card.controls_text(), "legacy translation")
	TranslationServer.remove_translation(translation)
