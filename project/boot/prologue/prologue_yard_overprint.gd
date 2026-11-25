class_name PrologueYardOverprint
extends RefCounted
## The world print flattens everything below paper luminance to a grey wash, so a cream
## appliance or a cardboard pallet printed with the floor turns into a dark box. A dressing
## row names the pieces (`over_print`) that stand on the printed floor in their own colours,
## on a static layer under the actors, like the ochre second impression.

const OVERHEAD_PREFIX: String = "span_"


static func attach(floor_view: Node2D, plan: PrologueYard, paint: PrologueYardPaint) -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = RenderLayers.canvas(&"actors")
	layer.follow_viewport_enabled = true
	floor_view.add_child(layer)
	RenderingServer.viewport_set_canvas_stacking(
		floor_view.get_viewport().get_viewport_rid(), layer.get_canvas(), layer.layer, -1
	)
	var node: Node2D = Node2D.new()
	node.transform = floor_view.global_transform
	node.z_index = RenderLayers.z(&"blood")
	node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	@warning_ignore("return_value_discarded")
	node.draw.connect(_draw_pieces.bind(node, plan, paint))
	layer.add_child(node)


## Ground debris first, then the wrecks, then the overhead spans: a beam stays above every
## ground piece it crosses.
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


static func _draw_pieces(node: Node2D, plan: PrologueYard, paint: PrologueYardPaint) -> void:
	if plan.dressing.impression != null:
		paint.ground(node, plan.dressing.impression)
	for piece: PrologueYard.Wreck in order(plan):
		if plan.wrecks.has(piece):
			var skin: PrologueYardDressing.CoverArt = plan.dressing.cover.get(piece.id)
			paint.wreck(node, piece, Color.WHITE, skin)
		else:
			paint.wreck(node, piece, piece.tint, null)
