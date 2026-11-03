class_name ArtIds
extends RefCounted
## Art by id from a data table (rows `{id, art, size_m?, draw_k?}`, DAT-05): a view asks for
## `rivet`, never a path, so an art lane can swap a file in the table without touching the scene.
## An id that is missing or fails to load draws a flat ink square and logs once (an art landing
## must never crash a scene). size_m (optional) is the drawn size in metres where the art fixes
## it; draw_k (optional, default 1) scales it.

const INK: Color = Color("17131b")

var _paths: Dictionary[StringName, String] = {}
var _sizes: Dictionary[StringName, Vector2] = {}
var _tex: Dictionary[StringName, Texture2D] = {}
var _placeholder: Texture2D = null
var _area: String = "art"


func _init(path: String, schema_id: String, area: String = "art") -> void:
	_area = area
	var t: DataTable = DataTable.open(path, schema_id)
	for row: Variant in t.array(t.raw, "art"):
		var r: Dictionary = row if row is Dictionary else {}
		var id: StringName = StringName(t.text(r, "id"))
		_paths[id] = t.text(r, "art")
		if r.has("size_m"):
			var k: float = t.num(r, "draw_k") if r.has("draw_k") else 1.0
			_sizes[id] = t.vec(r, "size_m") * k
	if not t.ok():
		Log.error(_area, str(t.errors()))


## The texture for `id`, loaded once; a flat ink square when the id is unknown or fails to load.
func texture(id: StringName) -> Texture2D:
	if _tex.has(id):
		return _tex[id]
	var tex: Texture2D = null
	var path: String = _paths.get(id, "")
	if path != "" and ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	if tex == null:
		Log.warn(_area, "no art for id %s (%s): drawing a placeholder" % [id, path])
		tex = _flat()
	_tex[id] = tex
	return tex


## The drawn size in metres (size_m x draw_k), or `fallback` when the row has none.
func size_m(id: StringName, fallback: Vector2 = Vector2.ONE) -> Vector2:
	return _sizes.get(id, fallback)


func has(id: StringName) -> bool:
	return _paths.has(id)


func _flat() -> Texture2D:
	if _placeholder == null:
		var img: Image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
		img.fill(INK)
		_placeholder = ImageTexture.create_from_image(img)
	return _placeholder
