class_name MotionCourseRun
extends Node
## rivet-motion: one Rivet driven by the real PlayerMotion (rivet_motion.json) through a scripted
## input course: a strafe box around a fixed aim mark (strafe, backpedal), stops, a sprint each
## way (the facing follows the walk), rolls out of a sprint and from a stand. The label shows the
## live state; an ink ring marks the roll's i-frames.

const PX: float = 32.0
const GROUND: String = "res://features/city/art/ground/"
const WALK_MPS: float = 4.5
const MARK: Vector2 = Vector2(0.0, -4.5)
## [seconds, move, held actions (comma list), aim at the mark?]
const COURSE: Array[Array] = [
	[0.8, Vector2.ZERO, "", true],
	[1.2, Vector2.RIGHT, "", true],
	[0.9, Vector2.DOWN, "", true],
	[2.0, Vector2.LEFT, "", true],
	[0.9, Vector2.UP, "", true],
	[0.7, Vector2.ZERO, "", true],
	[1.3, Vector2.RIGHT, "sprint", false],
	[0.05, Vector2.RIGHT, "sprint,roll", false],
	[0.8, Vector2.ZERO, "", true],
	[0.05, Vector2.DOWN, "roll", true],
	[0.8, Vector2.ZERO, "", true],
	[1.6, Vector2.LEFT, "sprint", false],
	[0.6, Vector2.ZERO, "", false],
	[0.05, Vector2.UP, "roll", true],
	[1.0, Vector2.ZERO, "", true],
]

## true: the D5 world print over look_d4 (the game's look); false: look_d4 alone (the before).
var d5: bool = true
var zoom: float = 1.0
var _d5: ShaderMaterial = null
var _world: CanvasLayer = CanvasLayer.new()
var _post: CanvasLayer = CanvasLayer.new()
var _actors: CanvasLayer = CanvasLayer.new()
var _hud: CanvasLayer = CanvasLayer.new()
var _look: ShaderMaterial = ShaderMaterial.new()
var _rig: CutRig = CutRig.new()
var _ring: Line2D = Line2D.new()
var _label: Label = Label.new()
var _motion: PlayerMotion = PlayerMotion.shipped()
var _actions: PlayerActions = PlayerActions.shipped()
var _pos: Vector2 = Vector2(-1.0, 1.0)
var _previous: int = 0
var _aim_mark: Line2D = null


func _ready() -> void:
	for i: int in 4:
		var layer: CanvasLayer = [_world, _post, _actors, _hud][i]
		layer.layer = i
		add_child(layer)
	for x: int in range(-3, 3):
		for y: int in range(-2, 2):
			_tile("sidewalk_tone", Vector2(x * 8 + 4, y * 8 + 4) * PX)
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_look.shader = load("res://assets/shaders/look_d4.gdshader") as Shader
	_look.set_shader_parameter(&"grime_tex", GrimeLattice.texture())
	rect.material = _look
	_post.add_child(rect)
	_actors.add_child(_rig)
	_rig.setup(RivetPlan.build(), RigVariant.rivet())
	_rig.snap_facing(-PI * 0.5)
	_ring.points = _circle(0.75 * PX)
	_ring.width = 3.0
	_ring.default_color = Color(0.1, 0.1, 0.12, 0.85)
	_actors.add_child(_ring)
	_aim_mark = _cross(MARK * PX)
	_label.position = Vector2(90, 24)
	_label.add_theme_font_size_override(&"font_size", 22)
	_label.add_theme_color_override(&"font_color", Color(0.1, 0.1, 0.12))
	_hud.add_child(_label)
	var view: Vector2 = get_viewport().get_visible_rect().size
	var xf: Transform2D = Transform2D(0.0, Vector2(zoom, zoom), 0.0, view * 0.5)
	_world.transform = xf
	_actors.transform = xf
	_look.set_shader_parameter("world_px", -view * 0.5)
	if d5:
		_d5 = RivetD5Post.attach(_post, zoom, -view * 0.5)


## Plays the course once; returns the exit code.
func play() -> int:
	for seg: Array in COURSE:
		var secs: float = seg[0]
		var move: Vector2 = seg[1]
		var held: String = seg[2]
		var aim_mark: bool = seg[3]
		for _t: int in maxi(roundi(secs / SimClock.TICK_DT), 1):
			_step(move, held, aim_mark)
			await get_tree().process_frame
	return 0


func _step(move: Vector2, held: String, aim_mark: bool) -> void:
	var c: PlayerCommand = PlayerCommand.new()
	c.move = move
	c.aim = (MARK - _pos).normalized() if aim_mark else Vector2.ZERO
	for n: String in held.split(",", false):
		c.held |= 1 << _actions.bit(StringName(n))
	c.pressed = c.held & ~_previous
	_previous = c.held
	var rolls: int = _motion.rolls
	_pos += _motion.step(c, WALK_MPS, _actions)
	if _motion.rolls != rolls:
		_rig.clips.roll(_motion.roll_ticks * SimClock.TICK_DT)
	_rig.position = _pos * PX
	_rig.vel_in = _motion.velocity() * PX
	_rig.face_to = _motion.facing().angle()
	_rig.drive(SimClock.TICK_DT)
	_ring.position = _rig.position
	_ring.visible = _motion.invulnerable()
	_label.text = "%s   %.1f m/s" % [_state(c), _motion.velocity().length()]


func _state(c: PlayerCommand) -> String:
	match _motion.phase:
		PlayerMotion.Phase.ROLL:
			return "ROLL (i-frames)" if _motion.invulnerable() else "ROLL"
		PlayerMotion.Phase.RECOVER:
			return "ROLL RECOVERY"
	if _motion.sprinting:
		return "SPRINT (tackles above 5.0)"
	if c.move == Vector2.ZERO:
		return "IDLE / STOP"
	var d: float = c.move.normalized().dot(_motion.facing())
	return "WALK FORWARD" if d > 0.7 else ("BACKPEDAL" if d < -0.7 else "STRAFE")


func _circle(r: float) -> PackedVector2Array:
	var pts: Array[Vector2] = []
	for i: int in 33:
		pts.append(Vector2.RIGHT.rotated(TAU * i / 32.0) * r)
	return PackedVector2Array(pts)


func _cross(at: Vector2) -> Line2D:
	var l: Line2D = Line2D.new()
	l.points = PackedVector2Array([Vector2(-10, 0), Vector2(10, 0), Vector2(0, 0), Vector2(0, -10)])
	l.add_point(Vector2(0, 10))
	l.width = 3.0
	l.default_color = Color(0.1, 0.1, 0.12)
	l.position = at
	_actors.add_child(l)
	return l


func _tile(tile: String, at: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(GROUND + tile + ".png") as Texture2D
	s.scale = Vector2.ONE * 8.0 * PX / s.texture.get_width()
	s.position = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)
