class_name BladeLines
extends Node2D
## n31 melee 01a dev overlay: the measured blade segment (magenta) and crescent outline (green)
## as thin lines on the views' own layer: a rendered frame shows if they sit on the drawn blade.

const BLADE: Color = Color(1.0, 0.0, 1.0)
const CRESCENT: Color = Color(0.0, 1.0, 0.2)

var _blade: PackedVector2Array = PackedVector2Array()
var _crescent: PackedVector2Array = PackedVector2Array()


func show_frame(frame: Dictionary) -> void:
	_blade = frame.get("blade_px", PackedVector2Array())
	_crescent = frame.get("crescent_px", PackedVector2Array())
	queue_redraw()


func _draw() -> void:
	if _blade.size() == 2:
		draw_line(_blade[0], _blade[1], BLADE, 1.5)
		draw_circle(_blade[0], 2.5, BLADE)
	if _crescent.size() > 2:
		var closed: PackedVector2Array = _crescent.duplicate()
		@warning_ignore("return_value_discarded")
		closed.append(_crescent[0])
		draw_polyline(closed, CRESCENT, 1.5)
