extends GutTest
## The control prompts name the device the player used last: keys and mouse buttons, or the pad's
## buttons and triggers (ObjectiveHint.with_keys + LiveInput.pad_last). Aim is not affected.


func before_each() -> void:
	PlayerActions.shipped().install()


func test_keyboard_prompt_names_keys() -> void:
	var out: String = ObjectiveHint.with_keys("Hold Dock 9: [fire] to shoot, [melee], [use]")
	assert_eq(out, "Hold Dock 9: [LMB] to shoot, [Space], [E]")


func test_pad_prompt_names_buttons_and_trigger() -> void:
	var out: String = ObjectiveHint.with_keys("Walk [move], [fire], [melee], [use]", true)
	assert_eq(out, "Walk [L-stick], [RT], [X], [A]")


func test_pad_then_key_switches_back() -> void:
	var live: LiveInput = LiveInput.new(PlayerActions.shipped())
	var press: InputEventJoypadButton = InputEventJoypadButton.new()
	press.button_index = JOY_BUTTON_A
	press.pressed = true
	live.note_event(press)
	assert_true(live.pad_last, "a pad button makes the prompts name the pad")
	assert_false(live.mouse_aims)
	var key: InputEventKey = InputEventKey.new()
	key.physical_keycode = KEY_W
	key.pressed = true
	live.note_event(key)
	assert_false(live.pad_last, "a key makes them name the keys again")
	assert_false(live.mouse_aims, "a key does not hand the aim back to the mouse")


func test_small_stick_drift_does_not_switch() -> void:
	var live: LiveInput = LiveInput.new(PlayerActions.shipped())
	var drift: InputEventJoypadMotion = InputEventJoypadMotion.new()
	drift.axis = JOY_AXIS_LEFT_X
	drift.axis_value = 0.1
	live.note_event(drift)
	assert_false(live.pad_last)
