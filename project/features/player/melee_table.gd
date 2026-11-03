class_name MeleeTable
extends RefCounted
## Rivet's bare-handed melee timing (data/tables/rivet_melee.json): the claw combo's hits as
## windup / active / recovery ticks, the cancel point and the combo window, and the charged
## shock. Read once through DataTable; a broken row is an error, never a crash.

const TABLE: String = "res://data/tables/rivet_melee.json"
const SCHEMA: String = "gtai.rivet-melee/1"

var hits: Array[MeleeHit] = []
var cancel_ticks: int = 4
var combo_window_ticks: int = 12
var shock: Dictionary = {}
var errors: Array[String] = []


static func shipped() -> MeleeTable:
	return from_table(DataTable.open(TABLE, SCHEMA))


static func from_table(t: DataTable) -> MeleeTable:
	var m: MeleeTable = MeleeTable.new()
	var claw: Dictionary = t.object(t.raw, "claw")
	m.cancel_ticks = t.integer(claw, "cancel_ticks")
	m.combo_window_ticks = t.integer(claw, "combo_window_ticks")
	for raw: Variant in t.array(claw, "hits"):
		var row: Dictionary = raw if raw is Dictionary else {}
		var h: MeleeHit = MeleeHit.new()
		h.id = StringName(t.text(row, "id"))
		h.windup = t.integer(row, "windup_ticks")
		h.active = t.integer(row, "active_ticks")
		h.recovery = t.integer(row, "recovery_ticks")
		h.reach_m = t.num(row, "reach_m")
		h.cone_dot = t.num(row, "cone_dot")
		h.damage = t.num(row, "damage")
		h.knockback_m = t.num(row, "knockback_m")
		m.hits.append(h)
	m.shock = t.object(t.raw, "shock")
	m.errors = t.errors()
	if m.hits.is_empty():
		m.errors.append("rivet_melee.json: claw.hits is empty")
	return m


func ok() -> bool:
	return errors.is_empty()
