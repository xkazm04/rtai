class_name PrologueYardFence
extends RefCounted
## Static yard perimeter art in the floor's metre coordinates.

const MESH: Texture2D = preload("res://boot/prologue/art/torn_line/fence_panel.png")
const LEAF: Texture2D = preload("res://boot/prologue/art/torn_line/sliding_gate.png")
const PANEL_M: float = 3.0
const HEIGHT_M: float = 0.98


static func panel(canvas: PrologueFloor, box: Rect2, mesh: Texture2D = MESH) -> void:
	var upright: bool = box.size.y > box.size.x
	if upright and box.position.y > canvas.plan.yard.position.y and box.end.y == canvas.plan.gate.y:
		_gate_post(canvas.draw_rect, box)
		return
	var length: float = box.size.y if upright else box.size.x
	var origin: Vector2 = Vector2(box.position.x, box.end.y - HEIGHT_M)
	if upright:
		origin = Vector2(box.end.x, box.position.y)
	canvas.draw_set_transform(Ink.px(origin), PI * 0.5 if upright else 0.0)
	var count: int = maxi(1, roundi(length / PANEL_M))
	var span: float = length / float(count)
	for i: int in count:
		var rect: Rect2 = Rect2(float(i) * span, 0, span, HEIGHT_M)
		canvas.draw_texture_rect(mesh, PrologueYardPaint.pixels(rect), false)
	canvas.draw_set_transform(Vector2.ZERO)


static func _gate_post(paint: Callable, box: Rect2) -> void:
	var post: Rect2 = PrologueYardPaint.pixels(box)
	var rim: float = Ink.PX_PER_M * 0.07
	paint.call(post, Ink.INK)
	var steel: Rect2 = post.grow(-rim)
	paint.call(steel, Color("514f4d"))
	paint.call(Rect2(steel.position, Vector2(rim, steel.size.y)), Color("b6aea2"))
	paint.call(Rect2(steel.position, Vector2(steel.size.x, rim * 2.0)), Color("96918a"))


static func open_leaf(canvas: CanvasItem, plan: PrologueYard, leaf: Texture2D = LEAF) -> void:
	var half_gate: float = plan.gate_width_m * 0.5
	var size: Vector2 = Vector2(half_gate * 1.7, half_gate + 0.15)
	var end: Vector2 = plan.gate - Vector2(half_gate, 0)
	canvas.draw_texture_rect(leaf, PrologueYardPaint.pixels(Rect2(end - size, size)), false)
