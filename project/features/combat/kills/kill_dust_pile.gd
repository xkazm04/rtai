class_name KillDustPile
extends RefCounted
## The ray gun's remains (lane brutality, style `dissolve`), render only: an irregular heap of
## glowing dust drawn out along the ray (showcase REQUEST 26: the round pile with an ink ring read
## as a cop's cap seen from above). The heap is a lumpy hashed outline, longer than wide, blown
## downstream; the empty uniform lies crumpled flat across its near half with ink fold lines; ink
## crumbs and cooling sparks are scattered along the ray. No circle. Shapes from a hash of the
## kill serial, so a replay draws the same.

const INK: Color = Color(0.07, 0.06, 0.07)
const HOT: Color = Color(1.0, 0.96, 0.78)
const DUST: Color = Color("#C9B98F")
const DUST_DARK: Color = Color("#8F805E")
const CLOTH: Color = Color("#2C4E86")
const CLOTH_DARK: Color = Color("#1B2F55")
## Half length along the ray, half width across it (metres), and the downstream shift.
const LONG_M: float = 0.62
const WIDE_M: float = 0.26
const BLOWN_M: float = 0.22
const LUMPS: int = 14
const CRUMBS: int = 9
const SPARKS: int = 16


## Draws the heap at `p` (pixels) on `ci`, grown to `g` (0..1); `axis` is the ray's direction.
static func draw(
	ci: CanvasItem, serial: int, p: Vector2, axis: Vector2, g: float, ppm: float, glow: float
) -> void:
	var ax: Vector2 = axis.normalized() if axis != Vector2.ZERO else Vector2.RIGHT
	var side: Vector2 = ax.orthogonal()
	var c: Vector2 = p + ax * BLOWN_M * ppm * g
	var heap: PackedVector2Array = _outline(serial, c, ax, side, ppm * g, 0)
	var under: PackedVector2Array = PackedVector2Array()
	for q: Vector2 in heap:  # the ink under-print: the heap's own shape, a touch larger and lower
		@warning_ignore("return_value_discarded")
		under.append(c + (q - c) * 1.08 + Vector2(0.0, 1.5))
	KillPoly.fill(ci, under, INK)
	KillPoly.fill(ci, heap, DUST)
	_shade(ci, serial, c, ax, side, ppm * g)
	_cloth(ci, serial, p, ax, side, ppm * g)
	_crumbs(ci, serial, c, ax, side, ppm, g, glow)


## A lumpy outline: an ellipse along the ray whose radius wobbles per lump (hashed).
static func _outline(
	serial: int, c: Vector2, ax: Vector2, side: Vector2, s: float, key: int
) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	for n: int in LUMPS:
		var a: float = TAU * float(n) / LUMPS
		var wob: float = 0.72 + 0.42 * _h(serial, n + key)
		var tail: float = 1.25 if cos(a) > 0.0 else 0.85  # drawn out downstream
		@warning_ignore("return_value_discarded")
		pts.append(c + (ax * cos(a) * LONG_M * tail + side * sin(a) * WIDE_M) * wob * s)
	return pts


## A darker drift on the heap's far side, so it reads as a mound, not a flat disc.
static func _shade(
	ci: CanvasItem, serial: int, c: Vector2, ax: Vector2, side: Vector2, s: float
) -> void:
	var drift: PackedVector2Array = PackedVector2Array()
	var o: Vector2 = c + side * WIDE_M * 0.35 * s + ax * LONG_M * 0.2 * s
	for n: int in 8:
		var a: float = TAU * float(n) / 8.0
		var wob: float = 0.7 + 0.4 * _h(serial, n + 30)
		@warning_ignore("return_value_discarded")
		drift.append(o + (ax * cos(a) * 0.4 + side * sin(a) * 0.09) * wob * s)
	KillPoly.fill(ci, drift, DUST_DARK)


## The empty uniform: a flat crumpled cloth on the near half, its folds inked.
static func _cloth(
	ci: CanvasItem, serial: int, p: Vector2, ax: Vector2, side: Vector2, s: float
) -> void:
	var cloth: PackedVector2Array = PackedVector2Array()
	var o: Vector2 = p - ax * 0.12 * s
	for n: int in 11:
		var a: float = TAU * float(n) / 11.0
		var rr: float = 0.65 + 0.5 * _h(serial, n + 60)
		@warning_ignore("return_value_discarded")
		cloth.append(o + (ax * cos(a) * 0.42 + side * sin(a) * 0.26) * rr * s)
	KillPoly.fill(ci, cloth, CLOTH)
	@warning_ignore("return_value_discarded")
	cloth.append(cloth[0])
	ci.draw_polyline(cloth, INK, 2.0, true)
	for n: int in 3:  # fold lines across the cloth
		var k: float = (float(n) - 1.0) * 0.14 + 0.06 * (_h(serial, n + 70) - 0.5)
		var a0: Vector2 = o + ax * k * s - side * 0.12 * s
		var a1: Vector2 = o + ax * (k + 0.08) * s + side * 0.13 * s
		ci.draw_line(a0, a1, CLOTH_DARK if n != 1 else INK, 2.0 if n != 1 else 1.5)


## Ink crumbs and cooling sparks scattered along the ray, past both ends of the heap.
static func _crumbs(
	ci: CanvasItem,
	serial: int,
	c: Vector2,
	ax: Vector2,
	side: Vector2,
	ppm: float,
	g: float,
	glow: float
) -> void:
	for n: int in CRUMBS:
		var along: float = (_h(serial, n + 110) * 2.0 - 0.7) * LONG_M * 1.6
		var across: float = (_h(serial, n + 130) - 0.5) * WIDE_M * 2.4
		var at: Vector2 = c + (ax * along + side * across) * ppm * g
		ci.draw_circle(at, (0.02 + 0.025 * _h(serial, n + 150)) * ppm + 0.6, INK)
	for n: int in SPARKS:  # the dust still glows, cooling slowly to a faint shimmer
		var along: float = (_h(serial, n + 170) * 2.0 - 1.0) * LONG_M * 1.1
		var across: float = (_h(serial, n + 190) - 0.5) * WIDE_M * 1.4
		var at: Vector2 = c + (ax * along + side * across) * ppm * g
		ci.draw_circle(at, 0.022 * ppm + 0.8, Color(HOT, glow))


static func _h(serial: int, key: int) -> float:
	return fposmod(sin(float(serial) * 12.9898 + float(key) * 78.233) * 43758.5453, 1.0)
