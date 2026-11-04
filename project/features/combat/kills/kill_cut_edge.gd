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


func _draw() -> void:
	var w: float = (b - a).length() * 0.09
	draw_line(a, b, INK, w * 0.55, true)
	var inset: Vector2 = side * w * 0.6
	draw_line(a.lerp(b, 0.08) + inset, b.lerp(a, 0.08) + inset, RAW, w, true)
	for i: int in 3:  # the meat shows in three ragged red dabs along the band
		var at: Vector2 = a.lerp(b, 0.25 + 0.25 * i) + inset * 1.4
		draw_circle(at, w * 0.55, RAW)
