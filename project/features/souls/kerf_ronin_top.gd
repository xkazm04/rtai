class_name KerfRoninTop
extends Node2D
## Overhead cutouts. Local +x faces forward. Sweep angles are measured out from the rear spine.

const POSE = KerfRoninDrawn.Pose
const PPM: float = SimConst.PX_PER_M
## Both packed overhead helmets are 165 pixels wide.
const PART_M: float = 0.96 / 270.0 * KerfRoninDrawn.SIZE_K
const SHOULDER_M: Vector2 = Vector2(0.02, 0.53) * KerfRoninDrawn.SIZE_K
const WING_REST: Vector2 = Vector2(45, 34)
const WING_FAST: Vector2 = Vector2(43, 20)
const TAIL_ROOT_M: Vector2 = Vector2(-0.28, 0) * KerfRoninDrawn.SIZE_K
## The helmet and its trailing crest share a texture. The crest passes behind the back plate.
const HELMET_Y: int = 138
const HEAD_M: float = 0.46 * KerfRoninDrawn.SIZE_K
const FLINCH_M: float = 0.12 * KerfRoninDrawn.SIZE_K

static var _cruise_sweep: Vector2 = Vector2.ZERO

var slots: KerfChargeSlots = KerfChargeSlots.new()
# PartLibrary resolves its folder from features/characters/art.
var _parts: PartLibrary = PartLibrary.of("../../souls/art/kerf/ronin")
var _upper: Array[Sprite2D] = []
var _blade: Array[Sprite2D] = []
var _angles: Array[Vector2] = [WING_REST, WING_REST]
var _curled: Sprite2D
var _straight: Sprite2D
var _crest: Sprite2D
var _head: Sprite2D


func _init() -> void:
	if _cruise_sweep == Vector2.ZERO:
		_cruise_sweep = cruise_sweep(LaunchArgs.value("--kerf-cruise-wings") == "open")
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_curled = _part("tail_curled", "tail_curled")
	_straight = _part("tail_straight", "tail_straight")
	for tail: Sprite2D in [_curled, _straight]:
		tail.rotation = PI / 2
		tail.position = TAIL_ROOT_M * PPM
	for side: String in ["left", "right"]:
		_upper.append(_part("upperarm", side + "_upperarm"))
		_blade.append(_part("blade", side + "_blade"))
	_crest = _head_part(true)
	var torso: Sprite2D = _part("torso", "torso")
	torso.rotation = -PI / 2
	slots.bind(torso)
	slots.paint(KerfChargeSlots.TOP, 3, 0.0)
	_head = _head_part(false)


func _head_part(crest: bool) -> Sprite2D:
	var sprite: Sprite2D = _part("head", "crest" if crest else "head")
	var region: Rect2 = Rect2(Vector2.ZERO, sprite.texture.get_size())
	if crest:
		region.size.y = HELMET_Y
	else:
		region.position.y = HELMET_Y
		region.size.y -= HELMET_Y
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = sprite.texture
	atlas.region = region
	atlas.filter_clip = true
	sprite.texture = atlas
	sprite.offset += region.position
	sprite.rotation = -PI / 2
	sprite.position = Vector2.RIGHT * HEAD_M * PPM
	return sprite


func pose(
	current: KerfRoninDrawn.Pose, speed: float, yaw: float, steps: int, flinch: bool = false
) -> void:
	_head.position.x = (HEAD_M - FLINCH_M if flinch and current == POSE.HIT else HEAD_M) * PPM
	_crest.position = _head.position
	var straight: float = clampf(speed / 12.0, 0.0, 1.0)
	_straight.self_modulate.a = straight
	_curled.self_modulate.a = 1.0 - straight
	# On release the extended elbow tucks in on the first moving frame.
	var retention: float = 0.30 if _angles[1].y > 90.0 else 0.48
	var ease: float = 1.0 - pow(retention, maxi(0, steps))
	if current == POSE.CUT:
		ease = 1.0
	for i: int in 2:
		var side: float = -1.0 if i == 0 else 1.0
		var target: Vector2 = _sweep(current, side, yaw)
		_angles[i] = _angles[i].lerp(target, ease)
		var shoulder: Vector2 = SHOULDER_M * Vector2(1, side) * PPM
		var elbow: Vector2 = _joint(_upper[i], "upperarm", shoulder, _angles[i].x, side)
		@warning_ignore("return_value_discarded")
		_joint(_blade[i], "blade", elbow, _angles[i].y, side)


static func cruise_sweep(open: bool) -> Vector2:
	return Vector2(62, 40) if open else WING_FAST


static func _sweep(current: KerfRoninDrawn.Pose, side: float, yaw: float) -> Vector2:
	match current:
		POSE.CRUISE:
			return _cruise_sweep
		POSE.BLINK:
			return Vector2(11, 0)
		POSE.TURN:
			return Vector2(50, 38) if side * yaw < 0.0 else Vector2(25, 9)
		POSE.HIT:
			return Vector2(55, 42)
		POSE.COCK:
			return Vector2(22, 4) if side > 0.0 else WING_REST
		POSE.CUT:
			return Vector2(115, 180) if side > 0.0 else WING_FAST
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
