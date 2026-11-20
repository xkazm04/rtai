extends GutTest

const PPM: float = 32.0


func test_sparks_clear_the_whole_victim_for_the_life_of_each_hanging_slot() -> void:
	var k: KerfStage = KerfStage.shipped()
	var slot: KerfSlot = KerfSlot.new()
	for tick: int in range(6):
		var from: Vector2 = Vector2(3, 5) * tick
		var dir: Vector2 = Vector2.RIGHT.rotated(tick)
		var radius: float = 0.45 + 0.2 * tick
		k._remember(tick, from, from + dir * 7, from + dir * 5, radius)
	assert_eq(k.trail_radius.size(), KerfStage.KEEP)
	for i: int in k.trail_tick.size():
		var cut: Vector2 = k.trail_cut[i] * PPM
		var radius: float = 0.45 + 0.2 * k.trail_tick[i]
		var life: int = ceili(k.num(&"cut_hang_s") / SimClock.TICK_DT)
		for age: int in life:
			slot.place(k, i, age, PPM)
			if age == 0:
				assert_gte(slot.motes.size(), 2)
			for at: Vector2 in slot.motes:
				assert_gt(at.distance_to(cut) - slot.mote_radius, (radius + 0.3) * PPM)
		slot.place(k, i, life, PPM)
		assert_true(slot.motes.is_empty())


func test_the_press_tick_seeds_the_motes_and_reduced_motion_clears_them() -> void:
	var k: KerfStage = KerfStage.shipped()
	var slot: KerfSlot = KerfSlot.new()
	k._remember(51, Vector2.ZERO, Vector2.RIGHT * 6, Vector2.INF, 0.0)
	slot.place(k, 0, 0, PPM)
	var press: PackedVector2Array = slot.motes.duplicate()
	assert_eq(press.size(), KerfSlot.SPARKS)
	slot.place(k, 0, 1, PPM)
	assert_ne(slot.motes, press)
	assert_lt(slot.motes[-1].distance_to(press[-1]), 0.01 * PPM)
	slot.place(k, 0, 0, PPM)
	assert_eq(slot.motes, press)
	k._remember(52, Vector2.ZERO, Vector2.RIGHT * 6, Vector2.INF, 0.0)
	slot.place(k, 1, 0, PPM)
	assert_ne(slot.motes, press)
	slot.place(k, 1, 0, PPM, true)
	assert_true(slot.motes.is_empty())
