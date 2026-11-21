extends GutTest

const Entry = preload("res://dev/gauntlet/gauntlet.gd")


func test_entry_validates_the_launch_contract() -> void:
	var entry: Entry = Entry.new()
	var good: PackedStringArray = [
		"--seed=7",
		"--bot=average",
		"--waves=1",
		"--pick=random",
		"--controls=wheel",
		"--result=C:/temp/run.json",
	]
	assert_eq(entry._invalid_arg(ArenaArgs.parse(good)), "")
	for arg: String in [
		"--seed=-1",
		"--bot=test",
		"--pick=last",
		"--waves=x",
		"--controls=x",
		"--result=relative.json",
		"--unused=yes"
	]:
		assert_string_contains(entry._invalid_arg(ArenaArgs.parse([arg])), arg.get_slice("=", 0))
	entry.free()


func test_scene_hands_its_control_mode_to_the_live_pilot() -> void:
	var entry: Entry = Entry.new()
	for flag: String in ["", "--controls=legacy", "--controls=wheel"]:
		var args: ArenaArgs = ArenaArgs.parse([] if flag.is_empty() else [flag])
		var session: GauntletSession = entry._open_street(args)
		var wheel: bool = flag != "--controls=legacy"
		assert_eq(entry.run.controls, &"wheel" if wheel else &"legacy")
		assert_eq(session.stage.pilot.guard != null, wheel)
		assert_eq(session.stage.pilot.wheel != null, wheel)
		assert_eq(bool(session.actions.live_mask & (1 << session.actions.bit(&"guard"))), wheel)
		session.close()
	entry.free()
	PlayerActions.shipped().install()


func test_fresh_human_run_has_only_observed_fields() -> void:
	var run: GauntletRun = GauntletRun.new()
	run.seed = 7
	assert_eq(
		run.to_result(),
		{
			"schema": "gtai.gauntlet-run/1",
			"seed": 7,
			"profile": "human",
			"controls": "legacy",
			"wave_reached": 0,
			"waves": [],
			"picks": [],
			"mods": {},
		}
	)


func test_recorded_wave_keeps_a_measured_zero_and_omits_unobserved_counters() -> void:
	var run: GauntletRun = GauntletRun.new()
	run.wave = 2
	run.alive = false
	run.death_by = &"rocket_trooper"
	run.waves.append({"n": 1, "damage_taken": 0, "shots": 8})
	run.picks.append({"wave": 1, "offered": ["a", "b", "c"], "taken": "b"})
	run.mods.add(&"hp_max", 1.25)
	var out: Dictionary = run.to_result()
	var death: Dictionary = out["death"]
	var waves: Array = out["waves"]
	var picks: Array = out["picks"]
	var mods: Dictionary = out["mods"]
	assert_eq(death, {"wave": 2, "by": "rocket_trooper"})
	assert_eq(waves, [{"n": 1, "damage_taken": 0, "shots": 8}])
	assert_eq(picks, run.picks)
	assert_eq(mods, {"hp_max": 1.25})


func test_pilot_picks_are_seeded_and_greedy_starts_at_zero() -> void:
	var a: GauntletPilot = GauntletPilot.new()
	var b: GauntletPilot = GauntletPilot.new()
	var offers: Array[StringName] = [&"a", &"b", &"c"]
	a.configure(&"novice", &"random", 7)
	b.configure(&"novice", &"random", 7)
	var seen: Array[int] = []
	for i: int in 24:
		var index: int = a.pick(offers)
		assert_eq(index, b.pick(offers))
		assert_between(index, 0, 2)
		if not seen.has(index):
			seen.append(index)
	assert_gt(seen.size(), 1)
	a.configure(&"expert", &"greedy", 7)
	assert_eq(a.profile(), &"expert")
	assert_eq(a.pick(offers), 0)
