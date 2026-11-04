class_name FightScorchArt
extends RefCounted
## The ink char under a fire patch (molotov, flamethrower, burning ground), drawn in the D5 print:
## a ragged soot blotch with tongues licking out, a darker char core, a broken ink edge and a few
## cinder specks past the rim. It replaces a flat grey disc that read as a debug area circle.
## The shape comes from a hash of the patch centre, so a patch keeps its outline every frame and
## two patches never match. View only: it reads the sim, never writes it, and takes no RNG
## stream. Lane gunplay.

const POINTS: int = 18
const CORE_POINTS: int = 12
const CINDERS: int = 7
const STREAKS: int = 9
const HATCHES: int = 6
const SOOT_A: float = 0.24
const CORE_A: float = 0.50
const EDGE_A: float = 0.85
const EDGE_PX: float = 3.0


## The char of a patch of radius r_m metres at c (metres); k fades it (1 = fresh, 0 = gone).
static func blotch(ci: CanvasItem, c: Vector2, r_m: float, k: float) -> void:
	if k <= 0.0 or r_m <= 0.0:
		return
	var key: int = _seed(c)
	var r: float = r_m * Ink.PX_PER_M
	var at: Vector2 = Ink.px(c)
	var rim: PackedVector2Array = _ring(at, r, POINTS, key, true)
	ci.draw_colored_polygon(rim, Color(Ink.INK, SOOT_A * k))
	var core: PackedVector2Array = _ring(at, r * 0.55, CORE_POINTS, key + 101, false)
	ci.draw_colored_polygon(core, Color(Ink.INK, CORE_A * k))
	_edge(ci, rim, key, k)
	_streaks(ci, at, r, key, k)
	_hatch(ci, at, r, key, k)
	for i: int in CINDERS:
		var ang: float = TAU * _h(key + 300 + i)
		var dist: float = r * (1.08 + 0.32 * _h(key + 320 + i))
		var size: float = 1.5 + 3.0 * _h(key + 340 + i)
		ci.draw_circle(at + Vector2.from_angle(ang) * dist, size, Color(Ink.INK, 0.7 * k))


## A star-shaped ring of n points round at: each point's reach varies, and with tongues every
## third one licks out past the rim (the flame's run-off). Angles stay in order, so the polygon
## never crosses itself.
static func _ring(at: Vector2, r: float, n: int, key: int, tongues: bool) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	var turn: float = TAU * _h(key + 7)
	for i: int in n:
		var ang: float = turn + TAU * (float(i) + 0.35 * _h(key + 40 + i)) / float(n)
		var reach: float = 0.80 + 0.28 * _h(key + 80 + i)
		if tongues and i % 3 == 1:
			reach = 1.08 + 0.30 * _h(key + 120 + i)
		@warning_ignore("return_value_discarded")
		out.append(at + Vector2.from_angle(ang) * r * reach)
	return out


## The blotch's ink edge, broken: about half the sides are inked, so it prints like a hand
## line, not a stencilled circle.
static func _edge(ci: CanvasItem, rim: PackedVector2Array, key: int, k: float) -> void:
	var n: int = rim.size()
	for i: int in n:
		if _h(key + 200 + i) < 0.5:
			continue
		ci.draw_line(rim[i], rim[(i + 1) % n], Color(Ink.INK, EDGE_A * k), EDGE_PX)


## The splash burn: soot streaks thrown out of the core where the fire ran, each a heavy ink
## stroke that thins toward its tip.
static func _streaks(ci: CanvasItem, at: Vector2, r: float, key: int, k: float) -> void:
	var c: Color = Color(Ink.INK, 0.6 * k)
	for i: int in STREAKS:
		var dir: Vector2 = Vector2.from_angle(TAU * (float(i) + 0.6 * _h(key + 400 + i)) / STREAKS)
		var from: Vector2 = at + dir * r * (0.25 + 0.2 * _h(key + 420 + i))
		var tip: Vector2 = at + dir * r * (0.85 + 0.45 * _h(key + 440 + i))
		var mid: Vector2 = from.lerp(tip, 0.55)
		ci.draw_line(from, mid, c, 5.0)
		ci.draw_line(mid, tip, c, 2.0)


## A few short diagonal hatch strokes over the char, the print's own floor hatch.
static func _hatch(ci: CanvasItem, at: Vector2, r: float, key: int, k: float) -> void:
	var c: Color = Color(Ink.INK, 0.7 * k)
	var slant: Vector2 = Vector2(1.0, -1.0).normalized() * r * 0.16
	for i: int in HATCHES:
		var spot: Vector2 = (
			Vector2.from_angle(TAU * _h(key + 500 + i)) * r * 0.6 * _h(key + 520 + i)
		)
		ci.draw_line(at + spot - slant, at + spot + slant, c, Ink.LINE_PX)


## A stable int from a patch centre (5 cm cells), so the same patch draws the same char.
static func _seed(c: Vector2) -> int:
	return (roundi(c.x * 20.0) * 73856093) ^ (roundi(c.y * 20.0) * 19349663)


## A hash in [0, 1) from an int (the classic fract(sin) hash: the multiplier is far from any
## multiple of 2 pi, so neighbouring ints do not trace a slow wave).
static func _h(n: int) -> float:
	var x: float = sin(float(n % 100003) * 12.9898) * 43758.5453
	return x - floorf(x)
