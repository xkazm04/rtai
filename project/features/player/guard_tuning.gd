class_name GuardTuning
extends RefCounted
## Guard meter, movement and facing limits from combat.json. Durations are in seconds.

var arc_deg: float
var move_k: float
var meter_max: float
var drain_per_round: float
var refill_per_s: float
var refill_delay_s: float
var stagger_s: float
var melee_drain: float


static func load_table() -> GuardTuning:
	var t: DataTable = DataTable.open(CombatTuning.TABLE, CombatTuning.SCHEMA)
	var row: Dictionary = t.object(t.raw, "guard")
	var g: GuardTuning = GuardTuning.new()
	g.arc_deg = t.num(row, "arc_deg")
	g.move_k = t.num(row, "move_k")
	g.meter_max = t.num(row, "meter_max")
	g.drain_per_round = t.num(row, "drain_per_round")
	g.refill_per_s = t.num(row, "refill_per_s")
	g.refill_delay_s = t.num(row, "refill_delay_s")
	g.stagger_s = t.num(row, "stagger_s")
	g.melee_drain = t.num(row, "melee_drain")
	if not t.ok():
		Log.error("guard", str(t.errors()))
	return g
