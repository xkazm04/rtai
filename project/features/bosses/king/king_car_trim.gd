class_name KingCarTrim
extends RefCounted
## The throne-car's plush and drapes from straight above (boss_king.jpg: the 90-degree panel's
## plum-quilted roof panels between gold cross-bars, and the 3/4 view's plum swags with gold
## tassels hung along both sides). Drawn on the car's canvas, nose along +x, in px.

const PLUM: Color = Color("#5A2335")
const PLUM_DARK: Color = Color("#3B1522")
const GOLD: Color = Color("#D9A933")
## The swags along each side: how many, and how far each bellies out past the body (at 32 px/m
## is about 7 px): they break the car's straight outline the way the target's drapes do.
const SWAGS: int = 5
const BELLY_M: float = 0.22
const PANELS_X: Array[float] = [-0.44, -0.28, 0.0]
const PANEL_W: Array[float] = [0.14, 0.18, 0.12]


static func draw(ci: CanvasItem, l: float, w: float, p: float) -> void:
	for i: int in PANELS_X.size():  # the plum roof panels (rear, the throne's plush, the front cabin)
		var r: Rect2 = Rect2(l * PANELS_X[i], -w * 0.5 + 7.0, l * PANEL_W[i], w - 14.0)
		ci.draw_rect(r, PLUM)
		var mid: float = r.position.x + r.size.x * 0.5  # the quilting's seam
		ci.draw_line(Vector2(mid, r.position.y + 4.0), Vector2(mid, r.end.y - 4.0), PLUM_DARK, 1.5)
		ci.draw_rect(Rect2(r.end.x, -w * 0.5 + 6.0, 3.0, w - 12.0), GOLD)  # the gold cross-bar after it
	for sy: float in [-1.0, 1.0]:
		_swags(ci, l, w, p, sy)


## Plum swags from the rear wheel to the front door along one side, a gold tassel between each.
static func _swags(ci: CanvasItem, l: float, w: float, p: float, sy: float) -> void:
	var x0: float = -l * 0.42
	var span: float = l * 0.6 / float(SWAGS)
	var edge: float = sy * w * 0.5
	for i: int in SWAGS:
		var cx: float = x0 + span * (float(i) + 0.5)
		var pts: PackedVector2Array = PackedVector2Array()
		@warning_ignore("return_value_discarded")
		pts.resize(11)
		for k: int in 9:
			var t: float = float(k) / 8.0
			var belly: float = sin(t * PI) * BELLY_M * p
			pts[k] = Vector2(cx - span * 0.5 + span * t, edge + sy * belly)
		pts[9] = Vector2(cx + span * 0.5, edge - sy * 3.0)
		pts[10] = Vector2(cx - span * 0.5, edge - sy * 3.0)
		ci.draw_colored_polygon(pts, PLUM)
		ci.draw_polyline(pts.slice(0, 9), GOLD, 1.5)  # the gold fringe on the swag's hem
		ci.draw_circle(Vector2(cx + span * 0.5, edge + sy * 2.0), 2.5, GOLD)  # a tassel
