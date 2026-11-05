class_name BossBar
extends Control
## The boss health bar on the HUD: the boss's name over a wide bar at the top of the screen, a
## tick at each phase threshold (from bosses.json), the lost hp trailing in pale ink for a moment
## (the read of a big hit), the bar flashing cream while the boss cannot be hurt (a transition).
## Render only: reads the fight each frame.

const WIDTH_K: float = 0.56
const BAR_H: float = 14.0
const TOP: float = 34.0
## The trail's fall per drawn frame (a render-only ease; about 0.35 of the bar a second at 60 fps).
const TRAIL_PER_FRAME: float = 0.006

var fight: BossFight = null
var _trail: float = 1.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	if fight == null:
		return
	_trail = maxf(fight.hp_frac(), _trail - TRAIL_PER_FRAME)
	size = get_viewport_rect().size
	queue_redraw()


func _draw() -> void:
	if fight == null:
		return
	var w: float = size.x * WIDTH_K
	var r: Rect2 = Rect2(Vector2((size.x - w) * 0.5, TOP), Vector2(w, BAR_H))
	draw_rect(r.grow(3.0), Ink.INK)
	draw_rect(r, Color(Ink.CREAM, 0.25))
	draw_rect(Rect2(r.position, Vector2(w * _trail, BAR_H)), Color(Ink.CREAM, 0.7))
	var fill: Color = Ink.CREAM if fight.state == BossFight.State.TRANSITION else Ink.VERMILION
	draw_rect(Rect2(r.position, Vector2(w * fight.hp_frac(), BAR_H)), fill)
	for p: BossSpec.Phase in fight.spec.phases:
		if p.hp_below < 1.0:
			var x: float = r.position.x + w * p.hp_below
			draw_line(Vector2(x, TOP - 5.0), Vector2(x, TOP + BAR_H + 5.0), Ink.INK, 3.0)
	var font: Font = ThemeDB.fallback_font
	var title: String = tr(String(fight.spec.id).to_upper())
	draw_string_outline(font, r.position + Vector2(0, -8), title, 0, -1, 20, 6, Ink.INK)
	draw_string(font, r.position + Vector2(0, -8), title, 0, -1, 20, Ink.CREAM)
	var mark: String = "%d / %d" % [fight.phase + 1, fight.spec.phases.size()]
	var at: Vector2 = r.position + Vector2(w - 40.0, -8)
	draw_string_outline(font, at, mark, 0, -1, 16, 5, Ink.INK)
	draw_string(font, at, mark, 0, -1, 16, Ink.CREAM)
