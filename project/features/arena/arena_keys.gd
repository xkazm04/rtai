class_name ArenaKeys
extends RefCounted
## The dev arena's keys (data/tables/arena_keys.json, gtai.arena-keys/1) put into the InputMap
## with the gameplay actions' row format (PlayerActions.events_of). They never enter TickInput.

const TABLE: String = "res://data/tables/arena_keys.json"
const SCHEMA: String = "gtai.arena-keys/1"


## Registers every row; returns the action ids registered.
static func install(path: String = TABLE) -> Array[StringName]:
	var t: DataTable = DataTable.open(path, SCHEMA)
	var ids: Array[StringName] = []
	for v: Variant in t.array(t.raw, "rows"):
		var row: Dictionary = v if v is Dictionary else {}
		var id: StringName = StringName(t.text(row, "id"))
		if InputMap.has_action(id):
			InputMap.erase_action(id)
		InputMap.add_action(id)
		for ev: InputEvent in PlayerActions.events_of(row):
			InputMap.action_add_event(id, ev)
		ids.append(id)
	if not t.ok():
		Log.warn("arena", "arena keys: %s" % [t.errors()])
	return ids
