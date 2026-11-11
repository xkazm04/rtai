extends GutTest
## n15 combat (DEFECTS c-2 #3): a round's body burst rides on its victim while the knock-back or
## a death's slide moves him (GunFxFollow), instead of staying on the floor where it stopped.


func _hit(fx: GunFx, at: Vector2, on: Fighter, tick: int = 100) -> Vector4:
	var im: Vector4 = Vector4(at.x, at.y, GunFx.Hit.BODY, tick)
	fx.impacts.append(im)
	@warning_ignore("return_value_discarded")
	fx.impact_dir.append(Vector2.RIGHT)
	if on != null:
		fx.follow.record(im, on)
	return im


func test_a_body_burst_moves_with_its_knocked_back_victim() -> void:
	var fx: GunFx = GunFx.new()
	var h: Fighter = Fighter.new()
	h.pos = Vector2(4.0, 2.0)
	var im: Vector4 = _hit(fx, Vector2(3.7, 2.0), h)
	h.pos += Vector2(0.5, 0.0)  # the knock-back
	assert_almost_eq(fx.follow.drawn_at(im).x, 4.2, 0.001, "the burst kept its place on him")
	assert_almost_eq(fx.follow.drawn_at(im).y, 2.0, 0.001)


func test_a_body_burst_rides_the_deaths_view_slide() -> void:
	var fx: GunFx = GunFx.new()
	var slide: Array[Vector2] = [Vector2.ZERO]
	fx.follow.body_off = func(_id: int) -> Vector2: return slide[0]
	var h: Fighter = Fighter.new()
	h.pos = Vector2(4.0, 2.0)
	var im: Vector4 = _hit(fx, Vector2(3.7, 2.0), h)
	slide[0] = Vector2(0.0, 0.5)  # the corpse is carried on the view only
	assert_almost_eq(fx.follow.drawn_at(im).y, 2.5, 0.001, "drawn on the carried body")


func test_a_ground_hit_stays_where_it_stopped() -> void:
	var fx: GunFx = GunFx.new()
	var im: Vector4 = _hit(fx, Vector2(1.0, 1.0), null)
	assert_eq(fx.follow.drawn_at(im), Vector2(1.0, 1.0))


func test_a_burst_past_its_life_is_forgotten() -> void:
	var fx: GunFx = GunFx.new()
	var h: Fighter = Fighter.new()
	var old: Vector4 = _hit(fx, Vector2.ZERO, h, 100)
	var new: Vector4 = _hit(fx, Vector2.ONE, h, 100 + GunFx.IMPACT_TICKS + 1)
	assert_false(fx.follow.has(old), "no victim held past the burst")
	assert_true(fx.follow.has(new))


func test_no_rigs_no_slide() -> void:
	assert_eq(RigCarry.metres(7, null), Vector2.ZERO)
	var hook: Callable = RigCarry.hook(null)
	var off: Vector2 = hook.call(7)
	assert_eq(off, Vector2.ZERO, "the hook ArenaRigs wires")


func test_a_body_hit_marks_his_front_not_the_rounds_closest_point() -> void:
	# the round's last step passed 0.6 m short of his centre (within radius + 0.3: a hit)
	var h: Fighter = Fighter.new()
	h.pos = Vector2(4.0, 2.0)
	var at: Vector2 = GunFxFollow.on_body(Vector2(3.4, 2.0), h, Vector2(0.5, 0.0))
	assert_almost_eq(at.x, 4.0 - GunFxFollow.FRONT_M, 0.001, "on his front, toward the shooter")
	assert_almost_eq(at.y, 2.0, 0.001)
