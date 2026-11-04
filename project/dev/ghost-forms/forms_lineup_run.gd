extends Node
## ghost-forms: base Rivet (the CharacterRigs pool, the n5-cast hybrid) beside TonnageRig, both
## facing up (screen -y), optionally walking in place (--walk: Rivet at 1.4 m/s, Tonnage at its
## gait). Writes <out>/<tag>-<ppm>ppm.png (the row crop), or with --frames=<n> a numbered PNG
## sequence at 32 px/m for a clip (<out>/<tag>-32-%04d.png).

const PX: float = 32.0
const GROUND: String = "res://features/city/art/ground/"
const ZOOMS: Array[float] = [1.0, 2.0]
const SETTLE_TICKS: int = 60
const TONNAGE_X_M: float = 2.6

var out_dir: String = ""
var tag: String = "tonnage-lineup"
var walk: bool = false
var unfold: float = 1.0
var frames: int = 0
var print_parts: bool = false
## --full: save the whole viewport (the HUD in frame), not the body crop.
var full: bool = false
## The sequence zoom (1 = 32 px/m, 2 = 64 px/m) for --frames runs.
var _zoom_base: float = 1.0
var _world: CanvasLayer = CanvasLayer.new()
var _post: CanvasLayer = CanvasLayer.new()
var _actors: CanvasLayer = CanvasLayer.new()
var _look: ShaderMaterial = ShaderMaterial.new()
var _rigs: CharacterRigs = CharacterRigs.new()
var _bus: EventBus = EventBus.new()
var _data: DataStore = DataStore.new()
var _tonnage: TonnageRig = TonnageRig.new()


func _ready() -> void:
	_world.layer = 0
	_post.layer = 1
	_actors.layer = 2
	for n: Node in [_world, _post, _actors, _bus, _data]:
		add_child(n)
	for x: int in range(-2, 2):
		for y: int in range(-3, 1):
			_tile("sidewalk_tone", Vector2(x * 8 + 4, y * 8 + 4) * PX)
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_look.shader = load("res://assets/shaders/look_d4.gdshader") as Shader
	_look.set_shader_parameter(&"grime_tex", GrimeLattice.texture())
	rect.material = _look
	_post.add_child(rect)
	_actors.add_child(_rigs)
	_rigs.setup(World.build_context(_bus, _data, 3))
	TonnageRig.print_parts = print_parts
	_actors.add_child(_tonnage)
	_tonnage.position = Vector2(TONNAGE_X_M * 0.5, 0.0) * PX
	_tonnage.rotation = -PI * 0.5
	_tonnage.unfold = unfold
	var f: RigFeed = _rigs.feed
	f.count = 0
	@warning_ignore("return_value_discarded")
	f.put(0, 1, BodyPlan.Kind.RIVET, Vector2(-TONNAGE_X_M * 0.5, 0.0) * PX, Vector2.ZERO)
	f.looks[0] = RigFeed.LOOK_AUTO


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	if frames > 0:
		return await _sequence()
	for z: float in ZOOMS:
		_frame(z)
		for t: int in SETTLE_TICKS:
			await _tick()
		await RenderingServer.frame_post_draw
		ok = _save(_crop(z), "%s-%dppm.png" % [tag, roundi(z * PX)]) and ok
	return 0 if ok else 1


func _sequence() -> int:
	_frame(1.0)
	var ppm: int = roundi(_zoom_base * PX)
	var ok: bool = true
	for i: int in frames:
		await _tick()
		await RenderingServer.frame_post_draw
		ok = _save(_crop(1.0), "%s-%d-%04d.png" % [tag, ppm, i]) and ok
	return 0 if ok else 1


func _tick() -> void:
	var f: RigFeed = _rigs.feed
	_rigs.focus = Vector2.ZERO
	f.clip[0] = RigClips.Clip.NONE
	f.face[0] = -PI * 0.5
	f.flags[0] = 0
	f.vel[0] = Vector2(0.0, -1.4 * PX) if walk else Vector2.ZERO
	_rigs.step_ticks(1)
	_tonnage.speed_mps = 2.2 if walk else 0.0
	_tonnage.advance(SimClock.TICK_DT)
	await get_tree().process_frame


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


func _crop(z: float) -> Rect2i:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var half: Vector2 = Vector2(TONNAGE_X_M + 1.6, 2.9) * PX * z
	return Rect2i(Vector2i(view * 0.5 - half), Vector2i(half * 2.0))


func _save(r: Rect2i, file: String) -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return false
	if full:
		r = Rect2i(Vector2i.ZERO, img.get_size())
	r = r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	return img.get_region(r).save_png(out_dir.path_join(file)) == OK
