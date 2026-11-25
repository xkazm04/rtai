class_name PrologueSpanShadow
extends Node2D
## A soft drop shadow under Rivet's feet while he stands on an overhead belt span (copper on
## copper he loses his contrast), drawn after the spans, under the actors. From a dressing's
## optional `span_shadow` row (absent = no node). Render only: reads, fades on the sim tick.

const NODE_NAME: String = "SpanShadow"
## Span art at or above this alpha is beam; below it the floor shows through.
const SOLID_ALPHA: float = 0.5
const GRADIENT_PX: int = 64


class Mask:
	extends RefCounted
	var bits: BitMap
	var box: Rect2
	var rotation: float
	var source: Rect2


var alpha: float = 0.45
var fade_ticks: int = 6
var size_m: Vector2 = Vector2(1.1, 0.45)
var stage: ArenaStage = null
var _masks: Array[Mask] = []
var _level: int = 0
var _last_tick: int = -1
var _feet_px: Vector2 = Vector2.ZERO
var _texture: GradientTexture2D = null


static func read(table: DataTable, row: Dictionary) -> Dictionary:
	return {
		"alpha": table.num(row, "alpha"),
		"fade_ticks": maxi(1, table.integer(row, "fade_ticks")),
		"size_m": table.vec(row, "size_m"),
	}


## Adds the shadow under `parent` when the dressing has a `span_shadow` row and spans.
static func attach(parent: Node, plan: PrologueYard, paint: PrologueYardPaint) -> void:
	var pieces: Array[PrologueYard.Wreck] = spans(plan)
	if not plan.dressing.span_shadow.is_empty() and not pieces.is_empty():
		parent.add_child(build(plan.dressing.span_shadow, pieces, paint))


static func track(root: Node, sim: ArenaStage) -> void:
	var node: PrologueSpanShadow = root.find_child(NODE_NAME, true, false) as PrologueSpanShadow
	if node != null:
		node.stage = sim


static func spans(plan: PrologueYard) -> Array[PrologueYard.Wreck]:
	var out: Array[PrologueYard.Wreck] = []
	for piece: PrologueYard.Wreck in PrologueYardOverprint.order(plan):
		if piece.id.begins_with(PrologueYardOverprint.OVERHEAD_PREFIX):
			out.append(piece)
	return out


static func build(
	spec: Dictionary, pieces: Array[PrologueYard.Wreck], paint: PrologueYardPaint
) -> PrologueSpanShadow:
	var node: PrologueSpanShadow = PrologueSpanShadow.new()
	node.name = NODE_NAME
	node.alpha = spec["alpha"]
	node.fade_ticks = spec["fade_ticks"]
	node.size_m = spec["size_m"]
	for piece: PrologueYard.Wreck in pieces:
		node._masks.append(_mask(piece, paint.texture(piece.art)))
	node._texture = _gradient()
	return node


## The span's alpha as `PrologueYardPaint.wreck` lays it: footprint box, crop, centre rotation.
static func _mask(piece: PrologueYard.Wreck, art: Texture2D) -> Mask:
	var image: Image = art.get_image()
	if image.is_compressed():
		@warning_ignore("return_value_discarded")
		image.decompress()
	var mask: Mask = Mask.new()
	mask.bits = BitMap.new()
	mask.bits.create_from_image_alpha(image, SOLID_ALPHA)
	var size: Vector2 = Vector2(image.get_size())
	mask.source = Rect2(piece.crop.position * size, piece.crop.size * size)
	mask.box = PrologueYardPaint.pixels(piece.footprint)
	mask.rotation = piece.rotation
	return mask


static func _gradient() -> GradientTexture2D:
	var ramp: Gradient = Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	ramp.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0.8), Color(1, 1, 1, 0)])
	var tex: GradientTexture2D = GradientTexture2D.new()
	tex.gradient = ramp
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = GRADIENT_PX
	tex.height = GRADIENT_PX
	return tex


## True when a point (metres) falls on solid span art.
func on_span(at_m: Vector2) -> bool:
	var at: Vector2 = Ink.px(at_m)
	for mask: Mask in _masks:
		var local: Vector2 = (at - mask.box.get_center()).rotated(-mask.rotation)
		local += mask.box.size * 0.5
		if not Rect2(Vector2.ZERO, mask.box.size).has_point(local):
			continue
		var texel: Vector2 = mask.source.position + local / mask.box.size * mask.source.size
		var last: Vector2i = mask.bits.get_size() - Vector2i.ONE
		if mask.bits.get_bitv(Vector2i(texel.floor()).clamp(Vector2i.ZERO, last)):
			return true
	return false


## One fade step per new sim tick: towards full while the feet are on a span, else towards 0.
func step(tick: int, feet_m: Vector2) -> void:
	if tick == _last_tick:
		return
	_last_tick = tick
	var level: int = clampi(_level + (1 if on_span(feet_m) else -1), 0, fade_ticks)
	var feet_px: Vector2 = Ink.px(feet_m)
	if level != _level or (level > 0 and feet_px != _feet_px):
		queue_redraw()
	_level = level
	_feet_px = feet_px


## The shadow's current alpha (0 off the spans, `alpha` after `fade_ticks` ticks on one).
func strength() -> float:
	return alpha * float(_level) / float(fade_ticks)


func _process(_delta: float) -> void:
	if stage != null:
		step(stage.tick, stage.arena.rivet.pos)


func _draw() -> void:
	if _level == 0:
		return
	var size: Vector2 = Ink.px(size_m)
	var ink: Color = Color(Ink.INK, strength())
	draw_texture_rect(_texture, Rect2(_feet_px - size * 0.5, size), false, ink)
