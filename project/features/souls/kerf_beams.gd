class_name KerfBeams
extends Node2D
## Tail lights in the body's ground axes. The camera applies ground_k() to their y component.
## The flight host lifts their common origin with the body.

const COUNT: int = 3
const GLOW: Color = Color("#2ec4b659")
const CORE: Color = Color(0.85, 1.0, 0.96)

var charges: int = COUNT
var recharge: float = 0.0
var fast: float = 0.0
var tick: int = 0
var reduced_motion: bool = false
var tail_x: float = -0.55 * SimConst.PX_PER_M


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
		draw_line(start, end, GLOW, 0.14 * SimConst.PX_PER_M, true)
		draw_line(start, end, CORE, 0.035 * SimConst.PX_PER_M, true)
