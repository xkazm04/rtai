class_name AchievementMirror
extends RefCounted
## Local achievements mirror (ACH-09): {unlocked, stats, pending} as JSON.
## Null builds: the store. Steam builds: an outbox, reconciled by union at startup.
## Lives under user://device/, which is never cloud-synced (SAV-06/07).

const SCHEMA: String = "gtai.achievements-mirror/1"
const DEFAULT_PATH: String = "user://device/achievements_mirror.json"

## id -> UTC ISO time of the unlock.
var unlocked: Dictionary[StringName, String] = {}
var stats: Dictionary[StringName, int] = {}
## Unlocks not yet confirmed by Steam; replayed at the next Steam launch (STM-06).
var pending: Array[StringName] = []
var _path: String


func _init(path: String = DEFAULT_PATH) -> void:
	_path = path


func location() -> String:
	return _path


func clear() -> void:
	unlocked.clear()
	stats.clear()
	pending.clear()


## A missing file is a fresh mirror (OK). A corrupt one is reported and left on disk untouched.
func load_from_disk() -> Error:
	clear()
	if not FileAccess.file_exists(_path):
		return OK
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(_path)) != OK or not json.data is Dictionary:
		return ERR_PARSE_ERROR
	var root: Dictionary = json.data
	if root.get("schema", "") != SCHEMA:
		return ERR_INVALID_DATA
	_apply(root)
	return OK


## Writes `<path>.tmp`, then renames it over the mirror.
func save_to_disk() -> Error:
	var dir_err: Error = DirAccess.make_dir_recursive_absolute(_path.get_base_dir())
	if dir_err != OK:
		return dir_err
	var tmp_path: String = _path + ".tmp"
	var file: FileAccess = FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var ok: bool = file.store_string(JSON.stringify(to_dict(), "\t", true) + "\n")
	file.close()
	if not ok:
		return ERR_FILE_CANT_WRITE
	return DirAccess.rename_absolute(tmp_path, _path)


func to_dict() -> Dictionary:
	var pending_ids: Array[String] = []
	for id: StringName in pending:
		pending_ids.append(String(id))
	return {"schema": SCHEMA, "unlocked": unlocked, "stats": stats, "pending": pending_ids}


func _apply(root: Dictionary) -> void:
	var raw_unlocked: Dictionary = root.get("unlocked", {})
	for key: Variant in raw_unlocked:
		unlocked[StringName(str(key))] = str(raw_unlocked[key])
	var raw_stats: Dictionary = root.get("stats", {})
	for key: Variant in raw_stats:
		if raw_stats[key] is float or raw_stats[key] is int:
			var number: float = raw_stats[key]
			stats[StringName(str(key))] = roundi(number)
	var raw_pending: Array = root.get("pending", [])
	for id: Variant in raw_pending:
		pending.append(StringName(str(id)))
