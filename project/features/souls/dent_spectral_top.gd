class_name DentSpectralTop
extends Node2D
## Belt-up bird's-eye rig. Local +x is the nose and +y the dummy's right shoulder.
## Joint positions use metres before PlayerScale; strike reach uses world metres.

const PPM: float = SimConst.PX_PER_M
const PART_M: float = 0.96 / 270.0
const JAB_REACH_M: float = 1.4

var _parts: PartLibrary = PartLibrary.of("dent/spectral")
var _head: Sprite2D
var _upper: Array[Sprite2D] = []
var _fore: Array[Sprite2D] = []
var _drag: float = 0.0
var _grip_ticks: int = 0


func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var finish: ShaderMaterial = ShaderMaterial.new()
	finish.shader = DentSpectralDrawn.FINISH
	material = finish
	var plume: Sprite2D = _part("tail_root", "tail_root")
	plume.position = Vector2.LEFT * 0.22 * PPM
	plume.rotation = PI * 0.5
	for side: String in ["left", "right"]:
		_upper.append(_part("upperarm", side + "_upperarm"))
		_fore.append(_part("forearm_open", side + "_forearm"))
	var torso: Sprite2D = _part("torso", "torso")
	torso.rotation = PI * 0.5
	_head = _part("head", "head")
	_head.rotation = PI * 0.5


func _part(id: String, label: String) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.name = label
	s.use_parent_material = true
	s.centered = false
	s.texture = _parts.tex(id)
	s.offset = -_parts.pivots_a[id]
	s.scale = Vector2.ONE * PART_M * PPM
	add_child(s)
	return s


func reset() -> void:
	_drag = 0.0
	_grip_ticks = 0


## car_at is the car in world pixels. Recoil begins after the tilt jab's cut window.
func pose(
	hover: GhostHover, act: DentSpectralDrawn.Pose, jab_age: int, car_at: Vector2, steps: int
) -> void:
	var sweep: float = clampf(hover.speed_mps / 7.0, 0.0, 1.0)
	var outside: float = -clampf(hover.bank / deg_to_rad(22.0), -1.0, 1.0)
	for i: int in steps:
		_drag = lerpf(_drag, outside, 0.32)
	_grip_ticks = _grip_ticks + steps if act == DentSpectralDrawn.Pose.STEER else 0
	_head.position = Vector2(0.23 + sin(hover.lean) * 0.55, _drag * 0.05) * PPM
	for i: int in 2:
		var side: float = -1.0 if i == 0 else 1.0
		var shoulder: Vector2 = Vector2(0.05, side * 0.36)
		var elbow: Vector2 = Vector2(lerpf(-0.04, -0.38, sweep), side * 0.53 + 0.36 * _drag)
		var hand: Vector2 = Vector2(lerpf(0.30, -0.77, sweep), side * 0.60 + 0.68 * _drag)
		var grip: String = "forearm_open"
		if i == 1:
			var target: Vector2 = _right_hand(act, hand, jab_age, car_at)
			elbow += (target - hand) * 0.42
			if act == DentSpectralDrawn.Pose.STEER:
				elbow = shoulder.lerp(target, 0.46)
			hand = target
			if act in [DentSpectralDrawn.Pose.COCK, DentSpectralDrawn.Pose.JAB] or _grip_ticks >= 4:
				grip = "forearm_fist"
		_limb(_upper[i], "upperarm", shoulder, elbow, side)
		_limb(_fore[i], grip, elbow, hand, side)


func _right_hand(act: DentSpectralDrawn.Pose, rest: Vector2, age: int, car_at: Vector2) -> Vector2:
	match act:
		DentSpectralDrawn.Pose.COCK:
			return Vector2(-0.32, 0.55)
		DentSpectralDrawn.Pose.JAB:
			var fist: Vector2 = Vector2(1.0, 0.12).normalized()
			var world_length: float = (to_global(fist) - global_position).length()
			fist *= JAB_REACH_M / world_length
			var recoil: float = clampf(
				float(age - GhostDrawn.CUT_TICKS + 1) / GhostDrawn.FOLLOW_TICKS, 0.0, 1.0
			)
			return fist.lerp(rest, recoil)
		DentSpectralDrawn.Pose.STEER:
			var shoulder: Vector2 = Vector2(0.05, 0.36)
			return shoulder + shoulder.direction_to(to_local(car_at) / PPM) * 0.82
	return rest


func _limb(s: Sprite2D, id: String, a: Vector2, b: Vector2, side: float) -> void:
	var bone: Vector2 = _parts.pivots_b[id] - _parts.pivots_a[id]
	var delta: Vector2 = (b - a) * PPM
	var along: float = delta.length() / bone.length()
	s.texture = _parts.tex(id)
	s.offset = -_parts.pivots_a[id]
	s.position = a * PPM
	s.scale = Vector2(along, side * PART_M * PPM)
	s.rotation = delta.angle() - (bone * s.scale).angle()
