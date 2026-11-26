class_name PrologueFloor
extends StageView
## Reuses the quest's concrete, pavement and road tiles at their authored scale.

## At the film's widest scale 1920/32 shows 30 m either side. Allow another 10 m,
## and grow the surround for wider viewports or the camera's 18% vertical lean.
const MIN_SURROUND_M: float = 40.0
const BACKLOT: Texture2D = preload("res://features/city/art/ground/road_box_plain.png")
const ZEBRA: Texture2D = preload("res://features/city/art/decals/zebra.png")

var plan: PrologueYard
var _paint: PrologueYardPaint = PrologueYardPaint.new()


func _ready() -> void:
	if plan == null:
		return
	var shade: float = plan.dressing.ground_shade
	self_modulate = Color(shade, shade, shade)
	PrologueYardOverprint.attach_ochre_first(self, plan, _paint)
	if plan.dressing.paint_id == "torn_line":
		_use_painted_cracks()


## The default D5 pass also stamps two diagonal crack families on light surfaces. The factory
## swatch and decals already carry their own fractures. Change only this stage's material.
func _use_painted_cracks() -> void:
	var stage_print: PrintStage = get_parent() as PrintStage
	if stage_print == null:
		return
	for node: Node in stage_print.find_children("*", "ColorRect", true, false):
		var overlay: LookOverlay = node.get_parent() as LookOverlay
		if overlay != null and overlay.spec.get("id") == "d5_riso":
			var pigment: ShaderMaterial = (node as ColorRect).material as ShaderMaterial
			pigment.set_shader_parameter(&"crack_k", 0.0)


func _draw() -> void:
	if plan == null:
		return
	var margin: float = _surround_m()
	_backlot(margin)
	_ground()
	_street_surface(margin)
	_crossing()
	# The back fence passes behind the loading hall. The yard perimeter still blocks travel.
	if not plan.dressing.factory_front.is_empty() and not plan.dressing.front_replaces.has_area():
		_fence(plan.fences[0])
	_paint.stamps(self, plan.dressing.outside)
	_stage_decals()
	_paint.stamps(self, plan.dressing.decals)
	_paint.shadows(self, plan)
	_paint.stamps(self, plan.dressing.factory_front)
	_paint.bases(self, plan, false)
	for wreck: PrologueYard.Wreck in plan.wrecks:
		if plan.dressing.over_print.has(wreck.id):
			continue
		var skin: PrologueYardDressing.CoverArt = plan.dressing.cover.get(wreck.id)
		_paint.wreck(self, wreck, Color("b5a293"), skin)
		if wreck.shell and skin == null:
			_broken_sill(_pixels(wreck.footprint))
	_draw_fences(margin)
	_paint.stamps(self, plan.dressing.fixtures)
	for phone: String in stage.layout.phones:
		_yard_phone(stage.layout.phones[phone])
	if not plan.exit_open:
		var size_m: Vector2 = Vector2(plan.gate_width_m, 0.22)
		var barrier: Rect2 = _pixels(Rect2(plan.gate - size_m * 0.5, size_m))
		draw_rect(barrier.grow(1.5), Ink.INK)
		draw_rect(barrier, Color("57758e"))


func _ground() -> void:
	for layer: PrologueYardDressing.Ground in plan.dressing.ground:
		if not layer.over_impression:
			_paint.ground(self, layer)


func _yard_phone(at: Vector2) -> void:
	var look: PrologueYardDressing = plan.dressing
	if look.phone_art.is_empty():
		_sprite("payphone", at, Vector2(1.3, 1.3))
		return
	var box: Rect2 = Rect2(at - look.phone_size * Vector2(0.5, 1.0), look.phone_size)
	draw_texture_rect(_paint.texture(look.phone_art), _pixels(box), false)


func _surround_m() -> float:
	var ppm: Vector2 = get_global_transform_with_canvas().get_scale().abs() * Ink.PX_PER_M
	var screen_m: Vector2 = get_viewport_rect().size / ppm
	return maxf(MIN_SURROUND_M, maxf(screen_m.x * 0.5, screen_m.y * 0.68) + 2.0)


func _backlot(margin: float) -> void:
	var surround: Rect2 = plan.yard.merge(plan.far_sidewalk).grow(margin)
	# The city's 768 px asphalt tile covers 8 m. Keep the backlot continuous behind the fences.
	var scale_xy: Vector2 = Ink.px(Vector2(8, 8)) / BACKLOT.get_size()
	draw_set_transform(Ink.px(surround.position), 0.0, scale_xy)
	var box: Rect2 = Rect2(Vector2.ZERO, Ink.px(surround.size) / scale_xy)
	draw_texture_rect(BACKLOT, box, true, Color("aaa198"))
	draw_set_transform(Vector2.ZERO)


func _street_surface(margin: float) -> void:
	var near_walk: Rect2 = plan.sidewalk.grow_individual(margin, 0, margin, 0)
	var far_walk: Rect2 = plan.far_sidewalk.grow_individual(margin, 0, margin, 0)
	_kerb(near_walk)
	_road(plan.street.grow_individual(margin, 0, margin, 0))
	draw_set_transform(Ink.px(far_walk.end), PI)
	_kerb(Rect2(Vector2.ZERO, far_walk.size))
	draw_set_transform(Vector2.ZERO)


func _draw_fences(margin: float) -> void:
	for fence: Rect2 in plan.fences:
		if fence == plan.fences[0] and not plan.dressing.factory_front.is_empty():
			continue
		var visible_box: Rect2 = fence
		if fence.position.y == plan.yard.position.y:
			# The simulation's side bounds cross Harbor Road. The visible yard fence ends at the kerb.
			visible_box.size.y = plan.yard.size.y
		elif fence.position.y == plan.far_sidewalk.end.y:
			visible_box = fence.grow_individual(margin, 0, margin, 0)
		_fence(visible_box)
	if plan.dressing.front_replaces.has_area():
		PrologueFactoryFence.parked_leaf(self, plan)
	elif plan.dressing.paint_id == "torn_line":
		PrologueYardFence.open_leaf(self, plan)


func _fence(box: Rect2) -> void:
	if plan.dressing.front_replaces.has_area() and box.position.y < plan.far_sidewalk.end.y:
		PrologueFactoryFence.panel(self, box)
		return
	if plan.dressing.paint_id == "torn_line":
		PrologueYardFence.panel(self, box)
		return
	draw_rect(_pixels(box), Ink.INK)
	_tiled(box, "cage_mesh", 2.0)


func _stage_decals() -> void:
	if plan.dressing.use_stage_decals:
		if not plan.dressing.decals_over_impression:
			_paint.scorch(self, plan)
	elif plan.dressing.layout.is_empty():
		return
	for piece: PrologueYard.Wreck in plan.debris:
		if not plan.dressing.over_print.has(piece.id):
			_paint.wreck(self, piece, piece.tint, null)


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
