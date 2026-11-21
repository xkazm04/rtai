extends GutTest


func _fixture(include_boss: bool) -> GauntletComposer:
	var rules: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	var rows: Array[Dictionary] = [
		{"id": "patrol_cop"}, {"id": "contractor"}, {"id": "riot_cop", "tier": 3}
	]
	if include_boss:
		rows.append({"id": "war_machine", "tier": 5})
	return GauntletComposer.new(RngRegistry.new(7), rules, rows)


func test_every_roster_respects_cost_unlocks_and_boss_slots() -> void:
	for seed_value: int in [7, 8, 0, RngRegistry.SEED_MASK]:
		var composer: GauntletComposer = GauntletComposer.shipped(RngRegistry.new(seed_value))
		for wave: int in range(1, 26):
			var roster: Array[StringName] = composer.compose(wave)
			var spent: int = 0
			var budget: int = composer.budget(wave)
			for id: StringName in roster:
				var tier: int = composer.tiers[id]
				spent += tier
				assert_gte(wave, composer.unlocks[tier - 1])
			assert_eq(spent, budget, "tier one can always fill the last slot")
			assert_gt(budget, composer.budget(wave - 1))
			if wave % composer.boss_every == 0:
				assert_eq(roster.count(roster[0]), 1)
			else:
				assert_false(roster.has(GauntletComposer.BOSS))


func test_enemy_rows_override_provisional_tiers_and_missing_boss_uses_highest_unlocked() -> void:
	var composer: GauntletComposer = _fixture(false)
	assert_eq(composer.tiers[&"riot_cop"], 3)
	assert_eq(composer.tiers[&"patrol_cop"], 1)
	var early: Array[StringName] = composer.compose(5)
	assert_eq(composer.tiers[early[0]], 1)
	assert_eq(early.count(early[0]), 1)
	var late: Array[StringName] = composer.compose(10)
	assert_eq(late[0], &"riot_cop")
	assert_eq(late.count(&"riot_cop"), 1)


func test_war_machine_has_exactly_one_reserved_place_every_fifth_wave() -> void:
	var composer: GauntletComposer = _fixture(true)
	assert_eq(composer.budget(1), 4)
	assert_eq(composer.budget(10), 22)
	for wave: int in range(1, 16):
		var roster: Array[StringName] = composer.compose(wave)
		assert_eq(roster.count(&"war_machine"), 1 if wave % 5 == 0 else 0)
		if wave % 5 == 0:
			assert_eq(roster[0], &"war_machine")


func test_boss_ignores_unlock_and_can_exceed_the_whole_budget() -> void:
	var rules: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	rules.raw["budget"] = {"base": 2, "per_wave": 0}
	rules.raw["tier_unlock_wave"] = [1, 3, 6, 9, 20]
	var rows: Array = [{"id": "patrol_cop", "tier": 1}, {"id": "war_machine", "tier": 5}]
	var composer: GauntletComposer = GauntletComposer.new(RngRegistry.new(7), rules, rows)
	for wave: int in [5, 10]:
		assert_eq(composer.compose(wave), [&"war_machine"])
	for wave: int in range(1, 5):
		assert_eq(composer.compose(wave), [&"patrol_cop", &"patrol_cop"])


func test_seed_and_wave_identify_the_draw_independent_of_other_waves() -> void:
	var a: GauntletComposer = GauntletComposer.shipped(RngRegistry.new(7))
	var b: GauntletComposer = GauntletComposer.shipped(RngRegistry.new(7))
	var c: GauntletComposer = GauntletComposer.shipped(RngRegistry.new(8))
	var expected: Array[StringName] = a.compose(10)
	assert_ne(a.compose(3), expected)
	assert_eq(a.compose(10), expected)
	assert_eq(b.compose(10), expected)
	assert_ne(c.compose(10), expected)


func test_tier_enters_on_its_exact_unlock_and_only_if_affordable() -> void:
	var rules: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	rules.raw["budget"] = {"base": 3, "per_wave": 0}
	var rows: Array = [
		{"id": "three", "tier": 3}, {"id": "high", "tier": 6}, {"id": "zero", "tier": 0}
	]
	var composer: GauntletComposer = GauntletComposer.new(RngRegistry.new(1), rules, rows)
	assert_eq(composer.tiers.size(), 1)
	var unlock: int = composer.unlocks[2]
	assert_true(composer.compose(unlock - 1).is_empty())
	assert_eq(composer.compose(unlock), [&"three"])
	rules.raw["budget"] = {"base": 2, "per_wave": 0}
	composer = GauntletComposer.new(RngRegistry.new(1), rules, rows)
	assert_true(composer.compose(unlock).is_empty())
