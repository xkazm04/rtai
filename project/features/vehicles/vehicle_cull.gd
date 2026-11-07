class_name VehicleCull
extends RefCounted
## n8 vehicles: the ground rect (metres) that a canvas item's viewport shows, through every parent
## and canvas transform (the tilt's squash included), grown by `grow_m` on each side so a card whose
## ground point is just off screen still draws its roof. Not in a tree: an empty rect (no cull).


static func screen_m(item: CanvasItem, grow_m: float) -> Rect2:
	if not item.is_inside_tree():
		return Rect2()
	var to_screen: Transform2D = item.get_global_transform_with_canvas()
	var r: Rect2 = to_screen.affine_inverse() * item.get_viewport_rect()
	var px: float = SimConst.PX_PER_M
	return Rect2(r.position / px, r.size / px).grow(grow_m)


## The distance from `at` to the farthest corner of `rect` (a query radius that holds every point
## of the rect: exact for a cull test on the same points); an empty rect (no cull) -> 1e6.
static func reach_m(rect: Rect2, at: Vector2) -> float:
	if not rect.has_area():
		return 1e6
	var far: Vector2 = (rect.get_center() - at).abs() + rect.size * 0.5
	return far.length()
