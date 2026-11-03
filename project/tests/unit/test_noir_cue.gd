extends GutTest
## Lane noir: the objective cue (NoirCue) rings only when asked, where asked, and pulses on the
## caller's tick (the same 30-tick period as the D4 ring it covers).


func test_cue_shows_where_and_when_asked() -> void:
	var cue: NoirCue = NoirCue.new()
	add_child_autofree(cue)
	cue.visible = false
	cue.show_ring(Vector2(48, 96), 7)
	assert_true(cue.visible, "show_ring shows the cue")
	assert_eq(cue.ring_at(), Vector2(48, 96))


func test_pulse_follows_the_callers_tick() -> void:
	var cue: NoirCue = NoirCue.new()
	add_child_autofree(cue)
	cue.show_ring(Vector2.ZERO, 0)
	var r0: float = cue.radius(0)
	cue.show_ring(Vector2.ZERO, NoirCue.PULSE_TICKS)
	assert_almost_eq(cue.radius(0), r0, 0.001, "one full period later the ring is back")
	cue.show_ring(Vector2.ZERO, NoirCue.PULSE_TICKS / 2)
	assert_gt(cue.radius(0), r0, "mid-pulse the ring has grown outward")
