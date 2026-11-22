class_name CastCards
extends RefCounted
## Whole-figure art by archetype and camera pitch. The enabled field selects the cast in both LODs.

const TABLE: String = "res://data/tables/cast_cards.json"
const SCHEMA: String = "gtai.cast_cards/1"
static var _library: CastCards

var _by_id: Dictionary[StringName, Dictionary] = {}


class Sheets:
	extends RefCounted
	var walk: String
	var attack: String
	var stomp: String
	var hit: String
	var fall: String


static func current(id: StringName) -> Sheets:
	var mode: ViewMode = ViewMode.shared()
	return shipped().lookup(id, mode.art) if mode.cards else null


static func shipped() -> CastCards:
	if _library == null:
		_library = from_table(DataTable.open(TABLE, SCHEMA))
	return _library


static func from_table(table: DataTable) -> CastCards:
	var result: CastCards = CastCards.new()
	var entries: Dictionary = table.object(table.raw, "archetypes")
	for key: String in entries:
		var row: Dictionary = table.object(entries, key)
		if table.text(row, "id") != key or not row.get("enabled") is bool:
			Log.error("cast", "invalid cast card row %s" % key)
			return CastCards.new()
		var pitches: Dictionary[String, Sheets] = {}
		for pitch: String in ["p55", "p70"]:
			var paths: Dictionary = table.object(row, pitch)
			var sheets: Sheets = _sheets(table, paths, pitch)
			if key == "war_machine":
				sheets.stomp = RigHeadCard.ART_DIR + pitch + "/" + table.text(paths, "stomp")
			pitches[pitch] = sheets
		if row.enabled:
			result._by_id[StringName(key)] = pitches
	if not table.ok():
		Log.error("cast", "; ".join(table.errors()))
		return CastCards.new()
	return result


func lookup(id: StringName, pitch: String) -> Sheets:
	if not _by_id.has(id):
		return null
	return _by_id[id].get(pitch)


static func _sheets(table: DataTable, row: Dictionary, pitch: String) -> Sheets:
	var out: Sheets = Sheets.new()
	var dir: String = RigHeadCard.ART_DIR + pitch + "/"
	out.walk = dir + table.text(row, "armed_walk")
	out.attack = dir + table.text(row, "attack")
	out.hit = dir + table.text(row, "hit")
	out.fall = dir + table.text(row, "fall")
	return out
