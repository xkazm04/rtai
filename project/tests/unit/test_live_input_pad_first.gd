extends GutTest
## features/player LiveInput (n9-handheld): a handheld row starts pad-first, so quest 1's first
## prompt names the pad's buttons (the title card eats the pad's first press before the session's
## input exists); a key or the mouse still hands the prompts back. The desktop starts on the keys.

var _saved: DeviceProfile = null


func before_each() -> void:
	_saved = DeviceProfile.shared()


func after_each() -> void:
	DeviceProfile._shared = _saved


func test_the_desktop_starts_on_the_keys_and_the_mouse() -> void:
	DeviceProfile._shared = DeviceProfile.of("desktop")
	var live: LiveInput = LiveInput.new(PlayerActions.shipped())
	assert_false(live.pad_last)
	assert_true(live.mouse_aims)


func test_every_handheld_row_starts_on_the_pad() -> void:
	for id: String in DeviceProfile.of("").ids:
		DeviceProfile._shared = DeviceProfile.of(id)
		var live: LiveInput = LiveInput.new(PlayerActions.shipped())
		assert_eq(live.pad_last, DeviceProfile._shared.is_handheld(), id)
		assert_eq(live.mouse_aims, not DeviceProfile._shared.is_handheld(), id)


func test_a_key_hands_the_prompts_back_on_a_handheld() -> void:
	DeviceProfile._shared = DeviceProfile.of("deck")
	var live: LiveInput = LiveInput.new(PlayerActions.shipped())
	var key: InputEventKey = InputEventKey.new()
	key.physical_keycode = KEY_W
	key.pressed = true
	live.note_event(key)
	assert_false(live.pad_last)


func test_the_first_quest_prompt_names_the_pad_on_a_deck() -> void:
	DeviceProfile._shared = DeviceProfile.of("deck")
	PlayerActions.shipped().install()
	var live: LiveInput = LiveInput.new(PlayerActions.shipped())
	var words: String = ObjectiveHint.with_keys(
		"Walk [move] to the dumpster, hide: [use]", live.pad_last
	)
	assert_eq(words.find("L-stick"), 6, words)
	assert_false(words.contains("W A S D"), words)
