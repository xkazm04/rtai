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
## story_voice: the shipped story (quest 1's sprite cast) shows the teal apparition on a whisper.
var story_voice: bool = false
## story_forms: the shipped story's sprite cast draws the ghost bodies, the morph and the HUD card.
var story_forms: bool = false
## story_lift: the shipped story's camera lifts a big form clear of the subtitle box (view only).
var story_lift: bool = false
var transform_unlocked: bool = false
var story_transform: bool = false
var bond_enabled: bool = false
var master_at: float
var per_kill: float
var per_stun: float
var per_boss_cut: float
var mastery_free: bool = false
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
	g.story_voice = t.raw.get("story_voice", false) == true
	g.story_forms = t.raw.get("story_forms", false) == true
	g.story_lift = t.raw.get("story_lift", false) == true
	g.transform_unlocked = t.raw.get("transform_unlocked", false) == true
	g.story_transform = t.raw.get("story_transform", false) == true
	var bond: Dictionary = t.object(t.raw, "bond")
	g.bond_enabled = bond.get("enabled") == true
	g.master_at = t.num(bond, "master_at")
	g.per_kill = t.num(bond, "per_kill")
	g.per_stun = t.num(bond, "per_stun")
	g.per_boss_cut = t.num(bond, "per_boss_cut")
	g.mastery_free = bond.get("mastery_free") == true
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


## The global/story override keeps its original selection. Earned T follows release order.
func transform_target(selected: StringName, bond: GhostBond, unrestricted: bool) -> StringName:
	return selected if unrestricted else bond.last_deployed_mastered()


func next_transform(id: StringName, locks: GhostLocks, bond: GhostBond) -> StringName:
	var candidate: StringName = id
	for _i: int in order.size():
		candidate = locks.next_after(self, candidate)
		if bond.mastered(candidate):
			return candidate
	return id


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
