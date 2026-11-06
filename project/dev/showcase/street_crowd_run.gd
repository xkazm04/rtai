extends Node
## n8 street evidence: 16 pedestrians (CharacterRigs.MAX_FULL, every crowd look, actor ids 1-16)
## walking a road in four lanes and both directions, through CharacterRigs under the run's
## --view (the camera's ground squash applied), with look_d4 over the world. Shoots SHOTS frames
## (street-<view>-<ppm>-<i>.png). Windowed only (needs a GPU). Deterministic: no RNG.

const PX: float = 32.0
const GROUND: String = "res://features/city/art/ground/"
const COUNT: int = 16
const SHOTS: PackedInt32Array = [60, 120, 180]
## The looks walked: every pedestrian look, the pooled ones (StreetCrowdCards.POOLS) twice.
const LOOKS: PackedByteArray = [0, 1, 2, 3, 4, 7, 1, 4, 7, 1, 4, 7, 0, 2, 3, 1]

var out_dir: String = ""
var ppm: float = 48.0
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
		for y: int in range(-2, 2):
			_tile("road_straight_tone_b", Vector2(x * 8 + 4, y * 8 + 4) * PX)
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
	var z: float = ppm / PX
	var view: Vector2 = get_viewport().get_visible_rect().size
	var xf: Transform2D = Transform2D(0.0, ViewMode.shared().zoom_of(z), 0.0, view * 0.5)
	_world.transform = xf
	_actors.transform = xf
	_rigs.zoom = z
	_look.set_shader_parameter("world_px", -view * 0.5)
	for t: int in SHOTS[SHOTS.size() - 1] + 1:
		_pose()
		_rigs.step_ticks(1)
		await get_tree().process_frame
		if SHOTS.has(t):
			await RenderingServer.frame_post_draw
			var img: Image = get_viewport().get_texture().get_image()
			var file: String = "street-%s-%d-%d.png" % [ViewMode.shared().id, roundi(ppm), t]
			ok = img != null and img.save_png(out_dir.path_join(file)) == OK and ok
	return 0 if ok else 1


func _tile(tile: String, at: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(GROUND + tile + ".png") as Texture2D
	s.scale = Vector2.ONE * 8.0 * PX / s.texture.get_width()
	s.position = at
	_world.add_child(s)


## Four lanes 1.6 m apart, alternate people walking east and west, staggered 2.2 m.
func _cast() -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	for i: int in COUNT:
		var lane: int = i % 4
		var x: float = -7.0 + float(i >> 2) * 4.4 + lane * 1.1
		@warning_ignore("return_value_discarded")
		f.put(i, i + 1, BodyPlan.Kind.PED, Vector2(x, -2.4 + lane * 1.6) * PX, Vector2.ZERO)
		f.looks[i] = LOOKS[i]


func _pose() -> void:
	var f: RigFeed = _rigs.feed
	_rigs.focus = Vector2.ZERO
	for i: int in f.count:
		var east: bool = i % 2 == 0
		f.clip[i] = RigClips.Clip.NONE
		f.vel[i] = Vector2(38.0 if east else -38.0, 0.0)
		f.face[i] = 0.0 if east else PI
		f.pos[i] += f.vel[i] * SimClock.TICK_DT
