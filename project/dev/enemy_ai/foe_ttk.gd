extends SceneTree
## node tools/dev/run.mjs foe_ttk --out=<absolute.json>

const KNOWN_FLAGS: PackedStringArray = ["--out"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var path: String = ArenaArgs.parse().text("--out")
	if not path.is_absolute_path() or path.get_extension() != "json":
		printerr("foe_ttk needs --out=<absolute.json>")
		quit(2)
		return
	var script: GDScript = load("res://dev/enemy_ai/foe_ttk_run.gd")
	if script == null or not script.can_instantiate():
		quit(1)
		return
	var runner: Object = script.new()
	var code: int = runner.call("run", path)
	quit(code)
