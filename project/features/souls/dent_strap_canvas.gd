class_name DentStrapCanvas
extends RefCounted
## The live seatbelt canvas forwards these commands. Headless tests record them.

var _item: CanvasItem


func _init(item: CanvasItem) -> void:
	_item = item


func stroke(path: PackedVector2Array, color: Color, width: float) -> void:
	_item.draw_polyline(path, color, width, true)


func line(a: Vector2, b: Vector2, color: Color, width: float) -> void:
	_item.draw_line(a, b, color, width, true)


func circle(c: Vector2, radius: float, color: Color) -> void:
	_item.draw_circle(c, radius, color, true, -1.0, true)


func polygon(points: PackedVector2Array, color: Color) -> void:
	_item.draw_colored_polygon(points, color)


func rect(bounds: Rect2, color: Color) -> void:
	_item.draw_rect(bounds, color)


func pose(origin: Vector2, yaw: float) -> void:
	_item.draw_set_transform(origin, yaw)
