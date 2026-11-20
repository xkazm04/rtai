class_name GhostShadow
extends Node2D
## Both discs live on the ground. Camera zoom supplies the tilt's foreshortening.

const INK: Color = Color(0.035, 0.085, 0.09)
const LIGHT: Color = Color(0.12, 0.92, 0.76)
const RINGS: int = 22

var _row: GhostHoverRow.Shadow
var _height: float = -1.0


func _init(row: GhostHoverRow.Shadow) -> void:
	_row = row


func step(ground_px: Vector2, lift_m: float) -> void:
	position = ground_px
	if lift_m != _height:
		_height = lift_m
		queue_redraw()


func _draw() -> void:
	var height: float = maxf(0.0, _height)
	var core: float = clampf(1.0 - height * _row.shrink_k, 0.08, 1.0)
	var spread: float = 1.0 + height * _row.shrink_k
	_disc(_row.pool_m * spread, LIGHT, _row.pool_alpha / (spread * spread))
	_disc(_row.radius_m * core, INK, _row.alpha * core)


func _disc(radius_m: float, colour: Color, alpha: float) -> void:
	var coat: Color = Color(colour, 1.0 - pow(1.0 - clampf(alpha, 0.0, 0.99), 1.0 / RINGS))
	for i: int in range(RINGS, 0, -1):
		var r: float = radius_m * SimConst.PX_PER_M * i / RINGS
		draw_circle(Vector2.ZERO, r, coat, true, -1.0, true)
