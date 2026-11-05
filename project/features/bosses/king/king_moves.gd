class_name KingMoves
extends BossMoves
## King's own movement (docs/bosses/king.md). Phase 1, the procession: the throne-car keeps its
## distance down the boulevard (keep_m 12) so its ram has room. Phases 2-3 (court, on foot): he
## closes in like the default walk (keep_m 3.5), so the press slam reaches.

const CAR_KEEP_M: float = 12.0
const FOOT_KEEP_M: float = 3.5


func _init() -> void:
	keep_m = CAR_KEEP_M


func phase_entered(_f: BossFight, phase: int) -> void:
	keep_m = CAR_KEEP_M if phase == 0 else FOOT_KEEP_M
