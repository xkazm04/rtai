extends SceneTree
## Headless paired 30-second encounters. Named seeds are always the prefix 1..N.

const KNOWN_FLAGS: PackedStringArray = ["--out", "--seeds", "--form"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var path: String = args.text("--out")
	var count: String = args.text("--seeds", "10")
	var known: bool = args.values.keys().all(func(key: String) -> bool: return key in KNOWN_FLAGS)
	if not known or not path.is_absolute_path() or path.get_extension() != "json":
		printerr("deploy_worth needs --out=<absolute.json>")
		quit(2)
		return
	if not count.is_valid_int() or count.to_int() < 1 or count.to_int() > 10:
		printerr("deploy_worth needs --seeds=1..10")
		quit(2)
		return
	var script: GDScript = load("res://dev/ghost-forms/deploy_worth_run.gd")
	if script == null or not script.can_instantiate():
		quit(1)
		return
	var runner: Object = script.new()
	var code: int = runner.call("run", path, args.text("--form", "all"), count.to_int())
	quit(code)
