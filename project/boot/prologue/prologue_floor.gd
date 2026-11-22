class_name PrologueFloor
extends StageView
## Reuses the quest's concrete, pavement and road tiles at their authored scale.

const SCORCH: Texture2D = preload("res://features/city/art/decals/scorch.png")
const ZEBRA: Texture2D = preload("res://features/city/art/decals/zebra.png")

var plan: PrologueYard
var _art_by_id: Dictionary[String, Texture2D] = {}


func _ready() -> void:
	for wreck: PrologueYard.Wreck in plan.wrecks:
		_art_by_id[wreck.id] = load(wreck.art) as Texture2D


func _draw() -> void:
	if plan == null:
		return
	_tiled(plan.yard, "dock_floor", 8.0)
	_kerb(plan.sidewalk)
	_road(plan.street)
	draw_set_transform(Ink.px(plan.far_sidewalk.end), PI)
	_kerb(Rect2(Vector2.ZERO, plan.far_sidewalk.size))
	draw_set_transform(Vector2.ZERO)
	_crossing()
	for stain: Rect2 in plan.scorch_marks:
		draw_texture_rect(SCORCH, _pixels(stain), false)
	for wreck: PrologueYard.Wreck in plan.wrecks:
		draw_texture_rect(_art_by_id[wreck.id], _pixels(wreck.footprint), false, Color("b5a293"))
	for fence: Rect2 in plan.fences:
		draw_rect(_pixels(fence), Ink.INK)
		_tiled(fence, "cage_mesh", 2.0)
	for phone: String in stage.layout.phones:
		_phone(phone, stage.layout.phones[phone])
	if not plan.exit_open:
		var size_m: Vector2 = Vector2(plan.gate_width_m, 0.22)
		var barrier: Rect2 = _pixels(Rect2(plan.gate - size_m * 0.5, size_m))
		draw_rect(barrier.grow(1.5), Ink.INK)
		draw_rect(barrier, Color("57758e"))


## The shipped stripe strip runs along its local x axis. Cross the street north to south
## and crop it to the road depth, keeping the stripes at their original proportions.
func _crossing() -> void:
	var width: float = plan.gate_width_m * 0.5
	var dst: Rect2 = Rect2(0.0, -width * 0.5, plan.street.size.y, width)
	var height: float = ZEBRA.get_height()
	var src: Rect2 = Rect2(0.0, 0.0, dst.size.x * height / width, height)
	draw_set_transform(Ink.px(Vector2(plan.gate.x, plan.street.position.y)), PI * 0.5)
	draw_texture_rect_region(ZEBRA, _pixels(dst), src)
	draw_set_transform(Vector2.ZERO)


static func _pixels(rect: Rect2) -> Rect2:
	return Rect2(Ink.px(rect.position), Ink.px(rect.size))
