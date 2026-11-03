class_name PowerTable
extends RefCounted
## Reader for data/tables/powers.json (gtai.powers/1): the power rows, the Madness meter stub and
## each soul's own tuning block (hauler, gearbox). A missing field is a load error (ok() false).

const PATH: String = "res://data/tables/powers.json"
const SCHEMA: String = "gtai.powers/1"

var madness_max: float = 100.0
var madness_decay_per_s: float = 0.0
var rows: Dictionary[StringName, PowerDef] = {}
## The raw tuning blocks, read by HaulerTuning / GearboxTuning.
var hauler: Dictionary = {}
var gearbox: Dictionary = {}
var source: DataTable = null
var _errors: Array[String] = []


static func load_default() -> PowerTable:
	return from_table(DataTable.open(PATH, SCHEMA))


static func from_table(t: DataTable) -> PowerTable:
	var p: PowerTable = PowerTable.new()
	p.source = t
	var m: Dictionary = t.object(t.raw, "madness")
	p.madness_max = t.num(m, "max")
	p.madness_decay_per_s = t.num(m, "decay_per_s")
	for item: Variant in t.array(t.raw, "rows"):
		var r: Dictionary = item if item is Dictionary else {}
		var d: PowerDef = PowerDef.from_row(t, r)
		p.rows[d.id] = d
	p.hauler = t.object(t.raw, "hauler")
	p.gearbox = t.object(t.raw, "gearbox")
	p._errors = t.errors()
	if p.rows.is_empty():
		p._errors.append("powers.json: no rows")
	return p


func ok() -> bool:
	return _errors.is_empty()


func errors() -> Array[String]:
	return _errors.duplicate()


func row(id: StringName) -> PowerDef:
	return rows.get(id, null)
