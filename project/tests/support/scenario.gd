@abstract class_name Scenario
extends RefCounted
## Base class for res://tests/scenarios/scenario_*.gd (TST-03). run() returns "" on success,
## or the failure reason. A scenario may leave a detail file for PoF with write_evidence(): it
## lands in the runner's --evidence-dir (the evidence writer's build/evidence/), else nowhere.

## Set by run_scenarios.gd from --evidence-dir; "" = do not write evidence files.
static var evidence_dir: String = ""

@abstract func run(tree: SceneTree) -> String


## Writes `data` as JSON to <evidence_dir>/<file_name>; "" on success (or when no dir is set).
static func write_evidence(file_name: String, data: Dictionary) -> String:
	if evidence_dir == "":
		return ""
	if DirAccess.make_dir_recursive_absolute(evidence_dir) != OK:
		return "cannot create %s" % evidence_dir
	var file: FileAccess = FileAccess.open(evidence_dir.path_join(file_name), FileAccess.WRITE)
	if file == null:
		return "cannot write %s (%d)" % [file_name, FileAccess.get_open_error()]
	var ok: bool = file.store_string(JSON.stringify(data, "  ", true) + "\n")
	file.close()
	if not ok:
		return "cannot write %s" % file_name
	return ""
