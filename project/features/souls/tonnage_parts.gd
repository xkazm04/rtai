class_name TonnageParts
extends Node2D
## Orthographic cut-out. Each cylinder pivots at its inner joint. Fists cover the wrist seams.

const ART: String = "res://features/souls/art/tonnage/spectral/"
const PPM: float = SimConst.PX_PER_M
const ARM_M: float = 0.72

var _upper: Array[Sprite2D] = []
var _fore: Array[Sprite2D] = []
var _fists: Array[Sprite2D] = []
var _back: Sprite2D
var _hoses: Sprite2D


func _ready() -> void:
	for i: int in 2:
		_upper.append(_part("upper_arm", true))
		_fore.append(_part("forearm", true))
	_back = _part("back")
	_hoses = _part("hoses")
	for i: int in 2:
		_fists.append(_part("fist"))


func _part(id: String, bone: bool = false) -> Sprite2D:
	var spr: Sprite2D = Sprite2D.new()
	spr.texture = load(ART + id + ".png") as Texture2D
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if bone:
		spr.centered = false
		spr.offset.y = -0.5 * spr.texture.get_height()
	else:
		spr.rotation = -PI * 0.5
	add_child(spr)
	return spr


func update_body(pose: TonnagePose, left: Vector2, right: Vector2, contact_fit: float) -> void:
	var centre: Vector2 = Vector2(pose.torso.x, pose.torso.y) * PPM
	_back.position = centre
	_hoses.position = centre + Vector2(-0.52, 0.0) * PPM
	_width(_back, 2.3, pose.torso.z)
	_width(_hoses, 1.0, pose.torso.z)
	_back.scale.y *= cos(pose.pitch)
	var alpha: float = 0.55 if pose.act and pose.column != TonnagePose.Act.RAISE else 0.88
	_back.self_modulate.a = alpha
	_hoses.self_modulate.a = alpha
	for i: int in 2:
		var side: float = -1.0 if i == 0 else 1.0
		var hand: Vector2 = left if i == 0 else right
		var h: float = pose.left.z if i == 0 else pose.right.z
		var shoulder: Vector2 = centre + Vector2(0.25, side * 0.95) * PPM
		_width(_fists[i], 0.95 * contact_fit, h)
		_fists[i].position = hand
		_fists[i].self_modulate.a = 0.88
		# Connect at the back of the palm; the striped face is the striking end.
		var wrist: Vector2 = hand - Vector2(0.42 * PPM * contact_fit, 0.0)
		_arm(i, shoulder, wrist, h)
		_upper[i].self_modulate.a = alpha
		_fore[i].self_modulate.a = alpha


func _arm(i: int, shoulder: Vector2, wrist: Vector2, h: float) -> void:
	var span: Vector2 = wrist - shoulder
	var half: float = span.length() * 0.5
	var outward: Vector2 = span.normalized().orthogonal()
	if outward.y * (-1.0 if i == 0 else 1.0) < 0.0:
		outward = -outward
	var bend: float = sqrt(maxf(0.0, pow(ARM_M * PPM, 2) - half * half))
	var elbow: Vector2 = (shoulder + wrist) * 0.5 + outward * bend
	var thick: float = 0.42 * PPM * (1.0 + 0.06 * h)
	GhostRim.place_limb(_upper[i], shoulder, elbow, thick)
	GhostRim.place_limb(_fore[i], elbow, wrist, thick)


func _width(spr: Sprite2D, metres: float, h: float) -> void:
	spr.scale = Vector2.ONE * metres * PPM * (1.0 + 0.06 * h) / spr.texture.get_width()
