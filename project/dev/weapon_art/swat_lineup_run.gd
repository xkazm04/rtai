class_name SwatLineupRun
extends Node
## weapon-art: the cop looks lineup for human-reactions REQUEST 1 (the SWAT parts): patrol, riot,
## SWAT (head_swat + torso_swat) and Rivet for scale, idle and walking, under look_d4 at 32, 48 and
## 128 px/m. Writes lineup-<idle|walk>-<ppm>.png.

const PX: float = 32.0
const GROUND: String = "res://features/city/art/ground/"
const ZOOMS: Array[float] = [1.0, 1.5, 4.0]
const SETTLE_TICKS: int = 90
const GAP_M: float = 1.8
const WALK_PX_S: float = 1.6 * PX

var out_dir: String = ""
var walk: bool = false
var _world: CanvasLayer = CanvasLayer.new()
var _post: CanvasLayer = CanvasLayer.new()
var _actors: CanvasLayer = CanvasLayer.new()
var _look: ShaderMaterial = ShaderMaterial.new()
var _rigs: Array[CutRig] = []


func _ready() -> void:
	_world.layer = 0
	_post.layer = 1
	_actors.layer = 2
	for n: Node in [_world, _post, _actors]:
		add_child(n)
	for x: int in range(-3, 3):
		_tile("sidewalk_tone", Vector2(x * 8 + 4, 0) * PX)
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_look.shader = load("res://assets/shaders/look_d4.gdshader") as Shader
	_look.set_shader_parameter(&"grime_tex", GrimeLattice.texture())
	rect.material = _look
	_post.add_child(rect)
	var plans: Array[BodyPlan] = [
		HumanPlan.cop(), HumanPlan.cop(), HumanPlan.cop(), RivetPlan.build(RivetPlan.FORM_BASE)
	]
	var swat: RigVariant = RigVariant.make(
		BodyPlan.Kind.COP, "swat", "head_swat", "torso_swat", false
	)
	var looks: Array[RigVariant] = [
		RigVariant.crowd(5), RigVariant.crowd(6), swat, RigVariant.rivet()
	]
	for i: int in plans.size():
		var rig: CutRig = CutRig.new()
		_actors.add_child(rig)
		rig.setup(plans[i], looks[i])
		rig.position = Vector2((i - 1.5) * GAP_M, 0.0) * PX
		rig.snap_facing(-PI * 0.5)
		_rigs.append(rig)


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	for w: bool in [false, true]:
		walk = w
		for z: float in ZOOMS:
			_frame(z)
			for t: int in SETTLE_TICKS:
				_drive()
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			ok = _save("lineup-%s-%dppm" % ["walk" if w else "idle", roundi(z * PX)]) and ok
	return 0 if ok else 1


func _drive() -> void:
	for rig: CutRig in _rigs:
		rig.face_to = -PI * 0.5
		rig.vel_in = Vector2(0.0, -WALK_PX_S) if walk else Vector2.ZERO
		rig.drive(SimClock.TICK_DT)


func _frame(z: float) -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var xf: Transform2D = Transform2D(0.0, Vector2(z, z), 0.0, view * 0.5)
	_world.transform = xf
	_actors.transform = xf
	_look.set_shader_parameter("world_px", -view * 0.5)


func _tile(tile: String, at: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(GROUND + tile + ".png") as Texture2D
	s.scale = Vector2.ONE * 8.0 * PX / s.texture.get_width()
	s.position = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)


func _save(name: String) -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return false
	return img.save_png(out_dir.path_join(name + ".png")) == OK
