class_name PrologueFactoryFence
extends RefCounted
## Printed factory perimeter, placed on the same metre bounds as the original yard.

const PANEL: Texture2D = preload("res://boot/prologue/art/line_fire/fence_panel.png")
const SIDE: Texture2D = preload("res://boot/prologue/art/line_fire/side_fence.png")
const LEAF: Texture2D = preload("res://boot/prologue/art/line_fire/sliding_gate.png")
const POSTS: Texture2D = preload("res://boot/prologue/art/line_fire/gate_posts.png")
const CORNER: Texture2D = preload("res://boot/prologue/art/line_fire/corner_post.png")


static func panel(canvas: PrologueFloor, box: Rect2) -> void:
	var plan: PrologueYard = canvas.plan
	if box.size.y > box.size.x:
		if box.end.y == plan.gate.y and box.position.y > plan.yard.position.y:
			_post(canvas, box, box.position.x > plan.gate.x)
		else:
			var side: Rect2 = Rect2(box.get_center().x - 0.16, box.position.y, 0.32, box.size.y)
			_bays(canvas, side, SIDE, Vector2.AXIS_Y, 6.0)
		return
	var rail: Rect2 = Rect2(box.position.x, box.end.y - 1.45, box.size.x, 1.45)
	_bays(canvas, rail, PANEL, Vector2.AXIS_X, 9.6)
	if box.end.y == plan.gate.y:
		_corner(canvas, box, box.position.x > plan.gate.x)


static func _bays(canvas: CanvasItem, box: Rect2, art: Texture2D, axis: int, bay_m: float) -> void:
	var count: int = maxi(1, roundi(box.size[axis] / bay_m))
	var tile: Rect2 = box
	tile.size[axis] /= float(count)
	for i: int in count:
		tile.position[axis] = box.position[axis] + i * tile.size[axis]
		canvas.draw_texture_rect(art, PrologueYardPaint.pixels(tile), false)


static func _corner(canvas: CanvasItem, rail: Rect2, east: bool) -> void:
	var size_m: Vector2 = Vector2(2.25, 2.44)
	var foot: Vector2 = Vector2(rail.end.x if east else rail.position.x, rail.end.y)
	canvas.draw_set_transform(Ink.px(foot), 0.0, Vector2(1 if east else -1, 1))
	canvas.draw_texture_rect(CORNER, PrologueYardPaint.pixels(Rect2(-size_m, size_m)), false)
	canvas.draw_set_transform(Vector2.ZERO)


static func _post(canvas: CanvasItem, box: Rect2, east: bool) -> void:
	var half: Vector2 = POSTS.get_size() * Vector2(0.5, 1)
	var source: Rect2 = Rect2(Vector2(half.x if east else 0.0, 0), half)
	canvas.draw_texture_rect_region(POSTS, PrologueYardPaint.pixels(box), source)


static func parked_leaf(canvas: CanvasItem, plan: PrologueYard) -> void:
	var west_post: Rect2 = plan.fences[-2]
	var size_m: Vector2 = Vector2(5.1, 2.38)
	var foot: Vector2 = Vector2(west_post.position.x, west_post.end.y)
	canvas.draw_texture_rect(LEAF, PrologueYardPaint.pixels(Rect2(foot - size_m, size_m)), false)
