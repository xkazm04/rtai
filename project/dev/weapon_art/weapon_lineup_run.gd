class_name WeaponLineupRun
extends Node
## Weapon-art lineup (dev): six Rivets on the real cutout rig, each aiming one core weapon held
## at its grip point in the closed claw, its pickup lying on the pavement below, a cop at the end
## for scale; look_d4 over the world. Writes <out>/lineup-32ppm.png (+ a 3x crop) and
## lineup-64ppm.png. Dev only: it points Rivet's gun cell at the closed claw so the baked pistol
## cell does not double the drawn weapon (rivet-arsenal owns the real socket).

const PX: float = 32.0
const GROUND: String = "res://features/city/art/ground/"
const IDS: Array[StringName] = [
	&"pistol", &"machine_pistol", &"electro_gun", &"flamethrower", &"rocket_launcher", &"molotov"
]
const STEP_M: float = 2.55
const SETTLE_TICKS: int = 90
const GRIP_U: float = 0.62  # where the claw closes along the claw cell
const TANK_M: float = 0.8
const PRINT: bool = true  # held parts through the rig's print_part material

var out_dir: String = ""
var _world: CanvasLayer = CanvasLayer.new()
var _post: CanvasLayer = CanvasLayer.new()
var _under: CanvasLayer = CanvasLayer.new()
var _actors: CanvasLayer = CanvasLayer.new()
var _over: CanvasLayer = CanvasLayer.new()
var _look: ShaderMaterial = ShaderMaterial.new()
var _rigs: CharacterRigs = CharacterRigs.new()
var _bus: EventBus = EventBus.new()
var _data: DataStore = DataStore.new()
var _art: WeaponArt = WeaponArt.new()
var _held: Array[Sprite2D] = []
var _tank: Sprite2D = null
var _hose: Line2D = Line2D.new()


func _ready() -> void:
	var layers: Array[CanvasLayer] = [_world, _post, _under, _actors, _over]
	for i: int in layers.size():
		layers[i].layer = i
		add_child(layers[i])
	add_child(_bus)
	add_child(_data)
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
	_props()


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	for z: float in [1.0, 2.0]:
		_frame(z)
		for t: int in SETTLE_TICKS:
			_pose()
			_rigs.step_ticks(1)
			_attach()
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		ok = _save(roundi(z * PX)) and ok
	return 0 if ok else 1


func _spot(i: int) -> Vector2:
	return Vector2((i - 3.0) * STEP_M, -0.9) * PX


func _cast() -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	for i: int in IDS.size() + 1:
		var kind: BodyPlan.Kind = BodyPlan.Kind.RIVET if i < IDS.size() else BodyPlan.Kind.COP
		@warning_ignore("return_value_discarded")
		f.put(i, i + 1, kind, _spot(i), Vector2.ZERO)
		f.looks[i] = RigFeed.LOOK_AUTO if i < IDS.size() else 5


func _props() -> void:
	for i: int in IDS.size():
		var id: StringName = IDS[i]
		var held: Sprite2D = _art.make_held(id)
		held.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		if PRINT:
			held.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
		_over.add_child(held)
		_held.append(held)
		var pick: Sprite2D = Sprite2D.new()
		pick.texture = _art.pickup_texture(id)
		pick.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		pick.scale = Vector2.ONE * _art.world_scale(id)
		pick.position = _spot(i) + Vector2(0.0, 2.4) * PX
		_world.add_child(pick)
	_tank = Sprite2D.new()
	_tank.texture = _art.part_texture(&"flamethrower", "tank")
	_tank.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_tank.scale = Vector2.ONE * TANK_M * PX / _tank.texture.get_width()
	if PRINT:
		_tank.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
	_over.add_child(_tank)
	_hose.width = 1.6
	_hose.default_color = Color("1b1517")
	_over.add_child(_hose)


func _pose() -> void:
	var f: RigFeed = _rigs.feed
	_rigs.focus = Vector2.ZERO
	for i: int in f.count:
		f.clip[i] = RigClips.Clip.NONE
		f.face[i] = 0.0
		f.aim[i] = f.pos[i] + Vector2(9.0, 0.0) * PX
		f.flags[i] = RigFeed.Flag.GUN_OUT | RigFeed.Flag.AIMING


## Puts each held part on its Rivet's claw (grip on the closing point, barrel along the claw).
func _attach() -> void:
	for i: int in IDS.size():
		var rig: CutRig = _rigs.rig_for(i + 1)
		if rig == null:
			continue
		rig.plan.hand_pistol = rig.plan.hand_closed
		var hand: Sprite2D = rig.sides[rig.plan.gun_arm].hand
		var tex: Vector2 = hand.texture.get_size()
		var local: Vector2 = Vector2(tex.x * GRIP_U, tex.y * 0.5) + hand.offset
		_held[i].position = hand.global_transform * local
		_held[i].rotation = hand.global_rotation
		if IDS[i] == &"flamethrower":
			_backpack(rig, _held[i])


func _backpack(rig: CutRig, wand: Sprite2D) -> void:
	var back: Vector2 = rig.torso.global_transform * Vector2(-90.0, 0.0)
	_tank.position = back
	_tank.rotation = rig.torso.global_rotation + PI * 0.5
	var tail: Vector2 = wand.global_transform * Vector2(-wand.offset.x * 0.0, -wand.offset.y)
	var side: Vector2 = Vector2(0.0, 1.0).rotated(rig.torso.global_rotation) * 0.3 * PX
	_hose.points = PackedVector2Array([back + side, back + side * 1.6 + Vector2(0.4, 0) * PX, tail])


func _frame(z: float) -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var xf: Transform2D = Transform2D(0.0, Vector2(z, z), 0.0, view * 0.5)
	for l: CanvasLayer in [_world, _under, _actors, _over]:
		l.transform = xf
	_rigs.zoom = z
	_look.set_shader_parameter("world_px", -view * 0.5)


func _ground() -> void:
	for x: int in range(-3, 3):
		_tile("sidewalk_tone", Vector2(x * 8 + 4, 0) * PX)
		_tile("road_straight_tone_b", Vector2(x * 8 + 4, 8) * PX)


func _tile(tile: String, at: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(GROUND + tile + ".png") as Texture2D
	s.scale = Vector2.ONE * 8.0 * PX / s.texture.get_width()
	s.position = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)


func _save(ppm: int) -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return false
	var base: String = out_dir.path_join("lineup-%dppm" % ppm)
	var ok: bool = img.save_png(base + ".png") == OK
	if ppm == 32:
		var view: Vector2 = Vector2(img.get_size())
		var r: Rect2i = Rect2i(
			Vector2i(view * 0.5 + Vector2(-9.5, -3.0) * PX), Vector2i(19 * 32, 7 * 32)
		)
		var crop: Image = img.get_region(r)
		crop.resize(r.size.x * 2, r.size.y * 2, Image.INTERPOLATE_NEAREST)
		ok = crop.save_png(base + "-2x.png") == OK and ok
	return ok
