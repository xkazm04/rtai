class_name AssetBoardRun
extends Node
## D4 asset board (night lane d4-production evidence): the city texture table's vehicles and
## decals drawn on D4 road and pavement tiles through CityTextures (so a row with no art shows
## its flat placeholder, exactly as the city does) plus every extra sprite under
## features/city/art/vehicles/ (damage states, wrecks, hijack overlays), with look_d4 over the
## world, at 32, 48 and 64 px/m. Deterministic: no RNG, no motion. Writes <out>/board-<ppm>.png.

const PX: float = 32.0
const GROUND: String = "res://features/city/art/ground/"
const EXTRA_DIR: String = "res://features/city/art/vehicles/"
const ZOOMS: Array[float] = [1.0, 1.5, 2.0]
const SETTLE_FRAMES: int = 8
const LANE_Y: Array[float] = [-2.0, 2.0]

var out_dir: String = ""
var page: String = "table"
var _world: CanvasLayer = CanvasLayer.new()
var _post: CanvasLayer = CanvasLayer.new()
var _look: ShaderMaterial = ShaderMaterial.new()


func _ready() -> void:
	_world.layer = 0
	_post.layer = 1
	add_child(_world)
	add_child(_post)
	for y: int in range(-2, 3):
		var road: bool = page == "extras" or y == 0 or y == -1
		var tile: String = "road_straight_tone_b" if road else "sidewalk_tone"
		for x: int in range(-4, 4):
			_tile(tile, Vector2(x * 8 + 4, y * 8) * PX)
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_look.shader = load("res://assets/shaders/look_d4.gdshader") as Shader
	rect.material = _look
	_post.add_child(rect)
	if page == "extras":
		_place_extras()
	else:
		_place_table()


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	for z: float in ZOOMS:
		var view: Vector2 = get_viewport().get_visible_rect().size
		_world.transform = Transform2D(0.0, Vector2(z, z), 0.0, view * 0.5)
		_look.set_shader_parameter("world_px", -view * 0.5)
		for i: int in SETTLE_FRAMES:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		var file: String = out_dir.path_join("%s-%dppm.png" % [page, roundi(z * PX)])
		ok = img != null and img.save_png(file) == OK and ok
	return 0 if ok else 1


func _tile(tile: String, at: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(GROUND + tile + ".png") as Texture2D
	s.scale = Vector2.ONE * 8.0 * PX / s.texture.get_width()
	s.position = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)


## Vehicles nose to +x on the centre road (two lanes), decals on the road row above.
func _place_table() -> void:
	var table: Dictionary = CityGen.read_json(CitySystem.TEXTURES)
	var tex: CityTextures = CityTextures.new(table)
	var rows: Array = table["textures"]
	var x: Array[float] = [-15.0, -15.0, -15.0, -15.0]
	for i: int in rows.size():
		var row: Dictionary = rows[i]
		var cls: String = row["class"]
		var lane: int = -1
		if cls == "vehicle":
			lane = 0 if x[0] <= x[1] else 1
		elif cls == "decal":
			lane = 2 + i % 2
		if lane < 0:
			continue
		var w: float = tex.size_px[i].x / PX
		var y: float = LANE_Y[lane] if lane < 2 else -10.0 + (lane - 2) * 4.0
		_sprite(tex.textures[i], Vector2(x[lane] + w * 0.5, y) * PX, tex.size_px[i])
		x[lane] += w + 0.8


## Every extra PNG (damage, wrecks) in name order, a grid of 6 columns at a 6.2 x 3.2 m pitch.
func _place_extras() -> void:
	var names: PackedStringArray = DirAccess.get_files_at(EXTRA_DIR)
	var k: int = 0
	for f: String in names:
		if not f.ends_with(".png") or f.begins_with("hijack_") or f.begins_with("traffic_"):
			continue
		var t: Texture2D = load(EXTRA_DIR + f) as Texture2D
		var at: Vector2 = Vector2(-15.5 + (k % 6) * 6.2, -11.0 + (k / 6) * 3.2)
		_sprite(t, at * PX, Vector2(t.get_size()) * PX / 80.0)
		k += 1


func _sprite(t: Texture2D, at: Vector2, size: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = t
	s.scale = size / Vector2(t.get_size())
	s.position = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)
