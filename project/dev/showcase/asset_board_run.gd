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
const ROOF_DIR: String = "res://features/city/art/roofs/"
## Shipped district roofs mixed with the generic block roofs (roof_*), 4 x 3 at a 9 m pitch.
const ROOFS: Array[String] = [
	"building_bar",
	"roof_skylights",
	"building_tall",
	"roof_garden",
	"roof_sawtooth",
	"building_osha",
	"roof_solar",
	"roof_telecom",
	"building_hq",
	"roof_tank",
	"building_union_hall",
	"roof_charging",
]

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
	if page == "corner":
		_corner_page()
		return
	if page == "roofs":
		_roofs_page()
		return
	for y: int in range(-2, 3):
		var all_road: bool = page in ["extras", "hijack"] or (page == "decals" and y < 2)
		var road: bool = all_road or y == 0 or y == -1
		var tile: String = "road_straight_tone_b" if road else "sidewalk_tone"
		for x: int in range(-4, 4):
			_tile(tile, Vector2(x * 8 + 4, y * 8) * PX)
	_post_pass()
	if page in ["extras", "hijack", "decals"]:
		_place_extras()
	elif page == "props":
		_place_props()
	else:
		_place_table()


func _post_pass() -> void:
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_look.shader = load("res://assets/shaders/look_d4.gdshader") as Shader
	rect.material = _look
	_post.add_child(rect)


## The kerb corner (pavement top-left) at the centre, joined by a horizontal kerb on its left,
## a vertical kerb (the straight turned -90 degrees) above it and pavement above-left.
func _corner_page() -> void:
	for j: int in range(-2, 3):
		for i: int in range(-3, 3):
			var tile: String = "road_straight_tone_b"
			var rot: float = 0.0
			if i < 0 and j < 0:
				tile = "sidewalk_tone"
			elif i < 0 and j == 0:
				tile = "curb_straight_tone"
			elif i == 0 and j < 0:
				tile = "curb_straight_tone_c"
				rot = -PI * 0.5
			elif i == 0 and j == 0:
				tile = "curb_corner_tone"
			_tile(tile, Vector2(i * 8, j * 8) * PX, rot)
	_post_pass()


func _roofs_page() -> void:
	for j: int in range(-2, 3):
		for i: int in range(-3, 3):
			_tile("sidewalk_tone", Vector2(i * 8 + 4, j * 8) * PX)
	for k: int in ROOFS.size():
		var path: String = ROOF_DIR + ROOFS[k] + ".png"
		if not ResourceLoader.exists(path):
			continue
		var t: Texture2D = load(path) as Texture2D
		var at: Vector2 = Vector2(-13.5 + (k % 4) * 9.0, -9.0 + (k / 4) * 9.0)
		_sprite(t, at * PX, Vector2(8.4, 8.4) * PX)
	_post_pass()


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


func _tile(tile: String, at: Vector2, rot: float = 0.0) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.rotation = rot
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


## The prop rows in two halves (by table order), each on the road and on the pavement, table size.
func _place_props() -> void:
	var table: Dictionary = CityGen.read_json(CitySystem.TEXTURES)
	var tex: CityTextures = CityTextures.new(table)
	var rows: Array = table["textures"]
	var x: Array[float] = [-12.0, -12.0]
	var k: int = 0
	for i: int in rows.size():
		var row: Dictionary = rows[i]
		if row["class"] != "prop":
			continue
		var half: int = 0 if k < 10 else 1
		var w: float = tex.size_px[i].x / PX
		for y: float in [[-6.5, 5.2], [-2.5, 7.4]][half]:
			_sprite(tex.textures[i], Vector2(x[half] + w * 0.5, y) * PX, tex.size_px[i])
		x[half] += w + 0.5
		k += 1


## Every extra PNG (damage, wrecks) in name order, a grid of 6 columns at a 6.2 x 3.2 m pitch.
func _place_extras() -> void:
	var dir: String = "res://features/city/art/decals/" if page == "decals" else EXTRA_DIR
	var names: PackedStringArray = DirAccess.get_files_at(dir)
	var k: int = 0
	for f: String in names:
		if not f.ends_with(".png") or f.begins_with("hijack_") or f.begins_with("traffic_"):
			continue
		var t: Texture2D = load(dir + f) as Texture2D
		var at: Vector2 = Vector2(-15.5 + (k % 6) * 6.2, -11.0 + (k / 6) * 3.2)
		_sprite(t, at * PX, Vector2(t.get_size()) * PX / 80.0)
		var hijack: String = EXTRA_DIR + "hijack_" + f
		if page == "hijack" and ResourceLoader.exists(hijack):
			_sprite(load(hijack) as Texture2D, at * PX, Vector2(t.get_size()) * PX / 80.0)
		k += 1


func _sprite(t: Texture2D, at: Vector2, size: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = t
	s.scale = size / Vector2(t.get_size())
	s.position = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)
