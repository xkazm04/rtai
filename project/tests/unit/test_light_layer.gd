extends GutTest
## The 2D light model (core/render/light_layer.gd): the table loads, lights live on sim ticks,
## the per-frame budget evicts the oldest timed light and refuses held lights when full.


func test_the_table_loads_every_kind_and_both_grades() -> void:
	var lights: LightLayer = autofree(LightLayer.new())
	for k: StringName in [&"muzzle_flash", &"explosion", &"headlight", &"siren", &"fire"]:
		assert_true(lights.kinds.has(k), String(k))
	assert_eq(lights.grades[&"day"], Color.WHITE)
	assert_true(lights.grades[&"night"].get_luminance() < 0.5)
	assert_eq(lights.layer, RenderLayers.canvas(&"light"))


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
