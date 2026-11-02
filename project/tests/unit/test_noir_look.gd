extends GutTest


func test_params_table_is_one_frame_table() -> void:
	var d: Dictionary = NoirLook.read_params(NoirLook.PARAMS)
	var schema: String = d.get("schema", "")
	assert_eq(schema, "gtai.look-noir-params/1")
	assert_true(d.get("frame", null) is Dictionary)


func test_every_param_is_a_shader_uniform() -> void:
	var d: Dictionary = NoirLook.read_params(NoirLook.PARAMS)
	var shader: Shader = load(NoirLook.SHADER) as Shader
	var names: Array[String] = []
	for u: Dictionary in shader.get_shader_uniform_list():
		var n: String = u["name"]
		names.append(n)
	var frame: Dictionary = d["frame"]
	for k: String in frame:
		assert_has(names, k, "look_noir.params.json frame.%s is not a uniform" % k)


func test_look_flag_is_known() -> void:
	assert_true(LaunchArgs.KNOWN_FLAGS.has("--look"))
	var look: NoirLook = NoirLook.new()
	assert_false(look.keep_d4, "the noir pass reads the raw art by default")
	look.free()
