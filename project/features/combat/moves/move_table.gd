class_name MoveTable
extends RefCounted
## Combat move tuning. Convert seconds to simulation ticks when loading the row.

const BLINK_BEHIND: StringName = &"kerf_blink_behind"
const SHORT_CIRCUIT: StringName = &"ohm_short_circuit"
const OVERKILL: StringName = &"overkill_carry"
const ARMOUR_CRACK: StringName = &"tonnage_armour_crack"


class Row:
	extends RefCounted
	var enabled: bool


class ShortCircuit:
	extends Row
	var stun_ticks: int
	var boss_stun_ticks: int
	var immune_ticks: int


class ArmourCrack:
	extends Row
	var open_ticks: int
	var open_front_k: float


class CarryRank:
	extends RefCounted
	var radius_m: float
	var hops: int


class Overkill:
	extends Row
	var first: CarryRank
	var second: CarryRank
	var carry_k: float
	var arc_ticks: int


var kerf_blink_behind: Row = Row.new()
var overkill_carry: Overkill = Overkill.new()
var tonnage_armour_crack: ArmourCrack = ArmourCrack.new()
var ohm_short_circuit: ShortCircuit = ShortCircuit.new()
var errors: Array[String] = []


static func shipped() -> MoveTable:
	return from_table(DataTable.open(CombatTuning.TABLE, CombatTuning.SCHEMA))


static func from_table(table: DataTable) -> MoveTable:
	var moves: MoveTable = MoveTable.new()
	var block: Dictionary = table.object(table.raw, "moves")
	moves.kerf_blink_behind.enabled = moves._enabled(
		table.object(block, BLINK_BEHIND), BLINK_BEHIND
	)
	moves._read_ohm(table, table.object(block, SHORT_CIRCUIT))
	moves._read_overkill(table, table.object(block, OVERKILL))
	moves._read_crack(table, table.object(block, ARMOUR_CRACK))
	moves.errors.append_array(table.errors())
	if not moves.errors.is_empty():
		moves.kerf_blink_behind.enabled = false
		moves.ohm_short_circuit.enabled = false
		moves.overkill_carry.enabled = false
		moves.tonnage_armour_crack.enabled = false
	return moves


func _read_ohm(table: DataTable, row: Dictionary) -> void:
	var ohm: ShortCircuit = ohm_short_circuit
	ohm.stun_ticks = CombatTuning.ticks(table.num(row, "stun_s"))
	ohm.boss_stun_ticks = CombatTuning.ticks(table.num(row, "boss_stun_s"))
	ohm.immune_ticks = CombatTuning.ticks(table.num(row, "immune_s"))
	ohm.enabled = _enabled(row, SHORT_CIRCUIT)
	if ohm.stun_ticks <= 0 or ohm.boss_stun_ticks <= 0 or ohm.immune_ticks < 0:
		errors.append("ohm_short_circuit needs positive stuns and nonnegative immunity")


func _read_crack(table: DataTable, row: Dictionary) -> void:
	var crack: ArmourCrack = tonnage_armour_crack
	crack.enabled = _enabled(row, ARMOUR_CRACK)
	crack.open_ticks = CombatTuning.ticks(table.num(row, "open_s"))
	crack.open_front_k = table.num(row, "open_front_k")
	if crack.open_ticks <= 0 or crack.open_front_k < 0.0:
		errors.append("tonnage_armour_crack needs positive duration and nonnegative multiplier")


func _read_overkill(table: DataTable, row: Dictionary) -> void:
	var carry: Overkill = overkill_carry
	carry.enabled = _enabled(row, OVERKILL)
	carry.first = _carry_rank(table, row)
	carry.second = _carry_rank(table, table.object(row, "rank_2"))
	carry.carry_k = table.num(row, "carry_k")
	carry.arc_ticks = CombatTuning.ticks(table.num(row, "arc_s"))
	if carry.carry_k <= 0.0 or carry.arc_ticks <= 0:
		errors.append("overkill_carry needs a positive carry multiplier and arc duration")


func _carry_rank(table: DataTable, row: Dictionary) -> CarryRank:
	var rank: CarryRank = CarryRank.new()
	rank.radius_m = table.num(row, "radius_m")
	var hops: float = table.num(row, "hops")
	rank.hops = roundi(hops)
	if rank.radius_m <= 0.0 or hops < 1.0 or hops != rank.hops:
		errors.append("overkill_carry needs a positive radius and positive whole hops")
	return rank


func _enabled(row: Dictionary, id: StringName) -> bool:
	if not row.get("enabled") is bool:
		errors.append("%s.enabled must be a boolean" % id)
		return false
	return row["enabled"]
