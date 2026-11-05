class_name RigGrip
extends RefCounted
## rivet-arsenal + d7-held: how both arms hold a weapon of a hold class (CutRig.grip and
## CutRig.hold, set each frame by RivetHeldView from data/tables/held_classes.json). ONE_HAND and
## THROWN keep RigArm's one-arm aim. While aiming, TWO_HAND_LONG pulls the gun claw in toward the
## shoulder (the stock) and puts the off hand forward under the barrel; SHOULDER pulls the claw in
## closer (the tube rides the shoulder) with the off hand on the front grip; HIP holds both hands
## low and forward (the flamer wand, the Gatling, the chainsaw). BLADE (d7-held, owner pick
## combat-notes-1 A: one claw) holds the gun claw at a low guard ahead of the gun-side hip, aimed
## or not, the off arm free; the blade leaves the claw in line with the forearm, turned in by the
## class's wrist_rad (wrist_turn). Targets are rig-local part px (x forward, y across, z up) on
## the weapon's line: from the chest, the class's `across` share of the way out toward the gun
## shoulder (Rivet's shoulders are wider apart than his reach, so a line from the gun shoulder is
## out of the off claw's reach), so the held weapon's barrel lies along the aim.

enum Kind { ONE_HAND, TWO_HAND_LONG, SHOULDER, HIP, THROWN, BLADE }

## The reload: the gun claw low and in at the chest; the off claw pulls the magazine down and
## back (MAG_DROP), brings the new one up, then racks back along the weapon by RACK_PX.
const RELOAD_GUN: Vector3 = Vector3(0.45, 0.35, -30.0)
const RACK_PX: float = 80.0
## Where the off claw takes the magazine: down and back from the gun claw, toward the chest.
const MAG_DROP: Vector3 = Vector3(-70.0, 0.0, -50.0)

## How much of the gun hand's recoil pull-back the off hand follows.
const OFF_RECOIL: float = 0.7
## Aimed with a long gun or a tube, the helmet leans this far (part px) toward the off side, off
## the stock (RigPose._head reads head_lean).
const HEAD_LEAN_PX: float = 24.0
## The blade's guard follows the walk this little (1 = the free arm's swing, 0 = held still).
const GUARD_SWAY: float = 0.15
## The kinds whose aimed stock rides the shoulder: the helmet leans off it.
const LEANS: Array[int] = [Kind.TWO_HAND_LONG, Kind.SHOULDER]
## The weapon's line stays within this of the torso's forward: while the torso turns behind a fast
## aim, a two-hand hold leads with the weapon instead of reaching the off claw behind the back.
const MAX_SWING_RAD: float = PI / 3.0
const RECOIL_PX: float = 60.0
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


## The hold class posing the rig: its own (CutRig.hold), else the first of its kind.
static func hold_of(rig: CutRig) -> HeldTable.Hold:
	var t: HeldTable = HeldTable.shipped()
	return t.holds[rig.hold] if t.holds.has(rig.hold) else t.by_kind(rig.grip)


## The hand target of arm `s` for the rig's hold; `tgt` unchanged otherwise.
static func target(rig: CutRig, tgt: Vector3, aim_arm: bool, reach: float) -> Vector3:
	if rig.reload_k >= 0.0 and rig.plan.gun_arm >= 0:
		return _reload(rig, aim_arm, reach)
	if rig.plan.gun_arm < 0 or not rig.gun_out:
		return tgt
	var hold: HeldTable.Hold = hold_of(rig)
	if hold == null:
		return tgt
	if rig.grip == Kind.BLADE:
		return _guard(rig, hold, tgt, aim_arm, reach)
	if not RigGrip.both_claws(rig, hold):
		return tgt
	var g2: Vector2 = _line_start(rig, hold)
	var dv: Vector2 = _aim_dir(rig, g2) if rig.aiming else Vector2.RIGHT  # not aimed: the facing
	var h: Vector2 = g2 + dv * reach * (hold.gun_reach if aim_arm else hold.off_reach)
	h -= dv * RECOIL_PX * rig.c_recoil * (1.0 if aim_arm else OFF_RECOIL)
	return Vector3(h.x, h.y, hold.hand_z)


## d7-held: the blade's turn off the facing or the aim (rad, global): in toward Rivet's centre
## line by the class's wrist_rad, straightening as the strike reaches.
static func wrist_turn(rig: CutRig) -> float:
	if rig.grip != Kind.BLADE or rig.plan.gun_arm < 0:
		return 0.0
	var hold: HeldTable.Hold = hold_of(rig)
	var gun_side: float = signf(rig.plan.shoulder[rig.plan.gun_arm].y)
	var flip: float = signf(rig.torso.global_transform.determinant())
	return -gun_side * flip * hold.wrist_rad * (1.0 - rig.c_reach) if hold != null else 0.0


## d7-held: a held blade's global angle: the aim line (or the facing) turned in at the wrist. The
## claw's own rotation follows the arm's IK, which at the low guard runs nearly across the body,
## so the blade takes the line MeleeSwing's arc is measured from instead.
static func blade_angle(rig: CutRig) -> float:
	var at: Vector2 = rig.torso.global_position
	var line: float = rig.torso.global_transform.x.angle()
	if rig.aiming and rig.aim_at.distance_to(at) > 1.0:
		line = (rig.aim_at - at).angle()
	return line + wrist_turn(rig)


## The blade's guard: the gun claw low and ahead of the gun-side hip, along the aim when aiming,
## else the facing, with a little of the walk's swing left in it; the off arm stays free.
static func _guard(
	rig: CutRig, hold: HeldTable.Hold, tgt: Vector3, aim_arm: bool, reach: float
) -> Vector3:
	if not aim_arm:
		return tgt
	var g2: Vector2 = _line_start(rig, hold)
	var dv: Vector2 = _aim_dir(rig, g2) if rig.aiming else Vector2.RIGHT
	var h: Vector2 = g2 + dv * reach * hold.gun_reach
	return Vector3(h.x, h.y, hold.hand_z).lerp(tgt, GUARD_SWAY)


## Where the weapon's line starts: the class's `across` share out toward the gun shoulder.
static func _line_start(rig: CutRig, hold: HeldTable.Hold) -> Vector2:
	var gs: Vector3 = rig.plan.shoulder[rig.plan.gun_arm]
	return Vector2(gs.x, gs.y * hold.across)


## The aim's direction from `g2` (torso frame), within MAX_SWING_RAD of the facing.
static func _aim_dir(rig: CutRig, g2: Vector2) -> Vector2:
	var tl: Vector2 = rig.torso.global_transform.affine_inverse() * rig.aim_at
	var dv: Vector2 = (tl - g2).normalized()
	return Vector2.from_angle(clampf(dv.angle(), -MAX_SWING_RAD, MAX_SWING_RAD))


## d7-held: both claws on the weapon: a two-claw kind while aiming, or always (two_claw_out).
static func both_claws(rig: CutRig, hold: HeldTable.Hold) -> bool:
	if rig.grip not in HeldTable.TWO_CLAW:
		return false
	return rig.aiming or hold.two_claw_out


## d7-held: the held class's walk: x = the stride's scale (heavy: shorter steps, a trudge), y = how
## far (part px) the body leans back against the weapon's weight. (1, 0) with nothing held.
static func walk(rig: CutRig) -> Vector2:
	if not rig.gun_out or rig.plan.gun_arm < 0 or rig.hold == &"":
		return Vector2(1.0, 0.0)
	var hold: HeldTable.Hold = hold_of(rig)
	return Vector2(hold.stride_k, hold.lean_px) if hold != null else Vector2(1.0, 0.0)


## The helmet's lean across (part px) while aiming a long gun or a tube: away from the gun side.
static func head_lean(rig: CutRig) -> float:
	if not rig.aiming or rig.grip not in LEANS or rig.plan.gun_arm < 0:
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
