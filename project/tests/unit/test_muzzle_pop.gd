extends GutTest
## MuzzlePop (lane d5-combat): a round lights the scene for one tick, inside the flash budget.


func _pop() -> MuzzlePop:
	var p: MuzzlePop = MuzzlePop.new({"radius_m": 5.0, "strength": 0.3, "lit_gap_ticks": 20})
	add_child_autofree(p)
	return p


func test_a_shot_lights_exactly_one_tick() -> void:
	var t: FxTriggers = FxTriggers.new()
	var p: MuzzlePop = _pop()
	p.attach(t)
	p.step(0)
	t.fire(&"shot", Vector2(64, 32), 0.0, 1)
	p.step(1)
	assert_true(p.lit(), "the shot's tick is lit")
	assert_eq(p.position, Vector2(64, 32))
	p.step(1)
	assert_true(p.lit(), "a second frame inside the same tick stays lit")
	p.step(2)
	assert_false(p.lit(), "the next tick is dark")


func test_a_burst_of_rounds_pops_at_most_once_per_gap_and_budget() -> void:
	var t: FxTriggers = FxTriggers.new()
	var p: MuzzlePop = _pop()
	var budget: FlashBudget = FlashBudget.new()
	p.budget = budget
	p.attach(t)
	var lit: int = 0
	for tick: int in 120:
		t.fire(&"shot", Vector2(tick, 0), 0.0, tick)
		p.step(tick)
		budget.step_ticks(1)
		lit += 1 if p.lit() else 0
	assert_eq(
		lit, 2, "2 s of a round every tick: 1 lit tick a second (the budget keeps a beat free)"
	)
	assert_eq(p.pops, 2)


func test_reduced_motion_never_pops() -> void:
	var t: FxTriggers = FxTriggers.new()
	var p: MuzzlePop = _pop()
	p.budget = FlashBudget.new()
	p.budget.enabled = false
	p.attach(t)
	t.fire(&"shot", Vector2.ZERO, 0.0, 1)
	p.step(1)
	assert_false(p.lit())
	assert_eq(p.held, 1)
