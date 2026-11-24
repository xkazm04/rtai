class_name GauntletDraw
extends RefCounted
## Offer weights apply to each successive slot, without replacement. Taken rows retire for the run.

const TABLE: String = "res://data/tables/gauntlet_bonuses.json"
const SCHEMA: String = "gtai.gauntlet_bonuses/1"

var rows: Dictionary[StringName, Dictionary] = {}
var moves: MoveTable = MoveTable.shipped()
var _rng: RandomNumberGenerator


func _init(registry: RngRegistry, table: DataTable = null) -> void:
	_rng = registry.stream(&"gauntlet_offers")
	if table == null:
		table = DataTable.open(TABLE, SCHEMA)
	for row: Dictionary in table.array(table.raw, "rows"):
		rows[StringName(table.text(row, "id"))] = row


func offer(wave: int, history: Array[Dictionary], held: Array[StringName]) -> Array[StringName]:
	var pool: Array[StringName] = _eligible(wave, history, held)
	var offered: Array[StringName] = _reserve_mastery(pool, history)
	var total: int = 0
	for id: StringName in pool:
		total += _weight(id)
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


## Full bonds reserve slots in the normal three-card hand. If all four are ready,
## show an unseen bond before one the player already passed over.
func _reserve_mastery(pool: Array[StringName], history: Array[Dictionary]) -> Array[StringName]:
	var ready: Array[StringName] = []
	for id: StringName in pool:
		if rows[id]["kind"] == "mastery":
			ready.append(id)
	for id: StringName in ready:
		pool.erase(id)
	if ready.size() > 3:
		for pick: Dictionary in history:
			for id: StringName in pick.get("offered", []):
				if ready.has(id):
					ready.erase(id)
					ready.append(id)
		return ready.slice(0, 3)
	return ready


## Eligibility only grows with wave number. Taking any eligible grant retires one grant,
## including its weapon/ghost aliases. Count future offers without spending a random ticket.
func offer_count(first: int, last: int, history: Array[Dictionary], held: Array[StringName]) -> int:
	var projected: Array[Dictionary] = history.duplicate()
	for wave: int in range(first, last + 1):
		var pool: Array[StringName] = _eligible(wave, projected, held)
		if not pool.is_empty():
			projected.append({"taken": pool[0]})
	return projected.size() - history.size()


func _eligible(wave: int, history: Array[Dictionary], held: Array[StringName]) -> Array[StringName]:
	var taken: Array[StringName] = []
	var owned: Array[StringName] = held.duplicate()
	for pick: Dictionary in history:
		var id: StringName = pick["taken"]
		taken.append(id)
		if rows.has(id) and rows[id]["kind"] != "stat":
			owned.append(StringName(str(rows[id]["ref"])))
	var pool: Array[StringName] = []
	for id: StringName in rows:
		var row: Dictionary = rows[id]
		var first: float = row["min_wave"]
		if first > wave or taken.has(id) or not MoveBonus.offerable(row, taken, moves):
			continue
		if row["kind"] == "mastery":
			if held.has(id):
				pool.append(id)
			continue
		if row["kind"] != "stat" and owned.has(StringName(str(row["ref"]))):
			continue
		pool.append(id)
	return pool


func _weight(id: StringName) -> int:
	var weight: float = rows[id]["weight"]
	return roundi(weight)
