extends GutTest
## n12 E2: a round's ground scuff that leaves GunFx is kept in a bounded ring; the oldest fade out
## first; nothing is kept with the table off.


func _ring(cap: int, fade_n: int) -> BattleResidue:
	var r: BattleResidue = BattleResidue.new()
	r.on = true
	r.cap = cap
	r.fade_n = fade_n
	r.alpha = 0.6
	return autofree(r)


func test_the_table_ships_it_bounded() -> void:
	var r: BattleResidue = autofree(BattleResidue.new())
	assert_true(r.on)
	assert_gt(r.cap, 0)
	assert_between(r.alpha, 0.01, 1.0)


func test_a_scuff_that_leaves_gun_fx_is_kept() -> void:
	var r: BattleResidue = _ring(8, 2)
	var fx: GunFx = GunFx.new()
	@warning_ignore("return_value_discarded")
	fx.impacts.append(Vector4(3.0, 4.0, GunFx.Hit.GROUND, 100))
	@warning_ignore("return_value_discarded")
	fx.impact_dir.append(Vector2.RIGHT)
	@warning_ignore("return_value_discarded")
	fx.impacts.append(Vector4(5.0, 4.0, GunFx.Hit.BODY, 100))  # a body hit leaves no scuff
	@warning_ignore("return_value_discarded")
	fx.impact_dir.append(Vector2.RIGHT)
	r.sync(fx)
	assert_eq(r.size(), 0, "still fresh in GunFx: nothing kept yet")
	fx.impacts.clear()
	fx.impact_dir.clear()
	r.sync(fx)
	assert_eq(r.size(), 1, "the ground scuff, not the body hit")


func test_the_ring_holds_its_cap_and_the_oldest_fade_first() -> void:
	var r: BattleResidue = _ring(4, 2)
	for i: int in 3:
		r.keep(Vector2(i, 0), Vector2.RIGHT, i)
	assert_eq(r.ink_of(0), 0.6, "room left: full ink")
	for i: int in 5:
		r.keep(Vector2(10 + i, 0), Vector2.RIGHT, 10 + i)
	assert_eq(r.size(), 4, "the hard cap")
	assert_lt(r.ink_of(0), r.ink_of(3), "the oldest fades")
	assert_almost_eq(r.ink_of(3), 0.6, 0.001)


func test_off_keeps_nothing() -> void:
	var r: BattleResidue = _ring(4, 2)
	r.on = false
	var fx: GunFx = GunFx.new()
	@warning_ignore("return_value_discarded")
	fx.impacts.append(Vector4(3.0, 4.0, GunFx.Hit.GROUND, 1))
	@warning_ignore("return_value_discarded")
	fx.impact_dir.append(Vector2.RIGHT)
	r.sync(fx)
	fx.impacts.clear()
	fx.impact_dir.clear()
	r.sync(fx)
	assert_eq(r.size(), 0)


func test_each_kept_scuff_draws_a_stroke_and_four_dots_fading_with_age() -> void:
	var r: BattleResidue = _ring(4, 2)
	for i: int in 4:
		r.keep(Vector2(i, 0), Vector2.RIGHT, 7 + i)
	var g: Array = r.geometry()
	var strokes: PackedVector2Array = g[0]
	var small: PackedVector2Array = g[2]
	var large: PackedVector2Array = g[4]
	assert_eq(strokes.size(), 8, "one stroke (two points) per scuff")
	assert_eq(small.size() + large.size(), 32, "four dots per scuff")
	var cols: PackedColorArray = g[1]
	assert_eq(cols.size(), 4)
	assert_lt(cols[0].a, cols[3].a, "the oldest is the faintest")
	assert_almost_eq(cols[3].a, GunFxMarks.SCUFF.a * 0.6, 0.001)
	var at: Vector2 = Ink.px(Vector2(3, 0))
	assert_lt(strokes[6].distance_to(at), Ink.px(Vector2(0.3, 0)).x + 1.0, "drawn where it fell")
	assert_eq(r.geometry(), g, "the same ring draws the same marks")
