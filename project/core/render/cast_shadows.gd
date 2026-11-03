class_name CastShadows
extends RefCounted
## The building_shadows band as data (data/tables/cast_shadows.json, gtai.cast-shadows/1): one
## material for every chunk shadow command (look_d5_shadow when the d5-close lane's file is in
## the tree, else this lane's cast_shadow placeholder) and the cast distance per texture class
## (the chunk data bakes a short offset; the view adds the rest). Render only.

const TABLE: String = "res://data/tables/cast_shadows.json"
const SCHEMA: String = "gtai.cast-shadows/1"

var shader_path: String = ""
var uniforms: Dictionary = {}
## class -> the extra offset in metres down-right the view adds to a baked shadow command.
var extra_m: Dictionary[String, float] = {}
## texture name -> the total cast distance in metres (overrides its class's offset_m)
var by_name_m: Dictionary[String, float] = {}
## the parapet ink core's cast distance for buildings (ChunkView; 0 = none)
var parapet_core_m: float = 0.0
var _baked_m: Dictionary[String, float] = {}


static func load_table() -> CastShadows:
	var out: CastShadows = CastShadows.new()
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(TABLE)) != OK or not parser.data is Dictionary:
		return out
	var d: Dictionary = parser.data
	if d.get("schema", "") != SCHEMA:
		return out
	var preferred: String = d["shader"]
	var fallback: String = d["fallback_shader"]
	out.shader_path = preferred if ResourceLoader.exists(preferred) else fallback
	out.uniforms = d["uniforms"]
	for row: Dictionary in d["classes"]:
		var cls: String = row["class"]
		var total: float = row["offset_m"]
		var baked: float = row["baked_offset_m"]
		out.extra_m[cls] = total - baked
		out._baked_m[cls] = baked
	out.parapet_core_m = d.get("parapet_core_m", 0.0)
	var names: Dictionary = d.get("by_name", {})
	for n: String in names:
		var m: float = names[n]
		out.by_name_m[n] = m
	return out


## The offset the chunk data bakes into a `cls` shadow command (m).
func baked_m(cls: StringName) -> float:
	return _baked_m.get(String(cls), 0.0)


## The shared shadow material (null when no shader loads: the band keeps its flat tint).
func material() -> ShaderMaterial:
	var sh: Shader = load(shader_path) as Shader if shader_path != "" else null
	if sh == null:
		return null
	var m: ShaderMaterial = ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter(&"grime_tex", GrimeLattice.texture())  # used if it declares it
	for k: String in uniforms:
		var v: float = uniforms[k]
		m.set_shader_parameter(StringName(k), v)
	return m


## The extra cast offset in px for each texture id of `classes` (CityTextures.classes order);
## `names` (the same order) picks a by_name length over the class's.
func extra_px(
	classes: Array[String], px_per_m: float, names: Array[String] = []
) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for i: int in classes.size():
		var cls: String = classes[i]
		var em: float = extra_m.get(cls, 0.0)
		if i < names.size() and by_name_m.has(names[i]):
			em = by_name_m[names[i]] - _baked_m.get(cls, 0.0)
		var e: float = em * px_per_m
		@warning_ignore("return_value_discarded")
		out.append(Vector2(e, e))
	return out
