class_name ArenaTuning
extends RefCounted
## The live tuning behind the arena's panel: a knob key "<table>.<json path>" (e.g.
## "input_actions.move.turn_dps", "combat.weapons.gloria.cooldown_s") reads its shipped value
## from data/tables/<table>.json, applies a new value to the running session at once (the
## PlayerActions feel, the CombatTuning weapons and bodies), saves it back into the table, or
## resets it. Every change is logged (`log`, and appended to LOG_PATH) so the owner's tuning is
## on record. Live changes are outside the input tape: a tuned run is tagged in the log.

const TABLES: String = "res://data/tables/%s.json"
const LOG_PATH: String = "user://arena/tuning-log.jsonl"

var actions: PlayerActions
var combat: CombatTuning
var log: Array[Dictionary] = []
## Other lanes' hooks: a knob the arena does not apply itself goes to them (ArenaHook.tune).
var hooks: Array[ArenaHook] = []
var _tables: Dictionary[String, Dictionary] = {}
var _shipped: Dictionary[String, float] = {}


func _init(p_actions: PlayerActions, p_combat: CombatTuning) -> void:
	actions = p_actions
	combat = p_combat


## The value in the table on disk (NAN when the key does not resolve).
func shipped(key: String) -> float:
	if not _shipped.has(key):
		var v: Variant = _walk(_table(key.get_slice(".", 0)), _path(key))
		var n: float = v if v is float or v is int else NAN
		_shipped[key] = n
	return _shipped[key]


## Applies `value` live; false when nothing in the session reads that key yet.
func set_value(key: String, value: float, tick: int = -1) -> bool:
	var table: String = key.get_slice(".", 0)
	var applied: bool = _apply(_path(key), table, value) or _apply_hooks(key, value)
	_note({"tick": tick, "key": key, "to": value, "applied": applied, "op": "set"})
	return applied


func reset(key: String, tick: int = -1) -> bool:
	return set_value(key, shipped(key), tick)


## Writes `value` into the table file (dev checkouts: res:// is the source tree).
func save(key: String, value: float) -> bool:
	var table: String = key.get_slice(".", 0)
	var raw: Dictionary = _table(table).duplicate(true)
	var path: PackedStringArray = _path(key)
	var at: Variant = _walk(raw, path.slice(0, path.size() - 1))
	var last: String = path[path.size() - 1]
	var rows: Array = at if at is Array else []
	if at is Dictionary:
		var parent: Dictionary = at
		parent[last] = value
	elif last.is_valid_int() and last.to_int() < rows.size():
		rows[last.to_int()] = value
	else:
		return false
	var f: FileAccess = FileAccess.open(TABLES % table, FileAccess.WRITE)
	if f == null:
		return false
	@warning_ignore("return_value_discarded")
	f.store_string(canonical(raw))
	f.close()
	_tables[table] = raw
	_shipped[key] = value
	_note({"key": key, "to": value, "op": "save"})
	return true


## JSON in the repo's canonical form (sorted keys, 2 spaces, LF, whole floats as ints).
static func canonical(raw: Dictionary) -> String:
	var text: String = JSON.stringify(raw, "  ", true)
	var re: RegEx = RegEx.create_from_string("(\\d)\\.0(?=[,\\n\\]}])")
	return re.sub(text, "$1", true) + "\n"


func _apply(path: PackedStringArray, table: String, v: float) -> bool:
	if table == "input_actions" and path.size() == 2 and path[0] == "move":
		actions.set(path[1], v)
		return true
	if table == "combat" and path.size() == 3 and path[0] == "weapons":
		return _apply_weapon(combat.weapon(StringName(path[1])), path[2], v)
	if table == "combat" and path.size() == 2 and path[0] in ["rivet", "human"]:
		var d: Dictionary[String, float] = combat.rivet if path[0] == "rivet" else combat.human
		d[path[1]] = v
		return true
	return false


func _apply_hooks(key: String, v: float) -> bool:
	for hook: ArenaHook in hooks:
		if hook.tune(key, v):
			return true
	return false


static func _apply_weapon(w: CombatTuning.Weapon, field: String, v: float) -> bool:
	if w == null:
		return false
	match field:
		"cooldown_s":
			w.cooldown_ticks = maxi(CombatTuning.ticks(v), 1)
		"speed_mps":
			w.speed_mps = v
		"range_m":
			w.range_m = v
		"damage":
			w.damage = v
		"spread_deg":
			w.spread_rad = deg_to_rad(v)
		_:
			return false
	return true


func _table(table: String) -> Dictionary:
	if not _tables.has(table):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(TABLES % table))
		_tables[table] = parsed if parsed is Dictionary else {}
	return _tables[table]


static func _path(key: String) -> PackedStringArray:
	return key.split(".").slice(1)


static func _walk(root: Variant, path: PackedStringArray) -> Variant:
	var at: Variant = root
	for p: String in path:
		if at is Array and p.is_valid_int():
			var a: Array = at
			if p.to_int() >= a.size():
				return null
			at = a[p.to_int()]
			continue
		var d: Dictionary = at if at is Dictionary else {}
		if not d.has(p):
			return null
		at = d[p]
	return at


func _note(entry: Dictionary) -> void:
	log.append(entry)
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(LOG_PATH.get_base_dir())
	var f: FileAccess = FileAccess.open(LOG_PATH, FileAccess.READ_WRITE)
	if f == null:
		f = FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if f != null:
		f.seek_end()
		@warning_ignore("return_value_discarded")
		f.store_line(JSON.stringify(entry, "", true))
		f.close()
