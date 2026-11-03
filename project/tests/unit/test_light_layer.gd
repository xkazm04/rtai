extends GutTest
## The 2D light model (core/render/light_layer.gd): the table loads, lights live on sim ticks,
## the per-frame budget evicts the oldest timed light and refuses held lights when full.


func test_the_table_loads_every_kind_and_both_grades() -> void:
	var lights: LightLayer = autofree(LightLayer.new())
	for k: StringName in [&"muzzle_flash", &"explosion", &"headlight", &"siren", &"fire"]:
		assert_true(lights.kinds.has(k), String(k))
	assert_true(LightLayer.is_identity(lights.grades[&"day"]), "day leaves the print untouched")
	assert_false(LightLayer.is_identity(lights.grades[&"night"]))
	assert_eq(lights.layer, RenderLayers.canvas(&"light"))


func test_day_hides_the_grade_and_night_shows_it() -> void:
	var lights: LightLayer = autofree(LightLayer.new())
	var rect: ColorRect = _grade_rect(lights)
	assert_false(rect.visible, "day by default: no screen read")
	lights.set_grade(&"night")
	assert_true(rect.visible)
	var mat: ShaderMaterial = rect.material
	var level: float = lights.grades[&"night"]["paper_level"]
	var set_level: float = mat.get_shader_parameter(&"paper_level")
	assert_almost_eq(set_level, level, 1e-6)
	lights.set_grade(&"dusk_that_does_not_exist")
	assert_eq(lights.grade, &"day")
	assert_false(rect.visible)


func test_night_darkens_the_paper_and_hardens_the_street_contrast() -> void:
	var lights: LightLayer = autofree(LightLayer.new())
	var night: Dictionary = lights.grades[&"night"]
	var level: float = night["paper_level"]
	var g: float = night["gamma"]
	var pal: PaletteTokens = PaletteTokens.shared()
	var paper: float = pal.color(&"paper").get_luminance()
	var street: float = pal.color(&"ink_2").get_luminance()
	var paper_n: float = level * pow(paper, g)
	var street_n: float = level * pow(street, g)
	assert_lt(paper_n, paper, "night darkens the paper")
	assert_gt(paper_n / street_n, paper / street, "and hardens the paper / street contrast")


func test_a_timed_light_fades_out_on_the_tick() -> void:
	var lights: LightLayer = autofree(LightLayer.new())
	var life: int = lights.kinds[&"muzzle_flash"]["life_ticks"]
	assert_gte(lights.add(&"muzzle_flash", Vector2.ZERO, 0.0, 100), 0)
	lights.step(100, Vector2.ZERO)
	assert_eq(lights.active, 1)
	lights.step(100 + life, Vector2.ZERO)
	assert_eq(lights.active, 0)


func test_the_budget_evicts_timed_and_refuses_held_lights() -> void:
	var lights: LightLayer = autofree(LightLayer.new())
	for i: int in lights.max_lights:
		assert_gte(lights.add(&"fire", Vector2(i, 0), 0.0, 0), 0)
	assert_eq(lights.add(&"headlight", Vector2.ZERO, 0.0, 0), -1)
	assert_eq(lights.add(&"explosion", Vector2.ZERO, 0.0, 0), -1, "no timed light to evict")
	assert_eq(lights.dropped, 2)
	lights.remove(0)
	assert_gte(lights.add(&"muzzle_flash", Vector2.ZERO, 0.0, 1), 0)
	var flash: int = lights.add(&"muzzle_flash", Vector2.ZERO, 0.0, 2)
	assert_eq(flash, 0, "the second flash evicts the first (the oldest timed light)")


func test_an_unknown_kind_is_refused() -> void:
	var lights: LightLayer = autofree(LightLayer.new())
	assert_eq(lights.add(&"laser", Vector2.ZERO, 0.0, 0), -1)


func test_a_light_added_inside_the_same_tick_still_draws() -> void:
	var l: LightLayer = autofree(LightLayer.new())
	var kind: StringName = l.kinds.keys()[0]
	l.step(3, Vector2.ZERO)
	assert_eq(l.active, 0)
	assert_gte(l.add(kind, Vector2.ZERO, 0.0, 3), 0)
	l.step(3, Vector2.ZERO)
	assert_eq(l.active, 1, "added inside tick 3: rewritten anyway")


func _grade_rect(lights: LightLayer) -> ColorRect:
	for c: Node in lights.get_children():
		if c is ColorRect:
			return c
	return null


func test_no_light_flashes_more_than_three_times_a_second() -> void:
	var lights: LightLayer = autofree(LightLayer.new())
	for k: StringName in lights.kinds:
		var hz: float = lights.kinds[k]["flicker_hz"]
		assert_lte(hz, LightLayer.MAX_FLASH_HZ, String(k))
	var row: Dictionary = {"id": "strobe", "token": "vermilion", "alt_token": "paper"}
	row["flicker_hz"] = 7.0
	lights._load(JSON.stringify({"kinds": [row], "max_flash_hz": 3}))
	var clamped: float = lights.kinds[&"strobe"]["flicker_hz"]
	assert_eq(clamped, 3.0)
