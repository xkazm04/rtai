extends GutTest


func _trial() -> RefCounted:
	var script: GDScript = load("res://dev/test_player/bot_pit_trial.gd")
	return script.new()


func test_tick_limit_preserves_unfinished_wave_and_per_wave_counters() -> void:
	var trial: RefCounted = _trial()
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


func test_wire_result_records_cap_and_omits_unobserved_telemetry() -> void:
	var trial: RefCounted = _trial()
	var result: Dictionary = trial.call("run", &"average", 20261103, 2400, true, 1)
	assert_eq(str(result.schema), "gtai.gauntlet-run/1")
	assert_eq(str(result.controls), "legacy")
	var reached: int = result.wave_reached
	var sim_s: float = result.sim_s
	assert_eq(reached, 1)
	assert_lt(sim_s, 40.0)
	assert_false(result.has("death"))
	var picks: Array = result.picks
	assert_eq(picks.size(), 0)
	var row: Dictionary = result.waves[0]
	assert_eq(str(row.status), "cleared")
	var seconds: float = row.seconds
	assert_gt(seconds, 0.0)
	var enemies: Dictionary = row.enemies
	assert_gt(enemies.size(), 0)
	assert_true(row.has("shots"))
	assert_false(row.has("hits"))
	assert_false(row.has("guard_deflects"))
