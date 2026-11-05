class_name KingMoves
extends BossMoves
## King's own movement (docs/bosses/king.md). Phase 1, the procession: the throne-car keeps its
## distance down the boulevard (keep_m 12) so its ram has room. Phases 2-3 (court, on foot): he
## closes in like the default walk (keep_m 3.5), so the press slam reaches.

const CAR_KEEP_M: float = 12.0
const FOOT_KEEP_M: float = 3.5
## The throne-car's hit radius (its 6.6 x 2.5 m body, round enough for a first pass).
const CAR_RADIUS_M: float = 2.0


func _init() -> void:
	keep_m = CAR_KEEP_M


func phase_entered(f: BossFight, phase: int) -> void:
	keep_m = CAR_KEEP_M if phase == 0 else FOOT_KEEP_M
	f.body.radius_m = CAR_RADIUS_M if phase == 0 else f.spec.radius_m
