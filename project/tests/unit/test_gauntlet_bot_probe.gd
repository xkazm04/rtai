extends GutTest


func test_tick_limit_preserves_unfinished_wave_and_per_wave_counters() -> void:
	var script: GDScript = load("res://dev/test_player/bot_pit_trial.gd")
	var trial: RefCounted = script.new()
	var result: Dictionary = trial.call("run", &"novice", 20261103, 128)
	var waves: Array = result.waves
	assert_eq(waves.size(), 1)
	if waves.is_empty():
		return
	var first: Dictionary = waves[0]
	var ordinal: int = first.n
	var status: String = first.status
	var end: int = first.end_tick
	assert_eq(ordinal, 1)
	assert_eq(status, "tick_limit")
	assert_eq(end, 127)
	assert_true(first.clear_s == null)
	var wave_deaths: int = first.deaths
	var total_deaths: int = result.deaths
	var wave_damage: float = first.damage_taken
	var total_damage: float = result.damage_taken
	var wave_shots: int = first.counters.shots
	var total_shots: int = result.counters.shots
	var cleared: int = result.waves_cleared
	assert_eq(wave_deaths, total_deaths)
	assert_eq(wave_damage, total_damage)
	assert_eq(wave_shots, total_shots)
	assert_eq(cleared, 0)
	var digest: String = result.input_sha256
	assert_eq(digest.length(), 64)
