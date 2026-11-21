extends GutTest


func test_default_preserves_mix_and_wave_sizes() -> void:
	var pit: ArenaPit = ArenaPit.new()
	var table: Array = ["swat", "riot_cop"]
	assert_same(FoeMix.choose(ArenaArgs.parse([]), EnemyRoster.shipped(), pit, table), table)
	assert_eq([pit.first_wave, pit.grow, pit.max_wave], [2, 1, 5])


func test_chosen_list_sets_wave_size_including_duplicates() -> void:
	var pit: ArenaPit = ArenaPit.new()
	var args: ArenaArgs = ArenaArgs.parse(["--foe-mix=rocket_trooper,sentry_turret,rocket_trooper"])
	var mix: Array = FoeMix.choose(args, EnemyRoster.shipped(), pit, [])
	assert_eq(mix, [&"rocket_trooper", &"sentry_turret", &"rocket_trooper"])
	assert_eq([pit.first_wave, pit.grow, pit.max_wave], [3, 0, 3])


func test_bad_id_rejects_the_whole_list_before_changing_wave_sizes() -> void:
	var pit: ArenaPit = ArenaPit.new()
	var args: ArenaArgs = ArenaArgs.parse(["--foe-mix=rocket_trooper,typo"])
	var table: Array = ["swat"]
	assert_same(FoeMix.choose(args, EnemyRoster.shipped(), pit, table), table)
	assert_eq([pit.first_wave, pit.grow, pit.max_wave], [2, 1, 5])
	assert_string_contains(Log.recent()[-1], "unknown --foe-mix id 'typo'")
