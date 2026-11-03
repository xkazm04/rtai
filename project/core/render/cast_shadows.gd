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
	return out


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


## The extra cast offset in px for each texture id of `classes` (CityTextures.classes order).
func extra_px(classes: Array[String], px_per_m: float) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for cls: String in classes:
		var e: float = extra_m.get(cls, 0.0) * px_per_m
		@warning_ignore("return_value_discarded")
		out.append(Vector2(e, e))
	return out
