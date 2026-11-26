class_name PropBase
extends RefCounted
## One rule in the yard and the gauntlet street: whatever blocks movement (and shots) stands on
## a dark contact base the exact size of its collision footprint. Drawn above the floor decals
## and below the prop art; nothing passable gets one.

## Near-black, a touch cool so it never reads as a warm stain on the ochre floor. Densest along
## the south edge where the object meets the ground, lighter to the north: a contact shadow.
const TINT: Color = Color(0.03, 0.03, 0.04, 0.86)
const NORTH_SHARE: float = 0.62
## The soft rim, in metres, centred on the footprint edge.
const EDGE_M: float = 0.08


## `box_m` is the collision footprint in metres; drawn in the canvas's metre-to-pixel space.
static func draw(ci: CanvasItem, box_m: Rect2, tint: Color = TINT) -> void:
	var half: float = EDGE_M * 0.5
	var inner: Rect2 = box_m.grow(-half)
	if inner.size.x <= 0.0 or inner.size.y <= 0.0:
		inner = Rect2(box_m.get_center(), Vector2.ZERO)
	var north: Color = Color(tint, tint.a * NORTH_SHARE)
	var shade: PackedColorArray = PackedColorArray([north, north, tint, tint])
	var a: PackedVector2Array = _corners(inner)
	var b: PackedVector2Array = _corners(box_m.grow(half))
	# Straight to the canvas item (same command list and transform as CanvasItem.draw_*), so a
	# recorder replaying a draw pass outside NOTIFICATION_DRAW adds commands instead of erroring.
	var item: RID = ci.get_canvas_item()
	if inner.has_area():
		RenderingServer.canvas_item_add_polygon(item, a, shade)
	for i: int in 4:
		var j: int = (i + 1) % 4
		RenderingServer.canvas_item_add_polygon(
			item,
			PackedVector2Array([a[i], a[j], b[j], b[i]]),
			PackedColorArray([shade[i], shade[j], Color(shade[j], 0.0), Color(shade[i], 0.0)])
		)


## Top-left, top-right, bottom-right, bottom-left, in pixels.
static func _corners(r: Rect2) -> PackedVector2Array:
	return PackedVector2Array(
		[
			Ink.px(r.position),
			Ink.px(Vector2(r.end.x, r.position.y)),
			Ink.px(r.end),
			Ink.px(Vector2(r.position.x, r.end.y)),
		]
	)
