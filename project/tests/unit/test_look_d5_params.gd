extends GutTest
## d5-close: look_d5.params.json is a proposal other lanes read; every key must be a real uniform of
## its shader (set_shader_parameter silently ignores a typo), and the zoom blend must leave the
## 32 px/m gameplay frame untouched.

const PARAMS: String = "res://assets/shaders/look_d5.params.json"
const SHADERS: Dictionary[String, String] = {
	"world": "res://assets/shaders/look_d5.gdshader",
	"part": "res://assets/shaders/look_d5_part.gdshader",
	"shadow": "res://assets/shaders/look_d5_shadow.gdshader",
}
## documented keys that are not uniforms (placement data for the caller)
const NOT_UNIFORMS: Array[String] = ["shadow.offset_m"]


func _params() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PARAMS))
	assert_true(parsed is Dictionary, "params parse")
	var data: Dictionary = {}
	if parsed is Dictionary:
		data = parsed
	return data


func _uniforms(path: String) -> Array[String]:
	var out: Array[String] = []
	var shader: Shader = load(path) as Shader
	for u: Dictionary in shader.get_shader_uniform_list():
		var name: String = u["name"]
		out.append(name)
	return out


func test_every_param_is_a_shader_uniform() -> void:
	var data: Dictionary = _params()
	var schema: String = data.get("schema", "")
	assert_eq(schema, "gtai.look-d5-params/1")
	for group: String in SHADERS:
		var names: Array[String] = _uniforms(SHADERS[group])
		var table: Dictionary = data.get(group, {})
		assert_gt(table.size(), 0, group)
		for key: String in table:
			if NOT_UNIFORMS.has("%s.%s" % [group, key]):
				continue
			assert_has(names, key, "%s.%s is a uniform" % [group, key])


func test_zoom_blend_is_off_at_gameplay_zoom_and_monotone() -> void:
	var stops: Array = _params().get("zoom_amount", [])
	assert_gt(stops.size(), 1)
	var prev_zoom: float = 0.0
	var prev_amount: float = 0.0
	for i: int in stops.size():
		var stop: Array = stops[i]
		var zoom: float = stop[0]
		var amount: float = stop[1]
		if i == 0:
			assert_eq(zoom, 1.0, "the first stop is the 32 px/m gameplay zoom")
			assert_eq(amount, 0.0, "nothing prints at the gameplay zoom")
		else:
			assert_gt(zoom, prev_zoom, "zoom stops ascend")
			assert_true(amount >= prev_amount, "amount never drops as the camera zooms in")
		prev_zoom = zoom
		prev_amount = amount


func test_gameplay_zoom_proposals_default_off() -> void:
	var world: Dictionary = _params().get("world", {})
	var floor_v: float = world.get("age_floor", -1.0)
	assert_eq(floor_v, 0.0, "age_floor stays off until the visual-engine lane adopts it")
