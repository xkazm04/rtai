class_name GibBlob
extends Node2D
## A stand-in gib part (lane brutality) when no rig is posed for the victim: a red blob with an
## ink rim. Render only.

var radius: float = 4.0


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius * 1.25, Ink.INK)
	draw_circle(Vector2.ZERO, radius, KillView.BLOOD)
