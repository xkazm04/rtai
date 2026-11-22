class_name MoveTable
extends RefCounted
## Combat move tuning. Convert seconds to simulation ticks when loading the row.

const SHORT_CIRCUIT: StringName = &"ohm_short_circuit"


class ShortCircuit:
	extends RefCounted
	var enabled: bool
	var stun_ticks: int
	var boss_stun_ticks: int
	var immune_ticks: int


var ohm_short_circuit: ShortCircuit = ShortCircuit.new()
var errors: Array[String] = []


static func shipped() -> MoveTable:
	return from_table(DataTable.open(CombatTuning.TABLE, CombatTuning.SCHEMA))


static func from_table(table: DataTable) -> MoveTable:
	var moves: MoveTable = MoveTable.new()
	var row: Dictionary = table.object(table.object(table.raw, "moves"), SHORT_CIRCUIT)
	var ohm: ShortCircuit = moves.ohm_short_circuit
	ohm.stun_ticks = CombatTuning.ticks(table.num(row, "stun_s"))
	ohm.boss_stun_ticks = CombatTuning.ticks(table.num(row, "boss_stun_s"))
	ohm.immune_ticks = CombatTuning.ticks(table.num(row, "immune_s"))
	moves.errors = table.errors()
	if not row.get("enabled") is bool:
		moves.errors.append("ohm_short_circuit.enabled must be a boolean")
	if ohm.stun_ticks <= 0 or ohm.boss_stun_ticks <= 0 or ohm.immune_ticks < 0:
		moves.errors.append("ohm_short_circuit needs positive stuns and nonnegative immunity")
	ohm.enabled = moves.errors.is_empty() and row.get("enabled") == true
	return moves
