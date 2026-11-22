extends GutTest


func _fixture(include_boss: bool) -> GauntletComposer:
	var rules: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	rules.raw["budget"] = {"base": 20, "per_wave": 20, "unit": 10}
	rules.raw["cost"] = {}
	var rows: Array[Dictionary] = [
		{"id": "patrol_cop"}, {"id": "contractor"}, {"id": "riot_cop", "tier": 3}
	]
	if include_boss:
		rows.append({"id": "war_machine", "tier": 5})
	return GauntletComposer.new(RngRegistry.new(7), rules, rows)


func test_every_roster_respects_cost_unlocks_and_boss_slots() -> void:
	for seed_value: int in [7, 8, 0, RngRegistry.SEED_MASK]:
		var composer: GauntletComposer = GauntletComposer.shipped(RngRegistry.new(seed_value))
		var cheapest: int = mini(composer.costs[&"patrol_cop"], composer.costs[&"contractor"])
		for wave: int in range(1, 26):
			var roster: Array[StringName] = composer.compose(wave)
			var spent: int = 0
			var budget: int = composer.budget(wave)
			for id: StringName in roster:
				var tier: int = composer.tiers[id]
				spent += composer.costs[id]
				assert_gte(wave, composer.unlocks[tier - 1])
			assert_lte(spent, budget)
			assert_lt(budget - spent, cheapest)
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
	assert_eq(composer.budget(1), 40)
	assert_eq(composer.budget(10), 220)
	for wave: int in range(1, 16):
		var roster: Array[StringName] = composer.compose(wave)
		assert_eq(roster.count(&"war_machine"), 1 if wave % 5 == 0 else 0)
		if wave % 5 == 0:
			assert_eq(roster[0], &"war_machine")


func test_boss_ignores_unlock_and_can_exceed_the_whole_budget() -> void:
	var rules: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	rules.raw["budget"] = {"base": 2, "per_wave": 0, "unit": 1}
	rules.raw["cost"] = {}
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


func test_roster_exclude_removes_tiered_enemies_from_every_wave() -> void:
	var rules: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	var rows: Array[Dictionary] = [{"id": "visitor", "tier": 1}, {"id": "regular", "tier": 1}]
	rules.raw["roster_exclude"] = ["visitor"]
	var filtered: GauntletComposer = GauntletComposer.new(RngRegistry.new(7), rules, rows)
	for wave: int in range(1, 51):
		var roster: Array[StringName] = filtered.compose(wave)
		assert_has(roster, &"regular")
		assert_does_not_have(roster, &"visitor")
	@warning_ignore("return_value_discarded")
	rules.raw.erase("roster_exclude")
	var unfiltered: GauntletComposer = GauntletComposer.new(RngRegistry.new(7), rules, rows)
	assert_has(unfiltered.compose(1), &"visitor")


func test_zero_budget_with_no_affordable_enemy_returns_an_empty_roster() -> void:
	var rules: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	rules.raw["budget"] = {"base": 0, "per_wave": 0, "unit": 1}
	var rows: Array[Dictionary] = [{"id": "regular", "tier": 1}]
	var composer: GauntletComposer = GauntletComposer.new(RngRegistry.new(7), rules, rows)
	assert_true(composer.compose(1).is_empty())


func test_tier_enters_on_its_exact_unlock_and_only_if_affordable() -> void:
	var rules: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	rules.raw["budget"] = {"base": 3, "per_wave": 0, "unit": 1}
	var rows: Array = [
		{"id": "three", "tier": 3}, {"id": "high", "tier": 6}, {"id": "zero", "tier": 0}
	]
	var composer: GauntletComposer = GauntletComposer.new(RngRegistry.new(1), rules, rows)
	assert_eq(composer.tiers.size(), 1)
	var unlock: int = composer.unlocks[2]
	assert_true(composer.compose(unlock - 1).is_empty())
	assert_eq(composer.compose(unlock), [&"three"])
	rules.raw["budget"] = {"base": 2, "per_wave": 0, "unit": 1}
	composer = GauntletComposer.new(RngRegistry.new(1), rules, rows)
	assert_true(composer.compose(unlock).is_empty())


func test_counting_in_tenths_preserves_each_seeded_roster() -> void:
	var rules: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	var enemies: DataTable = DataTable.open(EnemyRoster.TABLE, EnemyRoster.SCHEMA)
	var rows: Array = enemies.array(enemies.raw, "archetypes")
	@warning_ignore("return_value_discarded")
	rules.raw.erase("cost")
	for seed_value: int in range(1, 4):
		var registry: RngRegistry = RngRegistry.new(seed_value)
		rules.raw["budget"] = {"base": 2, "per_wave": 2, "unit": 1}
		var whole: GauntletComposer = GauntletComposer.new(registry, rules, rows)
		rules.raw["budget"] = {"base": 20, "per_wave": 20, "unit": 10}
		var tenths: GauntletComposer = GauntletComposer.new(registry, rules, rows)
		for wave: int in range(1, 31):
			var context: String = "seed %d wave %d" % [seed_value, wave]
			assert_eq(tenths.compose(wave), whole.compose(wave), context)


func test_fractional_cost_overrides_change_the_draw_and_boss_charge() -> void:
	var rules: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	var rows: Array[Dictionary] = [{"id": "contractor"}, {"id": "patrol_cop"}]
	var registry: RngRegistry = RngRegistry.new(1)
	rules.raw["budget"] = {"base": 8, "per_wave": 0, "unit": 10}
	rules.raw["cost"] = {}
	assert_true(GauntletComposer.new(registry, rules, rows).compose(1).is_empty())
	rules.raw["cost"] = {"patrol_cop": 8, "contractor": 12}
	var composer: GauntletComposer = GauntletComposer.new(registry, rules, rows)
	assert_eq(composer.costs[&"contractor"], 12)
	assert_eq(composer.compose(1), [&"patrol_cop"])
	assert_eq(composer.compose(5), [&"patrol_cop"])
	rules.raw["budget"] = {"base": 28, "per_wave": 0, "unit": 10}
	rules.raw["cost"]["war_machine"] = 20
	rows.append({"id": "war_machine", "tier": 5})
	composer = GauntletComposer.new(registry, rules, rows)
	assert_eq(composer.compose(5), [&"war_machine", &"patrol_cop"])
