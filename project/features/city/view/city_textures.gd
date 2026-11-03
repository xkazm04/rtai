class_name CityTextures
extends RefCounted
## The draw-list textures by table id: the shipped D4 art where the table names one, else a flat
## placeholder per class (vehicles, decals and the kerb corner have no D4 art yet). Every art
## file is requested on the loader threads first and collected after, all before the run
## (WLD-07: behind the loading screen, never blocking a gameplay frame). size_px is the drawn size
## at zoom 1 (the table's metres, not the texture's pixels: art density is free to change).

const PLACEHOLDER: Dictionary[String, Color] = {
	"ground": Color(0.24, 0.23, 0.25),
	"building": Color(0.32, 0.3, 0.36),
	"prop": Color(0.75, 0.45, 0.3),
	"vehicle": Color(0.45, 0.43, 0.45),
	"decal": Color(0.2, 0.2, 0.22, 0.5),
}

var rids: Array[RID] = []
var textures: Array[Texture2D] = []
var size_px: Array[Vector2] = []
## The table class of each id (ground, building, prop, vehicle, decal): picks its render layer.
var classes: Array[String] = []
## the table `name` per id (cast_shadows.json `by_name`)
var names: Array[String] = []
var placeholders: int = 0
var art_loaded: int = 0
var load_us: int = 0
var failures: Array[String] = []


func _init(texture_table: Dictionary) -> void:
	var t0: int = Time.get_ticks_usec()
	var rows: Array = texture_table.get("textures", [])
	var paths: Array[String] = []
	for row: Dictionary in rows:
		var size_m: Array = row["size_m"]
		var w: float = size_m[0]
		var h: float = size_m[1]
		size_px.append(Vector2(w, h) * SimConst.PX_PER_M)
		classes.append(str(row["class"]))
		names.append(str(row.get("name", "")))
		var art: Variant = row.get("art")
		var path: String = art if art is String else ""
		if path != "" and ResourceLoader.load_threaded_request(path, "Texture2D", false) != OK:
			failures.append("%s: load request refused" % path)
			path = ""
		paths.append(path)
	var flat: Dictionary[String, Texture2D] = {}
	for i: int in rows.size():
		var tex: Texture2D = _collect(paths[i])
		if tex == null:
			var row: Dictionary = rows[i]
			var cls: String = row["class"]
			if not flat.has(cls):
				var tint: Color = PLACEHOLDER.get(cls, Color.MAGENTA)
				flat[cls] = _flat(tint)
			tex = flat[cls]
			placeholders += 1
		else:
			art_loaded += 1
		textures.append(tex)
		rids.append(tex.get_rid())
	load_us = Time.get_ticks_usec() - t0


func _collect(path: String) -> Texture2D:
	if path == "":
		return null
	var tex: Texture2D = ResourceLoader.load_threaded_get(path)
	if tex == null:
		failures.append("%s: did not load" % path)
	return tex


static func _flat(c: Color) -> Texture2D:
	var img: Image = Image.create_empty(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(c)
	return ImageTexture.create_from_image(img)
