class_name PlayerGuardPose
extends Node2D
## The pitched rig is one painted figure. Keep its helmet, collar and torso in place and
## turn each painted forearm about its elbow on the same standing cell. Flat rigs use arm IK.

const CHILD: StringName = &"guard_pose"
# Occupied part pixels in the five standing cells (front to back) of Rivet's facing strip.
const BOUNDS: Dictionary[String, Array] = {
	"p70":
	[
		Rect2i(57, 22, 138, 164),
		Rect2i(64, 16, 123, 170),
		Rect2i(76, 7, 92, 179),
		Rect2i(63, 19, 117, 167),
		Rect2i(52, 25, 138, 161)
	],
	"p55":
	[
		Rect2i(24, 10, 106, 159),
		Rect2i(31, 9, 91, 161),
		Rect2i(49, 6, 52, 164),
		Rect2i(36, 9, 82, 161),
		Rect2i(22, 10, 103, 159)
	]
}
# Inner arm seams at elbow and cuff, fractions of the occupied width, left then right.
const SEAMS: Array[Vector4] = [
	Vector4(0.24, 0.25, 0.76, 0.76),
	Vector4(0.28, 0.28, 0.77, 0.78),
	Vector4(0.53, 0.51, 0.80, 0.82),
	Vector4(0.24, 0.23, 0.72, 0.73),
	Vector4(0.26, 0.24, 0.76, 0.74)
]
const BEND: Array[Vector2] = [
	Vector2(-103, 100),
	Vector2(-117, 104),
	Vector2(-116, -125),
	Vector2(-108, 119),
	Vector2(-122, 121)
]

var art_id: String
var _texture: Texture2D
var _frame: int
var _bounds: Rect2
var _origin: Vector2
var _cell_w: float
var _stride: float
var _alpha: float


static func for_card(card: Sprite2D, art: String, raised: bool) -> PlayerGuardPose:
	var pose: PlayerGuardPose = card.get_node_or_null(NodePath(CHILD)) as PlayerGuardPose
	if not raised or not BOUNDS.has(art):
		if pose != null and pose.visible:
			card.self_modulate.a = pose._alpha
			pose.hide()
		return null
	if pose == null:
		pose = PlayerGuardPose.new()
		pose.name = CHILD
		pose.visible = false
		card.add_child(pose)
	if not pose.visible:
		pose._alpha = card.self_modulate.a
		card.self_modulate.a = 0.0
		pose.show()
	return pose


func strip(art: String, texture: Texture2D, cells: int, foot_pad: float) -> void:
	art_id = art
	_texture = texture
	_cell_w = texture.get_width() / float(cells)
	_origin = Vector2(-_cell_w * 0.5, foot_pad - texture.get_height())


func face(frame: int, mirror: bool, scale_px: float, stride: float, feet: Vector2) -> void:
	_frame = frame
	var cell_bounds: Rect2i = BOUNDS[art_id][_frame]
	_bounds = Rect2(cell_bounds)
	var scale_xy: Vector2 = Vector2(-1.0 if mirror else 1.0, 1.0) * scale_px
	global_transform = Transform2D(0.0, scale_xy, 0.0, feet)
	_stride = stride * 0.035
	queue_redraw()


func _draw() -> void:
	if _texture == null:
		return
	var elbow: float = 0.72 if art_id == "p70" else 0.60
	var seam: Vector4 = SEAMS[_frame]
	if _frame >= 3:
		_arms(elbow, seam)
	var upper: Rect2 = Rect2(_bounds.position, _bounds.size * Vector2(1.0, elbow + 0.015))
	draw_texture_rect_region(
		_texture,
		Rect2(upper.position + _origin, upper.size),
		Rect2(upper.position + Vector2.RIGHT * _frame * _cell_w, upper.size)
	)
	var middle: float = (seam.y + seam.w) * 0.5
	_boot(Vector2(seam.x, middle), Vector2(seam.y, middle), elbow, _stride)
	_boot(Vector2(middle, seam.z), Vector2(middle, seam.w), elbow, -_stride)
	if _frame < 3:
		_arms(elbow, seam)


func _arms(elbow: float, seam: Vector4) -> void:
	_arm(Vector2(0, seam.x), Vector2(0, seam.y), elbow, BEND[_frame].x)
	_arm(Vector2(seam.z, 1), Vector2(seam.w, 1), elbow, BEND[_frame].y)


func _arm(top: Vector2, bottom: Vector2, y: float, degrees: float) -> void:
	var src: PackedVector2Array = [
		Vector2(top.x, y), Vector2(top.y, y), Vector2(bottom.y, 1), Vector2(bottom.x, 1)
	]
	var pivot: Vector2 = _pixel(Vector2((top.x + top.y) * 0.5, y))
	var pts: PackedVector2Array = PackedVector2Array()
	for v: Vector2 in src:
		@warning_ignore("return_value_discarded")
		pts.append(pivot + (_pixel(v) - pivot).rotated(deg_to_rad(degrees)))
	_textured(pts, src)


func _boot(top: Vector2, bottom: Vector2, split: float, stride: float) -> void:
	var src: PackedVector2Array = [
		Vector2(top.x, split), Vector2(top.y, split), Vector2(bottom.y, 1), Vector2(bottom.x, 1)
	]
	var pts: PackedVector2Array = PackedVector2Array()
	for v: Vector2 in src:
		@warning_ignore("return_value_discarded")
		pts.append(_pixel(v + (Vector2.DOWN * stride if v.y == 1.0 else Vector2.ZERO)))
	_textured(pts, src)


func _pixel(uv: Vector2) -> Vector2:
	return _origin + _bounds.position + uv * _bounds.size


func _textured(pts: PackedVector2Array, src: PackedVector2Array) -> void:
	var uv: PackedVector2Array = PackedVector2Array()
	for v: Vector2 in src:
		@warning_ignore("return_value_discarded")
		uv.append((_pixel(v) - _origin + Vector2.RIGHT * _frame * _cell_w) / _texture.get_size())
	draw_polygon(pts, PackedColorArray([Color.WHITE]), uv, _texture)
