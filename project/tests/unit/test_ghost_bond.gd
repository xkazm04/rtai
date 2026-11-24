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
	assert_eq(table.per_boss_cut, 5.0)
	bond.record(&"kerf", 0, 0, 2)
	assert_eq(bond.value(&"kerf"), 10.0)
	bond.record(&"kerf", 1, 1, 1)
	assert_eq(bond.value(&"kerf"), 22.0)
	bond.record(&"kerf", 0, 0, 100)
	assert_eq(bond.value(&"kerf"), table.master_at)
	assert_true(bond.ready(&"kerf"))


func test_the_only_deployed_ghost_is_found_by_last_deployed_mastered() -> void:
	bond.record(&"ohm", 30, 0)
	assert_true(bond.master(&"ohm"))
	assert_eq(bond.last_deployed_mastered(), &"ohm")


func test_tonnage_has_a_bar_of_his_own_and_the_others_keep_thirty() -> void:
	table.master_at_by_form[&"tonnage"] = 55.0
	bond = GhostBond.new(table)
	assert_eq(bond.master_at_for(&"tonnage"), 55.0)
	for id: StringName in [&"dent", &"kerf", &"ohm"]:
		assert_eq(bond.master_at_for(id), 30.0)
	assert_eq(bond.master_at_for(&"unknown"), 30.0)


func test_tonnage_caps_and_masters_at_his_bar_not_thirty() -> void:
	var own: float = 44.0
	table.master_at_by_form[&"tonnage"] = own
	bond = GhostBond.new(table)
	bond.record(&"tonnage", 8, 0)
	assert_eq(bond.value(&"tonnage"), 32.0)
	assert_false(bond.ready(&"tonnage"))
	assert_false(bond.master(&"tonnage"))
	bond.record(&"tonnage", 3, 0)
	assert_eq(bond.value(&"tonnage"), own)
	assert_true(bond.ready(&"tonnage"))
	assert_true(bond.master(&"tonnage"))
	bond.record(&"kerf", 20, 0)
	assert_eq(bond.value(&"kerf"), 30.0)


func test_a_bar_for_an_unknown_form_is_a_load_error() -> void:
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GhostFormTable.PATH))
	var bars: Dictionary = {"tonnage": 40, "nobody": 12}
	var section: Dictionary = raw["bond"]
	section["master_at_by_form"] = bars
	var data: DataTable = DataTable.parse(JSON.stringify(raw), GhostFormTable.SCHEMA, "forms")
	var bad: GhostFormTable = GhostFormTable.from_table(data)
	assert_false(bad.ok())
	assert_true("; ".join(bad.errors()).contains("master_at_by_form names unknown form nobody"))
	assert_eq(bad.master_at_for(&"tonnage"), 40.0)
	assert_eq(bad.master_at_for(&"ohm"), 30.0)
