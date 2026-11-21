class_name FoeLauncherView
extends RefCounted
## The steel tube sits across the trooper's right shoulder. The flared back and
## striped collar distinguish its ends, even when the trooper turns to relocate.

const TROUSER_BLUE: Color = Color("#364759")
static var _tube: PackedVector2Array = PackedVector2Array(
	[
		Vector2(-43, -11),
		Vector2(-27, -7),
		Vector2(52, -7),
		Vector2(52, 7),
		Vector2(-27, 7),
		Vector2(-43, 11),
		Vector2(-43, -11)
	]
)


static func draw_launcher(view: Node2D, h: Fighter) -> void:
	var kneels: bool = h.tell_left > 0
	var ground: Vector2 = Ink.px(h.pos)
	var side: Vector2 = h.facing.rotated(PI * 0.5)
	if kneels:
		view.draw_set_transform(ground, h.facing.angle())
		_knee(view, Vector2(-16, 9), Vector2(-25, 7))
		_knee(view, Vector2(10, -11), Vector2(18, -11))
	# Foreshorten the shoulder offset in depth so a left-facing tube clears the helmet.
	var offset: Vector2 = Vector2(side.x, side.y * 0.35) * 0.30
	var shoulder: Vector2 = h.pos + offset + Vector2.UP * (0.58 if kneels else 0.95)
	view.draw_set_transform(Ink.px(shoulder), h.facing.angle())
	view.draw_colored_polygon(_tube, FoeTurretView.STEEL)
	view.draw_polyline(_tube, Ink.INK, 3.0, true)
	view.draw_line(Vector2(-40, -8), Vector2(-40, 8), FoeTurretView.DARK, 5.0, true)
	Ink.box(view, Vector2(0.67, 0.0), Vector2(0.43, 0.40), FoeTurretView.AMBER)
	view.draw_line(Vector2(28, -8), Vector2(36, 8), Ink.INK, 4.0, true)
	Ink.box(view, Vector2(1.08, 0.0), Vector2(0.19, 0.49), FoeTurretView.DARK)
	view.draw_line(Vector2(-27, -5), Vector2(15, -5), Ink.CREAM, 2.0, true)
	view.draw_set_transform(Vector2.ZERO, 0.0)


static func _knee(view: Node2D, knee: Vector2, boot: Vector2) -> void:
	var leg: PackedVector2Array = PackedVector2Array([Vector2.ZERO, knee, boot])
	view.draw_polyline(leg, Ink.INK, 13.0, true)
	view.draw_line(Vector2.ZERO, knee, TROUSER_BLUE, 8.0, true)
	view.draw_line(knee, boot, FoeTurretView.DARK, 7.0, true)
