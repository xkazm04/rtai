class_name DentJabMark
extends Node2D
## Folded steel at the drawn knuckles. The jab's six strike ticks also time the trailing strokes.

const TICKS: int = 6
const PPM: float = SimConst.PX_PER_M
const SHAPE: PackedVector2Array = [
	Vector2(0.32, -0.025),
	Vector2(0.13, 0.05),
	Vector2(0.20, 0.23),
	Vector2(0.03, 0.13),
	Vector2(-0.09, 0.27),
	Vector2(-0.10, 0.10),
	Vector2(-0.28, 0.13),
	Vector2(-0.17, 0.01),
	Vector2(-0.30, -0.10),
	Vector2(-0.10, -0.09),
	Vector2(-0.09, -0.27),
	Vector2(0.015, -0.13),
	Vector2(0.17, -0.25),
	Vector2(0.12, -0.08)
]

var _hit: bool
var _fade: float
var _teal: Color
var _aqua: Color
var _ink: Color


func _init(teal: Color, aqua: Color, ink: Color) -> void:
	_teal = teal
	_aqua = aqua
	_ink = ink


func _ready() -> void:
	top_level = true
	z_as_relative = false
	z_index = RenderLayers.z(&"fx") + 1
	hide()


func place(age: int, hit: bool, fist_px: Vector2, axis: float) -> void:
	visible = age >= 0 and age < TICKS
	if visible:
		global_position = fist_px
		global_rotation = axis
		_hit = hit
		_fade = 1.0 - float(age) / TICKS
		queue_redraw()


func _draw() -> void:
	var ink: Color = Color(_ink, _fade)
	var aqua: Color = Color(_aqua, _fade)
	for i: int in range(-1, 2):
		var end: Vector2 = Vector2(-0.28 - 0.1 * absi(i), 0.14 * i) * PPM
		var start: Vector2 = end + Vector2(-0.34 - 0.14 * (i + 1), 0.025 * i) * PPM
		draw_line(start, end, ink, 0.075 * PPM, true)
		draw_line(start, end, aqua, 0.032 * PPM, true)
	if _hit:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * PPM)
		draw_colored_polygon(SHAPE, ink)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * PPM * 0.77)
		draw_colored_polygon(SHAPE, Color(_teal, _fade))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * PPM * 0.43)
		draw_colored_polygon(SHAPE, aqua)
