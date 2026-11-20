class_name KerfRoninTop
extends Node2D
## Overhead cutouts. Local +x faces forward. Sweep angles are measured out from the rear spine.

const POSE = KerfRoninDrawn.Pose
const PPM: float = SimConst.PX_PER_M
## Both packed overhead helmets are 165 pixels wide.
const PART_M: float = 0.96 / 270.0
const SHOULDER_M: Vector2 = Vector2(0.02, 0.53)
const WING_REST: Vector2 = Vector2(45, 34)
const WING_FAST: Vector2 = Vector2(43, 20)
const TAIL_ROOT_M: Vector2 = Vector2(-0.28, 0)

# PartLibrary resolves its folder from features/characters/art.
var _parts: PartLibrary = PartLibrary.of("../../souls/art/kerf/ronin")
var _upper: Array[Sprite2D] = []
var _blade: Array[Sprite2D] = []
var _angles: Array[Vector2] = [WING_REST, WING_REST]
var _curled: Sprite2D
var _straight: Sprite2D
var _head: Sprite2D


func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_curled = _part("tail_curled", "tail_curled")
	_straight = _part("tail_straight", "tail_straight")
	for tail: Sprite2D in [_curled, _straight]:
		tail.rotation = PI / 2
		tail.position = TAIL_ROOT_M * PPM
	for side: String in ["left", "right"]:
		_upper.append(_part("upperarm", side + "_upperarm"))
		_blade.append(_part("blade", side + "_blade"))
	var torso: Sprite2D = _part("torso", "torso")
	torso.rotation = -PI / 2
	_head = _part("head", "head")
	_head.rotation = -PI / 2
	_head.position = Vector2.RIGHT * 0.46 * PPM


func pose(current: KerfRoninDrawn.Pose, speed: float, yaw: float, steps: int) -> void:
	var straight: float = clampf(speed / 12.0, 0.0, 1.0)
	_straight.self_modulate.a = straight
	_curled.self_modulate.a = 1.0 - straight
	var ease: float = 1.0 - pow(0.48, maxi(0, steps))
	for i: int in 2:
		var side: float = -1.0 if i == 0 else 1.0
		var target: Vector2 = _sweep(current, side, yaw)
		_angles[i] = _angles[i].lerp(target, ease)
		var shoulder: Vector2 = SHOULDER_M * Vector2(1, side) * PPM
		var elbow: Vector2 = _joint(_upper[i], "upperarm", shoulder, _angles[i].x, side)
		@warning_ignore("return_value_discarded")
		_joint(_blade[i], "blade", elbow, _angles[i].y, side)


static func _sweep(current: KerfRoninDrawn.Pose, side: float, yaw: float) -> Vector2:
	match current:
		POSE.CRUISE:
			return WING_FAST
		POSE.BLINK:
			return Vector2(11, 0)
		POSE.TURN:
			return Vector2(50, 38) if side * yaw < 0.0 else Vector2(25, 9)
		POSE.HIT:
			return Vector2(55, 42)
		POSE.COCK:
			return Vector2(22, 4) if side > 0.0 else WING_REST
		POSE.CUT:
			return Vector2(50, 180) if side > 0.0 else WING_FAST
		POSE.RECOVER:
			return Vector2(49, 37) if side > 0.0 else WING_REST
	return WING_REST


func _joint(s: Sprite2D, id: String, at: Vector2, sweep: float, side: float) -> Vector2:
	var bone: Vector2 = _parts.pivots_b[id] - _parts.pivots_a[id]
	var axis: float = side * (PI - deg_to_rad(sweep))
	s.position = at
	# The plate has a short shoulder link and a longer cutting edge.
	var length_k: float = 0.74 if id == "upperarm" else 1.0
	# The cutter bows below its root-to-tip chord on the page. Reflect it so the bow
	# faces away from the spine. The node transform carries the same mirror into the echo.
	var across: float = -side if id == "blade" else side
	s.scale = Vector2(length_k, across) * PART_M * PPM
	s.rotation = axis - (bone * s.scale).angle()
	return s.transform * bone


func _part(id: String, label: String) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.name = label
	s.texture = _parts.tex(id)
	s.centered = false
	s.offset = -_parts.pivots_a[id]
	s.scale = Vector2.ONE * PART_M * PPM
	add_child(s)
	return s
