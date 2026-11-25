class_name PrologueYardOverprint
extends RefCounted
## The world print flattens everything below paper luminance to a grey wash, so a cream
## appliance or a cardboard pallet printed with the floor turns into a dark box. A dressing
## row names the pieces (`over_print`) that stand on the printed floor in their own colours,
## on a static layer under the actors, like the ochre second impression.

enum Part { ALL, GROUND, PIECES }

const OVERHEAD_PREFIX: String = "span_"


## The ochre layer and the over-print layer in stacking order. Without `ochre_over_impression`
## one node paints the impression and the pieces after the ochre layer (today). With it the
## impression and the flagged decals go below the ochre layer and the pieces above it.
static func attach_ochre_first(
	floor_view: Node2D, plan: PrologueYard, paint: PrologueYardPaint
) -> void:
	var look: PrologueYardDressing = plan.dressing
	var split: bool = look.ochre_over_impression and look.ochre_strength > 0.0
	if split:
		attach(floor_view, plan, paint, Part.GROUND)
	if look.ochre_strength > 0.0:
		paint.attach_ochre(floor_view, plan)
	if split:
		attach(floor_view, plan, paint, Part.PIECES)
	elif not look.over_print.is_empty() or look.impression != null:
		attach(floor_view, plan, paint)


## `Part.ALL` is one node (today). With `ochre_over_impression` the floor attaches `GROUND` before
## the ochre layer and `PIECES` after it, so a bay line sits above the impression, under a wreck.
static func attach(
	floor_view: Node2D, plan: PrologueYard, paint: PrologueYardPaint, part: Part = Part.ALL
) -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = RenderLayers.canvas(&"actors")
	layer.follow_viewport_enabled = true
	floor_view.add_child(layer)
	var sub: int = -2 if part == Part.GROUND else -1
	RenderingServer.viewport_set_canvas_stacking(
		floor_view.get_viewport().get_viewport_rid(), layer.get_canvas(), layer.layer, sub
	)
	var node: Node2D = Node2D.new()
	node.transform = floor_view.global_transform
	node.z_index = RenderLayers.z(&"blood")
	node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	@warning_ignore("return_value_discarded")
	node.draw.connect(_draw_part.bind(node, plan, paint, part))
	layer.add_child(node)


## Under the pieces: the impression, the ground layers flagged `over_impression`, then the
## decals of `decals_over_impression`. Ground debris first, then the wrecks, then the overhead
## spans: a beam stays above every ground piece it crosses.
static func order(plan: PrologueYard) -> Array[PrologueYard.Wreck]:
	var ids: PackedStringArray = plan.dressing.over_print
	var out: Array[PrologueYard.Wreck] = []
	var spans: Array[PrologueYard.Wreck] = []
	for piece: PrologueYard.Wreck in plan.debris:
		if ids.has(piece.id):
			if piece.id.begins_with(OVERHEAD_PREFIX):
				spans.append(piece)
			else:
				out.append(piece)
	for piece: PrologueYard.Wreck in plan.wrecks:
		if ids.has(piece.id):
			out.append(piece)
	out.append_array(spans)
	return out


static func _draw_part(
	node: Node2D, plan: PrologueYard, paint: PrologueYardPaint, part: Part
) -> void:
	if part != Part.PIECES:
		_draw_ground(node, plan, paint)
	if part != Part.GROUND:
		_draw_pieces(node, plan, paint)


static func _draw_ground(node: Node2D, plan: PrologueYard, paint: PrologueYardPaint) -> void:
	if plan.dressing.impression != null:
		paint.ground(node, plan.dressing.impression)
	for layer: PrologueYardDressing.Ground in plan.dressing.ground:
		if layer.over_impression:
			paint.ground(node, layer)
	if plan.dressing.use_stage_decals and plan.dressing.decals_over_impression:
		paint.scorch(node, plan)
	paint.stamps(node, plan.dressing.decals_over)


static func _draw_pieces(node: Node2D, plan: PrologueYard, paint: PrologueYardPaint) -> void:
	var shade: float = plan.dressing.over_print_shade
	var shaded: Color = Color(shade, shade, shade)
	for piece: PrologueYard.Wreck in order(plan):
		if plan.wrecks.has(piece):
			var skin: PrologueYardDressing.CoverArt = plan.dressing.cover.get(piece.id)
			paint.skin_tint = shaded
			paint.wreck(node, piece, shaded, skin)
			paint.skin_tint = Color.WHITE
		else:
			paint.wreck(node, piece, piece.tint, null)
