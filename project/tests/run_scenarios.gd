extends SceneTree
## Scenario runner (TST-03): runs every res://tests/scenarios/scenario_*.gd headless.
## Exits non-zero on any failure or on any unknown user argument (the engine ignores them).
## Usage: godot --headless --path project -s res://tests/run_scenarios.gd [-- --filter=<text>]

const SCENARIO_DIR: String = "res://tests/scenarios"
const KNOWN_FLAGS: PackedStringArray = ["--filter"]


func _initialize() -> void:
	var filter: String = ""
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("run_scenarios: unknown argument %s" % arg)
			quit(2)
			return
		filter = arg.substr(flag.length() + 1)
	quit(_run_all(filter))


func _run_all(filter: String) -> int:
	var failed: int = 0
	var ran: int = 0
	for file: String in DirAccess.get_files_at(SCENARIO_DIR):
		if not file.begins_with("scenario_") or not file.ends_with(".gd"):
			continue
		if filter != "" and not file.contains(filter):
			continue
		ran += 1
		var reason: String = _run_one(SCENARIO_DIR.path_join(file))
		if reason != "":
			failed += 1
			printerr("FAIL %s: %s" % [file, reason])
	printerr("run_scenarios: %d ran, %d failed" % [ran, failed])
	return 1 if failed > 0 else 0


func _run_one(path: String) -> String:
	var script: GDScript = load(path) as GDScript
	if script == null:
		return "does not load"
	var instance: Object = script.new()
	if not instance is Scenario:
		return "does not extend Scenario"
	var scenario: Scenario = instance as Scenario
	return scenario.run(self)
