class_name Quest1SettingsPanel
extends VBoxContainer
## The pause card's settings: master volume, reduced motion, a frame cap on a handheld device
## row (device / 30 / 40 / 60), and a keyboard rebind per action (press the button, then the
## new key; Esc or any pad button cancels). Every change is applied and saved at once
## (PlayerSettings, to `save_path`; "" = not saved); `changed` tells the game to refresh what
## reads the flags. A rebuild keeps the focus on the same button (d9-handheld: a pad or keyboard
## player pressing Toggle would otherwise lose the focus with the freed button, and the pad
## could no longer move in the card).

signal changed

const STEP: float = 0.1

var settings: PlayerSettings
var save_path: String = PlayerSettings.PATH
var _waiting: StringName = &""
var _text: QuestText = QuestText.new()


func _init(p_settings: PlayerSettings, p_save_path: String = PlayerSettings.PATH) -> void:
	settings = p_settings
	save_path = p_save_path
	add_theme_constant_override(&"separation", 6)


func _ready() -> void:
	_rebuild()


func _input(event: InputEvent) -> void:
	if _waiting == &"" or not event.is_pressed():
		return
	if event is InputEventJoypadButton:
		get_viewport().set_input_as_handled()
		_waiting = &""
		_rebuild()
		return
	if not event is InputEventKey:
		return
	var key: InputEventKey = event
	get_viewport().set_input_as_handled()
	if key.physical_keycode != KEY_ESCAPE:
		settings.rebind(_waiting, OS.get_keycode_string(key.physical_keycode))
		_commit()
	_waiting = &""
	_rebuild()


func _rebuild() -> void:
	var focus: Vector2i = focused_slot()
	_build_rows()
	if focus.x >= 0 and focus.x < get_child_count():
		var row: Node = get_child(focus.x)
		if focus.y < row.get_child_count() and row.get_child(focus.y) is Button:
			(row.get_child(focus.y) as Button).grab_focus()


## The focused button as (row, child) in this panel, or (-1, -1).
func focused_slot() -> Vector2i:
	var owner_c: Control = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	if owner_c == null or not is_ancestor_of(owner_c):
		return Vector2i(-1, -1)
	var row: Node = owner_c.get_parent()
	if row.get_parent() != self:
		return Vector2i(-1, -1)
	return Vector2i(row.get_index(), owner_c.get_index())


func _build_rows() -> void:
	for c: Node in get_children():
		remove_child(c)
		c.queue_free()
	var vol: String = _text.resolve(&"SLICE__VOLUME", "Volume %d%%") % roundi(settings.volume * 100)
	_row(vol, [["-", func() -> void: _volume(-STEP)], ["+", func() -> void: _volume(STEP)]])
	var rm_key: StringName = (
		&"SLICE__MOTION_ON" if settings.reduced_motion else &"SLICE__MOTION_OFF"
	)
	var rm: String = _text.resolve(
		rm_key, "Reduced motion: on" if settings.reduced_motion else "Reduced motion: off"
	)
	_row(rm, [[_text.resolve(&"SLICE__TOGGLE", "Toggle"), _toggle_motion]])
	if DeviceProfile.shared().is_handheld():
		_row(
			cap_label(settings.frame_cap), [[_text.resolve(&"SLICE__TOGGLE", "Toggle"), _cycle_cap]]
		)
	for action: StringName in PlayerSettings.REBINDABLE:
		var bound: String = "..." if _waiting == action else ObjectiveHint.key_name(action)
		var label: String = String(action).replace("_", " ")
		_row(
			"%s  [%s]" % [label, bound],
			[[_text.resolve(&"SLICE__REBIND", "Rebind"), func() -> void: _wait(action)]]
		)


func _row(text: String, buttons: Array) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	var l: Label = Label.new()
	l.text = text
	l.custom_minimum_size.x = 300
	l.add_theme_color_override(&"font_color", Ink.INK)
	l.add_theme_font_size_override(&"font_size", 20)
	row.add_child(l)
	for spec: Array in buttons:
		var b: Button = Button.new()
		b.text = str(spec[0])
		b.add_theme_font_size_override(&"font_size", 18)
		var cb: Callable = spec[1]
		@warning_ignore("return_value_discarded")
		b.pressed.connect(cb)
		row.add_child(b)
	add_child(row)


func _volume(delta: float) -> void:
	settings.volume = clampf(snappedf(settings.volume + delta, STEP), 0.0, 1.0)
	_commit()
	_rebuild()


func _toggle_motion() -> void:
	settings.reduced_motion = not settings.reduced_motion
	_commit()
	_rebuild()


func cap_label(cap: int) -> String:
	if cap <= 0:
		return _text.resolve(&"SLICE__FRAME_CAP_DEVICE", "Frame cap: device")
	return _text.resolve(&"SLICE__FRAME_CAP", "Frame cap: %d fps") % cap


func _cycle_cap() -> void:
	var caps: Array[int] = PlayerSettings.FRAME_CAPS
	settings.frame_cap = caps[(caps.find(settings.frame_cap) + 1) % caps.size()]
	_commit()
	_rebuild()


func _wait(action: StringName) -> void:
	_waiting = action
	_rebuild()


func _commit() -> void:
	settings.apply()
	var err: Error = settings.save(save_path) if save_path != "" else OK
	if err != OK:
		Log.warn("settings", "cannot save settings (%d)" % err)
	changed.emit()
