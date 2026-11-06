extends SceneTree
## Scenario runner (TST-03): runs every res://tests/scenarios/scenario_*.gd headless.
## Exits non-zero on any failure or on any unknown user argument (the engine ignores them).
## A scenario that compiles but logs any engine or script error fails too (ErrorCounter).
## --evidence-dir=<abs dir> lets scenarios leave detail files (Scenario.write_evidence).
## Usage: godot --headless --path project -s res://tests/run_scenarios.gd
##   [-- --filter=<text>] [--only=<name>[,<name>...]] [--evidence-dir=<dir>]
## --only runs exactly the named scenarios ("city_chase" or "scenario_city_chase.gd"); an unknown
## name exits 2. The tools runner uses it to re-judge budget scenarios on a quiet machine.

const SCENARIO_DIR: String = "res://tests/scenarios"
const KNOWN_FLAGS: PackedStringArray = ["--filter", "--only", "--evidence-dir"]


func _initialize() -> void:
	var values: Dictionary[String, String] = {}
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("run_scenarios: unknown argument %s" % arg)
			quit(2)
			return
		values[flag] = arg.substr(flag.length() + 1)
	var filter: String = values.get("--filter", "")
	Scenario.evidence_dir = values.get("--evidence-dir", "")
	var only_text: String = values.get("--only", "")
	var only: PackedStringArray = _split_only(only_text)
	var unknown: String = _unknown_only(only)
	if unknown != "":
		printerr("run_scenarios: unknown scenario %s" % unknown)
		quit(2)
		return
	quit(_run_all(filter, only))


func _run_all(filter: String, only: PackedStringArray) -> int:
	var failed: int = 0
	var ran: int = 0
	var errors: ErrorCounter = ErrorCounter.new()
	OS.add_logger(errors)
	for file: String in DirAccess.get_files_at(SCENARIO_DIR):
		if not file.begins_with("scenario_") or not file.ends_with(".gd"):
			continue
		if filter != "" and not file.contains(filter):
			continue
		if not only.is_empty() and not only.has(_short_name(file)):
			continue
		ran += 1
		errors.reset()
		var reason: String = _run_one(SCENARIO_DIR.path_join(file))
		if reason == "" and errors.count() > 0:
			reason = "%d engine/script error(s), first: %s" % [errors.count(), errors.first()]
		if reason != "":
			failed += 1
			printerr("FAIL %s: %s" % [file, reason])
	OS.remove_logger(errors)
	printerr("run_scenarios: %d ran, %d failed" % [ran, failed])
	return 1 if failed > 0 else 0


## "scenario_city_chase.gd" -> "city_chase".
func _short_name(file: String) -> String:
	return file.trim_prefix("scenario_").trim_suffix(".gd")


func _split_only(text: String) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for part: String in text.split(",", false):
		@warning_ignore("return_value_discarded")
		out.append(_short_name(part.strip_edges()))
	return out


## The first --only name that matches no scenario file, or "".
func _unknown_only(only: PackedStringArray) -> String:
	var have: PackedStringArray = PackedStringArray()
	for file: String in DirAccess.get_files_at(SCENARIO_DIR):
		if file.begins_with("scenario_") and file.ends_with(".gd"):
			@warning_ignore("return_value_discarded")
			have.append(_short_name(file))
	for name: String in only:
		if not have.has(name):
			return name
	return ""


func _run_one(path: String) -> String:
	var script: GDScript = load(path) as GDScript
	if script == null or not script.can_instantiate():
		return "does not compile"
	var instance: Object = script.new()
	if not instance is Scenario:
		return "does not extend Scenario"
	var scenario: Scenario = instance as Scenario
	return scenario.run(self)
