extends SceneTree
## Run the trial after the -s entry's autoloads have initialized.

const KNOWN_FLAGS: PackedStringArray = [
	"--profile", "--seed", "--out", "--result", "--ticks", "--waves"
]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	# --out retains the original digest-rich probe, including when the runner verifies that path.
	var path: String = args.text("--out", args.text("--result"))
	var wire: bool = not args.has("--out")
	var waves: String = args.text("--waves", "0")
	var profile: String = args.text("--profile", "average")
	var ticks: String = args.text("--ticks", "2400")
	var run_seed: String = args.text("--seed", "20261103")
	if not (
		args.values.keys().all(func(key: String) -> bool: return key in KNOWN_FLAGS)
		and profile in ["novice", "average", "expert"]
		and ticks.is_valid_int()
		and ticks.to_int() > 0
		and run_seed.is_valid_int()
		and run_seed.to_int() >= 0
		and run_seed.to_int() <= 0xFFFFFFFF
		and path.is_absolute_path()
		and path.get_extension().to_lower() == "json"
		and (not args.has("--result") or path == args.text("--result"))
		and (not args.has("--waves") or (wire and waves.is_valid_int() and waves.to_int() > 0))
	):
		printerr("bot_pit_probe: --result=<absolute.json> [--waves=N] or --out=<probe.json>")
		quit(2)
		return
	var script: GDScript = load("res://dev/test_player/bot_pit_trial.gd")
	var trial: RefCounted = script.new()
	var result: Dictionary = trial.call(
		"run", StringName(profile), run_seed.to_int(), ticks.to_int(), wire, waves.to_int()
	)
	if result.is_empty() or not _write(path, result):
		printerr("bot_pit_probe: could not complete trial or write ", path)
		quit(1)
		return
	quit(0)


func _write(path: String, result: Dictionary) -> bool:
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		return false
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	return file != null and file.store_string(JSON.stringify(result, "  ", true, true) + "\n")
