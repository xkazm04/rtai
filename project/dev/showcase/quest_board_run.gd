extends Node
## Quest 1 art board (night lane d4-production evidence): the collect-call places in D4 laid out
## like the quest's Dock 9 and Toner Room (dock floor, catwalk, the vault cage mesh over the TUCK-IN
## crates, a dock gate, the taped cash at a payphone, the basement checker beside a pavement tile),
## through look_d4 at 32, 48 and 64 px/m. Deterministic: no RNG, no motion.
## Launched by asset_board.gd with --page=quest; writes <out>/quest-<ppm>.png.

const PX: float = 32.0
const ART: String = "res://features/quest/art/collect_call/"
const PROPS: String = "res://features/city/art/props/"
const GROUND: String = "res://features/city/art/ground/"
const ZOOMS: Array[float] = [1.0, 1.5, 2.0]
const SETTLE_FRAMES: int = 8
## Quest 1's cast at the gameplay footprints, drawn at 1.5x (the guard 1.7x) as the README asks.
const CAST: Array[String] = ["juno", "brass", "kilohm", "don_fax", "dock_guard", "mertz"]
const CAST_FOOT: Array[Vector2] = [
	Vector2(0.8, 1.2),
	Vector2(1.6, 1.2),
	Vector2(0.8, 1.6),
	Vector2(1.8, 1.1),
	Vector2(0.9, 0.9),
	Vector2(1.9, 2.0),
]

var out_dir: String = ""
var page: String = "quest"
var _world: CanvasLayer = CanvasLayer.new()
var _post: CanvasLayer = CanvasLayer.new()
var _look: ShaderMaterial = ShaderMaterial.new()


func _ready() -> void:
	_world.layer = 0
	_post.layer = 1
	add_child(_world)
	add_child(_post)
	_tiled("dock_floor", Rect2(-24, -16, 32, 32), 8.0)
	_tiled("basement_floor", Rect2(8, -16, 12, 12), 4.0)
	_tiled_ground("sidewalk_tone", Vector2(12, 0))
	_tiled("catwalk", Rect2(-22, -13.6, 28, 1.2), 4.0, 1.2)
	for row: int in 2:
		for col: int in 5:
			var crate: String = "tuckin_crate_hit" if col == 4 else "tuckin_crate"
			_sprite(ART + crate, Vector2(-14.0 + col * 2.0, -9.0 + row * 1.6), Vector2(1.8, 1.4))
	_tiled("cage_mesh", Rect2(-20, -11, 16, 6), 2.0)
	_sprite(ART + "dock_gate", Vector2(-20, 4), Vector2(4.0, 0.7))
	_sprite(ART + "dock_gate", Vector2(-14, 4), Vector2(4.0, 0.7))
	_sprite(PROPS + "payphone", Vector2(10, 0.5), Vector2(1.3, 1.3))
	_sprite(ART + "cash_taped", Vector2(11.8, 0.2), Vector2(1.4, 0.8))
	_sprite(PROPS + "dumpster", Vector2(13.5, 2.5), Vector2(2.4, 1.6))
	for k: int in CAST.size():
		var foot: Vector2 = CAST_FOOT[k] * (1.7 if CAST[k] == "dock_guard" else 1.5)
		_sprite(ART + "cast_" + CAST[k], Vector2(-19.0 + k * 3.0, -1.0), foot)
		_sprite(ART + "cast_" + CAST[k], Vector2(11.0 + (k % 3) * 2.6, -14.0 + (k / 3) * 3.2), foot)
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_look.shader = load("res://assets/shaders/look_d4.gdshader") as Shader
	rect.material = _look
	_post.add_child(rect)


func shoot() -> int:
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	for z: float in ZOOMS:
		var view: Vector2 = get_viewport().get_visible_rect().size
		var focus: Vector2 = Vector2(-4.0, -4.0) * PX * z
		_world.transform = Transform2D(0.0, Vector2(z, z), 0.0, view * 0.5 - focus)
		_look.set_shader_parameter("world_px", focus - view * 0.5)
		for i: int in SETTLE_FRAMES:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		var file: String = out_dir.path_join("%s-%dppm.png" % [page, roundi(z * PX)])
		ok = img != null and img.save_png(file) == OK and ok
	return 0 if ok else 1


## A texture repeated over a rect in metres (one repeat = tile_w x tile_h m), clipped at the end.
func _tiled(name: String, r: Rect2, tile_w: float, tile_h: float = -1.0) -> void:
	var t: Texture2D = load(ART + name + ".png") as Texture2D
	var th: float = tile_w if tile_h < 0.0 else tile_h
	var y: float = 0.0
	while y < r.size.y:
		var x: float = 0.0
		while x < r.size.x:
			var cell: Vector2 = Vector2(minf(tile_w, r.size.x - x), minf(th, r.size.y - y))
			var s: Sprite2D = Sprite2D.new()
			s.texture = t
			s.centered = false
			s.region_enabled = true
			s.region_rect = Rect2(Vector2.ZERO, Vector2(t.get_size()) * cell / Vector2(tile_w, th))
			s.scale = Vector2(tile_w, th) * PX / Vector2(t.get_size())
			s.position = (r.position + Vector2(x, y)) * PX
			s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			_world.add_child(s)
			x += tile_w
		y += th


func _tiled_ground(tile: String, centre: Vector2) -> void:
	_sprite(GROUND + tile, centre, Vector2(8.0, 8.0))


func _sprite(path: String, at: Vector2, size: Vector2) -> void:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(path + ".png") as Texture2D
	s.scale = size * PX / Vector2(s.texture.get_size())
	s.position = at * PX
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_world.add_child(s)
