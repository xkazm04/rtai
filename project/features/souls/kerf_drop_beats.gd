class_name KerfDropBeats
extends RefCounted
## n31 ghost 21: Kerf's drop deploy drawn in beats (P = press, C = the cut tick, P + charge).
## He arrives at Rivet's side (KerfDrop) and faces the locked target, following it:
## - arrival: P..P+3 HOVER at the origin;
## - wind-up: P+4..C-1 COCK, pulled back RECOIL_M from the target over 8 ticks, the sighting
##   line (KerfSightLine) growing to the target by C-3;
## - cut: C blinks to the rear spot; C..C+7 CUT, C+8..C+15 RECOVER, then HOVER to the fade.

const ARRIVE_TICKS: int = 4
const RECOIL_M: float = 0.2
const RECOIL_TICKS: float = 8.0
## The sighting line is full this many ticks before the cut.
const SIGHT_FULL_BEFORE: int = 3


## Where the body stands (m) `age` ticks after the press; `struck` = ticks since C (< 0 before).
static func at(ghost: GhostDeploy, age: int, struck: int) -> Vector2:
	if struck >= 0:
		return ghost.spot
	var dir: Vector2 = ghost.origin.direction_to(aim_point(ghost))
	return ghost.origin - dir * RECOIL_M * smoothstep(0.0, RECOIL_TICKS, float(age))


## What he faces through the wind-up: the locked target's live position (else his facing).
static func aim_point(ghost: GhostDeploy) -> Vector2:
	var foe: Fighter = ghost.dump.kerf.target
	if foe != null and foe.pos != ghost.origin:
		return foe.pos
	return ghost.origin + ghost.facing


## The body's yaw: toward the live target before the cut, then the strike's facing (rear -> it).
static func yaw(ghost: GhostDeploy, struck: int) -> float:
	if struck >= 0:
		return ghost.facing.angle()
	return ghost.origin.angle_to_point(aim_point(ghost))


## The shipped spectral cell (KerfRoninDrawn.Pose) for the beat.
static func pose(age: int, struck: int) -> KerfRoninDrawn.Pose:
	if struck >= 0:
		return KerfSpectral.blink_pose(struck, true)
	return KerfRoninDrawn.Pose.COCK if age >= ARRIVE_TICKS else KerfRoninDrawn.Pose.HOVER


## The deploy's cell for KerfRig.deploy_pose: the drop beats, or the hold mode's strike pose
## on its clamped age (`drawn_age`, -1 before the strike = HOVER).
static func cell(drops: bool, age: int, struck: int, drawn_age: int) -> KerfRoninDrawn.Pose:
	if drops:
		return pose(age, struck)
	return KerfSpectral.blink_pose(drawn_age, true)


## The sighting line's grown share (0..1, ease-out) over the wind-up; 0 from the cut on.
static func sight_k(age: int, charge: int) -> float:
	if age >= charge:
		return 0.0
	var u: float = clampf(float(age) / maxf(1.0, charge - SIGHT_FULL_BEFORE), 0.0, 1.0)
	return 1.0 - (1.0 - u) * (1.0 - u)
