extends GutTest
## Metadata is informational: only its schema is checked, and write failures become notes.

var _slots: SaveSlots
var _case: int = 0
var _previous_after_tmp: Callable


func before_each() -> void:
	_case += 1
	_slots = SaveSlots.new(TestTmp.dir("save_meta/%d" % _case))
	_previous_after_tmp = SlotFile.after_tmp
	SlotFile.after_tmp = Callable()


func after_each() -> void:
	SlotFile.after_tmp = _previous_after_tmp
	for name: String in DirAccess.get_files_at(_slots.root):
		assert_eq(DirAccess.remove_absolute(_slots.root.path_join(name)), OK)
	assert_eq(DirAccess.remove_absolute(_slots.root), OK)


func test_missing_metadata_returns_empty_without_creating_a_file() -> void:
	assert_false(FileAccess.file_exists(_slots.meta_path()))
	assert_eq(SaveMeta.read(_slots), {})
	assert_false(FileAccess.file_exists(_slots.meta_path()))


func test_empty_or_malformed_json_returns_empty() -> void:
	for text: String in ["", "{", '{"schema":"gtai.save-meta/1"', "not json"]:
		_store(text)
		assert_eq(SaveMeta.read(_slots), {}, "unreadable metadata: %s" % text)
		assert_eq(FileAccess.get_file_as_string(_slots.meta_path()), text)


func test_valid_json_with_a_non_dictionary_root_returns_empty() -> void:
	for text: String in ["[]", '[{"schema":"gtai.save-meta/1"}]', '"text"', "0", "true", "null"]:
		_store(text)
		assert_eq(SaveMeta.read(_slots), {}, "non-dictionary root: %s" % text)


func test_schema_must_match_exactly() -> void:
	var invalid: Array[Dictionary] = [
		{},
		{"schema": null},
		{"schema": ""},
		{"schema": "gtai.save-meta/0"},
		{"schema": "gtai.save-meta/2"},
		{"schema": "GTAI.save-meta/1"},
		{"schema": "gtai.save-meta/1 "},
	]
	for doc: Dictionary in invalid:
		_store(JSON.stringify(doc))
		assert_eq(SaveMeta.read(_slots), {}, "schema rejected: %s" % doc)


func test_matching_schema_needs_no_other_fields_and_preserves_unknown_data() -> void:
	_store('{"schema":"gtai.save-meta/1"}')
	assert_eq(SaveMeta.read(_slots), {"schema": "gtai.save-meta/1"})
	var doc: Dictionary = {
		"schema": "gtai.save-meta/1",
		"slot": "unknown_slot",
		"seq": -1.0,
		"point": null,
		"extra": {"label": "Žluťoučký robot", "values": [true, null, 1.25]},
	}
	_store(JSON.stringify(doc))
	assert_eq(SaveMeta.read(_slots), doc, "metadata has no slot or payload validation")


func test_write_overrides_reserved_fields_for_both_slots_without_mutating_input() -> void:
	var meta: Dictionary = {
		"schema": "caller schema",
		"slot": "caller slot",
		"seq": -99,
		"point": "caller point",
		"last_played_unix": -1,
		"playtime": 123.25,
		"quest": {"id": "robot_ž", "beat": 3},
	}
	var original: Dictionary = meta.duplicate(true)
	for index: int in 2:
		var result: SaveWorker.Result = _result(index)
		var before: int = int(Time.get_unix_time_from_system())
		SaveMeta.write(_slots, meta, result)
		var after: int = int(Time.get_unix_time_from_system())
		var doc: Dictionary = _read_disk()
		var expected: Dictionary = meta.duplicate(true)
		expected["schema"] = "gtai.save-meta/1"
		expected["slot"] = "auto_a" if index == 0 else "auto_b"
		expected["seq"] = float(result.seq)
		expected["quest"] = {"id": "robot_ž", "beat": 3.0}
		expected["point"] = result.point
		expected["last_played_unix"] = doc.get("last_played_unix")
		assert_eq(doc, expected)
		var timestamp: Variant = doc.get("last_played_unix")
		assert_true(timestamp is float, "the timestamp is a JSON number")
		if timestamp is float:
			var seconds: float = timestamp
			assert_between(seconds, float(before), float(after))
		assert_eq(meta, original, "reserved fields are changed only in the copy")
		assert_eq(result.notes, ["existing note"])
		assert_eq(result.error, OK)
		assert_eq(SaveMeta.read(_slots), doc)


func test_empty_input_still_writes_the_five_reserved_fields() -> void:
	var result: SaveWorker.Result = _result(0)
	SaveMeta.write(_slots, {}, result)
	var doc: Dictionary = _read_disk()
	assert_eq(doc.size(), 5)
	assert_eq(
		doc,
		{
			"schema": "gtai.save-meta/1",
			"slot": "auto_a",
			"seq": 0.0,
			"point": "",
			"last_played_unix": doc.get("last_played_unix"),
		}
	)
	var timestamp: Variant = doc.get("last_played_unix")
	assert_true(timestamp is float)
	if timestamp is float:
		var seconds: float = timestamp
		assert_gt(seconds, 0.0)


func test_failed_write_appends_a_note_and_preserves_previous_metadata_and_result() -> void:
	var previous: String = '{"schema":"gtai.save-meta/1","quest":"previous"}'
	_store(previous)
	SlotFile.after_tmp = _corrupt_tmp
	var result: SaveWorker.Result = _result(1)
	result.error = ERR_BUSY
	var meta: Dictionary = {"quest": "replacement"}
	SaveMeta.write(_slots, meta, result)
	assert_eq(
		result.notes,
		["existing note", "meta.json not written (%s)" % error_string(ERR_FILE_CORRUPT)]
	)
	assert_eq(result.error, ERR_BUSY, "metadata failure never replaces the slot result")
	assert_eq(result.slot, 1)
	assert_eq(result.seq, 42)
	assert_eq(result.point, "mission_end")
	assert_eq(meta, {"quest": "replacement"})
	assert_eq(FileAccess.get_file_as_string(_slots.meta_path()), previous)
	assert_false(FileAccess.file_exists(SlotFile.tmp_path(_slots.meta_path())))


func _result(index: int) -> SaveWorker.Result:
	var result: SaveWorker.Result = SaveWorker.Result.new()
	result.slot = index
	result.seq = 0 if index == 0 else 42
	result.point = "" if index == 0 else "mission_end"
	result.notes.append("existing note")
	return result


func _store(text: String) -> void:
	var file: FileAccess = FileAccess.open(_slots.meta_path(), FileAccess.WRITE)
	assert_not_null(file)
	if file != null:
		assert_true(file.store_string(text))
		file.close()


func _read_disk() -> Dictionary:
	var parser: JSON = JSON.new()
	assert_eq(parser.parse(FileAccess.get_file_as_string(_slots.meta_path())), OK)
	assert_true(parser.data is Dictionary)
	var doc: Dictionary = parser.data if parser.data is Dictionary else {}
	return doc


func _corrupt_tmp(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file)
	if file != null:
		assert_true(file.store_string("corrupted"))
		file.close()
