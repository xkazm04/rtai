class_name RigGait
extends RefCounted
## The procedural gait: a speed-driven phase swings each foot to a planted world point ahead of
## its hip; standing, a stray foot takes a short timed step back under the hip. Legs are a
## three-bone chain solved in 3D (hip height = hip_z) and projected to the ground, so a lifted
## foot shortens the leg seen from above. Roll tucks the feet in, death sprawls them out.

const STAND_STEP_S: float = 0.16
const LIFT_PX: float = 45.0
## rivet-motion: the sprint's top (PlayerMotion sprint_mps 6.2 at 32 px/m): sprint_stride is full.
## A plan's speed_k scales it (Rivet 1.5: his 9.3 m/s sprint top since 2026-11-04).
const SPRINT_SPEED: float = 198.0
## rivet-arsenal: the stride share of a full backpedal (see backpedal_scale).
const BACKPEDAL_STRIDE: float = 0.55
## rivet-arsenal: the planted foot's longest trail behind its hip, in half-stances (see _cap_trail).
const TRAIL_K: float = 1.2
## human-reactions: the stiff corpse's feet this far (part px) along the facing, on the side
## CutRig.plank_feet names (-340 behind was the only layout before).
const PLANK_FEET_PX: float = 340.0


static func step(rig: CutRig, dt: float) -> void:
	var p: BodyPlan = rig.plan
	var spd: float = rig.speed_now
	var k: float = p.speed_k
	rig.run_blend = smoothstep(CutRig.WALK_SPEED * 1.1 * k, CutRig.RUN_SPEED * 0.95 * k, spd)
	var stride: float = lerpf(CutRig.STRIDE_WALK, CutRig.STRIDE_RUN, rig.run_blend) * p.gait_scale
	if p.sprint_stride > 0.0:
		stride *= 1.0 + p.sprint_stride * smoothstep(CutRig.RUN_SPEED * k, SPRINT_SPEED * k, spd)
	stride *= backpedal_scale(rig) * RigGrip.walk(rig).x  # d7-held: the held class's stride
	var moving: bool = spd > 6.0 and not rig.dead and rig.c_tuck < 0.3
	if moving:
		rig.phase += spd * dt / stride
	rig.xf = rig.global_transform
	rig.xf_inv = rig.xf.affine_inverse()
	var foot_fwd: Vector2 = rig.fwd() * p.foot_fwd * CutRig.SC
	for s: int in 2:
		var side: RigLimbs = rig.sides[s]
		var hl: Vector2 = rig.hip_local(s)
		var hw: Vector2 = rig.xf * hl
		if moving:
			_swing(rig, side, s, hw, stride)
		else:
			_stand(rig, side, rig.sides[1 - s], hw + foot_fwd, dt)
		_clip_feet(rig, side, s, hw, dt)
		_solve_leg(rig, side, s, hl)


## rivet-arsenal: a twin-stick plan (hip_follow > 0) walking away from its aim shuffles: the
## stride shrinks to BACKPEDAL_STRIDE as the walk turns against the facing, so the trailing foot
## no longer reaches out past the shoulder (at stride 1.3 it read as a flung arm at 64 px/m).
static func backpedal_scale(rig: CutRig) -> float:
	if rig.plan.hip_follow <= 0.0 or rig.vel_in.length() < 0.01:
		return 1.0
	var back01: float = clampf(-rig.vel_in.normalized().dot(rig.fwd()), 0.0, 1.0)
	return lerpf(1.0, BACKPEDAL_STRIDE, smoothstep(0.0, 0.7, back01))


static func _swing(rig: CutRig, side: RigLimbs, s: int, hw: Vector2, stride: float) -> void:
	var swing_frac: float = lerpf(0.42, 0.62, rig.run_blend)
	var vdir: Vector2 = rig.vel_in.normalized() if rig.speed_now > 0.01 else rig.fwd()
	var ph: float = fposmod(rig.phase + (0.0 if s == BodyPlan.L else 0.5), 1.0)
	if ph >= swing_frac:
		side.stepping = false
		side.lift = 0.0
		_cap_trail(rig, side, hw, (1.0 - swing_frac) * stride)
		return
	if not side.stepping or side.timed:
		side.stepping = true
		side.timed = false
		side.foot_from = side.foot_w
	var s01: float = ph / swing_frac
	var ext: float = (1.0 - swing_frac) * stride * 0.5
	var target: Vector2 = hw + vdir * ((swing_frac - ph) * stride + ext)
	side.foot_w = side.foot_from.lerp(target, smoothstep(0.0, 1.0, s01))
	side.lift = sin(PI * s01)


## rivet-arsenal: a twin-stick plan's planted foot never trails its hip by more than TRAIL_K of
## half the stance (a normal step ends at 0.5): slowing out of a run or turning a strafe left the
## old long-stride foot far out behind, and at 64 px/m it read as a flung arm. It slides instead.
static func _cap_trail(rig: CutRig, side: RigLimbs, hw: Vector2, stance: float) -> void:
	if rig.plan.hip_follow <= 0.0:
		return
	var trail: Vector2 = side.foot_w - hw
	var cap: float = TRAIL_K * 0.5 * stance
	if trail.length() > cap:
		side.foot_w = hw + trail.normalized() * cap


static func _stand(rig: CutRig, side: RigLimbs, other: RigLimbs, rest: Vector2, dt: float) -> void:
	if side.stepping and not side.timed:
		side.timed = true
		side.step_t = 0.0
		side.foot_from = side.foot_w
	var stray: bool = side.foot_w.distance_to(rest) > 2.5
	if not side.stepping and not other.stepping and stray and not rig.dead:
		side.stepping = true
		side.timed = true
		side.step_t = 0.0
		side.foot_from = side.foot_w
	if side.stepping and side.timed:
		side.step_t += dt / STAND_STEP_S
		var k: float = minf(side.step_t, 1.0)
		side.foot_w = side.foot_from.lerp(rest, smoothstep(0.0, 1.0, k))
		side.lift = sin(PI * k) * 0.6
		if k >= 1.0:
			side.stepping = false
			side.timed = false
			side.lift = 0.0


static func _clip_feet(rig: CutRig, side: RigLimbs, s: int, hw: Vector2, dt: float) -> void:
	if rig.c_sprawl > 0.0:
		var wide: float = lerpf(230.0, 55.0, rig.c_plank)
		var from: float = -210.0 if rig.plank_feet < 0.0 else 0.0  # ahead: from under the hips
		var back: float = lerpf(from, PLANK_FEET_PX * rig.plank_feet, rig.c_plank)
		var spread: Vector2 = rig.xf * Vector2(back, rig.plan.side_sign(s) * wide)
		side.foot_w = side.foot_w.lerp(spread, minf(rig.c_sprawl * dt * 8.0, 1.0))
		side.lift = 0.0
	if rig.c_tuck > 0.0:
		side.foot_w = side.foot_w.lerp(hw, minf(rig.c_tuck, 1.0))


static func _solve_leg(rig: CutRig, side: RigLimbs, s: int, hl: Vector2) -> void:
	var p: BodyPlan = rig.plan
	var fl: Vector2 = rig.xf_inv * side.foot_w
	var lift: float = side.lift
	if s == BodyPlan.R and rig.c_kick > 0.0:
		var reach: Vector2 = Vector2(p.thigh_len + p.shin_len, 0) * 0.95
		fl = fl.lerp(rig.hip_local(BodyPlan.R) + reach, rig.c_kick)
		lift = maxf(lift, 0.5 * rig.c_kick)
	var hz: float = p.hip_z * (1.0 - 0.75 * rig.c_sprawl) * (1.0 - 0.35 * rig.c_tuck)
	var pole2: Vector2 = Vector2(1.0, p.side_sign(s) * 0.25).rotated(rig.hip_yaw)
	var pole: Vector3 = Vector3(pole2.x, pole2.y, 0.0)
	var hip3: Vector3 = Vector3(hl.x, hl.y, hz)
	var knee3: Vector3 = ik3(
		hip3, Vector3(fl.x, fl.y, lift * LIFT_PX), p.thigh_len, p.shin_len, pole
	)
	var knee: Vector2 = Vector2(knee3.x, knee3.y)
	place(side.thigh, hl, knee, p.thigh_draw)
	place(side.shin, knee, fl, p.shin_draw)
	if p.leg_w != 1.0:
		side.thigh.scale.y = p.leg_w
		side.shin.scale.y = p.leg_w
	var fs: float = (1.0 + 0.08 * lift) * p.foot_k
	var splay: float = p.side_sign(s) * 0.8 * rig.c_sprawl * (1.0 - 0.8 * rig.c_plank)
	side.foot.transform = Transform2D(splay, Vector2(fs, fs), 0.0, fl)
	if p.has_toeoff():
		var cell: String = p.foot_toeoff[s] if lift > 0.12 else p.foot_part[s]
		if cell != side.foot_cell:
			side.foot_cell = cell
			rig.set_part_tex(side.foot, cell)


## Two-bone IK in 3D: the joint between root and target, bent toward the pole.
static func ik3(root: Vector3, target: Vector3, l1: float, l2: float, pole: Vector3) -> Vector3:
	var dv: Vector3 = target - root
	var d: float = clampf(dv.length(), absf(l1 - l2) + 0.01, l1 + l2 - 0.01)
	var u: Vector3 = dv.normalized() if dv.length() > 0.001 else Vector3(1, 0, 0)
	var a: float = (l1 * l1 - l2 * l2 + d * d) / (2.0 * d)
	var h: float = sqrt(maxf(l1 * l1 - a * a, 0.0))
	var v: Vector3 = pole - u * pole.dot(u)
	v = v.normalized() if v.length() > 0.001 else Vector3(0, 0, 1)
	return root + u * a + v * h


## A rigid part from joint a to joint b, stretched along x to the drawn length.
static func place(spr: Sprite2D, a: Vector2, b: Vector2, native_len: float) -> void:
	var d: Vector2 = b - a
	var sx: float = clampf(d.length() / maxf(native_len, 1.0), 0.14, 1.8)
	spr.transform = Transform2D(d.angle(), Vector2(sx, 1.0), 0.0, a)
