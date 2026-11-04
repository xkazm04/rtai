class_name AlleyDecor
extends Node2D
## n5-look: the alley's set dressing in quest 1's ink, from data/tables/alley_decor.json. Two
## instances: the ground one (puddles, the chain-link fence, litter) on the world print, and the
## overhead one (fire escapes seen from straight above: landing grates and stair treads) on the
## roof_occluders band, above the cast. A fire escape stands 3 m+ up, always over a 1.8 m fighter,
## so one order holds in every pose (registry depth-ordered-layered-art: no interlock to split).
## Reads data only, never the sim.

const PUDDLE: Color = Color(0.090, 0.075, 0.106, 0.62)
const GRATE_STEP_M: float = 0.25
const TREAD_STEP_M: float = 0.3
const MESH_STEP_M: float = 0.2

var _rows: Dictionary = {}
var _base: Vector2 = Vector2.ZERO
var _overhead: bool = false


func _init(rows: Dictionary, base: Vector2, overhead: bool) -> void:
	_rows = rows
	_base = base
	_overhead = overhead


func _draw() -> void:
	if _overhead:
		for e: Variant in _rows.get("escapes", []):
			_escape(_rect(e))
		return
	for p: Variant in _rows.get("puddles", []):
		_puddle(_rect(p))
	for f: Variant in _rows.get("fences", []):
		_fence(_rect(f))


func _rect(v: Variant) -> Rect2:
	var raw: Array = v if v is Array else [0, 0, 0, 0]
	var a: PackedFloat32Array = PackedFloat32Array(raw)
	var at: Vector2 = _base + Vector2(a[0], a[1])
	return Rect2(Ink.px(at), Vector2(a[2], a[3]) * Ink.PX_PER_M)


## A puddle: a dark ink pool with a cream glint along its upper-left rim.
func _puddle(r: Rect2) -> void:
	var c: Vector2 = r.get_center()
	var rad: Vector2 = r.size * 0.5
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in 20:
		var a: float = TAU * i / 20.0
		var k: float = 1.0 + 0.12 * sin(a * 3.0 + c.x * 0.01)
		@warning_ignore("return_value_discarded")
		pts.append(c + Vector2(cos(a) * rad.x, sin(a) * rad.y) * k)
	draw_colored_polygon(pts, PUDDLE)
	draw_arc(c, minf(rad.x, rad.y) * 0.7, PI * 1.05, PI * 1.45, 6, Ink.CREAM, Ink.LINE_PX)


## A chain-link run: posts every 2.5 m, a 45-degree mesh between the rails.
func _fence(r: Rect2) -> void:
	var long_x: bool = r.size.x >= r.size.y
	var step: float = MESH_STEP_M * Ink.PX_PER_M
	var n: int = int(maxf(r.size.x, r.size.y) / step)
	var w: float = minf(r.size.x, r.size.y)
	for i: int in n:
		var o: float = step * i
		var a: Vector2 = r.position + (Vector2(o, 0.0) if long_x else Vector2(0.0, o))
		var b: Vector2 = a + (Vector2(w, w) if long_x else Vector2(w, w))
		draw_line(a, b.min(r.end), Ink.INK, 1.0)
	draw_rect(r, Ink.INK, false, Ink.LINE_PX)


## A fire escape from above: the landing's grate and a stair run of treads beside it.
func _escape(r: Rect2) -> void:
	draw_rect(r, Color(0.090, 0.075, 0.106, 0.35), true)
	var step: float = GRATE_STEP_M * Ink.PX_PER_M
	var x: float = r.position.x + step
	while x < r.end.x:
		draw_line(Vector2(x, r.position.y), Vector2(x, r.end.y), Ink.INK, 1.0)
		x += step
	draw_rect(r, Ink.INK, false, Ink.LINE_PX * 1.5)
