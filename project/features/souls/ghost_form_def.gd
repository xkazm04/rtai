class_name GhostFormDef
extends RefCounted
## One row of data/tables/ghost_forms.json (gtai.ghost_forms/1): a ghost form's body, locomotion,
## transformation timings and attack anchors. Seconds become whole sim ticks here, once.

var id: StringName = &""
## The cost row in powers.json (tonnage -> hauler, dent -> gearbox: the old ids as aliases).
var power: StringName = &""
var name_key: String = ""
var body_class: StringName = &""
var gait: StringName = &""
var radius_m: float = 0.0
var size_k: float = 1.0
var top_mps: float = 0.0
var accel_mps2: float = 0.0
var turn_dps: float = 0.0
var enter_ticks: int = 1
var exit_ticks: int = 1
var upgrade_tier: int = 0
## Attack emit points, metres in the body frame (+x forward, +y right).
var anchors: Dictionary[StringName, Vector2] = {}


static func from_row(t: DataTable, r: Dictionary) -> GhostFormDef:
	var f: GhostFormDef = GhostFormDef.new()
	f.id = StringName(t.text(r, "id"))
	f.power = StringName(t.text(r, "power"))
	f.name_key = t.text(r, "name_key")
	f.body_class = StringName(t.text(r, "body_class"))
	f.gait = StringName(t.text(r, "gait"))
	f.radius_m = t.num(r, "radius_m")
	f.size_k = t.num(r, "size_k")
	f.top_mps = t.num(r, "top_mps")
	f.accel_mps2 = t.num(r, "accel_mps2")
	f.turn_dps = t.num(r, "turn_dps")
	f.enter_ticks = maxi(1, PowerDef.ticks(t.num(r, "enter_s")))
	f.exit_ticks = maxi(1, PowerDef.ticks(t.num(r, "exit_s")))
	f.upgrade_tier = t.integer(r, "upgrade_tier")
	var a: Dictionary = t.object(r, "anchors")
	for key: Variant in a.keys():
		f.anchors[StringName(str(key))] = t.vec(a, str(key))
	return f


## The anchor in the body frame (Vector2.ZERO when the form has no such anchor).
func anchor(key: StringName) -> Vector2:
	return anchors.get(key, Vector2.ZERO)
