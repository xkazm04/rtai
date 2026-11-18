class_name CoverUpperCard
extends Sprite2D
## The north face is behind the station card. Trace Rivet's actual helmet and gun cell over
## that card translucently. The boots stay behind the prop with its ordinary ink silhouette.

## The equipped side cell carries the pistol below the belt, roughly 85% down its crop.
const UPPER: float = 0.87


static func show_above(source: Sprite2D, last: CoverUpperCard) -> CoverUpperCard:
	var ink: CoverUpperCard = last
	if not is_instance_valid(ink):
		ink = CoverUpperCard.new()
		ink.centered = false
		ink.region_enabled = true
		ink.z_as_relative = false
		ink.z_index = RenderLayers.z(&"roof_occluders") + 1
		ink.self_modulate.a = 0.78
		source.add_child(ink)
	elif ink.get_parent() != source:
		ink.reparent(source, false)
	var rect: Rect2 = source.get_rect()
	var cell: Vector2 = rect.size
	var tex_origin: Vector2 = source.region_rect.position if source.region_enabled else Vector2.ZERO
	ink.texture = source.texture
	ink.flip_h = source.flip_h
	ink.position = rect.position
	ink.region_rect = Rect2(
		tex_origin + Vector2(source.frame_coords) * cell, cell * Vector2(1, UPPER)
	)
	ink.texture_filter = source.texture_filter
	ink.material = source.material
	ink.show()
	return ink
