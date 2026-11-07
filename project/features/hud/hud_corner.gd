class_name HudCorner
extends Node2D
## n8-hud: one of the HUD's top corners as its own canvas item, so it can turn see-through
## (HudSee) on its own: `paint` draws the corner onto this node; `rect` is what it covered on the
## last draw (screen px), the box HudSee tests the clear points against.

var paint: Callable = Callable()
var rect: Rect2 = Rect2()
var alpha: float = 1.0


func _draw() -> void:
	if paint.is_valid():
		paint.call(self)


## Eases the alpha by `dt` seconds against the clear points and applies it.
func fade(points: PackedVector2Array, dt: float) -> void:
	alpha = HudSee.step(alpha, HudSee.covers(rect, points), dt)
	modulate = Color(1.0, 1.0, 1.0, alpha)
	queue_redraw()
