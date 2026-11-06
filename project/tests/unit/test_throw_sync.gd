extends GutTest
## n7-ranged it18: the view sees a molotov wind-up `wound` ticks in (and draws one frame behind),
## so the throw clip draws only the wind-up left: the claw whips through on the sim's release tick.
## Planted fault: `--throw-sync=off` (RigThrow.sync false) draws the whole wind-up, 2 ticks late.

const WINDUP: int = 14


func after_each() -> void:
	RigThrow.sync = true


func test_the_whip_lands_on_the_release_tick() -> void:
	for wound: int in [1, 2, 3]:
		var sim_left: int = WINDUP - wound  # ticks until PlayerThrow releases the bottle
		var drawn: int = RigThrow.windup_left(WINDUP, wound) + 1  # + the frame drawn behind
		assert_eq(drawn, sim_left, "seen %d ticks in" % wound)


func test_a_wind_up_already_released_whips_at_once() -> void:
	assert_eq(RigThrow.windup_left(WINDUP, -1), 0)


func test_planted_fault_off_draws_the_whole_wind_up() -> void:
	RigThrow.sync = false
	var late: int = RigThrow.windup_left(WINDUP, 1) + 1 - (WINDUP - 1)
	assert_eq(late, 2, "off: the whip trails the bottle by 2 ticks (the before)")
