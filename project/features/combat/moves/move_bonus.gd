class_name MoveBonus
extends RefCounted
## A distinct card ref per rank doubles as the localization suffix.

const OVERKILL_2: StringName = &"overkill_carry_2"


static func offerable(row: Dictionary, taken: Array[StringName], moves: MoveTable) -> bool:
	var required: StringName = row.get("requires", &"")
	if required != &"" and not taken.has(required):
		return false
	if row["kind"] != "effect":
		return true
	var ref: StringName = row["ref"]
	return moves.overkill_carry.enabled and _rank(ref) > 0


static func apply(stage: ArenaStage, row: Dictionary) -> bool:
	var ref: StringName = row["ref"]
	return MoveCarry.grant(stage, _rank(ref))


static func _rank(ref: StringName) -> int:
	match ref:
		MoveTable.OVERKILL:
			return 1
		OVERKILL_2:
			return 2
	return 0
