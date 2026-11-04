class_name GhostFormTable
extends RefCounted
## Reader for data/tables/ghost_forms.json (gtai.ghost_forms/1): the four ghost forms, their cycle
## order and the form-to-form switch time. A missing field is a load error (ok() false).

const PATH: String = "res://data/tables/ghost_forms.json"
const SCHEMA: String = "gtai.ghost_forms/1"

var forms: Dictionary[StringName, GhostFormDef] = {}
## The selection cycle (G / RB steps through it).
var order: Array[StringName] = []
var switch_ticks: int = 1
var _errors: Array[String] = []


static func load_default() -> GhostFormTable:
	return from_table(DataTable.open(PATH, SCHEMA))


static func from_table(t: DataTable) -> GhostFormTable:
	var g: GhostFormTable = GhostFormTable.new()
	for item: Variant in t.array(t.raw, "forms"):
		var r: Dictionary = item if item is Dictionary else {}
		var f: GhostFormDef = GhostFormDef.from_row(t, r)
		g.forms[f.id] = f
	for id: Variant in t.array(t.raw, "order"):
		g.order.append(StringName(str(id)))
	g.switch_ticks = maxi(1, PowerDef.ticks(t.num(t.raw, "switch_s")))
	g._errors = t.errors()
	for id: StringName in g.order:
		if not g.forms.has(id):
			g._errors.append("ghost_forms.json: order names unknown form %s" % id)
	return g


func ok() -> bool:
	return _errors.is_empty()


func errors() -> Array[String]:
	return _errors.duplicate()


func form(id: StringName) -> GhostFormDef:
	return forms.get(id, null)


## The form after `id` in the cycle (wraps; the first form for an unknown id).
func next_after(id: StringName) -> StringName:
	if order.is_empty():
		return &""
	var i: int = order.find(id)
	return order[(i + 1) % order.size()]


## The form a powers.json row id runs (hauler -> tonnage, gearbox -> dent); &"" when none.
func form_of_power(power: StringName) -> StringName:
	for id: StringName in forms:
		if forms[id].power == power:
			return id
	return &""
