extends GutTest
## n15 combat item 3 (the n13/n14 owner call): the body-hit ink burst every gun draws is smaller
## (0.12 m, was n7's 0.22 m) and still shrinks over its ticks; `--body-ink=n7` is the before.


func after_each() -> void:
	GunFxMarks._body_m = -1.0


func test_the_burst_starts_at_the_smaller_radius_and_shrinks() -> void:
	assert_almost_eq(GunFxMarks.body_radius(0), GunFxMarks.BODY_INK_M, 1e-6)
	assert_lt(GunFxMarks.BODY_INK_M, GunFxMarks.BODY_INK_N7_M)
	for age: int in range(1, GunFxMarks.BODY_TICKS):
		assert_lt(GunFxMarks.body_radius(age), GunFxMarks.body_radius(age - 1), "shrinks")
		assert_gt(GunFxMarks.body_radius(age), 0.0)


func test_the_n7_radius_keeps_its_old_curve() -> void:
	GunFxMarks._body_m = GunFxMarks.BODY_INK_N7_M
	for age: int in GunFxMarks.BODY_TICKS:
		assert_almost_eq(GunFxMarks.body_radius(age), 0.22 - 0.03 * float(age), 0.002)
