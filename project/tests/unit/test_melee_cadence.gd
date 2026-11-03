extends GutTest
## rivet-motion: combo cadence, the brief's feel number (item 5), per melee table: mash at 20
## presses a second and read the tick each hit lands. The electro baton is the fast stun stick,
## so its whole chain lands before the claw's and the katana's; every chain lands its finisher
## within one second. Planted fault: a baton with no cancel point chains only after the full
## recovery, and the cadence check catches the slower finisher.

const MASH_EVERY: int = 3
const ONE_SECOND: int = 60


func test_every_chain_lands_its_finisher_within_a_second() -> void:
	for id: StringName in [&"", &"electro_baton", &"katana"]:
		var landed: Array[int] = _mash(_table(id))
		gut.p("cadence %s: landing ticks %s" % [id if id != &"" else &"claw", landed])
		assert_eq(landed.size(), 3, "%s lands three hits" % id)
		assert_lt(landed[2], ONE_SECOND, "%s finisher inside a second" % id)


func test_baton_chain_is_the_fastest() -> void:
	var baton: int = _mash(_table(&"electro_baton"))[2]
	assert_lt(baton, _mash(_table(&""))[2], "the baton beats the claw")
	assert_lt(baton, _mash(_table(&"katana"))[2], "the baton beats the katana")


func test_planted_fault_no_cancel_slows_the_finisher() -> void:
	var good: int = _mash(_table(&"electro_baton"))[2]
	var slow: MeleeTable = _table(&"electro_baton")
	slow.cancel_ticks = slow.hits[0].recovery
	var bad: Array[int] = _mash(slow)
	assert_eq(bad.size(), 3)
	assert_gt(bad[2], good, "without the cancel the finisher lands later; the check sees it")


func _table(id: StringName) -> MeleeTable:
	var t: MeleeTable = MeleeTable.shipped() if id == &"" else MeleeTable.weapon(id)
	assert_true(t.ok(), str(t.errors))
	return t


## The landing ticks of the first chain (the finisher ends it; later presses restart).
func _mash(table: MeleeTable) -> Array[int]:
	var c: MeleeCombo = MeleeCombo.new(table)
	var landed: Array[int] = []
	for t: int in 120:
		if t % MASH_EVERY == 0:
			c.press()
		if c.lands() and landed.size() < 3:
			landed.append(t)
		c.step()
	return landed
