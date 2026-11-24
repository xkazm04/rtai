extends GutTest

var table: GhostFormTable
var bond: GhostBond


func before_each() -> void:
	table = GhostFormTable.load_default()
	bond = GhostBond.new(table)


func test_only_effective_releases_earn_their_forms_bond() -> void:
	assert_true(bond.enabled)
	assert_eq(bond.master_at, 30.0)
	bond.record(&"kerf", 2, 1)
	bond.record(&"ohm", 0, 3)
	bond.record(&"kerf", 0, 0)
	bond.record(&"unknown", 30, 2)
	assert_eq(bond.snapshot(), {&"dent": 0.0, &"kerf": 11.0, &"ohm": 9.0, &"tonnage": 0.0})
	assert_eq(bond.last_deployed_mastered(), &"")
	assert_false(bond.master(&"unknown"))


func test_checkpoint_can_only_take_a_full_unmastered_bond() -> void:
	bond.record(&"kerf", 4, 4)
	assert_false(bond.ready(&"kerf"))
	assert_false(bond.master(&"kerf"))
	bond.record(&"kerf", 0, 1)
	assert_true(bond.ready(&"kerf"))
	assert_false(bond.mastered(&"kerf"))
	assert_true(bond.master(&"kerf"))
	assert_false(bond.ready(&"kerf"))
	assert_false(bond.master(&"kerf"))
	assert_false(bond.mastered(&"ohm"))
	bond.record(&"kerf", 5, 3)
	assert_eq(bond.value(&"kerf"), 30.0)
	var other_run: GhostBond = GhostBond.new(table)
	assert_eq(other_run.value(&"kerf"), 0.0)
	assert_false(other_run.mastered(&"kerf"))


func test_last_deploy_order_survives_reverse_mastery_order_and_misses() -> void:
	bond.record(&"ohm", 30, 0)
	bond.record(&"kerf", 30, 0)
	assert_true(bond.master(&"kerf"))
	assert_true(bond.master(&"ohm"))
	assert_eq(bond.last_deployed_mastered(), &"kerf")
	bond.record(&"ohm", 0, 0)
	bond.record(&"dent", 1, 0)
	assert_eq(bond.last_deployed_mastered(), &"ohm")


func test_disabled_bond_stays_empty_and_never_offers_mastery() -> void:
	table.bond_enabled = false
	bond = GhostBond.new(table)
	bond.record(&"ohm", 100, 100)
	assert_eq(bond.value(&"ohm"), 0.0)
	assert_false(bond.ready(&"ohm"))
	assert_false(bond.master(&"ohm"))
	assert_false(bond.mastered(&"ohm"))
	assert_eq(bond.last_deployed_mastered(), &"")


func test_boss_cuts_earn_per_boss_cut_and_the_cap_holds() -> void:
	assert_eq(table.per_boss_cut, 3.0)
	bond.record(&"kerf", 0, 0, 2)
	assert_eq(bond.value(&"kerf"), 6.0)
	bond.record(&"kerf", 1, 1, 1)
	assert_eq(bond.value(&"kerf"), 16.0)
	bond.record(&"kerf", 0, 0, 100)
	assert_eq(bond.value(&"kerf"), table.master_at)
	assert_true(bond.ready(&"kerf"))
