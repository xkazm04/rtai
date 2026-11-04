class_name RigPose
extends RefCounted
## The upper body: torso twist against the pelvis with the stride plus the twist spring (stepped in
## RigSprings, kicked by hits), shoulder sway and a run lean, the head looking toward the aim, and
## the clip envelopes (roll tuck, death sprawl, punch lean). Then both arms (RigArm).

const SPRINT_LEAN_PX: float = 30.0
## rivet-motion: the tackle read. At the sprint top the torso turns this far (rad) so the claw
## shoulder leads, and the stride's torso swing drops by SPRINT_SWING_CUT (a braced shoulder).
const SHOULDER_LEAD: float = 0.5
const SPRINT_SWING_CUT: float = 0.6


static func step(rig: CutRig) -> void:
	var p: BodyPlan = rig.plan
	var walk01: float = clampf(rig.speed_now / CutRig.WALK_SPEED, 0.0, 1.0)
	walk01 *= (0.0 if rig.dead else 1.0) * (1.0 - rig.c_tuck)
	var ph: float = TAU * rig.phase
	var s01: float = sprint01(rig) * walk01
	var tw_amp: float = lerpf(0.07, 0.13, rig.run_blend) * walk01
	tw_amp *= 1.0 - SPRINT_SWING_CUT * s01
	var reach_tw: float = 0.32 * rig.c_reach * (-1.0 if rig.strike_arm == BodyPlan.R else 1.0)
	reach_tw *= 0.0 if rig.strike_arm == 2 else 1.0
	rig.torso.rotation = tw_amp * sin(ph) + rig.twist + reach_tw + SHOULDER_LEAD * s01
	rig.pelvis.rotation = -0.55 * tw_amp * sin(ph) + rig.twist * 0.4 + rig.hip_yaw
	_body(rig, walk01, ph)
	_head(rig, p)
	for s: int in 2:
		RigArm.solve(rig, s, ph, walk01)


static func _body(rig: CutRig, walk01: float, ph: float) -> void:
	var sway: float = lerpf(9.0, 6.0, rig.run_blend) * walk01 * cos(ph)
	var bob: float = 1.0 + (0.018 + 0.02 * rig.run_blend) * walk01 * absf(sin(ph))
	var lean: float = 22.0 * rig.run_blend * walk01 + 40.0 * rig.c_lean
	lean += SPRINT_LEAN_PX * sprint01(rig)
	var at: Vector2 = Vector2(lean - 25.0 * rig.c_sprawl, sway) + rig.shove
	var tuck: Vector2 = Vector2(1.0 - 0.34 * rig.c_tuck, 1.0 - 0.22 * rig.c_tuck)
	var sc: Vector2 = Vector2(bob, bob) * tuck * (1.0 + 0.06 * rig.c_sprawl)
	rig.body.transform = Transform2D(0.25 * rig.c_sprawl * (1.0 - rig.c_plank), sc, 0.0, at)


## rivet-motion: how far into the sprint a plan with a sprint stride is (0 at the run speed,
## 5 m/s, 1 at the sprint top, 6.2 m/s; both x plan.speed_k); 0 for everyone else. Drives the
## lean and the shoulder.
static func sprint01(rig: CutRig) -> float:
	if rig.plan.sprint_stride <= 0.0:
		return 0.0
	var k: float = rig.plan.speed_k
	return smoothstep(CutRig.RUN_SPEED * k, RigGait.SPRINT_SPEED * k, rig.speed_now)


static func _head(rig: CutRig, p: BodyPlan) -> void:
	var look: float = 0.0
	if rig.aiming:
		var to_aim: float = (rig.aim_at - rig.global_position).angle()
		look = clampf(wrapf(to_aim - rig.facing - rig.torso.rotation, -PI, PI), -0.6, 0.6)
	var rot: float = (
		-rig.torso.rotation * 0.75 + look * 0.8 + 0.5 * rig.c_sprawl * (1.0 - rig.c_plank)
	)
	var back: float = -40.0 * rig.c_tuck - 30.0 * rig.c_sprawl
	var hs: float = (1.0 - 0.18 * rig.c_tuck) * p.head_k
	var at: Vector2 = p.head_pos - p.torso_pos + Vector2(back, RigGrip.head_lean(rig))
	rig.head.transform = Transform2D(rot, Vector2(hs, hs), 0.0, at)
