extends RefCounted
## n31-21: the files of a prop walk: walk.jsonl (one row per tick) and stops.json (one per probe).

var _dir: String
var _log: FileAccess
var _stops: Array = []


func _init(dir: String) -> void:
	_dir = dir
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(dir)
	_log = FileAccess.open(dir.path_join("walk.jsonl"), FileAccess.WRITE)


func tick(n: int, at: Vector2, probe: String) -> void:
	@warning_ignore("return_value_discarded")
	_log.store_line(JSON.stringify({"tick": n, "rivet_m": [at.x, at.y], "probe": probe}))


func stop(row: Dictionary) -> void:
	_stops.append(row)


func finish() -> void:
	_log.close()
	var file: FileAccess = FileAccess.open(_dir.path_join("stops.json"), FileAccess.WRITE)
	var doc: Dictionary = {"schema": "gtai.prop-walk/1", "stops": _stops}
	@warning_ignore("return_value_discarded")
	file.store_string(JSON.stringify(doc, " ") + "\n")
	file.close()
