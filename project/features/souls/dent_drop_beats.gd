class_name DentDropBeats
extends RefCounted
## n31 ghost 17: Dent's drop deploy drawn in beats (P = press, R = the ram tick, P + charge).
## He faces along the lane (DentLane) and waits at its origin, Rivet's side:
## - arrival: P..P+3 HOVER at the origin;
## - wind-up: P+4..R-1 COCK, pulled back RECOIL_M along the lane over 8 ticks;
## - ram: R..R+7 DIVE, from the pulled-back point to the spot (ease-out quad: the shove lands on R);
## - stop: R+8.. JAB held at the spot until the deploy's fade.

const ARRIVE_TICKS: int = 4
const RAM_TICKS: int = 8
const RECOIL_M: float = 0.3
const RECOIL_TICKS: float = 8.0


## Where the body stands (m) `age` ticks after the press; `struck` = ticks since R (< 0 before).
static func at(ghost: GhostDeploy, age: int, struck: int) -> Vector2:
	var dir: Vector2 = ghost.origin.direction_to(ghost.spot)
	if struck < 0:
		return ghost.origin - dir * RECOIL_M * smoothstep(0.0, RECOIL_TICKS, float(age))
	var u: float = clampf(float(struck) / RAM_TICKS, 0.0, 1.0)
	return (ghost.origin - dir * RECOIL_M).lerp(ghost.spot, 1.0 - (1.0 - u) * (1.0 - u))


## The shipped spectral cell (DentSpectralDrawn.Pose) for the beat.
static func pose(age: int, struck: int) -> DentSpectralDrawn.Pose:
	if struck >= RAM_TICKS:
		return DentSpectralDrawn.Pose.JAB
	if struck >= 0:
		return DentSpectralDrawn.Pose.DIVE
	return DentSpectralDrawn.Pose.COCK if age >= ARRIVE_TICKS else DentSpectralDrawn.Pose.HOVER


## The deploy's cell for DentBody.deploy_pose: the drop beats, or the hold mode's JAB once the
## strike has landed (-1 before it: the flight's own pose).
static func cell(drops: bool, age: int, struck: int) -> int:
	if drops:
		return pose(age, struck)
	return DentSpectralDrawn.Pose.JAB if struck >= 0 else -1
