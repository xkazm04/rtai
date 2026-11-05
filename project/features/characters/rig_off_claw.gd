class_name RigOffClaw
extends RefCounted
## d7-held: Rivet's off claw on a two-claw weapon. His off forearm is a welding-torch tool whose
## art runs about twice the arm's IK length, so on a long gun, a tube, the Gatling or the flamer
## the torch stuck out past the barrel instead of closing on the foregrip (the owner's cast-3 note:
## "the holding of larger guns above uzi does not look natural"). While the off claw holds the
## weapon (aiming a two-claw kind, or any reload) the torch forearm swaps to a plain forearm and a
## closed claw clamps the barrel: the wrist beside it on the off side, the claw turned ACROSS_RAD
## off the weapon's line so its jaws straddle the barrel, drawn over the weapon. The weapon's line
## is the drawn one (through the gun claw's grip point, RivetHeldView.GRIP_U, toward the aim), not
## the IK line, which runs a claw's width off it. `--torch-off-arm` brings the night's hold back.

const FORE: String = "r_forearm_grip"
const CLAW: String = "claw_grip"
## Over the held weapon (RivetHeldView draws at the rigs' z + 60; the torso adds its own).
const Z: int = 61
## The claw's turn off the weapon's line toward the gun side (rad; PI/2 = square across).
const ACROSS_RAD: float = 1.25
## From the claw's wrist to the middle of its jaws (claw_grip part px, before hand_k).
const JAW_PX: float = 100.0
## False (`--torch-off-arm`): the torch forearm holds the weapon (the A/B's before).
static var enabled: bool = not OS.get_cmdline_user_args().has("--torch-off-arm")


## True when the plan names an off claw and its art folder has both cells (the ghost forms and
## the King build on RivetPlan with their own art: no off claw).
static func has_art(p: BodyPlan) -> bool:
	if p.off_grip_hand == "" or p.gun_arm < 0:
		return false
	var lib: PartLibrary = PartLibrary.of(p.art_dir)
	return lib.sizes.has(p.off_grip_hand) and lib.sizes.has(p.off_grip_fore)


## True while arm `s` is the off arm and its claw is on the weapon.
static func holds(rig: CutRig, s: int) -> bool:
	var p: BodyPlan = rig.plan
	if rig.sides[s].grip == null or s == p.gun_arm or not rig.gun_out:
		return false
	if rig.reload_k >= 0.0:
		return true
	return rig.aiming and rig.grip in HeldTable.TWO_CLAW


## The off forearm's cell for arm `s` (the plain forearm while the claw holds), else `cell`.
static func fore_cell(rig: CutRig, s: int, cell: String) -> String:
	return rig.plan.off_grip_fore if holds(rig, s) else cell


## The off hand's IK target while it holds a two-claw weapon (not during a reload): the wrist
## beside the drawn barrel, `tgt`'s distance along it, so the jaws close on the barrel.
static func target(rig: CutRig, s: int, tgt: Vector3) -> Vector3:
	if rig.reload_k >= 0.0 or not holds(rig, s):
		return tgt
	var grip: Vector2 = grip_point(rig)
	var dv: Vector2 = _line(rig, grip)
	var along: float = (Vector2(tgt.x, tgt.y) - rig.sides[rig.plan.gun_arm].j_hand).dot(dv)
	var w: Vector2 = grip + dv * along - _jaw(rig, dv) * JAW_PX * rig.plan.hand_k
	return Vector3(w.x, w.y, tgt.z)


## Shows the off claw on the hand point of arm `s` while it holds: across the barrel (during a
## reload along the forearm, working the magazine). Torso-local px.
static func place(rig: CutRig, s: int) -> void:
	var side: RigLimbs = rig.sides[s]
	if side.grip == null:
		return
	var on: bool = holds(rig, s)
	side.grip.visible = on
	if not on:
		return
	var ang: float = (side.j_hand - side.j_elbow).angle()
	if rig.reload_k < 0.0:
		ang = _jaw(rig, _line(rig, grip_point(rig))).angle()
	side.grip.position = side.j_hand
	side.grip.rotation = ang
	side.grip.scale = Vector2.ONE * rig.plan.hand_k


## The gun claw's grip point (where RivetHeldView puts the weapon), torso-local px; the gun arm
## is solved first (RigPose: L then R; Rivet's gun arm is L).
static func grip_point(rig: CutRig) -> Vector2:
	var hand: Sprite2D = rig.sides[rig.plan.gun_arm].hand
	if hand == null:
		return rig.sides[rig.plan.gun_arm].j_hand
	var t: Vector2 = hand.texture.get_size()
	var local: Vector2 = Vector2(t.x * RivetHeldView.GRIP_U, t.y * 0.5) + hand.offset
	return (hand.get_parent() as Node2D).transform * (hand.transform * local)


## The middle of arm `s`'s off claw jaws (torso-local px): where it clamps the barrel.
static func jaw_point(rig: CutRig, s: int) -> Vector2:
	var g: Sprite2D = rig.sides[s].grip
	return g.position + Vector2.from_angle(g.rotation) * JAW_PX * rig.plan.hand_k


## The drawn weapon's direction (torso frame): from the grip point toward the aim.
static func _line(rig: CutRig, grip: Vector2) -> Vector2:
	var tl: Vector2 = rig.torso.global_transform.affine_inverse() * rig.aim_at
	return (tl - grip).normalized() if tl.distance_to(grip) > 1.0 else Vector2.RIGHT


## The claw's direction: the line turned ACROSS_RAD toward the gun side (wrist on the off side).
static func _jaw(rig: CutRig, dv: Vector2) -> Vector2:
	return dv.rotated(signf(rig.plan.shoulder[rig.plan.gun_arm].y) * ACROSS_RAD)
