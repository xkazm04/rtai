extends GutTest
## rivet-motion: the claw combo's timing from rivet_melee.json: one landing tick per hit at the
## windup's end, buffered presses chain at the cancel point, the combo window continues the chain,
## a late press restarts it, and the finisher ends it. Planted fault: a zero combo window must
## break the late chain (the test proves it can fail).

var table: MeleeTable


func before_each() -> void:
	table = MeleeTable.shipped()


func test_table_loads() -> void:
	assert_true(table.ok(), str(table.errors))
	assert_eq(table.hits.size(), 3)
	assert_gt(table.hits[2].knockback_m, table.hits[0].knockback_m, "the finisher knocks back")


func test_mashing_lands_three_hits_on_schedule() -> void:
	var c: MeleeCombo = MeleeCombo.new(table)
	var landed: Array[int] = []
	for t: int in 120:
		if t % 3 == 0:
			c.press()
		if c.lands():
			landed.append(t)
		c.step()
	var h1: MeleeHit = table.hits[0]
	var h2: MeleeHit = table.hits[1]
	var c1: int = h1.windup + h1.active + table.cancel_ticks
	var c2: int = c1 + h2.windup + h2.active + table.cancel_ticks
	var want: Array[int] = [h1.windup, c1 + h2.windup, c2 + table.hits[2].windup]
	assert_eq(landed.slice(0, 3), want, "hits 1-3 land at windup ends, chained at the cancel")
	assert_gt(landed.size(), 3, "after the finisher, mashing starts a new chain")


func test_late_press_in_window_continues_and_after_restarts() -> void:
	assert_eq(_second_hit_after_gap(table.combo_window_ticks - 1), 2, "inside the window")
	assert_eq(_second_hit_after_gap(table.combo_window_ticks + 5), 1, "after it: restart")


func test_planted_fault_zero_window_breaks_the_chain() -> void:
	var gap: int = 6
	assert_eq(_second_hit_after_gap(gap), 2)
	table.combo_window_ticks = 0
	assert_eq(_second_hit_after_gap(gap), 1, "the fault is caught")


func test_finisher_ends_the_chain() -> void:
	var c: MeleeCombo = MeleeCombo.new(table)
	c.hit_index = 0
	c.last_index = table.hits.size()
	c.since_end = 0
	c.press()
	assert_eq(c.hit_index, 1, "after the finisher the next press is hit 1")


## Plays hit 1 to its end, waits `gap` idle ticks, presses again; returns the hit that starts.
func _second_hit_after_gap(gap: int) -> int:
	var c: MeleeCombo = MeleeCombo.new(table)
	c.press()
	while c.hit_index != 0:
		c.step()
	for _k: int in gap:
		c.step()
	c.press()
	return c.hit_index
