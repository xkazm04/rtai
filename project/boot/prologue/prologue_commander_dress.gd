class_name PrologueCommanderDress
extends Node2D
## A split-skirt service coat, cap band and short wood-stock gun over the posed
## officer. The same silhouette follows his ground position outside the rig bubble.

const CAP: Texture2D = preload("res://features/characters/art/view/p70/cop_cap_card.png")
const WOOL: Color = Color("#343847")
const LAPEL: Color = Color("#596075")
const BRASS: Color = Color("#d9c99b")


class RackPose:
	extends RefCounted
	var axis: Vector2
	var stock: Vector2
	var shoulder: Vector2
	var elbow: Vector2
	var grip: Vector2

	func place(face: Vector2, progress: float) -> void:
		var aim: Vector2 = face.normalized()
		var side: Vector2 = aim.orthogonal()
		if side.y < 0.0:
			side = -side
		var pull: float = PrologueCommanderDress.rack_travel(progress)
		var lift: float = deg_to_rad(28.0) * pull
		axis = aim.rotated(lift if aim.x < 0.0 else -lift)
		stock = side * 9 - aim * (2.0 + pull * 3.0)
		shoulder = side * 8 - aim * 2
		elbow = shoulder + side * (7.0 + 5.0 * pull) - aim * (2.0 + 9.0 * pull)
		grip = stock + axis * lerpf(25, 10, pull)


var pump: float = -1.0
var _rack: RackPose = RackPose.new()
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
	_rack.place(face, pump)
	var dir: Vector2 = _rack.axis
	var stock: Vector2 = _rack.stock
	var muzzle: Vector2 = stock + dir * 32
	var slide: Vector2 = _rack.grip
	var arm: PackedVector2Array = PackedVector2Array([_rack.shoulder, _rack.elbow, slide])
	draw_polyline(arm, Ink.INK, 7.5, true)
	draw_polyline(arm, LAPEL, 4.5, true)
	draw_line(stock - dir * 5, muzzle, Ink.INK, 6, true)
	draw_line(stock - dir * 4, stock + dir * 9, Color("#967653"), 4, true)
	draw_line(stock + dir * 10, muzzle, Color("#78808a"), 2, true)
	draw_line(slide - dir * 4, slide + dir * 3, BRASS, 4.5, true)
	draw_circle(slide + slide.direction_to(_rack.elbow) * 2.5, 2.7, Ink.CREAM, true, -1, true)


static func rack_travel(progress: float) -> float:
	return smoothstep(0.0, 1.0, 1.0 - absf(2.0 * clampf(progress, 0, 1) - 1.0))


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
