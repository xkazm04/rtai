class_name RigHips
extends RefCounted
## Twin-stick hips (rivet-motion, 2026-11-03 eve): the rig's root faces the aim (the torso and
## arms follow it), the hips turn toward the walk direction, folded so a backpedal keeps the hips
## forward and walks the legs backwards, clamped to the plan's twist limit and springed. RigPose
## adds `hip_yaw` to the pelvis; RigGait swings the hips and bends the knees along it. A plan with
## `hip_follow` 0 (cops, peds: they walk where they face) never moves it.

## Beyond this angle between walk and aim the move is a backpedal, not a turn of the hips.
const BACKPEDAL_RAD: float = deg_to_rad(105.0)
const SPRING_K: float = 140.0
## Below this ground speed (world px/s) the hips settle back onto the aim.
const MOVE_PX_S: float = 6.0
const FULL_PX_S: float = 40.0


static func step(rig: CutRig, dt: float) -> void:
	var p: BodyPlan = rig.plan
	if p.hip_follow <= 0.0 and rig.hip_yaw == 0.0:
		return
	var want: float = target(rig.vel_in, rig.facing, p) if not rig.dead else 0.0
	var k: float = SPRING_K
	rig.hip_yaw_v += (k * (want - rig.hip_yaw) - 2.0 * sqrt(k) * rig.hip_yaw_v) * dt
	rig.hip_yaw += rig.hip_yaw_v * dt


## The hips' yaw against the facing (radians) for a walk velocity; 0 when standing.
static func target(vel: Vector2, facing: float, p: BodyPlan) -> float:
	var spd: float = vel.length()
	if spd < MOVE_PX_S or p.hip_follow <= 0.0:
		return 0.0
	var rel: float = wrapf(vel.angle() - facing, -PI, PI)
	if absf(rel) > BACKPEDAL_RAD:
		rel = wrapf(rel + PI, -PI, PI)
	rel = clampf(rel, -p.hip_twist_max, p.hip_twist_max)
	return rel * p.hip_follow * smoothstep(MOVE_PX_S, FULL_PX_S, spd)
