extends GutTest
## The building_shadows band as data (core/render/cast_shadows.gd, cast_shadows.json): a shader
## that loads (n-d5's look_d5_shadow when present, else the placeholder), the table's uniforms on
## it, and the per-class cast distance the view adds to the baked offset.

var _casts: CastShadows


func before_all() -> void:
	_casts = CastShadows.load_table()


func test_a_shader_that_exists_is_picked() -> void:
	assert_true(ResourceLoader.exists(_casts.shader_path), _casts.shader_path)
	var mat: ShaderMaterial = _casts.material()
	assert_not_null(mat)
	var period: float = mat.get_shader_parameter(&"period")
	assert_almost_eq(period, 5.0, 0.0001)


func test_buildings_cast_further_than_props() -> void:
	var classes: Array[String] = ["ground", "building", "prop"]
	var px: PackedVector2Array = _casts.extra_px(classes, 32.0)
	assert_eq(px[0], Vector2.ZERO)
	assert_almost_eq(px[1].x, (1.1 - 0.25) * 32.0, 0.001)
	assert_eq(px[1].x, px[1].y)
	assert_eq(px[2], Vector2.ZERO)


func test_both_shadow_shaders_declare_the_table_uniforms() -> void:
	var sh: Shader = load("res://assets/shaders/cast_shadow.gdshader")
	var names: Array[String] = []
	for u: Dictionary in sh.get_shader_uniform_list():
		names.append(str(u["name"]))
	for k: String in _casts.uniforms:
		assert_has(names, k)


func test_a_named_prop_casts_its_hero_scene_length() -> void:
	# D5HeroPropShadow LENGTH_M adopted (2026-11-03): dumpster 0.45 m total, the class bakes 0.18 m
	var classes: Array[String] = ["prop", "prop", "vehicle"]
	var names: Array[String] = ["dumpster", "lamp_post", "sedan"]
	var px: PackedVector2Array = _casts.extra_px(classes, 32.0, names)
	assert_almost_eq(px[0].x, (0.45 - 0.18) * 32.0, 0.001)
	assert_eq(px[1], Vector2.ZERO, "an unnamed prop keeps its class length")
	assert_almost_eq(px[2].x, (0.4 - 0.18) * 32.0, 0.001)
