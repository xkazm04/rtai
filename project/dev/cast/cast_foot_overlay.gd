class_name CastFootOverlay
extends Node2D
## Sole dots per rendered frame in screen pixels, one colour per contact, each contact bracketed.

const COLORS: Array[Color] = [Color(0.1, 0.85, 1.0), Color(1.0, 0.55, 0.1)]
const MARGIN: float = 6.0

var _groups: Array[Dictionary] = []


func add(contact: int, at: Vector2) -> void:
	if _groups.is_empty() or _groups[-1].id != contact:
		_groups.append({"id": contact, "pts": PackedVector2Array()})
	var points: PackedVector2Array = _groups[-1].pts
	@warning_ignore("return_value_discarded")
	points.append(at)
	_groups[-1].pts = points
	queue_redraw()


func _draw() -> void:
	for i: int in _groups.size():
		var color: Color = COLORS[i % 2]
		var points: PackedVector2Array = _groups[i].pts
		var box: Rect2 = Rect2(points[0], Vector2.ZERO)
		for p: Vector2 in points:
			draw_circle(p, 2.5, color)
			box = box.expand(p)
		draw_rect(box.grow(MARGIN), color, false, 2.0)
