class_name GauntletDraw
extends RefCounted
## Offer weights apply to each successive slot, without replacement. Taken rows retire for the run.

const TABLE: String = "res://data/tables/gauntlet_bonuses.json"
const SCHEMA: String = "gtai.gauntlet_bonuses/1"

var rows: Dictionary[StringName, Dictionary] = {}
var _rng: RandomNumberGenerator


func _init(registry: RngRegistry, table: DataTable = null) -> void:
	_rng = registry.stream(&"gauntlet_offers")
	if table == null:
		table = DataTable.open(TABLE, SCHEMA)
	for row: Dictionary in table.array(table.raw, "rows"):
		rows[StringName(table.text(row, "id"))] = row


func offer(wave: int, history: Array[Dictionary], held: Array[StringName]) -> Array[StringName]:
	var taken: Array[StringName] = []
	var owned: Array[StringName] = held.duplicate()
	for pick: Dictionary in history:
		var id: StringName = pick["taken"]
		taken.append(id)
		if rows.has(id) and rows[id]["kind"] != "stat":
			owned.append(StringName(str(rows[id]["ref"])))
	var pool: Array[StringName] = []
	var total: int = 0
	for id: StringName in rows:
		var row: Dictionary = rows[id]
		var first: float = row["min_wave"]
		if first > wave or taken.has(id):
			continue
		if row["kind"] != "stat" and owned.has(StringName(str(row["ref"]))):
			continue
		pool.append(id)
		total += _weight(id)
	var offered: Array[StringName] = []
	while offered.size() < 3 and not pool.is_empty():
		var ticket: int = _rng.randi_range(1, total)
		for id: StringName in pool:
			var weight: int = _weight(id)
			ticket -= weight
			if ticket <= 0:
				offered.append(id)
				total -= weight
				pool.erase(id)
				break
	return offered


func _weight(id: StringName) -> int:
	var weight: float = rows[id]["weight"]
	return roundi(weight)
