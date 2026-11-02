class_name CityTextures
extends RefCounted
## The draw-list textures by table id: the shipped art where the table names one (loaded with
## load_threaded_request behind the loading screen, WLD-07), else a flat placeholder per class
## until the art lane (F-08) lands real textures. size_px is the drawn size at zoom 1.

const PLACEHOLDER: Dictionary[String, Color] = {
	"ground": Color(0.55, 0.53, 0.5),
	"building": Color(0.32, 0.3, 0.36),
	"prop": Color(0.75, 0.45, 0.3),
	"vehicle": Color(0.3, 0.45, 0.7),
	"decal": Color(0.2, 0.2, 0.22, 0.5),
}

var rids: Array[RID] = []
var size_px: Array[Vector2] = []
var placeholders: int = 0
var _keep: Array[Texture2D] = []


func _init(texture_table: Dictionary) -> void:
	var rows: Array = texture_table.get("textures", [])
	var flat: Dictionary[String, Texture2D] = {}
	for row: Dictionary in rows:
		var size_m: Array = row["size_m"]
		var w: float = size_m[0]
		var h: float = size_m[1]
		size_px.append(Vector2(w, h) * SimConst.PX_PER_M)
		var art: Variant = row.get("art")
		var tex: Texture2D = null
		if art is String:
			var path: String = art
			tex = _load_art(path)
		if tex == null:
			var cls: String = row["class"]
			if not flat.has(cls):
				var tint: Color = PLACEHOLDER.get(cls, Color.MAGENTA)
				flat[cls] = _flat(tint)
			tex = flat[cls]
			placeholders += 1
		_keep.append(tex)
		rids.append(tex.get_rid())


static func _load_art(path: String) -> Texture2D:
	if ResourceLoader.load_threaded_request(path, "Texture2D", true) != OK:
		return null
	var tex: Texture2D = ResourceLoader.load_threaded_get(path)
	return tex


static func _flat(c: Color) -> Texture2D:
	var img: Image = Image.create_empty(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(c)
	return ImageTexture.create_from_image(img)
