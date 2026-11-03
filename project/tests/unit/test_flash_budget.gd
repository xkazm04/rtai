extends GutTest
## FlashBudget (lane noir): the kill beat and the muzzle light share one photosensitivity budget.


func test_the_budget_allows_two_flashes_a_second() -> void:
	var b: FlashBudget = FlashBudget.new()
	var spent: int = 0
	for t: int in 120:
		spent += 1 if b.spend(FlashBudget.LIGHT_COST) else 0
		b.step_ticks(1)
	assert_eq(spent, 2 * FlashBudget.MAX_FLASHES, "2 s of rounds every tick light 4 frames")


func test_a_kill_beat_and_rounds_never_pass_the_budget_together() -> void:
	var f: ImpactFrame = ImpactFrame.new()
	var m: MuzzleFlash = MuzzleFlash.new()
	m.budget = f.budget
	var lit: int = 0
	f.fire(Vector2(0.5, 0.5))
	assert_false(f.calm(), "the first beat flashes")
	for t: int in 59:
		m.fire(Vector2(t, 0), Vector2.RIGHT)
		lit += 1 if m.lit() else 0
		m.step_ticks(1)
		f.step_ticks(1)
	assert_eq(lit, 0, "no muzzle light inside 1 s of a full beat")
	f.free()
	m.free()


func test_flashes_off_gives_the_calm_beat_and_no_light() -> void:
	var f: ImpactFrame = ImpactFrame.new()
	f.budget.enabled = false
	var m: MuzzleFlash = MuzzleFlash.new()
	m.budget = f.budget
	f.fire(Vector2(0.5, 0.5))
	assert_true(f.calm(), "flashes off: the calm beat")
	assert_true(f.active(), "the calm beat still holds the panel")
	m.fire(Vector2.ZERO, Vector2.RIGHT)
	assert_false(m.lit(), "flashes off: the muzzle does not light the scene")
	f.free()
	m.free()


func test_the_params_ship_with_flashes_on() -> void:
	var d: Dictionary = NoirLook.read_params(NoirLook.PARAMS)
	assert_true(FlashBudget.from_params(d).enabled)
	assert_false(FlashBudget.from_params({"safety": {"flashes": false}}).enabled)
