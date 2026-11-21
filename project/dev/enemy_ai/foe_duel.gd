extends SceneTree
## node tools/dev/run.mjs foe_duel --enemy=rocket_trooper --seeds=20 --out=<absolute.json>

const KNOWN_FLAGS: PackedStringArray = ["--enemy", "--seeds", "--out"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var path: String = args.text("--out")
	var seeds: String = args.text("--seeds", "20")
	var known: bool = args.values.keys().all(func(key: String) -> bool: return key in KNOWN_FLAGS)
	if not known or not seeds.is_valid_int() or seeds.to_int() < 1 or not path.is_absolute_path():
		printerr("foe_duel needs --enemy=<id> --seeds=<positive integer> --out=<absolute.json>")
		quit(2)
		return
	# Load after autoloads initialize, as for fight_probe.
	var trial: GDScript = load("res://dev/enemy_ai/foe_duel_trial.gd")
	var runner: Object = trial.new()
	var enemy: StringName = runner.get("enemy")
	if enemy == &"" or not runner.call("knows", enemy):
		printerr("foe_duel: unknown enemy ", enemy)
		quit(2)
		return
	var runs: Array[Dictionary] = []
	for i: int in seeds.to_int():
		var row: Dictionary = runner.call("run", enemy, i + 1)
		runs.append(row)
	var out: Dictionary = {"schema": "gtai.foe-duel/1", "enemy": enemy, "tick_hz": 60, "runs": runs}
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		quit(1)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null or not file.store_string(JSON.stringify(out, "  ") + "\n"):
		printerr("foe_duel: could not write ", path)
		quit(1)
		return
	quit(0)
