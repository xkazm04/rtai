class_name GauntletHud
extends CanvasLayer
## Screen-space meters. GuardMeter has reserved space even when guard has no sample.

const PAPER: Color = Ink.CREAM
const PLATE: Color = HudArt.INK
const ENGLISH: Translation = preload("res://data/loc/en.po")


class Meter:
	extends Range

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		max_value = 1.0
		step = 0.0
		@warning_ignore("return_value_discarded")
		value_changed.connect(func(_sample: float) -> void: queue_redraw())

	func _draw() -> void:
		var track: Rect2 = Rect2(Vector2.ZERO, size)
		draw_rect(track, PLATE)
		draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * ratio, size.y)), PAPER)
		draw_rect(track.grow(1.0), PAPER.darkened(0.45), false, 1.0)


var session: GauntletSession
var run: GauntletRun
var waves: GauntletWaves
var guard_meter: Meter = Meter.new()
var _wave: Label
var _time: Label
var _hp: Meter = Meter.new()
var _health: Label


func _ready() -> void:
	TranslationServer.add_translation(ENGLISH)
	name = &"GauntletHud"
	layer = RenderLayers.canvas(&"hud")
	var panel: ColorRect = preload("gauntlet_status.tscn").instantiate() as ColorRect
	panel.color = PLATE
	add_child(panel)
	_wave = panel.get_node(^"Wave") as Label
	_time = panel.get_node(^"Time") as Label
	_health = panel.get_node(^"Health") as Label
	_meter(panel, _hp, 67, 9)
	_meter(panel, guard_meter, 81, 5)
	guard_meter.name = &"GuardMeter"
	guard_meter.hide()


func _process(_delta: float) -> void:
	var rivet: Fighter = session.stage.arena.rivet
	_wave.text = tr("GAUNTLET__WAVE").format({"wave": run.wave})
	_time.text = tr("GAUNTLET__TIMER").format(
		{"seconds": "%.1f" % waves.wave_seconds(session.stage.tick)}
	)
	_health.text = tr("GAUNTLET__HEALTH").format(
		{"hp": ceili(rivet.hp), "max_hp": roundi(rivet.max_hp)}
	)
	_hp.value = clampf(rivet.hp / rivet.max_hp, 0.0, 1.0)


func set_guard_meter(fraction: float, broken: bool = false) -> void:
	guard_meter.show()
	guard_meter.value = clampf(fraction, 0.0, 1.0)
	guard_meter.modulate = Color.GRAY if broken else Color.WHITE


func _meter(parent: Control, bar: Meter, y: float, height_px: float) -> void:
	bar.position = Vector2(14, y)
	bar.size = Vector2(210, height_px)
	parent.add_child(bar)
