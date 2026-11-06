class_name RivetCarryAngle
extends RefCounted
## rivet-arsenal: the carry of a long gun or a tube while Rivet is not aiming (render only). Held
## along the claw, the stock ran back over his helmet (weapon-art's 32 px/m lineup, tick 394: the
## rocket and the nuke covered his face), because seen from above the claw sits just in front of
## the head. Carried, the weapon instead lies across the front of the body: the barrel turned
## ACROSS_RAD off the facing toward the off side, the stock out past the gun-side shoulder. Raising
## the aim swings it back onto the aim line over about 1 / EASE frames.

## Off the facing, toward the off side (radians). PI / 2 would be square across the chest.
const ACROSS_RAD: float = 1.2
## Aimed or carried, the weapon's axis passes at least this share of (head half-width +
## weapon half-thickness) beside the head's centre, on the gun side: a tube rides the
## shoulder, not the face. 1.0 since RigGrip.GUN_SIDE_BY starts the aimed line near the
## clearance (0.85 left the stock on the helmet's rim at 64 px/m).
const BESIDE: float = 1.0
## Per drawn frame, the share of the way to the carry (or back to the aim) covered.
const EASE: float = 0.25

## 0 = on the claw / aim line, 1 = fully across.
var k: float = 0.0


## Whether this grip class is carried across the body (the long two-handers and the tubes).
static func applies(grip: RigGrip.Kind) -> bool:
	return grip == RigGrip.Kind.TWO_HAND_LONG or grip == RigGrip.Kind.SHOULDER


## The rotation to add to the held sprite this frame. `fwd` is the torso's facing, `grip_at` the
## claw's closing point and `torso_at` the torso's centre (global).
func step(carry: bool, fwd: Vector2, grip_at: Vector2, torso_at: Vector2, rot: float) -> float:
	k = move_toward(k, 1.0 if carry else 0.0, EASE)
	if k <= 0.0:
		return 0.0
	var gun_side: float = signf(fwd.cross(grip_at - torso_at))
	if gun_side == 0.0:
		gun_side = 1.0
	var across: float = fwd.angle() - gun_side * ACROSS_RAD
	return angle_difference(rot, across) * smoothstep(0.0, 1.0, k)


## The shift (global px) that moves a weapon at `at`, axis angle `rot`, beside the head at `head`.
## `half_sum` is the head's half-width plus the weapon's half-thickness (px). `side` (+1 / -1, in
## the axis normal's sense) keeps that side of the head; 0 takes the nearer side.
static func beside_head(
	at: Vector2, rot: float, head: Vector2, half_sum: float, side: float = 0.0
) -> Vector2:
	var n: Vector2 = Vector2.from_angle(rot).orthogonal()
	var dist: float = (at - head).dot(n)
	var clear: float = BESIDE * half_sum
	if side == 0.0:
		side = signf(dist) if dist != 0.0 else 1.0
	if dist * side >= clear:
		return Vector2.ZERO
	return n * (side * clear - dist)


## n7-ranged: an aimed weapon stays on the gun shoulder's side of the head. Taking the nearer side
## popped a tube to the off shoulder for one frame on every rocket and nuke launch: the reload's
## first frame poses the claw on the centre line (its axis 0.1 px off the head's centre).
static func aim_side(rig: CutRig, rot: float, head: Vector2) -> float:
	if not rig.aiming or rig.plan.gun_arm < 0:
		return 0.0
	var shoulder: Vector2 = rig.sides[rig.plan.gun_arm].upper.global_position
	var d: float = (shoulder - head).dot(Vector2.from_angle(rot).orthogonal())
	return signf(d)


## Moves the held `gun` beside Rivet's helmet; d7-held: the claws take the same shift one frame
## later (CutRig.held_shift into RigGrip.target), so it is measured from the unshifted point.
static func place_beside(rig: CutRig, gun: Sprite2D) -> void:
	gun.global_position -= rig.torso.global_transform.basis_xform(rig.held_shift)
	var head: Sprite2D = rig.head_spr
	var head_half: float = head.texture.get_width() * absf(head.global_scale.x) * 0.5
	var gun_half: float = gun.texture.get_height() * absf(gun.global_scale.y) * 0.5
	var at: Vector2 = gun.global_position
	var rot: float = gun.global_rotation
	var side: float = aim_side(rig, rot, head.global_position)
	var shift: Vector2 = beside_head(at, rot, head.global_position, head_half + gun_half, side)
	gun.global_position += shift
	var follow: bool = rig.aiming and rig.reload_k < 0.0 and RigGrip.follow_shift
	var to_local: Transform2D = rig.torso.global_transform.affine_inverse()
	rig.held_shift = to_local.basis_xform(shift) if follow else Vector2.ZERO
