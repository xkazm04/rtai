class_name KingCarTrim
extends RefCounted
## The throne-car's plush and drapes from straight above (boss_king.jpg: the 90-degree panel's
## plum-quilted roof panels between gold cross-bars, and the 3/4 view's plum swags with gold
## tassels hung along both sides). Drawn on the car's canvas, nose along +x, in px.

const PLUM: Color = Color("#5A2335")
const GOLD_DARK: Color = Color("#8A6418")
const GOLD_HI: Color = Color("#F6D678")
const INK: Color = Color("#1B1517")
## it12: the hood cannon's profile from straight above (boss_king.jpg's 90-degree panel: a fat gold
## barrel on a round swivel mount, banded, flared at the muzzle): [along the barrel 0..1, half
## width px at the 48 px/m base]. The muzzle stays where the coins leave (KingBodyView._coins).
const CANNON_PROFILE: Array[Vector2] = [
	Vector2(0.0, 12.0),
	Vector2(0.72, 8.5),
	Vector2(0.86, 8.5),
	Vector2(0.9, 12.5),
	Vector2(1.0, 12.5)
]
const CANNON_BANDS: Array[float] = [0.3, 0.55]
const PLUM_DARK: Color = Color("#3B1522")
const GOLD: Color = Color("#D9A933")
## The swags along each side: how many, and how far each bellies out past the body (at 32 px/m
## is about 7 px): they break the car's straight outline the way the target's drapes do.
const SWAGS: int = 5
const BELLY_M: float = 0.22
const PANELS_X: Array[float] = [-0.44, -0.28, 0.0]
const PANEL_W: Array[float] = [0.14, 0.18, 0.12]
## it14: the rounded gold bumpers at both ends (the 90-degree panel's bars past the nose and the
## trunk), standing out this far (m); 0 = the it13 square-ended box.
const BUMPER_M: float = 0.18


static func draw(ci: CanvasItem, l: float, w: float, p: float) -> void:
	for i: int in PANELS_X.size():  # the plum roof panels (rear, the throne's plush, the front cabin)
		var r: Rect2 = Rect2(l * PANELS_X[i], -w * 0.5 + 7.0, l * PANEL_W[i], w - 14.0)
		ci.draw_rect(r, PLUM)
		var mid: float = r.position.x + r.size.x * 0.5  # the quilting's seam
		ci.draw_line(Vector2(mid, r.position.y + 4.0), Vector2(mid, r.end.y - 4.0), PLUM_DARK, 1.5)
		ci.draw_rect(Rect2(r.end.x, -w * 0.5 + 6.0, 3.0, w - 12.0), GOLD)  # the gold cross-bar after it
	for sy: float in [-1.0, 1.0]:
		_swags(ci, l, w, p, sy)


## The gold bumpers, drawn under the body: a rounded bar across each end, past the outline.
static func bumpers(ci: CanvasItem, l: float, w: float, p: float) -> void:
	if BUMPER_M <= 0.0:
		return
	var t: float = BUMPER_M * p
	var h: float = w * 0.78
	for sx: float in [-1.0, 1.0]:
		var x: float = sx * (l * 0.5 + t * 0.5)
		for edge: float in [3.0, 0.0]:  # the ink edge, then the gold
			var col: Color = INK if edge > 0.0 else GOLD
			ci.draw_rect(Rect2(x - t * 0.5 - edge, -h * 0.5, t + edge * 2.0, h), col)
			for sy: float in [-1.0, 1.0]:
				ci.draw_circle(Vector2(x, sy * h * 0.5), t * 0.5 + edge, col)
		ci.draw_line(Vector2(x, -h * 0.45), Vector2(x, h * 0.45), GOLD_HI, maxf(t * 0.18, 1.5))


## The hood cannon from `tail` to `tip` (car px): ink-edged, shaded, banded, on its mount.
static func cannon(ci: CanvasItem, tail: Vector2, tip: Vector2) -> void:
	var a: Vector2 = (tip - tail).normalized()
	var n: Vector2 = a.orthogonal()
	var span: float = tail.distance_to(tip)
	ci.draw_circle(tail + a * span * 0.2, 17.0, INK)  # the swivel mount under the breech
	ci.draw_circle(tail + a * span * 0.2, 14.5, GOLD_DARK)
	ci.draw_colored_polygon(_barrel(tail - a * 3.0, a, n, span + 6.0, 3.0), INK)
	ci.draw_colored_polygon(_barrel(tail, a, n, span, 0.0), GOLD)
	ci.draw_line(tail + a * span * 0.05 + n * 5.0, tail + a * span * 0.84 + n * 3.5, GOLD_HI, 3.0)
	ci.draw_line(tail + a * span * 0.05 - n * 8.0, tail + a * span * 0.84 - n * 6.0, GOLD_DARK, 2.5)
	for s: float in CANNON_BANDS:
		var hw: float = lerpf(12.0, 8.5, s / 0.72)
		ci.draw_line(tail + a * span * s + n * hw, tail + a * span * s - n * hw, GOLD_DARK, 3.0)
	ci.draw_line(tail + a * span * 0.88 + n * 10.0, tail + a * span * 0.88 - n * 10.0, INK, 2.0)
	ci.draw_line(tip - a * 1.5 + n * 7.0, tip - a * 1.5 - n * 7.0, INK, 3.5)  # the bore's lip
	ci.draw_circle(tail - a * 4.0, 7.5, INK)  # the breech knob
	ci.draw_circle(tail - a * 4.0, 5.5, GOLD)


static func _barrel(
	at: Vector2, a: Vector2, n: Vector2, k: float, grow: float
) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	for q: Vector2 in CANNON_PROFILE:
		@warning_ignore("return_value_discarded")
		pts.append(at + a * k * q.x + n * (q.y + grow))
	for i: int in range(CANNON_PROFILE.size() - 1, -1, -1):
		var q: Vector2 = CANNON_PROFILE[i]
		@warning_ignore("return_value_discarded")
		pts.append(at + a * k * q.x - n * (q.y + grow))
	return pts


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
