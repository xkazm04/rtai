class_name RigShowcaseRun
extends Node
## F-09b evidence frames: Rivet, a patrol and a riot cop and four pedestrians on D4 pavement and
## charcoal asphalt, through CharacterRigs, with look_d4 over the world, at 32 and 48 px/m.
## Writes <out>/rig-32ppm.png and rig-48ppm.png (+ 3x / 2x crops) and the baked crowd atlas
## (crowd-atlas.png). Windowed only (needs a GPU).

const PX: float = 32.0
const GROUND: String = "res://features/city/art/ground/"
const ZOOMS: Array[float] = [1.0, 1.5]
const SETTLE_TICKS: int = 90

var out_dir: String = ""
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
	_ground()
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_look.shader = load("res://assets/shaders/look_d4.gdshader") as Shader
	_look.set_shader_parameter(&"grime_tex", GrimeLattice.texture())
	rect.material = _look
	_post.add_child(rect)
	_actors.add_child(_rigs)
	_rigs.setup(World.build_context(_bus, _data, 3))
	_cast()


## Shoots both zooms, then returns the exit code.
func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	for z: float in ZOOMS:
		_frame(z)
		for t: int in SETTLE_TICKS:
			_pose(t)
			_rigs.step_ticks(1)
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		ok = _save(roundi(z * PX)) and ok
	await _rigs.bake_crowd()
	var t0: int = Time.get_ticks_msec()
	ok = _rigs.atlas.baked and ok
	if _rigs.atlas.texture != null:
		var path: String = out_dir.path_join("crowd-atlas.png")
		ok = _rigs.atlas.texture.get_image().save_png(path) == OK and ok
	if _rigs.atlas_d5.texture != null:  # the D5 twin (same cells, 64 px/m, D5 part overlays)
		var d5_path: String = out_dir.path_join("crowd-atlas-d5.png")
		ok = _rigs.atlas_d5.texture.get_image().save_png(d5_path) == OK and ok
	printerr(
		(
			"rig_showcase: crowd atlas baked=%s (%d ms to save)"
			% [_rigs.atlas.baked, Time.get_ticks_msec() - t0]
		)
	)
	return 0 if ok else 1


func _frame(z: float) -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var xf: Transform2D = Transform2D(0.0, Vector2(z, z), 0.0, view * 0.5)
	_world.transform = xf
	_actors.transform = xf
	_rigs.zoom = z
	_look.set_shader_parameter("world_px", -view * 0.5)


func _ground() -> void:
	for x: int in range(-3, 3):
		_tile("sidewalk_tone", Vector2(x * 8 + 4, -4) * PX)
		_tile("road_straight_tone_b", Vector2(x * 8 + 4, 4) * PX)


func _tile(tile: String, at: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(GROUND + tile + ".png") as Texture2D
	s.scale = Vector2.ONE * 8.0 * PX / s.texture.get_width()
	s.position = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)


## Rivet on the kerb line facing the cops; the riot cop aims; peds walk the pavement.
func _cast() -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	var kinds: Array[BodyPlan.Kind] = [
		BodyPlan.Kind.RIVET,
		BodyPlan.Kind.COP,
		BodyPlan.Kind.COP,
		BodyPlan.Kind.PED,
		BodyPlan.Kind.PED,
		BodyPlan.Kind.PED,
		BodyPlan.Kind.PED
	]
	var looks: PackedByteArray = PackedByteArray([RigFeed.LOOK_AUTO, 5, 6, 0, 1, 2, 3])
	var spots: PackedVector2Array = PackedVector2Array(
		[
			Vector2(0.0, 0.6),
			Vector2(4.2, 2.6),
			Vector2(5.0, -0.4),
			Vector2(-5.5, -2.6),
			Vector2(-3.2, -3.4),
			Vector2(-2.0, -1.8),
			Vector2(-6.4, -1.0)
		]
	)
	for i: int in kinds.size():
		@warning_ignore("return_value_discarded")
		f.put(i, i + 1, kinds[i], spots[i] * PX, Vector2.ZERO)
		f.looks[i] = looks[i]


func _pose(t: int) -> void:
	var f: RigFeed = _rigs.feed
	_rigs.focus = f.pos[0]
	for i: int in f.count:
		f.clip[i] = RigClips.Clip.NONE
	f.face[0] = 0.0
	for i: int in [1, 2]:
		f.face[i] = (f.pos[0] - f.pos[i]).angle()
		f.aim[i] = f.pos[0]
		f.flags[i] = RigFeed.Flag.GUN_OUT | RigFeed.Flag.AIMING
	if t % 40 == 20:
		f.clip[2] = RigClips.Clip.SHOOT
	for i: int in range(3, f.count):
		f.vel[i] = Vector2(40.0 + i * 6.0, 0.0)
		f.face[i] = 0.0
		f.pos[i] += f.vel[i] * SimClock.TICK_DT


func _save(ppm: int) -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return false
	var base: String = out_dir.path_join("rig-%dppm" % ppm)
	var ok: bool = img.save_png(base + ".png") == OK
	var k: int = 3 if ppm == 32 else 2
	var z: float = ppm / PX
	var view: Vector2 = Vector2(img.get_size())
	var lo: Vector2 = view * 0.5 + Vector2(-7.0, -4.2) * PX * z
	var size: Vector2 = Vector2(13.0, 7.6) * PX * z
	var r: Rect2i = Rect2i(Vector2i(lo), Vector2i(size)).intersection(
		Rect2i(Vector2i.ZERO, img.get_size())
	)
	var crop: Image = img.get_region(r)
	crop.resize(r.size.x * k, r.size.y * k, Image.INTERPOLATE_NEAREST)
	return crop.save_png(base + "-%dx.png" % k) == OK and ok
