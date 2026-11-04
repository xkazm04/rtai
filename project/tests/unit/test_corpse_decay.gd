extends GutTest
## Corpse decay (features/combat/decay): a body lingers, then fades out over its fade (no pop),
## the oldest fade early past cap - room, the hard cap never lets more than cap be drawn, a
## standing-again dummy is forgotten, and the table loads with stains outliving bodies.
## Planted fault: a linger that never expires and no cap keeps every body (the cap check sees it).


func _ledger(
	linger_s: float = 1.0, fade_s: float = 0.5, cap: int = 4, room: int = 1
) -> DecayLedger:
	return DecayLedger.make(linger_s, fade_s, cap, room)


func test_a_body_lingers_then_fades_smoothly_then_is_released() -> void:
	var l: DecayLedger = _ledger()
	l.add(7, 0)
	var last: float = 1.0
	var released_at: int = -1
	for t: int in range(1, 200):
		l.step(t)
		if l.released.has(7):
			released_at = t
			break
		var a: float = l.alpha(7)
		assert_true(a <= last + 1e-6, "the fade never brightens")
		assert_true(last - a < 0.08, "no step larger than a smooth fade's (tick %d: %f)" % [t, a])
		if t < l.linger_ticks:
			assert_eq(a, 1.0, "solid while it lingers")
		last = a
	assert_eq(released_at, l.linger_ticks + l.fade_ticks, "released at linger + fade")
	assert_lt(last, 0.01, "faded out before release")
	assert_false(l.has(7))


func test_the_oldest_fade_early_past_cap_minus_room() -> void:
	var l: DecayLedger = _ledger(100.0, 0.5, 4, 1)
	for id: int in 4:
		l.add(id, 0)
	l.step(1)
	assert_eq(l.solid(), 3, "cap 4 - room 1 stay solid")
	assert_eq(l.early, 1, "the oldest started its fade early")
	for t: int in range(2, 40):
		l.step(t)
	assert_false(l.has(0), "the early fade ran out")
	assert_eq(l.forced, 0, "no pop")


func test_the_hard_cap_never_draws_more_than_cap() -> void:
	var l: DecayLedger = _ledger(100.0, 1.0, 4, 1)
	for id: int in 10:  # a mini-nuke: ten at once
		l.add(id, 0)
		l.step(id)
		assert_true(l.count() <= 4, "count %d" % l.count())
	assert_gt(l.forced, 0, "a burst past the cap releases the most faded")
	assert_eq(l.peak, 4)


func test_a_dummy_standing_again_is_forgotten() -> void:
	var l: DecayLedger = _ledger()
	l.add(3, 0)
	l.forget(3)
	assert_false(l.has(3))
	assert_eq(l.alpha(3), 1.0)
	assert_eq(l.total_released, 0)


func test_the_same_deaths_decay_on_the_same_ticks() -> void:
	var a: StreamPeerBuffer = _run()
	var b: StreamPeerBuffer = _run()
	assert_eq(a.data_array, b.data_array)


func test_the_shipped_table_loads_and_stains_outlive_bodies() -> void:
	var d: CorpseDecay = CorpseDecay.shipped()
	assert_true(d.problems.is_empty(), str(d.problems))
	assert_gt(d.bodies.linger_ticks, 0)
	var body_life: int = d.bodies.linger_ticks + d.bodies.fade_ticks
	assert_gt(d.stains.linger_ticks + d.stains.fade_ticks, body_life, "stains outlive bodies")
	assert_gt(d.stains.fade_ticks, d.bodies.fade_ticks, "and fade slower")
	assert_eq(d.sink_of(1), 1.0, "an unknown body is whole")


func test_planted_fault_a_linger_that_never_expires_overflows() -> void:
	var l: DecayLedger = _ledger(1.0e6, 1.0, 100000, 0)
	for id: int in 40:
		l.add(id, id)
		l.step(id)
	assert_gt(l.count(), 16, "the fault keeps every body: a cap check over count() catches it")


func _run() -> StreamPeerBuffer:
	var d: CorpseDecay = CorpseDecay.shipped()
	for t: int in 1200:
		if t % 13 == 0:
			d.add(t, t)
		d.step(t)
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	d.write_state(out)
	return out
