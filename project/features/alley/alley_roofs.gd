class_name AlleyRoofs
extends Node2D
## n5-look: the alley's buildings seen from straight above (target r2_a6: brick buildings either
## side of a narrow lane): a tar roof (sparse hatch, gravel), a brick lip and a cream coping of
## stones along the alley face, AC boxes with a fan and vent stacks on the roof, a drainpipe on
## the face; a doorway gap stays a dark side passage between buildings. Drawn on the ground
## band over the floor view's flat wall slabs (the station's wall_high props stay the collision).
## Reads data only (alley_decor.json "roofs" + the station's walls), never the sim.

const TAR: Color = Color("#A48A72")
const BRICK: Color = Color("#B07F62")
const STONE: Color = Color("#D9CDB6")
const RECESS: Color = Color("#5C544D")
const LIP_M: float = 0.95
const COPING_M: float = 0.32
const COURSE_M: float = 0.16
const STONE_M: float = 0.6
const AC_EVERY_M: float = 6.5
const PIPE_EVERY_M: float = 9.0

var _roofs: Array[Rect2] = []
var _walls: Array[Rect2] = []
var _mid_px: float = 0.0


func _init(rows: Dictionary, base: Vector2, walls: Array[Rect2], mid_px: float) -> void:
	for r: Variant in rows.get("roofs", []):
		_roofs.append(AlleyDecor.rect_px(r, base))
	_walls = walls
	_mid_px = mid_px


func _draw() -> void:
	for r: Rect2 in _roofs:
		draw_rect(r, RECESS, true)  # the side passages: what no wall strip covers
	for w: Rect2 in _walls:
		if w.size.y >= 1.0 * Ink.PX_PER_M:  # every building (the fence is the thin cross wall)
			_tar(_merged(w) if w.size.x < w.size.y else w)
	for w: Rect2 in _walls:
		if w.size.x < w.size.y:
			_face(w)


## The wall strip widened out to the roof behind it, so one tar slab spans strip and building.
func _merged(w: Rect2) -> Rect2:
	for r: Rect2 in _roofs:
		if r.grow(1.0).intersects(w):
			var x0: float = minf(r.position.x, w.position.x)
			var x1: float = maxf(r.end.x, w.end.x)
			return Rect2(x0, w.position.y, x1 - x0, w.size.y)
	return w


func _tar(r: Rect2) -> void:
	draw_rect(r, TAR, true)
	var step: float = 0.9 * Ink.PX_PER_M
	var y: float = r.position.y + fposmod(-r.position.y, step)
	while y < r.end.y:  # sparse diagonal hatch, world-locked
		var a: Vector2 = Vector2(r.position.x, y)
		var b: Vector2 = a + Vector2(minf(r.size.x, r.end.y - y), minf(r.size.x, r.end.y - y))
		draw_line(a, b, Color(Ink.INK, 0.18), 1.0)
		y += step
	var n: int = int(r.size.y / (AC_EVERY_M * Ink.PX_PER_M))
	for i: int in n:
		var cy: float = r.position.y + (i + 0.5) * AC_EVERY_M * Ink.PX_PER_M
		var cx: float = r.get_center().x + (0.22 if i % 2 == 0 else -0.18) * r.size.x
		_ac(Vector2(cx, cy))
		_vent(Vector2(cx + (0.9 if i % 2 == 0 else -0.8) * Ink.PX_PER_M, cy + 1.7 * Ink.PX_PER_M))
	draw_rect(r, Ink.INK, false, Ink.LINE_PX)


## An AC box from above: a 1.1 m housing, a fan circle with spokes, a soft ink drop shadow.
func _ac(c: Vector2) -> void:
	var s: float = 1.1 * Ink.PX_PER_M
	var box: Rect2 = Rect2(c - Vector2(s, s) * 0.5, Vector2(s, s))
	draw_rect(Rect2(box.position + Vector2(4.0, 4.0), box.size), Color(Ink.INK, 0.35), true)
	draw_rect(box, STONE, true)
	draw_rect(box, Ink.INK, false, 2.0)
	draw_circle(c, s * 0.36, Color(Ink.INK, 0.85))
	for k: int in 6:
		var a: float = TAU * k / 6.0
		draw_line(c, c + Vector2(cos(a), sin(a)) * s * 0.34, STONE, 1.5)
	draw_circle(c, s * 0.08, STONE)


func _vent(c: Vector2) -> void:
	var r: float = 0.22 * Ink.PX_PER_M
	draw_circle(c + Vector2(3.0, 3.0), r, Color(Ink.INK, 0.35))
	draw_circle(c, r, STONE)
	draw_arc(c, r, 0.0, TAU, 16, Ink.INK, 2.0)
	draw_circle(c, r * 0.45, Ink.INK)


## The alley face of a building: a brick lip (courses, staggered joints), the coping stones on
## top of it, and a drainpipe with brackets every PIPE_EVERY_M.
func _face(w: Rect2) -> void:
	var east: bool = w.get_center().x < _mid_px  # the west building faces east
	var lip_w: float = LIP_M * Ink.PX_PER_M
	var x_lip: float = w.end.x - lip_w if east else w.position.x
	var lip: Rect2 = Rect2(x_lip, w.position.y, lip_w, w.size.y)
	draw_rect(lip, BRICK, true)
	var course: float = COURSE_M * Ink.PX_PER_M
	var row: int = 0
	var y: float = lip.position.y
	while y < lip.end.y:
		draw_line(Vector2(lip.position.x, y), Vector2(lip.end.x, y), Color(Ink.INK, 0.55), 1.0)
		var jx: float = lip.position.x + lip_w * (0.33 if row % 2 == 0 else 0.72)
		var y1: float = minf(y + course, lip.end.y)
		draw_line(Vector2(jx, y), Vector2(jx, y1), Color(Ink.INK, 0.5), 1.0)
		y += course
		row += 1
	var cw: float = COPING_M * Ink.PX_PER_M
	var cop: Rect2 = Rect2(x_lip - cw if east else lip.end.x, w.position.y, cw, w.size.y)
	draw_rect(cop, STONE, true)
	var s: float = cop.position.y + STONE_M * Ink.PX_PER_M
	while s < cop.end.y:
		draw_line(Vector2(cop.position.x, s), Vector2(cop.end.x, s), Ink.INK, 1.5)
		s += STONE_M * Ink.PX_PER_M
	draw_rect(cop, Ink.INK, false, 2.0)
	draw_rect(lip, Ink.INK, false, Ink.LINE_PX)
	var px: float = lip.end.x - 4.0 if east else lip.position.x + 4.0
	var p: float = lip.position.y + PIPE_EVERY_M * 0.5 * Ink.PX_PER_M
	while p < lip.end.y:  # a drainpipe: a short cream run down the face, two brackets
		draw_line(Vector2(px, p), Vector2(px, p + 2.4 * Ink.PX_PER_M), STONE, 5.0)
		var bracket: float = p + 0.6 * Ink.PX_PER_M
		draw_line(Vector2(px - 5.0, bracket), Vector2(px + 5.0, bracket), Ink.INK, 2.0)
		p += PIPE_EVERY_M * Ink.PX_PER_M
