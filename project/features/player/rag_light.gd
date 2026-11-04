class_name RagLight
extends Node2D
## rivet-arsenal: the molotov's draw is lighting the rag (rivet_arsenal.json thrown: "draw is
## lighting the rag"). While the bottle comes up, a flame catches at its rag end: an inked star,
## vermilion with a cream core, growing from a spark to the lit flame over the draw and flickering
## on the frame count. Render only; RivetHeldView places it each frame.

const SPARK_M: float = 0.05
const FLAME_M: float = 0.16
const POINTS: int = 6

var k: float = 0.0
var flicker: int = 0


## Shows the flame at a global position, `draw_k` (0..1) through the draw.
func light(at: Vector2, draw_k: float, frame: int) -> void:
	global_position = at
	k = clampf(draw_k, 0.0, 1.0)
	flicker = frame
	visible = true
	queue_redraw()


func _draw() -> void:
	var r: float = lerpf(SPARK_M, FLAME_M, k) * WeaponArt.WORLD_PX_PER_M
	var turn: float = float(flicker % 4) * PI / float(POINTS * 2)
	draw_colored_polygon(_star(r * 1.25, turn), Ink.INK)
	draw_colored_polygon(_star(r, turn), Ink.VERMILION)
	draw_colored_polygon(_star(r * 0.45, -turn), Ink.CREAM)


func _star(r: float, turn: float) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in POINTS * 2:
		var rad: float = r if i % 2 == 0 else r * 0.45
		@warning_ignore("return_value_discarded")
		pts.append(Vector2.from_angle(turn + TAU * float(i) / float(POINTS * 2)) * rad)
	return pts
