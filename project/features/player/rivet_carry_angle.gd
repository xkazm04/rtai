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
## shoulder, not the face.
const BESIDE: float = 0.85
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
## `head_half` and `gun_half` are the head's half-width and the weapon's half-thickness (px).
static func beside_head(
	at: Vector2, rot: float, head: Vector2, head_half: float, gun_half: float
) -> Vector2:
	var n: Vector2 = Vector2.from_angle(rot).orthogonal()
	var dist: float = (at - head).dot(n)
	var clear: float = BESIDE * (head_half + gun_half)
	if absf(dist) >= clear:
		return Vector2.ZERO
	var side: float = signf(dist) if dist != 0.0 else 1.0
	return n * (side * clear - dist)
