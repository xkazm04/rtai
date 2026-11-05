extends GutTest


func test_the_cane_plants_ahead_and_slides_back_a_stride() -> void:
	var plant: float = 1.0 - OhmRig.SWING_K
	assert_almost_eq(OhmRig.cane_tip(0.0).x, OhmRig.CANE_AHEAD_M, 0.0001, "planted ahead")
	var back: float = OhmRig.cane_tip(plant - 0.0001).x
	assert_almost_eq(OhmRig.CANE_AHEAD_M - back, OhmRig.STRIDE_M, 0.001, "left a stride behind")


func test_the_swing_closes_the_cycle_without_a_jump() -> void:
	var end: Vector2 = OhmRig.cane_tip(0.9999)
	assert_almost_eq(end.x, OhmRig.cane_tip(0.0).x, 0.001, "the swing lands where the cycle starts")
	var prev: float = OhmRig.cane_tip(0.0).x
	for i: int in range(1, 200):
		var x: float = OhmRig.cane_tip(float(i) / 200.0).x
		assert_lt(absf(x - prev), 0.06, "no jump at step %d" % i)
		prev = x


func test_the_gait_advances_with_ground_not_time() -> void:
	var rig: OhmRig = OhmRig.new()
	add_child_autofree(rig)
	rig.speed_mps = 0.0
	rig.advance(1.0)
	assert_eq(rig.phase, 0.0, "standing still: the cane stays planted")
	rig.speed_mps = OhmRig.STRIDE_M
	rig.advance(0.5)
	assert_almost_eq(rig.phase, 0.5, 0.0001, "half a stride of ground, half a cycle")
