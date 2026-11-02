class_name PartsBoardRun
extends Node
## Ped look board and pickup board (--page=pickups: every token at 1.2 m in the item pass, as
## the game draws pickups above the world print).
## Ped look board (night lane d4-production evidence): torso + head combinations of the ped
## parts printed through the real print_part materials at the rig scale (CutRig.SC), with the
## cream halo under the torso as the rig draws it at gameplay zoom, on D4 pavement (top row) and
## charcoal asphalt (bottom row), at 32, 48 and 64 px/m. Deterministic: no rig, no motion.
## Writes <out>/parts-<ppm>.png. Parts missing from the ped folder are skipped.

const PX: float = 32.0
const GROUND: String = "res://features/city/art/ground/"
const ZOOMS: Array[float] = [1.0, 1.5, 2.0]
const HALO_SCALE: float = 1.22
const PICKUP_DIR: String = "res://assets/pickups/"
const PICKUP_M: float = 1.2
const ITEM_SHADER: String = "res://assets/shaders/look_d4_item.gdshader"
const LOOKS: Array[PackedStringArray] = [
	["torso", "head_hat"],
	["torso_jacket", "head_hair"],
	["torso", "head_hood"],
	["torso_vest", "head_hair"],
	["torso_hoodie", "head_cap"],
	["torso_overalls", "head_bald"],
	["torso_hoodie", "head_beanie"],
	["torso_overalls", "head_cap"],
]

var out_dir: String = ""
var page: String = "parts"
var _world: CanvasLayer = CanvasLayer.new()
var _post: CanvasLayer = CanvasLayer.new()
var _actors: CanvasLayer = CanvasLayer.new()
var _look: ShaderMaterial = ShaderMaterial.new()


func _ready() -> void:
	_world.layer = 0
	_post.layer = 1
	_actors.layer = 2
	for n: Node in [_world, _post, _actors]:
		add_child(n)
	for i: int in range(-3, 3):
		_tile("sidewalk_tone", Vector2(i * 8 + 4, -4) * PX)
		_tile("road_straight_tone_b", Vector2(i * 8 + 4, 4) * PX)
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_look.shader = load("res://assets/shaders/look_d4.gdshader") as Shader
	rect.material = _look
	_post.add_child(rect)
	if page == "pickups":
		_pickups()
		return
	if page == "fx":
		_fx()
		return
	for k: int in LOOKS.size():
		for y: float in [-1.6, 1.6]:
			_person(LOOKS[k], Vector2(-7.0 + k * 2.0, y) * PX)


## The FX atlas: all 32 cells (8 x 4, 256 px = 3.2 m) in the item pass, rows 0-1 on pavement,
## rows 2-3 on asphalt, at a 4 x 3 m pitch.
func _fx() -> void:
	var item: ShaderMaterial = _item_mat()
	var atlas: Texture2D = load("res://features/fx/art/fx_atlas.png") as Texture2D
	for k: int in 32:
		var cell: AtlasTexture = AtlasTexture.new()
		cell.atlas = atlas
		cell.region = Rect2((k % 8) * 256, (k / 8) * 256, 256, 256)
		var spr: Sprite2D = Sprite2D.new()
		spr.texture = cell
		spr.position = Vector2(-14.0 + (k % 8) * 4.0, -6.0 + (k / 8) * 3.0 + (k / 16) * 1.0) * PX
		spr.scale = Vector2.ONE * 3.2 * PX / 256.0
		spr.material = item
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		_actors.add_child(spr)


func _item_mat() -> ShaderMaterial:
	var item: ShaderMaterial = ShaderMaterial.new()
	item.shader = load(ITEM_SHADER) as Shader
	return item


func _pickups() -> void:
	var item: ShaderMaterial = _item_mat()
	var k: int = 0
	for f: String in DirAccess.get_files_at(PICKUP_DIR):
		if not f.ends_with(".png"):
			continue
		var t: Texture2D = load(PICKUP_DIR + f) as Texture2D
		for y: float in [-1.6, 1.6]:
			var spr: Sprite2D = Sprite2D.new()
			spr.texture = t
			spr.position = Vector2(-7.0 + k * 2.0, y) * PX
			spr.scale = Vector2.ONE * PICKUP_M * PX / t.get_width()
			spr.material = item
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			_actors.add_child(spr)
		k += 1


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	for z: float in ZOOMS:
		var view: Vector2 = get_viewport().get_visible_rect().size
		var xf: Transform2D = Transform2D(0.0, Vector2(z, z), 0.0, view * 0.5)
		_world.transform = xf
		_actors.transform = xf
		_look.set_shader_parameter("world_px", -view * 0.5)
		PartMaterials.set_view(z)
		for i: int in 6:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		var file: String = out_dir.path_join("%s-%dppm.png" % [page, roundi(z * PX)])
		ok = img != null and img.save_png(file) == OK and ok
	return 0 if ok else 1


func _person(look: PackedStringArray, at: Vector2) -> void:
	var lib: PartLibrary = PartLibrary.of("ped")
	for part: String in look:
		if not ResourceLoader.exists("res://features/characters/art/ped/%s.png" % part):
			return
	var torso: Texture2D = lib.tex(look[0])
	_part(torso, at, PartMaterials.PartKind.HALO, HALO_SCALE)
	_part(torso, at, PartMaterials.PartKind.PART, 1.0)
	_part(lib.tex(look[1]), at, PartMaterials.PartKind.PART, 1.0)


func _part(t: Texture2D, at: Vector2, kind: PartMaterials.PartKind, s: float) -> void:
	var spr: Sprite2D = Sprite2D.new()
	spr.texture = t
	spr.position = at
	spr.rotation = -PI * 0.5
	spr.scale = Vector2.ONE * CutRig.SC * s
	spr.material = PartMaterials.get_mat(kind, false, 0)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_actors.add_child(spr)


func _tile(tile: String, at: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(GROUND + tile + ".png") as Texture2D
	s.scale = Vector2.ONE * 8.0 * PX / s.texture.get_width()
	s.position = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)
