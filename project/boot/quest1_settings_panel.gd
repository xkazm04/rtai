class_name Quest1SettingsPanel
extends VBoxContainer
## The pause card's settings: master volume, reduced motion, and a keyboard rebind per action
## (press the button, then the new key; Esc cancels). Every change is applied and saved at once
## (PlayerSettings); `changed` tells the game to refresh what reads the flags.

signal changed

const STEP: float = 0.1

var settings: PlayerSettings
var _waiting: StringName = &""
var _text: QuestText = QuestText.new()


func _init(p_settings: PlayerSettings) -> void:
	settings = p_settings
	add_theme_constant_override(&"separation", 6)


func _ready() -> void:
	_rebuild()


func _input(event: InputEvent) -> void:
	if _waiting == &"" or not event is InputEventKey or not event.is_pressed():
		return
	var key: InputEventKey = event
	get_viewport().set_input_as_handled()
	if key.physical_keycode != KEY_ESCAPE:
		settings.rebind(_waiting, OS.get_keycode_string(key.physical_keycode))
		_commit()
	_waiting = &""
	_rebuild()


func _rebuild() -> void:
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


func _wait(action: StringName) -> void:
	_waiting = action
	_rebuild()


func _commit() -> void:
	settings.apply()
	var err: Error = settings.save()
	if err != OK:
		Log.warn("settings", "cannot save settings (%d)" % err)
	changed.emit()
