class_name PrologueFloor
extends StageView

var yard_size_m: Vector2


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Ink.px(yard_size_m)), Ink.CREAM)
