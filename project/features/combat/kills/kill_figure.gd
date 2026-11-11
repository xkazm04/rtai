class_name KillFigure
extends RefCounted
## n16 kills-polish: where a kill body's drawn figure is. A body group's origin is its sprites'
## mean origin (about the hips, or the feet of an upright walker card), so an effect centred there
## sat on the legs (the ray gun's mask, the burn's embers and smoke). The box of the body's own
## sprites, cached on the body the first time it is asked, says where the man is drawn.

const BOX: StringName = &"kill_figure_box"


## The box of `body`'s direct Sprite2D children in its local pixels (none: a square of half side
## `r` on the origin).
static func box(body: Node2D, r: float) -> Rect2:
	var out: Rect2 = Rect2()
	var any: bool = false
	for ch: Node in body.get_children():
		var spr: Sprite2D = ch as Sprite2D
		if spr == null or spr.texture == null:
			continue
		var b: Rect2 = spr.transform * spr.get_rect()
		out = out.merge(b) if any else b
		any = true
	return out if any else Rect2(-Vector2.ONE * r, Vector2.ONE * r * 2.0)


## The cached box (computed on the first call: after the card swaps of the kill frame).
static func cached(body: Node2D, r: float) -> Rect2:
	if not body.has_meta(BOX):
		body.set_meta(BOX, box(body, r))
	var b: Rect2 = body.get_meta(BOX)
	return b


## The point at `u` on the figure in the body's parent space (x -1..1 across, y -1 head..1 feet).
static func at(body: Node2D, u: Vector2, r: float = 8.0) -> Vector2:
	var b: Rect2 = cached(body, r)
	return body.transform * (b.get_center() + u * b.size * 0.5)
