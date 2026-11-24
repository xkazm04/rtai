extends SceneTree
## Direct starts on the seeded street. The normal test player's numbered deploy targets the boss.

const KNOWN_FLAGS: PackedStringArray = ["--seeds", "--out", "--loadout"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var path: String = args.text("--out")
	var count: int = args.text("--seeds", "10").to_int()
	if not path.is_absolute_path() or path.get_extension() != "json" or count < 1 or count > 10:
		quit(2)
		return
	var trial: GDScript = load("res://dev/ghost-forms/boss_wave_trial.gd")
	var rows: Array[Dictionary] = []
	for wave: int in [5, 10]:
		for seed_id: int in range(1, count + 1):
			for arm: String in ["no_kerf", "kerf_uncapped", "kerf_capped"]:
				var instance: RefCounted = trial.new()
				var row: Dictionary = instance.call(
					"measure", wave, seed_id, arm, args.text("--loadout", "pistol")
				)
				if row.is_empty():
					quit(1)
					return
				rows.append(row)
	var report: Dictionary = {
		"schema": "gtai.kerf-boss-wave/1", "tick_hz": SimClock.TICK_RATE, "rows": rows
	}
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	quit(0 if file != null and file.store_string(JSON.stringify(report, "  ") + "\n") else 1)
