class_name HeatClipMark
extends Node2D
## heat_clip.gd's ring on the last-seen point A (dev only): a dashed grey ring the search radius.

const R_PX: float = 3.0 * 32.0


func _init(at_px: Vector2) -> void:
	position = at_px
	z_index = 50


func _draw() -> void:
	draw_arc(Vector2.ZERO, R_PX, 0.0, TAU, 48, Color(0.1, 0.1, 0.1, 0.8), 3.0)
	draw_line(Vector2(-12, 0), Vector2(12, 0), Color(0.1, 0.1, 0.1, 0.8), 3.0)
	draw_line(Vector2(0, -12), Vector2(0, 12), Color(0.1, 0.1, 0.1, 0.8), 3.0)
