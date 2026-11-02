class_name PartLibrary
extends RefCounted
## Part textures and the slicer's per-part measurements (parts.json: size, pivot_a = the joint the
## part rotates about, pivot_b = the far joint), loaded once per art folder and shared by every rig.

const ART_ROOT: String = "res://features/characters/art/"

static var _metas: Dictionary[String, PartLibrary] = {}

var folder: String = ""
var textures: Dictionary[String, Texture2D] = {}
var sizes: Dictionary[String, Vector2] = {}
var pivots_a: Dictionary[String, Vector2] = {}
var pivots_b: Dictionary[String, Vector2] = {}


static func of(dir: String) -> PartLibrary:
	if not _metas.has(dir):
		var lib: PartLibrary = PartLibrary.new()
		lib.folder = dir
		lib._load(ART_ROOT + dir + "/parts.json")
		_metas[dir] = lib
	return _metas[dir]


static func texture(p_folder: String, part: String) -> Texture2D:
	return of(p_folder).tex(part)


## The part's texture, loaded once; hot paths call this on a held PartLibrary (no path building).
func tex(part: String) -> Texture2D:
	var t: Texture2D = textures.get(part, null)
	if t == null:
		t = load(ART_ROOT + folder + "/" + part + ".png") as Texture2D
		textures[part] = t
	return t


## The joint the part rotates about, or its centre when the slicer measured none.
func pivot(part: String, t: Texture2D) -> Vector2:
	if pivots_a.has(part):
		return pivots_a[part]
	return t.get_size() * 0.5


## Cap-to-cap length of a limb part (pivot_b.x - pivot_a.x), 0 when unmeasured.
func span(part: String) -> float:
	if not pivots_a.has(part) or not pivots_b.has(part):
		return 0.0
	return pivots_b[part].x - pivots_a[part].x


func size(part: String) -> Vector2:
	return sizes.get(part, Vector2.ZERO)


func _load(path: String) -> void:
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK or not json.data is Dictionary:
		Log.error("characters", "cannot read %s" % path)
		return
	var data: Dictionary = json.data
	for key: Variant in data:
		var part: String = str(key)
		if not data[key] is Dictionary:
			continue
		var m: Dictionary = data[key]
		sizes[part] = _vec(m.get("size"))
		if m.has("pivot_a"):
			pivots_a[part] = _vec(m["pivot_a"])
		if m.has("pivot_b"):
			pivots_b[part] = _vec(m["pivot_b"])


static func _vec(v: Variant) -> Vector2:
	if v is Array:
		var a: Array = v
		if a.size() >= 2:
			var x: float = a[0]
			var y: float = a[1]
			return Vector2(x, y)
	return Vector2.ZERO
