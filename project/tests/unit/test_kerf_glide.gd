extends GutTest
## n7-melee KerfGlide (view only): after a blink the camera starts where Kerf stood and eases to
## where he landed over cam_glide_s, a chain carries on without a jump, a short hop and an old blink
## leave none.


func _kerf() -> KerfStage:
	return KerfStage.shipped()


func _blink(k: KerfStage, from: Vector2, to: Vector2, tick: int) -> void:
	@warning_ignore("return_value_discarded")
	k.trail_from.append(from)
	@warning_ignore("return_value_discarded")
	k.trail_to.append(to)
	@warning_ignore("return_value_discarded")
	k.trail_cut.append(Vector2.INF)
	@warning_ignore("return_value_discarded")
	k.trail_tick.append(tick)


func _span(k: KerfStage) -> int:
	return roundi(k.num(&"cam_glide_s") / SimClock.TICK_DT)


func test_the_camera_starts_where_kerf_stood_and_eases_to_him() -> void:
	var k: KerfStage = _kerf()
	assert_gt(_span(k), 4, "the shipped glide is several ticks")
	_blink(k, Vector2(10.0, 0.0), Vector2(16.0, 0.0), 100)
	assert_eq(
		KerfGlide.offset_m(k, 100), Vector2(-6.0, 0.0), "on the blink tick: still on the start"
	)
	var mid: Vector2 = KerfGlide.offset_m(k, 100 + _span(k) / 3)
	assert_between(mid.x, -2.5, -1.0, "a third in: most of the way there (ease-out)")
	assert_eq(KerfGlide.offset_m(k, 100 + _span(k)), Vector2.ZERO, "done: on Rivet")
	assert_eq(KerfGlide.offset_m(k, 99), Vector2.ZERO, "before the blink: nothing")


func test_a_chain_carries_on_without_a_jump() -> void:
	var k: KerfStage = _kerf()
	_blink(k, Vector2(0.0, 0.0), Vector2(6.0, 0.0), 100)
	var t2: int = 100 + _span(k) / 2
	var cam_before: Vector2 = Vector2(6.0, 0.0) + KerfGlide.offset_m(k, t2)
	_blink(k, Vector2(6.0, 0.0), Vector2(6.0, 7.0), t2)
	var cam_at: Vector2 = Vector2(6.0, 7.0) + KerfGlide.offset_m(k, t2)
	assert_lt(cam_at.distance_to(cam_before), 0.01, "the second blink does not snap the camera")


func test_a_short_hop_leaves_no_glide() -> void:
	var k: KerfStage = _kerf()
	_blink(k, Vector2(0.0, 0.0), Vector2(0.5, 0.0), 100)
	assert_eq(KerfGlide.offset_m(k, 101), Vector2.ZERO)
	assert_eq(KerfGlide.offset_m(null, 101), Vector2.ZERO, "no Kerf: no offset")
