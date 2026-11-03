class_name Checkpoint
extends RefCounted
## A quest checkpoint as JSON (`gtai.checkpoint/1`, version 1): the quest, the beat it was
## taken at, the tick, the master seed, the input tape before that tick and the sim's state hash
## there. Loading re-simulates the tape on a fresh world and must land on the same hash, so a
## load is exact or refused, never approximate. Read with the JSON class only (SEC-02); every
## field validated before use. Written tmp -> rename so a crash never leaves half a file.

const SCHEMA: String = "gtai.checkpoint/1"
const VERSION: int = 1
const DEFAULT_PATH: String = "user://saves/quest1_checkpoint.json"

var quest: String = ""
var beat: String = ""
var tick: int = 0
var master_seed: int = 0
var state_hash: String = ""
var input_ticks: Array[int] = []
var inputs: Array[int] = []


func to_dict() -> Dictionary:
	return {
		"schema": SCHEMA,
		"version": VERSION,
		"quest": quest,
		"beat": beat,
		"tick": tick,
		"master_seed": master_seed,
		"state_hash": state_hash,
		"input_ticks": input_ticks,
		"inputs": inputs,
	}


## null (with the reason logged) when the text is not a valid version-1 checkpoint.
static func from_json(text: String) -> Checkpoint:
	var parser: JSON = JSON.new()
	var parsed: Variant = parser.data if parser.parse(text) == OK else null
	return from_dict(parsed if parsed is Dictionary else {})


## null (with the reason logged) when `d` is not a valid version-1 checkpoint. The Save slot
## carries `to_dict()` as its body; this is what reads it back (every field validated).
static func from_dict(d: Dictionary) -> Checkpoint:
	if d.get("schema") != SCHEMA or _int(d.get("version")) != VERSION:
		Log.warn("save", "not a %s v%d checkpoint" % [SCHEMA, VERSION])
		return null
	var c: Checkpoint = Checkpoint.new()
	c.quest = str(d.get("quest", ""))
	c.beat = str(d.get("beat", ""))
	c.tick = _int(d.get("tick"))
	c.master_seed = _int(d.get("master_seed"))
	c.state_hash = str(d.get("state_hash", ""))
	var t: Variant = d.get("input_ticks")
	var i: Variant = d.get("inputs")
	var ticks: Array = t if t is Array else []
	var packed: Array = i if i is Array else []
	if c.quest == "" or c.tick <= 0 or c.state_hash.length() != 64 or ticks.size() != packed.size():
		Log.warn("save", "checkpoint fields invalid")
		return null
	for k: int in ticks.size():
		c.input_ticks.append(_int(ticks[k]))
		c.inputs.append(_int(packed[k]))
	return c


static func load_file(path: String = DEFAULT_PATH) -> Checkpoint:
	if not FileAccess.file_exists(path):
		return null
	return from_json(FileAccess.get_file_as_string(path))


func save(path: String = DEFAULT_PATH) -> Error:
	var err: Error = DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if err != OK:
		return err
	var tmp: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(tmp, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var ok: bool = file.store_string(JSON.stringify(to_dict(), "", true))
	file.close()
	if not ok:
		return ERR_FILE_CANT_WRITE
	erase(path)
	return DirAccess.rename_absolute(tmp, path)


static func erase(path: String = DEFAULT_PATH) -> void:
	if FileAccess.file_exists(path):
		@warning_ignore("return_value_discarded")
		DirAccess.remove_absolute(path)


static func _int(v: Variant) -> int:
	if v is int:
		return v
	var f: float = v if v is float else -1.0
	return roundi(f)
