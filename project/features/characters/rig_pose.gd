class_name RigPose
extends RefCounted
## The upper body: torso twist against the pelvis with the stride, a twist spring kicked by hits,
## shoulder sway and a run lean, the head looking toward the aim, and the clip envelopes (roll
## tuck, death sprawl, punch lean). Then both arms (RigArm).

const TWIST_K: float = 90.0


static func step(rig: CutRig, dt: float) -> void:
	var p: BodyPlan = rig.plan
	var walk01: float = clampf(rig.speed_now / CutRig.WALK_SPEED, 0.0, 1.0)
	walk01 *= (0.0 if rig.dead else 1.0) * (1.0 - rig.c_tuck)
	var ph: float = TAU * rig.phase
	var tw_amp: float = lerpf(0.07, 0.13, rig.run_blend) * walk01
	rig.twist_v += (-TWIST_K * rig.twist - 2.0 * sqrt(TWIST_K) * rig.twist_v) * dt
	rig.twist += rig.twist_v * dt
	rig.torso.rotation = tw_amp * sin(ph) + rig.twist + 0.32 * rig.c_reach
	rig.pelvis.rotation = -0.55 * tw_amp * sin(ph) + rig.twist * 0.4
	_body(rig, walk01, ph)
	_head(rig, p)
	for s: int in 2:
		RigArm.solve(rig, s, ph, walk01)


static func _body(rig: CutRig, walk01: float, ph: float) -> void:
	var sway: float = lerpf(9.0, 6.0, rig.run_blend) * walk01 * cos(ph)
	var bob: float = 1.0 + (0.018 + 0.02 * rig.run_blend) * walk01 * absf(sin(ph))
	var lean: float = 22.0 * rig.run_blend * walk01 + 40.0 * rig.c_lean
	var at: Vector2 = Vector2(lean - 25.0 * rig.c_sprawl, sway) + rig.shove
	var tuck: Vector2 = Vector2(1.0 - 0.34 * rig.c_tuck, 1.0 - 0.22 * rig.c_tuck)
	var sc: Vector2 = Vector2(bob, bob) * tuck * (1.0 + 0.06 * rig.c_sprawl)
	rig.body.transform = Transform2D(0.25 * rig.c_sprawl, sc, 0.0, at)


static func _head(rig: CutRig, p: BodyPlan) -> void:
	var look: float = 0.0
	if rig.aiming:
		var to_aim: float = (rig.aim_at - rig.global_position).angle()
		look = clampf(wrapf(to_aim - rig.facing - rig.torso.rotation, -PI, PI), -0.6, 0.6)
	var rot: float = -rig.torso.rotation * 0.75 + look * 0.8 + 0.5 * rig.c_sprawl
	var back: float = -40.0 * rig.c_tuck - 30.0 * rig.c_sprawl
	var hs: float = 1.0 - 0.18 * rig.c_tuck
	var at: Vector2 = p.head_pos - p.torso_pos + Vector2(back, 0.0)
	rig.head.transform = Transform2D(rot, Vector2(hs, hs), 0.0, at)
