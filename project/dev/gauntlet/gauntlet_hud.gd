class_name GauntletHud
extends CanvasLayer
## Screen-space meters. GuardMeter has reserved space even when guard has no sample.

const PAPER: Color = Color("#f6edd8")
const PLATE: Color = Color("#242127")
const TEAL: Color = Color("#83d7ba")

var session: GauntletSession
var run: GauntletRun
var waves: GauntletWaves
var guard_meter: ProgressBar = ProgressBar.new()
var _wave: Label = Label.new()
var _time: Label = Label.new()
var _hp: ProgressBar = ProgressBar.new()
var _health: Label = Label.new()


func _ready() -> void:
	layer = RenderLayers.canvas(&"hud")
	var panel: Panel = Panel.new()
	panel.position = Vector2(18, 18)
	panel.size = Vector2(238, 98)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override(&"panel", _fill(PLATE))
	add_child(panel)
	_text(panel, _wave, Vector2(14, 6), 22)
	_text(panel, _time, Vector2(148, 10), 17)
	_text(panel, _health, Vector2(14, 41), 15)
	_meter(panel, _hp, 67, 9)
	_meter(panel, guard_meter, 81, 5)
	guard_meter.name = &"GuardMeter"
	guard_meter.hide()


func _process(_delta: float) -> void:
	var rivet: Fighter = session.stage.arena.rivet
	_wave.text = tr("Wave %d") % run.wave
	_time.text = tr("%.1f s") % waves.wave_seconds(session.stage.tick)
	_health.text = tr("Health  %d / %d") % [ceili(rivet.hp), roundi(rivet.max_hp)]
	_hp.value = clampf(rivet.hp / rivet.max_hp, 0.0, 1.0)


func set_guard_meter(fraction: float, broken: bool = false) -> void:
	guard_meter.show()
	guard_meter.value = clampf(fraction, 0.0, 1.0)
	guard_meter.modulate = Color.SALMON if broken else Color.WHITE


func _text(parent: Control, label: Label, pos: Vector2, font_size: int) -> void:
	label.position = pos
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override(&"font_size", font_size)
	label.add_theme_color_override(&"font_color", PAPER)
	parent.add_child(label)


func _meter(parent: Control, bar: ProgressBar, y: float, height_px: float) -> void:
	bar.position = Vector2(14, y)
	bar.size = Vector2(210, height_px)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.max_value = 1.0
	bar.step = 0.0
	bar.show_percentage = false
	bar.add_theme_stylebox_override(&"background", _fill(PLATE.lightened(0.2)))
	bar.add_theme_stylebox_override(&"fill", _fill(TEAL))
	parent.add_child(bar)


func _fill(colour: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = colour
	return style
