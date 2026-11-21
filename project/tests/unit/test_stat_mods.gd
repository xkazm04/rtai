extends GutTest


func test_all_stats_start_at_one_and_only_changed_values_are_reported() -> void:
	var mods: StatMods = StatMods.new()
	for stat: StringName in StatMods.STATS:
		assert_eq(mods.value(stat), 1.0)
	assert_eq(mods.to_dict(), {})
	mods.add(&"speed", 1.25)
	mods.add(&"speed", 1.25)
	mods.add(&"damage", 1.1)
	mods.add(&"regen", 2.0)
	mods.add(&"regen", 0.5)
	assert_eq(mods.value(&"speed"), 1.5625)
	assert_eq(mods.to_dict().keys(), ["damage", "speed"])


func test_unknown_stat_logs_and_is_ignored() -> void:
	var mods: StatMods = StatMods.new()
	mods.add(&"missing", 3.0)
	assert_string_contains(Log.recent()[-1], "[ERROR] gauntlet: unknown stat missing")
	assert_eq(mods.value(&"missing"), 1.0)
	assert_eq(mods.to_dict(), {})
