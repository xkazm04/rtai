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

## Per kind: x = the gun hand along the aim as a share of the arm's reach, y = the off hand's
## share, z = the hands' height (part px; below 0 is toward the hip).
const SHAPE: Dictionary[int, Vector3] = {
	Kind.TWO_HAND_LONG: Vector3(0.35, 0.8, -10.0),
	Kind.SHOULDER: Vector3(0.32, 0.78, 20.0),
	Kind.HIP: Vector3(0.5, 0.85, -60.0),
}
## How much of the gun hand's recoil pull-back the off hand follows.
const OFF_RECOIL: float = 0.7
## Where the weapon's line starts across the chest: 0 = the centre, 1 = the gun shoulder.
const GUN_SIDE: float = 0.3
const RECOIL_PX: float = 60.0

const BY_CLASS: Dictionary[StringName, int] = {
	&"one_hand": Kind.ONE_HAND,
	&"two_hand_long": Kind.TWO_HAND_LONG,
	&"shoulder": Kind.SHOULDER,
	&"backpack_hose": Kind.HIP,
	&"heavy_two_hand": Kind.HIP,
	&"thrown": Kind.THROWN,
}


static func kind_of(grip_class: StringName) -> int:
	return BY_CLASS.get(grip_class, Kind.ONE_HAND)


## The hand target of arm `s` for the rig's grip while aiming; `tgt` unchanged otherwise.
static func target(rig: CutRig, tgt: Vector3, aim_arm: bool, reach: float) -> Vector3:
	if not rig.aiming or not SHAPE.has(rig.grip) or rig.plan.gun_arm < 0:
		return tgt
	var p: BodyPlan = rig.plan
	var gs: Vector3 = p.shoulder[p.gun_arm]
	var g2: Vector2 = Vector2(gs.x, gs.y * GUN_SIDE)
	var tl: Vector2 = rig.torso.global_transform.affine_inverse() * rig.aim_at
	var dv: Vector2 = (tl - g2).normalized()
	var shape: Vector3 = SHAPE[rig.grip]
	var h: Vector2 = g2 + dv * reach * (shape.x if aim_arm else shape.y)
	h -= dv * RECOIL_PX * rig.c_recoil * (1.0 if aim_arm else OFF_RECOIL)
	return Vector3(h.x, h.y, shape.z)
