class_name ArenaPanel
extends PanelContainer
## The arena's live tuning panel (dev overlay, toggled by `arena_panel`): one row per knob the
## stations expose (ArenaStation.knobs): its key, a slider over the station's range, the value,
## and Save (into the data table) and Reset (to the table's value) buttons. A slider moves the
## running session at once through ArenaTuning, which logs every change.

const ROW_LABEL_PX: float = 300.0
const SLIDER_PX: float = 220.0
const FONT_PX: int = 15

var tuning: ArenaTuning = null
## The sim tick for the log (a callable so the panel never holds the session).
var tick_now: Callable = func() -> int: return -1
var _values: Dictionary[String, Label] = {}
var _sliders: Dictionary[String, HSlider] = {}


## Builds the rows for every knob of every station (a key two stations share gets one row).
func build(stations: ArenaStations, p_tuning: ArenaTuning) -> void:
	tuning = p_tuning
	var box: VBoxContainer = VBoxContainer.new()
	add_child(box)
	box.add_child(_text(tr("TUNING  (F1 hides)  changes are live and logged"), FONT_PX + 2))
	for s: ArenaStation in stations.stations:
		var rows: Array[ArenaStation.Knob] = []
		for k: ArenaStation.Knob in s.knobs:
			if not _sliders.has(k.key):
				rows.append(k)
		if rows.is_empty():
			continue
		box.add_child(_text("%s  [%s]" % [s.name, s.lane], FONT_PX + 1))
		for k: ArenaStation.Knob in rows:
			box.add_child(_row(k))


func _row(k: ArenaStation.Knob) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	var name_label: Label = _text(k.key.trim_prefix("input_actions."), FONT_PX)
	name_label.custom_minimum_size.x = ROW_LABEL_PX
	row.add_child(name_label)
	var slider: HSlider = HSlider.new()
	slider.min_value = k.min_value
	slider.max_value = k.max_value
	slider.step = k.step
	slider.custom_minimum_size.x = SLIDER_PX
	var shipped: float = tuning.shipped(k.key)
	slider.value = shipped if not is_nan(shipped) else k.min_value
	row.add_child(slider)
	var value: Label = _text(_fmt(slider.value), FONT_PX)
	value.custom_minimum_size.x = 64.0
	row.add_child(value)
	_values[k.key] = value
	_sliders[k.key] = slider
	@warning_ignore("return_value_discarded")
	slider.value_changed.connect(func(v: float) -> void: _changed(k.key, v))
	row.add_child(_button(tr("save"), func() -> void: _save(k.key)))
	row.add_child(_button(tr("reset"), func() -> void: _reset(k.key)))
	return row


## Moves a knob's slider as a hand would (the change applies and is logged); false if absent.
func set_live(key: String, v: float) -> bool:
	if not _sliders.has(key):
		return false
	_sliders[key].value = v
	return true


func _changed(key: String, v: float) -> void:
	var tick: int = tick_now.call()
	var applied: bool = tuning.set_value(key, v, tick)
	_values[key].text = _fmt(v) if applied else _fmt(v) + " (no reader)"


func _save(key: String) -> void:
	var ok: bool = tuning.save(key, _sliders[key].value)
	_values[key].text = _fmt(_sliders[key].value) + (" saved" if ok else " save failed")


func _reset(key: String) -> void:
	_sliders[key].set_value_no_signal(tuning.shipped(key))
	var tick: int = tick_now.call()
	@warning_ignore("return_value_discarded")
	tuning.reset(key, tick)
	_values[key].text = _fmt(_sliders[key].value)


static func _fmt(v: float) -> String:
	return "%.2f" % v if absf(v) < 10.0 else "%d" % roundi(v)


func _text(s: String, px: int) -> Label:
	var l: Label = Label.new()
	l.text = s
	l.add_theme_font_size_override("font_size", px)
	return l


func _button(s: String, on: Callable) -> Button:
	var b: Button = Button.new()
	b.text = s
	b.focus_mode = Control.FOCUS_NONE
	@warning_ignore("return_value_discarded")
	b.pressed.connect(on)
	return b
