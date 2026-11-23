class_name PrologueFloor
extends StageView
## Reuses the quest's concrete, pavement and road tiles at their authored scale.

const SCORCH: Texture2D = preload("res://features/city/art/decals/scorch.png")
const ZEBRA: Texture2D = preload("res://features/city/art/decals/zebra.png")

var plan: PrologueYard
var _paint: PrologueYardPaint = PrologueYardPaint.new()


func _draw() -> void:
	if plan == null:
		return
	for layer: PrologueYardDressing.Ground in plan.dressing.ground:
		_paint.ground(self, layer)
	_kerb(plan.sidewalk)
	_road(plan.street)
	draw_set_transform(Ink.px(plan.far_sidewalk.end), PI)
	_kerb(Rect2(Vector2.ZERO, plan.far_sidewalk.size))
	draw_set_transform(Vector2.ZERO)
	_crossing()
	if plan.dressing.use_stage_decals:
		_stage_decals()
	_paint.stamps(self, plan.dressing.decals)
	_paint.stamps(self, plan.dressing.factory_front)
	_paint.stamps(self, plan.dressing.outside)
	for wreck: PrologueYard.Wreck in plan.wrecks:
		var skin: PrologueYardDressing.CoverArt = plan.dressing.cover.get(wreck.id)
		_draw_piece(wreck, Color("b5a293"), skin)
		if wreck.shell:
			_broken_sill(_pixels(wreck.footprint))
	for fence: Rect2 in plan.fences:
		draw_rect(_pixels(fence), Ink.INK)
		_tiled(fence, "cage_mesh", 2.0)
	for phone: String in stage.layout.phones:
		_sprite("payphone", stage.layout.phones[phone], Vector2(1.3, 1.3))
	if not plan.exit_open:
		var size_m: Vector2 = Vector2(plan.gate_width_m, 0.22)
		var barrier: Rect2 = _pixels(Rect2(plan.gate - size_m * 0.5, size_m))
		draw_rect(barrier.grow(1.5), Ink.INK)
		draw_rect(barrier, Color("57758e"))


func _stage_decals() -> void:
	for stain: Rect2 in plan.scorch_marks:
		draw_texture_rect(SCORCH, _pixels(stain), false)
	for piece: PrologueYard.Wreck in plan.debris:
		_draw_piece(piece, Color.WHITE, null)


func _draw_piece(
	piece: PrologueYard.Wreck, tint: Color, skin: PrologueYardDressing.CoverArt
) -> void:
	var art: Texture2D = _paint.texture(skin.art if skin != null else piece.art)
	var crop: Rect2 = skin.crop if skin != null else piece.crop
	var cell: Vector2 = art.get_size()
	var source: Rect2 = Rect2(crop.position * cell, crop.size * cell)
	draw_texture_rect_region(art, _pixels(piece.footprint), source, tint)


## A fractured concrete lintel under the surviving sawtooth bays. Where a panel
## has fallen, the ink edge and the bent reinforcing rods show through the break.
func _broken_sill(box: Rect2) -> void:
	var sill: Rect2 = Rect2(box.position.x, box.end.y - 13, box.size.x, 13)
	draw_rect(sill, Ink.INK)
	var breaks: PackedFloat32Array = [0.0, 0.31, 0.72, 1.0]
	for i: int in breaks.size() - 1:
		var a: float = sill.position.x + sill.size.x * breaks[i] + 2
		var b: float = sill.position.x + sill.size.x * breaks[i + 1] - 3
		var y: float = sill.position.y
		draw_colored_polygon(
			PackedVector2Array(
				[
					Vector2(a + 3, y),
					Vector2(b, y),
					Vector2(b - 4, y + 6),
					Vector2(b - 2, y + 10),
					Vector2(a, y + 12)
				]
			),
			Color("#9b9182")
		)
	for n: int in 3:
		var root: Vector2 = Vector2(sill.position.x + 9 + n * 6, sill.end.y)
		draw_polyline(
			PackedVector2Array([root, root + Vector2(-2, 6), root + Vector2(-7, 11 + n * 2)]),
			Ink.INK,
			2,
			true
		)


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
