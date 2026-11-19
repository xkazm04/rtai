class_name GhostShadow
extends Node2D
## The camera foreshortens this ground-space ink disc by ViewMode.ground_k() exactly once.

const INK: Color = Color(0.08, 0.10, 0.11)

var _row: GhostHoverRow.Shadow


func _init(row: GhostHoverRow.Shadow) -> void:
	_row = row


func step(ground_px: Vector2, lift_m: float) -> void:
	position = ground_px
	var k: float = clampf(1.0 - lift_m * _row.shrink_k, 0.08, 1.0)
	scale = Vector2.ONE * k
	modulate.a = k


func _draw() -> void:
	# Layer translucent ink discs, with the faintest edges on the outside.
	const RINGS: int = 12
	var coat: Color = Color(INK, 1.0 - pow(1.0 - _row.alpha, 1.0 / RINGS))
	for i: int in range(RINGS, 0, -1):
		var r: float = _row.radius_m * SimConst.PX_PER_M * i / RINGS
		draw_circle(Vector2.ZERO, r, coat, true, -1.0, true)
