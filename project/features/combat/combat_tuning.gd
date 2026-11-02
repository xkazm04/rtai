class_name CombatTuning
extends RefCounted
## combat.json (gtai.combat/1) read once into typed fields, times already in ticks (SIM-01).
## Weapons are keyed by their id (`gloria`, `assault-rifle`).

const TABLE: String = "res://data/tables/combat.json"
const SCHEMA: String = "gtai.combat/1"


class Weapon:
	extends RefCounted
	var id: StringName = &""
	var burst: int = 1
	var burst_gap_ticks: int = 0
	var cooldown_ticks: int = 1
	var damage: float = 1.0
	var damage_vs_rivet: float = 0.0
	var magazine: int = 0
	var range_m: float = 20.0
	var speed_mps: float = 30.0
	var spread_rad: float = 0.0


var rivet: Dictionary[String, float] = {}
var human: Dictionary[String, float] = {}
var tazer: Dictionary[String, float] = {}
var weapons: Dictionary[StringName, Weapon] = {}
var _errors: Array[String] = []


static func shipped(path: String = TABLE) -> CombatTuning:
	var c: CombatTuning = CombatTuning.new()
	var t: DataTable = DataTable.open(path, SCHEMA)
	c.rivet = _floats(t, t.object(t.raw, "rivet"))
	c.human = _floats(t, t.object(t.raw, "human"))
	c.tazer = _floats(t, t.object(t.raw, "robo_tazer"))
	var rows: Dictionary = t.object(t.raw, "weapons")
	for id: String in rows:
		c.weapons[StringName(id)] = _weapon(t, StringName(id), t.object(rows, id))
	c._errors = t.errors()
	if not c.ok():
		Log.error("combat", str(c._errors))
	return c


static func ticks(seconds: float) -> int:
	return ceili(seconds * SimClock.TICK_RATE - SimClock.EPSILON)


func ok() -> bool:
	return _errors.is_empty()


func weapon(id: StringName) -> Weapon:
	return weapons[id]


static func _floats(t: DataTable, row: Dictionary) -> Dictionary[String, float]:
	var out: Dictionary[String, float] = {}
	for key: String in row:
		out[key] = t.num(row, key)
	return out


static func _weapon(t: DataTable, id: StringName, row: Dictionary) -> Weapon:
	var w: Weapon = Weapon.new()
	w.id = id
	w.burst = t.integer(row, "burst")
	w.burst_gap_ticks = ticks(t.num(row, "burst_gap_s"))
	w.cooldown_ticks = ticks(t.num(row, "cooldown_s"))
	w.damage = t.num(row, "damage")
	w.damage_vs_rivet = t.num(row, "damage_vs_rivet")
	w.magazine = t.integer(row, "magazine")
	w.range_m = t.num(row, "range_m")
	w.speed_mps = t.num(row, "speed_mps")
	w.spread_rad = deg_to_rad(t.num(row, "spread_deg"))
	return w
