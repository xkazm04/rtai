class_name FoeWalkerCrackView
extends RefCounted
## Local chassis pixels. The feet remain planted as the chassis sinks and its halves lift apart.

const SAG_PX: float = 7.0
const LIFT_PX: float = 5.0
const SPLIT: PackedVector2Array = [
	Vector2(19, -17), Vector2(15, -6), Vector2(22, -1), Vector2(16, 6), Vector2(19, 17)
]


static func plates(view: Node2D, sag: bool, opened: bool) -> void:
	if sag:
		for side: int in [-1, 1]:
			var edge: PackedVector2Array = [
				Vector2(9, side * 22), Vector2(24, side * 19), Vector2(28, side * 8)
			]
			view.draw_polyline(edge, Ink.INK, 7.0, true)
			view.draw_polyline(edge, FoeTurretView.STEEL, 3.0, true)
	if opened:
		view.draw_polyline(SPLIT, Ink.INK, 9.0, true)
		view.draw_polyline(SPLIT, FoeTurretView.AMBER, 6.0, true)
		view.draw_polyline(SPLIT, Ink.CREAM, 2.5, true)
