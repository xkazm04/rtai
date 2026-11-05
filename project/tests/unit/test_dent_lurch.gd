extends GutTest
## ghost-forms: Dent's stagger (DentLurch): still = a small idle sway only, walking = the roll and
## the yaw at full size once per STRIDE_M, the limp makes the stride's two halves uneven.


func _walk(l: DentLurch, mps: float, ticks: int) -> void:
	for i: int in ticks:
		l.step(mps, SimClock.TICK_DT)


func test_standing_still_only_idles() -> void:
	var l: DentLurch = DentLurch.new()
	var most: float = 0.0
	for i: int in 240:
		l.step(0.0, SimClock.TICK_DT)
		most = maxf(most, absf(l.yaw()))
		assert_eq(l.sway_m(), 0.0, "no roll standing still")
	assert_gt(most, 0.0, "a slow idle sway")
	assert_lte(most, DentLurch.IDLE_YAW + 0.0001, "the idle sway stays small")


func test_walking_rolls_and_yaws_at_full_size() -> void:
	var l: DentLurch = DentLurch.new()
	_walk(l, 6.0, 60)
	assert_almost_eq(l.amount, 1.0, 0.001, "full lurch at a walk")
	var most_sway: float = 0.0
	var most_yaw: float = 0.0
	for i: int in 120:
		l.step(6.0, SimClock.TICK_DT)
		most_sway = maxf(most_sway, absf(l.sway_m()))
		most_yaw = maxf(most_yaw, absf(l.yaw()))
	assert_gt(most_sway, DentLurch.SWAY_M * 0.9, "the roll reaches its size")
	assert_gt(most_yaw, DentLurch.YAW * 0.9, "the yaw reaches its size")


func test_the_limp_makes_the_halves_uneven() -> void:
	var l: DentLurch = DentLurch.new()
	_walk(l, 6.0, 60)
	l.phase = 0.0
	var right: int = 0
	var ticks: int = roundi(DentLurch.STRIDE_M / 6.0 / SimClock.TICK_DT)
	for i: int in ticks:
		l.step(6.0, SimClock.TICK_DT)
		right += 1 if l.sway_m() > 0.0 else 0
	assert_ne(right, ticks / 2, "one half of the stride is shorter than the other")
