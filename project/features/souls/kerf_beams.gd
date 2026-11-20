class_name KerfBeams
extends Node2D
## Tail lights in the body's ground axes. The camera applies ground_k() to their y component.
## The flight host lifts their common origin with the body.

const COUNT: int = 3
const GLOW: Color = Color("#2ec4b659")
const INK: Color = Color(0.09, 0.08, 0.07, 0.35)
const CORE: Color = Color(0.85, 1.0, 0.96)
## Rear cable manifold in each facing, as a fraction of the hover cell. Both pitches share it.
const SOCKETS: Array[Vector2] = [
	Vector2(0.50, 0.33),
	Vector2(0.34, 0.37),
	Vector2(0.32, 0.46),
	Vector2(0.26, 0.58),
	Vector2(0.50, 0.76),
]

var charges: int = COUNT
var recharge: float = 0.0
var fast: float = 0.0
var tick: int = 0
var reduced_motion: bool = false
var tail_x: float = -0.55 * SimConst.PX_PER_M


func attach_to_cell(sprite: Sprite2D) -> void:
	var uv: Vector2 = SOCKETS[sprite.frame_coords.y] - Vector2(0.5, 0.5)
	if sprite.flip_h:
		uv.x = -uv.x
	var cell: Vector2 = sprite.texture.get_size() / Vector2(sprite.hframes, sprite.vframes)
	tail_x = 0.0
	global_position = sprite.to_global(uv * cell)


func length_m(i: int) -> float:
	var full: float = lerpf(0.9, 3.2, fast)
	if i < charges:
		return full
	return full * recharge if i == charges else 0.0


func _draw() -> void:
	for i: int in COUNT:
		var length: float = length_m(i)
		if length <= 0.0:
			continue
		var side: float = float(i - 1)
		var wave: float = 0.0 if reduced_motion else sin(tick * 0.075 + i * TAU / COUNT)
		var angle: float = deg_to_rad(side * 7.0 + wave * 3.0) * (1.0 - fast)
		var start: Vector2 = Vector2(tail_x, -side * 0.12 * fast * SimConst.PX_PER_M)
		var end: Vector2 = start + Vector2.LEFT.rotated(angle) * length * SimConst.PX_PER_M
		draw_line(start, end, INK, 0.07 * SimConst.PX_PER_M, true)
		draw_line(start, end, GLOW, 0.14 * SimConst.PX_PER_M, true)
		draw_line(start, end, CORE, 0.035 * SimConst.PX_PER_M, true)
