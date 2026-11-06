extends GutTest
## d8-weapons: under a tilt a floor pickup hovers over its disc; the hover stays in its band and
## two neighbouring pickups bob out of step. Straight down the view lifts nothing (flat path).


func test_the_hover_stays_in_its_band() -> void:
	for f: int in 240:
		var h: float = PickupsView.hover_m(float(f) * SimClock.TICK_DT, 0)
		assert_between(
			h,
			PickupsView.HOVER_M - PickupsView.BOB_M - 0.0001,
			PickupsView.HOVER_M + PickupsView.BOB_M + 0.0001
		)


func test_neighbours_bob_out_of_step() -> void:
	assert_ne(PickupsView.hover_m(0.0, 0), PickupsView.hover_m(0.0, 1), "item phase differs")


func test_the_default_view_keeps_pickups_flat() -> void:
	assert_eq(ShotLift.up_m(), Vector2.ZERO, "top: no hover, no stand-up, no shadow")
