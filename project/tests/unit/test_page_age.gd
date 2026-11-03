extends GutTest
## The page age (look_overlay.gd page_age -> light_layer.gd set_page_age -> grade_ink.gdshader):
## the D5 overlay's aged paper is taken out of the world-only overlay and graded over the whole
## page, so the actors, vehicles and FX age with the world (a D4-cream body read cool-grey on the
## D5-warmed paper at 64 px/m in the 4-lane trial merge).

const PARAMS: String = "user://test_page_age_params.json"


func _row() -> Dictionary:
	return {
		"amount_ppm": [[48, 0], [64, 1]],
		"base": "d4",
		"doc": "t",
		"full_looks": ["d5"],
		"id": "t_overlay",
		"params": PARAMS,
		"params_key": "world",
		"shader": "res://assets/shaders/look_d4.gdshader",
		"zoom_looks": ["auto"],
	}


func _write(world: Dictionary) -> void:
	var f: FileAccess = FileAccess.open(PARAMS, FileAccess.WRITE)
	assert_true(f.store_string(JSON.stringify({"world": world})))
	f.close()


func _overlay_mat(o: LookOverlay) -> ShaderMaterial:
	for c: Node in o.get_children():
		if c is ColorRect:
			return (c as ColorRect).material
	return null


func _grade_rect(lights: LightLayer) -> ColorRect:
	for c: Node in lights.get_children():
		if c is ColorRect:
			return c
	return null


func test_the_age_moves_from_the_overlay_to_the_page() -> void:
	_write({"age": 1.0, "age_floor": 0.0, "hatch": 0.3})
	var o: LookOverlay = autofree(LookOverlay.create(_row()))
	var mat: ShaderMaterial = _overlay_mat(o)
	var printed: float = mat.get_shader_parameter(&"age")
	assert_eq(printed, 0.0, "the world-only layer never ages: the page does")
	var hatch: float = mat.get_shader_parameter(&"hatch")
	assert_almost_eq(hatch, 0.3, 1e-6, "the other params still reach the overlay")
	o.update(&"auto", 32.0, Vector2.ZERO)
	assert_eq(o.page_age(), 0.0, "pure D4 at gameplay zoom")
	o.update(&"auto", 56.0, Vector2.ZERO)
	assert_almost_eq(o.page_age(), 0.5, 1e-4)
	o.update(&"auto", 64.0, Vector2.ZERO)
	assert_almost_eq(o.page_age(), 1.0, 1e-4)
	o.update(&"d4", 64.0, Vector2.ZERO)
	assert_eq(o.page_age(), 0.0, "a look without the overlay")
	o.update(&"d5", 32.0, Vector2.ZERO)
	assert_almost_eq(o.page_age(), 1.0, 1e-4, "pinned d5")


func test_an_age_floor_holds_below_the_ramp_but_not_off_the_look() -> void:
	_write({"age": 1.0, "age_floor": 0.25})
	var o: LookOverlay = autofree(LookOverlay.create(_row()))
	o.update(&"auto", 32.0, Vector2.ZERO)
	assert_almost_eq(o.page_age(), 0.25, 1e-4)
	o.update(LookProfiles.OFF, 32.0, Vector2.ZERO)
	assert_eq(o.page_age(), 0.0)
	o.update(&"d1", 64.0, Vector2.ZERO)
	assert_eq(o.page_age(), 0.0)
	var a: Array[LookOverlay] = [o]
	o.update(&"auto", 56.0, Vector2.ZERO)
	assert_almost_eq(LookOverlay.page_age_of(a), 0.5, 1e-4)
	var none: Array[LookOverlay] = []
	assert_eq(LookOverlay.page_age_of(none), 0.0, "no overlay (branch without look_d5): no age")


func test_the_grade_rect_draws_for_an_age_and_hides_without_one() -> void:
	var lights: LightLayer = autofree(LightLayer.new())
	var rect: ColorRect = _grade_rect(lights)
	var mat: ShaderMaterial = rect.material
	lights.set_page_age(0.6)
	assert_true(rect.visible, "day + an aged page: the rect draws")
	var got: float = mat.get_shader_parameter(&"age")
	assert_almost_eq(got, 0.6, 1e-6)
	lights.set_page_age(0.001)
	assert_false(rect.visible, "below AGE_EPS = no age, zero cost")
	assert_eq(lights.page_age, 0.0)
	lights.set_grade(&"night")
	lights.set_page_age(0.0)
	assert_true(rect.visible, "night still grades without an age")
	lights.set_grade(&"day")
	assert_false(rect.visible)


func test_the_grade_shader_declares_the_age() -> void:
	var sh: Shader = load(LightLayer.GRADE_SHADER)
	var names: Array[String] = []
	for u: Dictionary in sh.get_shader_uniform_list():
		var n: String = u["name"]
		names.append(n)
	for n: String in ["age", "age_dark", "age_light"]:
		assert_true(names.has(n), n)
