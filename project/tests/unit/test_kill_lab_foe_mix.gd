extends GutTest
## n29 combat 07: a single --foe-mix archetype also dresses the lab guard of a gun kill.


func test_a_single_foe_mix_names_the_gun_victim() -> void:
	var args: ArenaArgs = ArenaArgs.parse(["--foe-mix=sergeant_mulroney"])
	assert_eq(KillLabTurn.melee_victim(&"", args), &"sergeant_mulroney")


func test_no_mix_keeps_the_gun_guard_unnamed() -> void:
	assert_eq(KillLabTurn.melee_victim(&"", ArenaArgs.parse([])), &"")


func test_a_list_names_no_victim_for_a_gun() -> void:
	var args: ArenaArgs = ArenaArgs.parse(["--foe-mix=contractor,swat"])
	assert_eq(KillLabTurn.melee_victim(&"", args), &"")
