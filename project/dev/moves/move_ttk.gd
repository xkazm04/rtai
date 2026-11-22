extends SceneTree
## node tools/dev/run.mjs move_ttk --out=<absolute.json> [--move=<id>] [--seeds=10] [--slice-k=1.0]

const KNOWN_FLAGS: PackedStringArray = ["--out", "--move", "--seeds", "--slice-k"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var path: String = args.text("--out")
	var seeds: String = args.text("--seeds", "10")
	var known: bool = args.values.keys().all(func(key: String) -> bool: return key in KNOWN_FLAGS)
	if not known or not path.is_absolute_path() or path.get_extension() != "json":
		printerr("move_ttk needs --out=<absolute.json>")
		quit(2)
		return
	if not seeds.is_valid_int() or seeds.to_int() < 1:
		printerr("move_ttk needs a positive integer for --seeds")
		quit(2)
		return
	if args.has("--move") and args.text("--move").is_empty():
		printerr("move_ttk needs a move id for --move")
		quit(2)
		return
	var scale: String = args.text("--slice-k", "1.0")
	var slice_k: float = scale.to_float()
	if not scale.is_valid_float() or not is_finite(slice_k) or slice_k < 0.0:
		printerr("move_ttk needs a finite, nonnegative number for --slice-k")
		quit(2)
		return
	# The combat scripts rely on autoloads being ready before their first load.
	var script: GDScript = load("res://dev/moves/move_ttk_run.gd")
	if script == null or not script.can_instantiate():
		quit(1)
		return
	var runner: Object = script.new(slice_k)
	var code: int = runner.call("run", path, args.text("--move"), seeds.to_int())
	quit(code)
