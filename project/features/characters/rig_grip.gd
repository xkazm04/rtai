class_name RigGrip
extends RefCounted
## rivet-arsenal: how both arms hold a weapon of a grip class while aiming (CutRig.grip, set each
## frame by RivetHeldView from rivet_arsenal.json). ONE_HAND and THROWN keep RigArm's one-arm
## aim. TWO_HAND_LONG pulls the gun claw in toward the shoulder (the stock) and puts the off hand
## forward under the barrel; SHOULDER pulls the claw in closer (the tube rides the shoulder) with
## the off hand on the front grip; HIP holds both hands low and forward (the flamer wand, the
## chainsaw). Targets are rig-local part px (x forward, y across, z up) on the
## weapon's line: from the chest, GUN_SIDE of the way out toward the gun shoulder (Rivet's
## shoulders are wider apart than his reach, so a line from the gun shoulder is out of the off
## claw's reach), so the held weapon's barrel lies along the aim.

enum Kind { ONE_HAND, TWO_HAND_LONG, SHOULDER, HIP, THROWN }

## The reload: the gun claw low and in at the chest; the off claw pulls the magazine down and
## back (MAG_DROP), brings the new one up, then racks back along the weapon by RACK_PX.
const RELOAD_GUN: Vector3 = Vector3(0.45, 0.35, -30.0)
const RACK_PX: float = 80.0
## Where the off claw takes the magazine: down and back from the gun claw, toward the chest.
const MAG_DROP: Vector3 = Vector3(-70.0, 0.0, -50.0)

## Per kind: x = the gun hand along the aim as a share of the arm's reach, y = the off hand's
## share, z = the hands' height (part px; below 0 is toward the hip).
const SHAPE: Dictionary[int, Vector3] = {
	Kind.TWO_HAND_LONG: Vector3(0.4, 0.8, -10.0),
	Kind.SHOULDER: Vector3(0.32, 0.78, 20.0),
	Kind.HIP: Vector3(0.5, 0.85, -60.0),
}
## How much of the gun hand's recoil pull-back the off hand follows.
const OFF_RECOIL: float = 0.7
## Where the weapon's line starts across the chest: 0 = the centre, 1 = the gun shoulder.
const GUN_SIDE: float = 0.3
## Per kind, the same share for a long gun or a tube: further out, so the stock lies beside the
## helmet instead of under it (at 0.3 the barrel line ran 46 px off his centre, inside the
## helmet's 78 px half-width: the 64 px/m rim clip).
const GUN_SIDE_BY: Dictionary[int, float] = {Kind.TWO_HAND_LONG: 0.42, Kind.SHOULDER: 0.42}
## Aimed with a long gun or a tube, the helmet leans this far (part px) toward the off side, off
## the stock (RigPose._head reads head_lean).
const HEAD_LEAN_PX: float = 24.0
## The weapon's line stays within this of the torso's forward: while the torso turns behind a fast
## aim, a two-hand hold leads with the weapon instead of reaching the off claw behind the back.
const MAX_SWING_RAD: float = PI / 3.0
const RECOIL_PX: float = 60.0
## The off claw's place on a two-handed melee hilt: this far ahead of the gun claw (part px),
## at this height.
const HILT_PX: float = 46.0
const HILT_Z: float = -10.0
## The gun claw brings a two-handed hilt in front of the chest: this share of the arm's reach
## ahead (at rest, and at the strike's full reach), and this share of the way out toward the gun
## shoulder (Rivet's shoulders are 316 part px apart, his reach 246: a hilt held at the gun side
## is out of the off claw's reach, which is why it folded or pointed away in iteration 3).
const HILT_FWD: Vector2 = Vector2(0.46, 0.56)
const HILT_ACROSS: float = 0.08

const BY_CLASS: Dictionary[StringName, int] = {
	&"one_hand": Kind.ONE_HAND,
	&"two_hand_long": Kind.TWO_HAND_LONG,
	&"shoulder": Kind.SHOULDER,
	&"backpack_hose": Kind.HIP,
	&"heavy_two_hand": Kind.HIP,
	&"hip_belt": Kind.HIP,
	&"thrown": Kind.THROWN,
}


static func kind_of(grip_class: StringName) -> int:
	return BY_CLASS.get(grip_class, Kind.ONE_HAND)


## The hand target of arm `s` for the rig's grip while aiming; `tgt` unchanged otherwise.
static func target(rig: CutRig, tgt: Vector3, aim_arm: bool, reach: float) -> Vector3:
	if rig.reload_k >= 0.0 and rig.plan.gun_arm >= 0:
		return _reload(rig, aim_arm, reach)
	if not rig.aiming or not SHAPE.has(rig.grip) or rig.plan.gun_arm < 0:
		return tgt
	var p: BodyPlan = rig.plan
	var gs: Vector3 = p.shoulder[p.gun_arm]
	var out: float = GUN_SIDE_BY[rig.grip] if GUN_SIDE_BY.has(rig.grip) else GUN_SIDE
	var g2: Vector2 = Vector2(gs.x, gs.y * out)
	var tl: Vector2 = rig.torso.global_transform.affine_inverse() * rig.aim_at
	var dv: Vector2 = (tl - g2).normalized()
	dv = Vector2.from_angle(clampf(dv.angle(), -MAX_SWING_RAD, MAX_SWING_RAD))
	var shape: Vector3 = SHAPE[rig.grip]
	var h: Vector2 = g2 + dv * reach * (shape.x if aim_arm else shape.y)
	h -= dv * RECOIL_PX * rig.c_recoil * (1.0 if aim_arm else OFF_RECOIL)
	return Vector3(h.x, h.y, shape.z)


## combat-notes (owner note 2026-11-04, "player's hold of melee weapons"): with a two-handed
## melee weapon (CutRig.two_hand_melee) the gun claw holds the hilt in front of the chest
## (HILT_FWD, HILT_ACROSS) and the off claw closes on the hilt HILT_PX ahead of the gun
## claw's hand this frame (the gun arm solves first), along the blade (CutRig.hilt_dir), at its
## height, so both claws close on the hilt one above the other.
static func melee_hilt(rig: CutRig, s: int, tgt: Vector3, reach: float) -> Vector3:
	var g: int = rig.plan.gun_arm
	if not rig.two_hand_melee or g < 0:
		return tgt
	if s == g:
		var gs: Vector3 = rig.plan.shoulder[g]
		var fwd: float = lerpf(HILT_FWD.x, HILT_FWD.y, rig.c_reach)
		return Vector3(gs.x + reach * fwd, gs.y * HILT_ACROSS, HILT_Z)
	var gh: Vector2 = rig.sides[g].j_hand
	var h: Vector2 = gh + rig.hilt_dir.normalized() * HILT_PX
	return Vector3(h.x, h.y, HILT_Z)


## The helmet's lean across (part px) while aiming a long gun or a tube: away from the gun side.
static func head_lean(rig: CutRig) -> float:
	if not rig.aiming or not GUN_SIDE_BY.has(rig.grip) or rig.plan.gun_arm < 0:
		return 0.0
	return -signf(rig.plan.shoulder[rig.plan.gun_arm].y) * HEAD_LEAN_PX


## The reload pantomime's hand target (the gun claw holds, the off claw works the magazine).
static func _reload(rig: CutRig, aim_arm: bool, reach: float) -> Vector3:
	var gs: Vector3 = rig.plan.shoulder[rig.plan.gun_arm]
	var gun: Vector3 = Vector3(gs.x + reach * RELOAD_GUN.x, gs.y * RELOAD_GUN.y, RELOAD_GUN.z)
	if aim_arm:
		return gun
	var hip: Vector3 = gun + MAG_DROP  # short of the hip: a deeper fold flings the elbow out
	var k: float = rig.reload_k
	if k < 1.0:
		return gun.lerp(hip, smoothstep(0.0, 1.0, k))
	if k < 2.0:
		return hip.lerp(gun, smoothstep(0.0, 1.0, k - 1.0))
	return gun - Vector3(RACK_PX * sin(PI * clampf(k - 2.0, 0.0, 1.0)), 0.0, 0.0)
