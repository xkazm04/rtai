class_name KingMoves
extends BossMoves
## King's own movement (docs/bosses/king.md). Phase 1, the procession: the throne-car keeps its
## distance down the boulevard (keep_m 12) so its ram has room. Phase 2 (the court): the car has
## stalled and King rules from it. Phase 3 (on foot): he closes in (keep_m 3.5) so the slam reaches.

const CAR_KEEP_M: float = 12.0
const FOOT_KEEP_M: float = 3.5
## Phase 2, the court: the car has stalled, King rules from it (he never walks).
const STALLED_KEEP_M: float = 1000.0
## The throne-car's hit radius (its 6.6 x 2.5 m body, round enough for a first pass).
const CAR_RADIUS_M: float = 2.0
## Phase 3: King steps down off the car's right side this far; the car stays where it stalled.
const STEP_DOWN_M: float = 2.4

## Where the stalled car rests from phase 3 on (KingBodyView draws the wreck there).
var car_at: Vector2 = Vector2.INF
var car_facing: Vector2 = Vector2.RIGHT
## The way the car points once it stalls (the court): it no longer turns, only its cannon does.
var stall_facing: Vector2 = Vector2.INF


func _init() -> void:
	keep_m = CAR_KEEP_M


func phase_entered(f: BossFight, phase: int) -> void:
	keep_m = [CAR_KEEP_M, STALLED_KEEP_M, FOOT_KEEP_M][mini(phase, 2)]
	f.body.radius_m = CAR_RADIUS_M if phase <= 1 else f.spec.radius_m
	if phase == 1 and stall_facing == Vector2.INF:
		stall_facing = f.body.facing
	if phase >= 2 and car_at == Vector2.INF:
		car_at = f.body.pos
		car_facing = stall_facing if stall_facing != Vector2.INF else f.body.facing
		f.body.pos += step_down(car_facing)


## The step-down offset from the car's centre (the throne's right-hand side).
static func step_down(facing: Vector2) -> Vector2:
	return facing.orthogonal() * STEP_DOWN_M + facing * KingRigs.THRONE_M
