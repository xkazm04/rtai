extends Scenario
## Every station file in data/tables/arena_stations loads, every hook a station names builds and
## every knob whose table is in this tree resolves (dev/arena/stations_report.gd), so a lane's
## broken file shows up in the suite at the merge, not as a silently skipped station.
## TST-05: a planted station with a knob that names a missing path must be reported.

const REPORT: String = "res://dev/arena/stations_report.gd"
const EVIDENCE_FILE: String = "arena-stations.json"
const FAULT_DIR: String = "user://test_tmp/arena_stations_fault"
const FAULT: String = """{"schema": "gtai.arena-station/1", "doc": "planted", "lane": "probe",
"stations": [{"id": "probe", "name": "Probe", "area": "hub", "tuning": [
{"key": "input_actions.move.no_such_knob", "min": 0, "max": 1, "step": 0.1}]}]}"""


func run(_tree: SceneTree) -> String:
	var checker: GDScript = load(REPORT) as GDScript
	var report: Dictionary = checker.call(&"check", ArenaStations.DIR)
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, report)
	var problems: Array = report["problems"]
	if not problems.is_empty():
		return "arena stations: %s" % [problems]
	var count: int = report["count"]
	if count < 3:
		return "arena stations: only %d stations loaded" % count
	return _planted(checker)


func _planted(checker: GDScript) -> String:
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(FAULT_DIR)
	var f: FileAccess = FileAccess.open(FAULT_DIR + "/probe.json", FileAccess.WRITE)
	if f == null:
		return "arena stations: cannot write the planted file"
	@warning_ignore("return_value_discarded")
	f.store_string(FAULT)
	f.close()
	var report: Dictionary = checker.call(&"check", FAULT_DIR)
	var problems: Array = report["problems"]
	@warning_ignore("return_value_discarded")
	DirAccess.remove_absolute(FAULT_DIR + "/probe.json")
	if problems.size() != 1:
		return "arena stations: the planted bad knob was not caught (%s)" % [problems]
	return ""
