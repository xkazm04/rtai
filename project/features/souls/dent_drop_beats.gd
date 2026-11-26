class_name DentDropBeats
extends RefCounted
## n31 ghost 17: Dent's drop deploy drawn in beats (P = press, R = the ram tick, P + charge).
## He faces along the lane (DentLane) and waits at its origin, Rivet's side:
## - arrival: P..P+3 HOVER at the origin;
## - wind-up: P+4..R-7 COCK, pulled back RECOIL_M along the lane over 8 ticks;
## - ram: R-6..R-1 DIVE, from the pulled-back point to the spot (ease-out quad), so the body meets
##   the cops on R, the tick the sim's ram lands (n31 ghost 25: the hit no longer leads him);
## - stop: R.. JAB held at the spot until the deploy's fade.

const ARRIVE_TICKS: int = 4
const DIVE_TICKS: int = 6
const RECOIL_M: float = 0.3
const RECOIL_TICKS: float = 8.0


## Where the body stands (m) `age` ticks after the press; `struck` = ticks since R (< 0 before).
static func at(ghost: GhostDeploy, age: int, struck: int) -> Vector2:
	var dir: Vector2 = ghost.origin.direction_to(ghost.spot)
	if struck < -DIVE_TICKS:
		return ghost.origin - dir * RECOIL_M * smoothstep(0.0, RECOIL_TICKS, float(age))
	return dive(ghost.origin, ghost.spot, struck)


## The diving body (m) `struck` ticks after R: from the pulled-back point on R-DIVE_TICKS to the
## spot on R, ease-out quad (n31 ghost 18b: the dust wake's head follows it too).
static func dive(origin: Vector2, spot: Vector2, struck: int) -> Vector2:
	var launch: Vector2 = origin - origin.direction_to(spot) * RECOIL_M
	var u: float = clampf(float(struck + DIVE_TICKS) / DIVE_TICKS, 0.0, 1.0)
	return launch.lerp(spot, 1.0 - (1.0 - u) * (1.0 - u))


## The shipped spectral cell (DentSpectralDrawn.Pose) for the beat.
static func pose(age: int, struck: int) -> DentSpectralDrawn.Pose:
	if struck >= 0:
		return DentSpectralDrawn.Pose.JAB
	if struck >= -DIVE_TICKS:
		return DentSpectralDrawn.Pose.DIVE
	return DentSpectralDrawn.Pose.COCK if age >= ARRIVE_TICKS else DentSpectralDrawn.Pose.HOVER


## The deploy's cell for DentBody.deploy_pose: the drop beats, or the hold mode's JAB once the
## strike has landed (-1 before it: the flight's own pose).
static func cell(drops: bool, age: int, struck: int) -> int:
	if drops:
		return pose(age, struck)
	return DentSpectralDrawn.Pose.JAB if struck >= 0 else -1
