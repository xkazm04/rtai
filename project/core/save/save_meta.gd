class_name SaveMeta
extends RefCounted
## `meta.json` (SAV-08): what the title screen and the Steam conflict dialog show - last played,
## playtime, quest and beat - plus which slot and sequence they describe. Informational only:
## the slots are the truth, so a missing or damaged meta.json is rebuilt from the loaded slot
## and never blocks a load.

const SCHEMA: String = "gtai.save-meta/1"


## Writes meta.json for a successful slot write (off-thread safe). A failure becomes a note.
static func write(slots: SaveSlots, meta: Dictionary, result: SaveWorker.Result) -> void:
	var doc: Dictionary = meta.duplicate()
	doc["schema"] = SCHEMA
	doc["slot"] = SaveSlots.IDS[result.slot]
	doc["seq"] = result.seq
	doc["point"] = result.point
	doc["last_played_unix"] = int(Time.get_unix_time_from_system())
	var bytes: PackedByteArray = JSON.stringify(doc, "\t", true, true).to_utf8_buffer()
	var err: Error = SlotFile.write(slots.meta_path(), bytes)
	if err != OK:
		result.notes.append("meta.json not written (%s)" % error_string(err))


## The parsed meta.json, or {} when absent or unreadable.
static func read(slots: SaveSlots) -> Dictionary:
	var path: String = slots.meta_path()
	if not FileAccess.file_exists(path):
		return {}
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		return {}
	var doc: Dictionary = parser.data
	return doc if doc.get("schema") == SCHEMA else {}
