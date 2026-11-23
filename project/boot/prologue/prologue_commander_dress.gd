class_name PrologueCommanderDress
extends Node2D
## A split-skirt service coat, cap band and short wood-stock gun over the posed
## officer. The same silhouette follows his ground position outside the rig bubble.

const CAP: Texture2D = preload("res://features/characters/art/view/p70/cop_cap_card.png")
const WOOL: Color = Color("#343847")
const LAPEL: Color = Color("#596075")
const BRASS: Color = Color("#d9c99b")

var pump: float = -1.0
var _chest: Vector2
var _head: Vector2
var _face: Vector2
var _frame: Vector2i


func pose(at: Vector2, chest: Vector2, head: Vector2, face: Vector2, frame: Vector2i) -> void:
	position = at
	_chest = chest
	_head = head
	_face = face
	_frame = frame
	queue_redraw()


func _draw() -> void:
	# The collar stays at the shoulders while the vent and weighted hem trail the turn.
	var tilt: float = _face.x * 0.20
	draw_set_transform(_chest, tilt)
	var coat: PackedVector2Array = PackedVector2Array(
		[
			Vector2(-13, -5),
			Vector2(-8, -10),
			Vector2(8, -10),
			Vector2(13, -5),
			Vector2(9, 2),
			Vector2(14, 16),
			Vector2(3, 17),
			Vector2(0, 12),
			Vector2(-3, 17),
			Vector2(-14, 16),
			Vector2(-9, 2)
		]
	)
	draw_colored_polygon(coat, WOOL)
	@warning_ignore("return_value_discarded")
	coat.append(coat[0])
	draw_polyline(coat, Ink.INK, 2.0, true)
	_lapels()
	draw_set_transform(_chest)
	_shotgun(_face)
	_cap()


func _lapels() -> void:
	for side: int in [-1, 1]:
		draw_colored_polygon(
			PackedVector2Array(
				[
					Vector2(side * 9, -7),
					Vector2(side * 3, -6),
					Vector2(0, 7),
					Vector2(side * 6, 0),
					Vector2(side * 4, -2)
				]
			),
			LAPEL
		)
		draw_line(Vector2(side * 11, -5), Vector2(side * 7, -7), BRASS, 2)
		for y: int in [5, 10]:
			draw_circle(Vector2(side * 3, y), 1.1, BRASS)


func _shotgun(face: Vector2) -> void:
	var dir: Vector2 = face.normalized()
	var rack: float = sin(PI * maxf(pump, 0.0))
	dir = dir.rotated(rack * 0.32)
	var stock: Vector2 = dir.orthogonal() * 9 - dir * (3.0 + rack * 3.0)
	var muzzle: Vector2 = stock + dir * 25
	draw_line(stock - dir * 5, muzzle, Ink.INK, 6, true)
	draw_line(stock - dir * 4, stock + dir * 9, Color("#967653"), 4, true)
	draw_line(stock + dir * 10, muzzle, Color("#78808a"), 2, true)
	var slide: Vector2 = stock + dir * (17.0 - rack * 7.0)
	draw_line(slide - dir * 4, slide + dir * 3, BRASS, 3.5, true)


func _cap() -> void:
	var size_px: Vector2 = Vector2(CAP.get_width() / 5.0, CAP.get_height())
	draw_set_transform(_head, 0.0, Vector2(-1 if _frame.y else 1, 1))
	draw_texture_rect_region(
		CAP, Rect2(-13, -15, 26, 20), Rect2(Vector2(_frame.x * size_px.x, 0), size_px)
	)
	# Brass cap band and badge pick out the black peak from the patrol's blue helmets.
	draw_line(Vector2(-7, -6), Vector2(7, -5), BRASS, 2.0, true)
	draw_circle(Vector2(1, -8), 1.8, BRASS)
	draw_set_transform(Vector2.ZERO)
