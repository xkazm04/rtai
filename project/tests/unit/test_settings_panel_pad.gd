extends GutTest
## d9-handheld: the pause card's settings walked on a pad alone (Steam Deck Verified: every menu
## works on the controller). Godot 4.7 gives ui_accept no pad button:
## PlayerActions.install_menu_pad (LaunchArgs, every run) adds A, so A presses the focused
## button. Under a handheld row the frame cap is offered; A on its Toggle cycles the cap and
## the focus stays on that button (the rebuild used to free it, and the pad was left with no
## focus to move); the d-pad then moves on. A pad button cancels a keyboard rebind's wait (on the
## desktop row: a handheld tier lists no keyboard rebinds). The card is pad first on a handheld
## tier (the controls line, a thick focus mark) and unchanged on the desktop.

const CAP_ROW: int = 2
const REBIND_ROW: int = 2

var _fps_before: int = 0
var _panel: Quest1SettingsPanel = null


func before_each() -> void:
	_fps_before = Engine.max_fps
	@warning_ignore("return_value_discarded")
	DeviceProfile.select("deck")
	@warning_ignore("return_value_discarded")
	PlayerActions.install_menu_pad()
	_panel = Quest1SettingsPanel.new(PlayerSettings.new(), "")
	add_child_autofree(_panel)


func after_each() -> void:
	@warning_ignore("return_value_discarded")
	DeviceProfile.select("")
	PlayerActions.shipped().install()
	Engine.max_fps = _fps_before


func test_a_cycles_the_cap_and_the_focus_stays_for_the_dpad() -> void:
	(_panel.get_child(CAP_ROW).get_child(1) as Button).grab_focus()
	_pad(JOY_BUTTON_A)
	assert_eq(_panel.settings.frame_cap, 30, "A pressed the cap's Toggle")
	assert_eq(Engine.max_fps, 30, "the cap reached the engine")
	assert_eq(_panel.focused_slot(), Vector2i(CAP_ROW, 1), "the focus stayed on Toggle")
	_pad(JOY_BUTTON_A)
	assert_eq(_panel.settings.frame_cap, 40, "a second A cycles on")
	await wait_process_frames(2)  # the rebuilt rows are laid out (a player's next press is later)
	_pad(JOY_BUTTON_DPAD_UP)
	assert_eq(_panel.focused_slot().x, CAP_ROW - 1, "the d-pad moves to the row above")


func test_a_pad_button_cancels_a_rebind_wait() -> void:
	@warning_ignore("return_value_discarded")
	DeviceProfile.select("")
	_panel.free()
	_panel = Quest1SettingsPanel.new(PlayerSettings.new(), "")
	add_child_autofree(_panel)
	assert_eq(_panel.get_child_count(), 2 + PlayerSettings.REBINDABLE.size(), "desktop: no cap row")
	var rebind: Button = _panel.get_child(REBIND_ROW).get_child(1) as Button
	rebind.grab_focus()
	_pad(JOY_BUTTON_A)
	assert_string_contains((_panel.get_child(REBIND_ROW).get_child(0) as Label).text, "[...]")
	_pad(JOY_BUTTON_B)
	var label: String = (_panel.get_child(REBIND_ROW).get_child(0) as Label).text
	assert_false(label.contains("[...]"), "B cancelled the wait: %s" % label)
	assert_eq(_panel.focused_slot(), Vector2i(REBIND_ROW, 1), "the focus stayed on Rebind")


func test_menu_pad_adds_a_and_b_once() -> void:
	var a: InputEventJoypadButton = InputEventJoypadButton.new()
	a.button_index = JOY_BUTTON_A
	var b: InputEventJoypadButton = InputEventJoypadButton.new()
	b.button_index = JOY_BUTTON_B
	assert_true(InputMap.action_has_event(&"ui_accept", a), "A presses a focused button")
	assert_true(InputMap.action_has_event(&"ui_cancel", b), "B cancels")
	assert_eq(PlayerActions.install_menu_pad(), 0, "idempotent: nothing added twice")
	var keys: int = 0
	for ev: InputEvent in InputMap.action_get_events(&"ui_accept"):
		keys += 1 if ev is InputEventKey else 0
	assert_eq(keys, 3, "the keyboard keeps Enter, keypad Enter and Space")


func test_handheld_card_is_pad_first_and_desktop_unchanged() -> void:
	assert_eq(_panel.get_child_count(), CAP_ROW + 1, "deck: volume, motion, cap; no keyboard rows")
	var card: Quest1Card = Quest1Card.new()
	add_child_autofree(card)
	var pad: String = card.controls_text()
	assert_false(pad.contains("WASD"), pad)
	assert_string_contains(pad, "[L-stick] move")
	assert_string_contains(pad, "[A]: use")
	var b: Button = _panel.get_child(CAP_ROW).get_child(1) as Button
	assert_true(b.has_theme_stylebox_override(&"focus"), "deck: the thick focus mark")
	@warning_ignore("return_value_discarded")
	DeviceProfile.select("")
	assert_eq(card.controls_text(), Quest1Card.CONTROLS, "desktop: the shipped line")
	var plain: Button = Button.new()
	Quest1Card.mark_focus(plain)
	assert_false(plain.has_theme_stylebox_override(&"focus"), "desktop: the default mark")
	plain.free()


func test_b_on_the_pause_card_resumes_and_esc_is_left_to_pause() -> void:
	var card: Quest1Card = Quest1Card.new()
	add_child_autofree(card)
	watch_signals(card)
	card.show_pause()
	_pad(JOY_BUTTON_B)
	assert_signal_emit_count(card, "resume_pressed", 1, "B resumes from the pause card")
	var esc: InputEventKey = InputEventKey.new()
	esc.keycode = KEY_ESCAPE
	esc.physical_keycode = KEY_ESCAPE
	esc.pressed = true
	get_viewport().push_input(esc)
	assert_signal_emit_count(card, "resume_pressed", 1, "Esc stays the game's pause toggle")
	card.hide_all()
	_pad(JOY_BUTTON_B)
	assert_signal_emit_count(card, "resume_pressed", 1, "no card up: B is the game's again")


func _pad(button: JoyButton) -> void:
	for down: bool in [true, false]:
		var ev: InputEventJoypadButton = InputEventJoypadButton.new()
		ev.button_index = button
		ev.pressed = down
		get_viewport().push_input(ev)
