class_name CoverUpperCard
extends RefCounted
## The prop redraw masks the ordinary opaque sprite. Only colour the covered pixels, using
## the current cell's outer contour. The floor's ordinary outlined marker is for other bodies.

const STANCE: StringName = &"rivet_cover_ink"
const BRONZE: Color = Color("#39291e")
static var _outlines: Dictionary[String, Array] = {}


static func bind(rig: CutRig, cover: PlayerCover) -> void:
	if rig == null:
		return
	if cover != null and cover.spot != null:
		rig.set_meta(STANCE, cover)
	elif rig.has_meta(STANCE):
		rig.remove_meta(STANCE)


static func draw_hidden(canvas: Node2D, hit: PropOcclusion.Hit) -> bool:
	if hit.rig == null or not hit.rig.has_meta(STANCE):
		return false
	var cover: PlayerCover = hit.rig.get_meta(STANCE)
	if cover.spot == null or hit.rig.dead:
		return false
	var card: Sprite2D = hit.rig.head_card
	if (
		not cover.silhouette_enabled
		or cover.silhouette_alpha <= 0
		or not RivetFrames.drawn(hit.rig)
	):
		return true
	var color: Color = Color(BRONZE, cover.silhouette_alpha)
	var k: Vector2 = Vector2.ONE
	if not MoveCells.shows(card):
		k = CoverView.scale_for(cover.crouch_scale_y, cover.crouch_weight(), false)
	var rig_xf: Transform2D = hit.rig.global_transform
	var pose: Transform2D = rig_xf.scaled_local(k) * rig_xf.affine_inverse()
	var xf: Transform2D = canvas.global_transform.affine_inverse() * pose * card.global_transform
	for line: PackedVector2Array in outlines(card):
		var placed: PackedVector2Array = xf * line
		for cut: PackedVector2Array in hit.cut:
			for part: PackedVector2Array in Geometry2D.intersect_polygons(placed, cut):
				if not Geometry2D.triangulate_polygon(part).is_empty():
					canvas.draw_colored_polygon(part, color)
	return true


## Trace once per used texture region. Keep offsets and flips out of the cache.
static func outlines(card: Sprite2D) -> Array[PackedVector2Array]:
	var rect: Rect2 = card.get_rect()
	var origin: Vector2 = card.region_rect.position if card.region_enabled else Vector2.ZERO
	var cell: Rect2i = Rect2i(origin + Vector2(card.frame_coords) * rect.size, rect.size)
	var key: String = "%d:%s" % [card.texture.get_instance_id(), cell]
	if not _outlines.has(key):
		var bitmap: BitMap = BitMap.new()
		bitmap.create_from_image_alpha(card.texture.get_image().get_region(cell))
		_outlines[key] = bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, cell.size), 1.0)
	var result: Array[PackedVector2Array] = []
	for line: PackedVector2Array in _outlines[key]:
		var points: PackedVector2Array = line.duplicate()
		for i: int in points.size():
			if card.flip_h:
				points[i].x = rect.size.x - points[i].x
			points[i] += rect.position
		result.append(points)
	return result
