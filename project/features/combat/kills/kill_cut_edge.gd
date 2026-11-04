class_name KillCutEdge
extends Node2D
## The raw edge of a blade-split half (lane brutality, KillSplitFx): an ink lip along the cut
## and a red band just inside it on the half's own `side`. Drawn once (it moves with its half).

const INK: Color = KillSplitFx.INK
const RAW: Color = KillSplitFx.RAW

var a: Vector2 = Vector2.ZERO
var b: Vector2 = Vector2.ZERO
## Unit normal pointing into the half.
var side: Vector2 = Vector2.UP
## Cauterised (the plasma sword): a hot cream band in a heat bloom, no red.
var hot: bool = false


func _draw() -> void:
	var w: float = (b - a).length() * 0.13
	draw_line(a, b, INK, w * 0.55, true)
	var inset: Vector2 = side * w * 0.6
	if hot:
		var bloom: Color = Color(KillHoleFx.HOT, 0.45)
		draw_line(a + inset * 1.5, b + inset * 1.5, bloom, w * 2.6, true)
		draw_line(a.lerp(b, 0.05) + inset, b.lerp(a, 0.05) + inset, KillHoleFx.HOT, w, true)
		return
	draw_line(a.lerp(b, 0.08) + inset, b.lerp(a, 0.08) + inset, RAW, w, true)
	for i: int in 3:  # the meat shows in three ragged red dabs along the band
		var at: Vector2 = a.lerp(b, 0.25 + 0.25 * i) + inset * 1.4
		draw_circle(at, w * 0.55, RAW)
