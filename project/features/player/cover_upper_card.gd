class_name CoverUpperCard
extends RefCounted
## The prop redraw masks the ordinary opaque sprite. Only colour the covered pixels, using
## the current cell's outer contour. The floor's ordinary outlined marker is for other bodies.

const STANCE: StringName = &"rivet_cover_ink"
const BRONZE: Color = Color("#39291e")
static var _outlines: Dictionary[String, Array] = {}

var _card: Sprite2D
var _scale: Vector2
var _alpha: float


static func publish(rig: Node2D, source: Sprite2D, pose_scale: Vector2, opacity: float) -> void:
	var ink: CoverUpperCard
	if rig.has_meta(STANCE):
		ink = rig.get_meta(STANCE)
	else:
		ink = CoverUpperCard.new()
		rig.set_meta(STANCE, ink)
	ink._card = source
	ink._scale = pose_scale
	ink._alpha = opacity


static func release(rig: Node2D) -> void:
	if rig.has_meta(STANCE):
		rig.remove_meta(STANCE)


static func draw_hidden(canvas: Node2D, hit: PropOcclusion.Hit) -> bool:
	var rig: CutRig = hit.rig
	if rig == null or not rig.has_meta(STANCE):
		return false
	var ink: CoverUpperCard = rig.get_meta(STANCE)
	if ink._alpha <= 0.0 or not is_instance_valid(ink._card):
		return true
	var color: Color = Color(BRONZE, ink._alpha)
	var rig_xf: Transform2D = rig.global_transform
	var pose: Transform2D = rig_xf.scaled_local(ink._scale) * rig_xf.affine_inverse()
	var xf: Transform2D = (
		canvas.global_transform.affine_inverse() * pose * ink._card.global_transform
	)
	for line: PackedVector2Array in outlines(ink._card):
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
