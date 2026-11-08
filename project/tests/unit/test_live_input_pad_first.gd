extends GutTest
## features/player LiveInput (n9-handheld): a handheld row starts pad-first, so quest 1's first
## prompt names the pad's buttons (the title card eats the pad's first press before the session's
## input exists); a key or a click still hands the prompts back, mouse motion (a Deck trackpad)
## does not. The desktop starts on the keys and any mouse use hands them back.

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


func test_mouse_motion_aims_but_keeps_the_pad_prompts_on_a_handheld() -> void:
	DeviceProfile._shared = DeviceProfile.of("deck")
	var live: LiveInput = LiveInput.new(PlayerActions.shipped())
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.relative = Vector2(14, -3)
	live.note_event(motion)
	assert_true(live.mouse_aims, "a trackpad still aims")
	assert_true(live.pad_last, "but the prompts stay on the pad")
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	live.note_event(click)
	assert_false(live.pad_last, "a click hands them to the keys")


func test_mouse_motion_hands_the_prompts_back_on_the_desktop() -> void:
	DeviceProfile._shared = DeviceProfile.of("desktop")
	var live: LiveInput = LiveInput.new(PlayerActions.shipped())
	live.pad_last = true
	live.note_event(InputEventMouseMotion.new())
	assert_false(live.pad_last)
