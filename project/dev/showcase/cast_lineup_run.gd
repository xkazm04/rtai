class_name CastLineupRun
extends Node
## n5-cast: the cast lineup from straight above (Rivet, patrol, riot, SWAT, three pedestrians),
## standing in a row facing up (screen -y), through CharacterRigs with look_d4 over the pavement,
## at 32 and 64 px/m. Optionally walking (--walk): every body strides in place up the frame.
## Writes <out>/lineup-<ppm>ppm.png (the row crop). Windowed only (needs a GPU).

const PX: float = 32.0
const GROUND: String = "res://features/city/art/ground/"
const ZOOMS: Array[float] = [1.0, 2.0]
const SETTLE_TICKS: int = 90
const GAP_M: float = 2.3
## Rivet, patrol, riot, SWAT, coat-hat, jacket-hair, hoodie-cap.
const LOOKS: Array[int] = [RigFeed.LOOK_AUTO, 5, 6, RigVariant.SWAT, 0, 1, 3]

var out_dir: String = ""
var walk: bool = false
var _world: CanvasLayer = CanvasLayer.new()
var _post: CanvasLayer = CanvasLayer.new()
var _actors: CanvasLayer = CanvasLayer.new()
var _look: ShaderMaterial = ShaderMaterial.new()
var _rigs: CharacterRigs = CharacterRigs.new()
var _bus: EventBus = EventBus.new()
var _data: DataStore = DataStore.new()


func _ready() -> void:
	_world.layer = 0
	_post.layer = 1
	_actors.layer = 2
	for n: Node in [_world, _post, _actors, _bus, _data]:
		add_child(n)
	for x: int in range(-3, 3):
		_tile("sidewalk_tone", Vector2(x * 8 + 4, 0) * PX)
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_look.shader = load("res://assets/shaders/look_d4.gdshader") as Shader
	_look.set_shader_parameter(&"grime_tex", GrimeLattice.texture())
	rect.material = _look
	_post.add_child(rect)
	_actors.add_child(_rigs)
	_rigs.setup(World.build_context(_bus, _data, 3))
	_cast()


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	for z: float in ZOOMS:
		_frame(z)
		for t: int in SETTLE_TICKS:
			_pose()
			_rigs.step_ticks(1)
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		ok = _save(roundi(z * PX), z) and ok
	return 0 if ok else 1


func _frame(z: float) -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var xf: Transform2D = Transform2D(0.0, Vector2(z, z), 0.0, view * 0.5)
	_world.transform = xf
	_actors.transform = xf
	_rigs.zoom = z
	_look.set_shader_parameter("world_px", -view * 0.5)


func _tile(tile: String, at: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(GROUND + tile + ".png") as Texture2D
	s.scale = Vector2.ONE * 8.0 * PX / s.texture.get_width()
	s.position = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)


func _cast() -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	for i: int in LOOKS.size():
		var kind: BodyPlan.Kind = BodyPlan.Kind.PED
		if i == 0:
			kind = BodyPlan.Kind.RIVET
		elif i <= 3:
			kind = BodyPlan.Kind.COP
		var at: Vector2 = Vector2((i - (LOOKS.size() - 1) * 0.5) * GAP_M, 0.0) * PX
		@warning_ignore("return_value_discarded")
		f.put(i, i + 1, kind, at, Vector2.ZERO)
		f.looks[i] = LOOKS[i]


func _pose() -> void:
	var f: RigFeed = _rigs.feed
	_rigs.focus = Vector2.ZERO
	for i: int in f.count:
		f.clip[i] = RigClips.Clip.NONE
		f.face[i] = -PI * 0.5
		f.flags[i] = 0
		f.vel[i] = Vector2(0.0, -1.4 * PX) if walk else Vector2.ZERO


func _save(ppm: int, z: float) -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return false
	var view: Vector2 = Vector2(img.get_size())
	var half: Vector2 = Vector2(LOOKS.size() * GAP_M * 0.5 + 0.2, 1.6) * PX * z
	var r: Rect2i = Rect2i(Vector2i(view * 0.5 - half), Vector2i(half * 2.0))
	r = r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	var tag: String = "walk-" if walk else ""
	return img.get_region(r).save_png(out_dir.path_join("lineup-%s%dppm.png" % [tag, ppm])) == OK
