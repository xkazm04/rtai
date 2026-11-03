extends GutTest
## d5-close: look_d5.params.json is a proposal other lanes read; every key must be a real uniform of
## its shader (set_shader_parameter silently ignores a typo), and the zoom blend must leave the
## 32 px/m gameplay frame untouched.

const PARAMS: String = "res://assets/shaders/look_d5.params.json"
const SHADERS: Dictionary[String, String] = {
	"world": "res://assets/shaders/look_d5.gdshader",
	"part": "res://assets/shaders/look_d5_part.gdshader",
	"shadow": "res://assets/shaders/look_d5_shadow.gdshader",
	"print": "res://assets/shaders/look_d5_print.gdshader",
	"halo": "res://assets/shaders/look_d5_halo.gdshader",
	"ui": "res://assets/shaders/look_d5_ui.gdshader",
}
## documented keys that are not uniforms (placement data for the caller)
const NOT_UNIFORMS: Array[String] = ["shadow.offset_m", "halo.shadow_m"]


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
	var grain_v: float = world.get("grain_floor", -1.0)
	assert_eq(grain_v, 0.0, "grain_floor stays off until the visual-engine lane adopts it")


func test_tier_zoom_stops_match_rig_detail_and_keep_the_car_camera_d4() -> void:
	var data: Dictionary = _params()
	var off_z: float = data.get("tier_off_zoom", -1.0)
	var on_z: float = data.get("tier_on_zoom", -1.0)
	var full_z: float = data.get("tier_full_zoom", -1.0)
	assert_eq(off_z, RigDetail.OFF_ZOOM, "params tier_off_zoom = RigDetail.OFF_ZOOM")
	assert_eq(on_z, RigDetail.ON_ZOOM, "params tier_on_zoom = RigDetail.ON_ZOOM")
	assert_eq(full_z, RigDetail.FULL_ZOOM, "params tier_full_zoom = RigDetail.FULL_ZOOM")
	assert_lt(off_z, on_z, "hysteresis band: off below on, against switch shimmer")
	assert_true(on_z <= full_z, "the fade completes at or after the switch")
	assert_gt(off_z, 1.5, "the 48 px/m car camera (zoom 1.5) never shows the D5 tier")
	assert_eq(smoothstep(on_z, full_z, on_z), 0.0, "the overlay is invisible at the switch")


func test_soul_shader_exposes_the_uniforms_the_hero_shot_relies_on() -> void:
	## look_d5_soul is not in the params proposal (teal belongs to the dead only; it is a
	## per-material print), so this is its only guard against a rename or a parse break.
	var names: Array[String] = _uniforms("res://assets/shaders/look_d5_soul.gdshader")
	for want: String in ["fade", "amount", "ink_at", "rim_sat"]:
		assert_has(names, want, "look_d5_soul keeps uniform " + want)
