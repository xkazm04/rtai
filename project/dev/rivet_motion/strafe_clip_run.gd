class_name StrafeClipRun
extends Node
## rivet-motion: two Rivets walk the same box (forward, strafe right, backpedal, strafe left) at
## walk then run speed while both aim straight up the screen. Left: hips locked to the aim (the
## day rig, hip_follow 0); right: twin-stick hips (RigHips). A crosshair marks each one's aim.

const PX: float = 32.0
const GROUND: String = "res://features/city/art/ground/"
const LEG_S: float = 1.5
const WALK_MPS: float = 1.6
const RUN_MPS: float = 4.0
const HOLD_S: float = 1.0
const AIM_M: float = 2.6
const SPOTS: Array[Vector2] = [Vector2(-4.7, 1.2), Vector2(2.3, 1.2)]
## Box legs: forward (up = the aim), right, back, left.
const LEGS: Array[Vector2] = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

var zoom: float = 1.5
## > 0: the stride A/B instead (both with hips; left gait_scale 1.0, right this value).
var stride_k: float = 0.0
var _world: CanvasLayer = CanvasLayer.new()
var _post: CanvasLayer = CanvasLayer.new()
var _actors: CanvasLayer = CanvasLayer.new()
var _look: ShaderMaterial = ShaderMaterial.new()
var _rigs: Array[CutRig] = []
var _marks: Array[Line2D] = []


func _ready() -> void:
	_world.layer = 0
	_post.layer = 1
	_actors.layer = 2
	for n: Node in [_world, _post, _actors]:
		add_child(n)
	for x: int in range(-3, 3):
		for y: int in range(-2, 2):
			_tile("sidewalk_tone", Vector2(x * 8 + 4, y * 8 + 4) * PX)
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_look.shader = load("res://assets/shaders/look_d4.gdshader") as Shader
	_look.set_shader_parameter(&"grime_tex", GrimeLattice.texture())
	rect.material = _look
	_post.add_child(rect)
	for i: int in 2:
		var plan: BodyPlan = RivetPlan.build()
		plan.hip_follow = 0.0 if i == 0 and stride_k <= 0.0 else 1.0
		if stride_k > 0.0 and i == 1:
			plan.gait_scale = stride_k
		var rig: CutRig = CutRig.new()
		_actors.add_child(rig)
		rig.setup(plan, RigVariant.rivet())
		rig.position = SPOTS[i] * PX
		rig.snap_facing(-PI * 0.5)
		_rigs.append(rig)
		_marks.append(_cross())
	var view: Vector2 = get_viewport().get_visible_rect().size
	var xf: Transform2D = Transform2D(0.0, Vector2(zoom, zoom), 0.0, view * 0.5)
	_world.transform = xf
	_actors.transform = xf
	_look.set_shader_parameter("world_px", -view * 0.5)


## Plays the whole pattern once (walk box, hold, run box, hold); returns the exit code.
func play() -> int:
	await _hold()
	for mps: float in [WALK_MPS, RUN_MPS]:
		for leg: Vector2 in LEGS:
			for t: int in roundi(LEG_S / SimClock.TICK_DT):
				_step(leg * mps * PX)
				await get_tree().process_frame
		await _hold()
	return 0


func _hold() -> void:
	for t: int in roundi(HOLD_S / SimClock.TICK_DT):
		_step(Vector2.ZERO)
		await get_tree().process_frame


func _step(vel: Vector2) -> void:
	for i: int in _rigs.size():
		var rig: CutRig = _rigs[i]
		rig.position += vel * SimClock.TICK_DT
		rig.vel_in = vel
		rig.face_to = -PI * 0.5
		rig.drive(SimClock.TICK_DT)
		_marks[i].position = rig.position + Vector2(0.0, -AIM_M * PX)


func _cross() -> Line2D:
	var l: Line2D = Line2D.new()
	l.points = PackedVector2Array([Vector2(-8, 0), Vector2(8, 0), Vector2(0, 0), Vector2(0, -8)])
	l.add_point(Vector2(0, 8))
	l.width = 2.0
	l.default_color = Color(0.1, 0.1, 0.12)
	_actors.add_child(l)
	return l


func _tile(tile: String, at: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(GROUND + tile + ".png") as Texture2D
	s.scale = Vector2.ONE * 8.0 * PX / s.texture.get_width()
	s.position = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)
