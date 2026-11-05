extends GutTest
## n5-look: the flamethrower's loose embers (WeaponFxEmber, data/tables/flame_embers.json).


func test_rules_load_from_the_table() -> void:
	var r: WeaponFxEmber = WeaponFxEmber.rules()
	assert_gt(r.count, 0)
	assert_lt(r.size_px.x, r.size_px.y)
	assert_gt(r.width_px, 0.0)
	assert_between(r.blink, 0.0, 1.0)


func test_ember_colours_are_never_blood_red_or_teal() -> void:
	var r: WeaponFxEmber = WeaponFxEmber.rules()
	for c: Color in [r.hot, r.rim]:
		assert_gt(c.g, 0.35, "an ember is hot orange-yellow, not blood red: %s" % c.to_html())
		assert_gt(c.r, c.b, "an ember is warm, never teal: %s" % c.to_html())
