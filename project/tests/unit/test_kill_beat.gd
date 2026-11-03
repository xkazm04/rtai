extends GutTest
## The comic kill beat A/B (lane d5-combat): off by default, fires on rivet_kill, never past the
## shared flash budget, never flashing under reduced motion.


func _beat(mode: String) -> KillBeat:
	var b: KillBeat = KillBeat.new(mode)
	b.mode = mode
	add_child_autofree(b)
	return b


func test_off_fires_nothing() -> void:
	var t: FxTriggers = FxTriggers.new()
	var b: KillBeat = _beat("off")
	b.attach(t)
	t.fire(&"rivet_kill", Vector2(10, 10), 0.0, 1)
	b.step(1)
	assert_eq(b.beats, 0)


func test_a_rivet_kill_fires_one_beat_and_the_gap_holds_the_next() -> void:
	var t: FxTriggers = FxTriggers.new()
	var b: KillBeat = _beat("both")
	b.attach(t)
	t.fire(&"rivet_kill", Vector2(10, 10), 0.0, 1)
	b.step(1)
	assert_eq(b.beats, 1)
	assert_true(b.impact.active())
	t.fire(&"rivet_kill", Vector2(10, 10), 0.0, 2)
	b.step(2)
	assert_eq(b.beats, 1, "a second kill inside BEAT_GAP keeps its blood, gets no beat")


func test_the_budget_caps_flashes_per_second() -> void:
	var t: FxTriggers = FxTriggers.new()
	var b: KillBeat = _beat("flash")
	b.attach(t)
	var tick: int = 1
	for k: int in 5:
		t.fire(&"rivet_kill", Vector2.ZERO, 0.0, tick)
		b.step(tick)
		tick += ImpactFrame.BEAT_GAP
	assert_eq(b.beats, 5)
	assert_lte(b.impact.budget.used(), FlashBudget.MAX_FLASHES)


func test_reduced_motion_never_flashes() -> void:
	var t: FxTriggers = FxTriggers.new()
	var b: KillBeat = _beat("both")
	b.set_reduced_motion(true)
	b.attach(t)
	t.fire(&"rivet_kill", Vector2.ZERO, 0.0, 1)
	b.step(1)
	assert_eq(b.beats, 1)
	assert_eq(b.calm_beats, 1, "the calm beat: a thin border, no flash")
	assert_eq(b.impact.budget.used(), 0)
