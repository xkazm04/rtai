class_name FoeTurretView
extends RefCounted
## A bolted foot, fixed hazard apron and rotating gun carriage, in Ink's world pixels.

const STEEL: Color = Color("#626674")
const DARK: Color = Color("#393b49")
const AMBER: Color = Color("#edab42")
const HEAD: Texture2D = preload("res://features/characters/art/thug/helmet.png")


static func draw_mount(view: Node2D, h: Fighter, heat: float) -> void:
	var at: Vector2 = Ink.px(h.pos)
	view.draw_set_transform(at, 0.0)
	Ink.box(view, Vector2(0, 0.08), Vector2(1.48, 1.22), DARK)
	Ink.box(view, Vector2(0, -0.08), Vector2(1.36, 1.08), STEEL)
	view.draw_rect(Rect2(-31, 15, 62, 8), AMBER)
	for x: int in range(-25, 30, 13):
		view.draw_line(Vector2(x, 15), Vector2(x - 5, 23), Ink.INK, 5.0)
	for x: int in [-26, 26]:
		view.draw_circle(Vector2(x, -19), 3.0, Ink.CREAM)
	view.draw_set_transform(at + Vector2(0, -6), h.facing.angle())
	Ink.box(view, Vector2(0.69, 0), Vector2(1.26, 0.29), STEEL)
	Ink.box(view, Vector2(1.19, 0), Vector2(0.28, 0.37), DARK)
	Ink.disc(view, Vector2.ZERO, 0.46, DARK)
	view.draw_texture_rect(HEAD, Rect2(-19, -18, 38, 36), false)
	if heat > 0.0:
		view.draw_circle(Vector2(58, 0), 13.0, Color(AMBER, heat * 0.4))
		view.draw_line(Vector2(26, 0), Vector2(59, 0), Color(AMBER, heat), 7.0, true)
	view.draw_set_transform(Vector2.ZERO, 0.0)
