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
