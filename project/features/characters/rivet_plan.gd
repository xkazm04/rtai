class_name RivetPlan
extends RefCounted
## Rivet's body plan: the cutout lane's RIVET2 numbers (tuned against the bind sheet), unchanged
## for the D4 parts, which were drawn to the same layout templates (anchor torso 297 px).
## Scale (d5-cast, 2026-11-03): the owner's verdict "Rivet is too massive"; in the concept he is
## only slightly larger than a human. A FORM is a [size_k, guard_k, hand_z] profile: size_k scales
## the whole figure, guard_k pulls the ready (guard) hands toward the chest, hand_z drops them
## (part px below the shoulders): T2's hunch, arms hanging forward, so the plan view foreshortens
## them instead of spreading a 2 m guard. Only BASE is built for Rivet today; the later bulky
## ghost form adds its own row here (and needs no new rig code).
## Proportions (rivet-motion, 2026-11-03 eve): the owner, "too large and large arms". T2 measures
## arm (shoulder to wrist) : leg (hip to sole) = 0.8 and a claw about a quarter of the leg; the
## day plan was 341 : 303 = 1.13. ARMS holds [arm_k, hand_k, arm_w] per form: arm_k scales both
## arm segments (and the guard and hang targets about the shoulder), hand_k the claw cell, arm_w
## the arm's drawn thickness (T2's forearm is about a third of the torso's width, not half).

const FORM_BASE: StringName = &"base"
## The pre-2026-11-03 numbers (2.5 x 2.6 m footprint, 2.0x a cop's length); kept for A/B frames.
const FORM_NIGHT: StringName = &"night"
## The open guard (hands level and forward): King's stance, a boss squares up.
const FORM_OPEN: StringName = &"open"
## The day's base (size 1.2, hunched guard, full-length arms): kept for the before frames.
const FORM_DAY: StringName = &"day"
## The owner's ASK rivet-motion-1 options: T2's ratio (base), a milder cut, the day's arms.
const FORM_MILD: StringName = &"mild"
## The Hauler ghost tank (features/souls): 2.6 = BODY_SIZE_K x (0.9 / 0.42), the rivet_ghost radius.
const FORM_HAULER: StringName = &"hauler"
## n5-cast (2026-11-04): the pre-hybrid base (size 1.2, the d5 arms), kept for the A/B frames.
const FORM_STOCKY: StringName = &"stocky"
## The size_k at which the art matched the rivet_base body radius (d5); the Hauler tank's absolute
## size hangs off this, not off FORM_BASE, so slimming the base does not shrink the tank.
const BODY_SIZE_K: float = 1.2
## n5-cast: the lanky + android hybrid (r2_c3) is about 1.1x the crowd's 0.83 m shoulder span.
const FORMS: Dictionary[StringName, Vector3] = {
	FORM_BASE: Vector3(0.97, 0.7, -250.0),
	FORM_STOCKY: Vector3(1.2, 0.7, -250.0),
	FORM_OPEN: Vector3(1.1, 0.85, -30.0),
	FORM_NIGHT: Vector3(1.3, 1.0, -30.0),
	FORM_DAY: Vector3(1.2, 0.7, -250.0),
	FORM_MILD: Vector3(1.2, 0.7, -250.0),
	FORM_HAULER: Vector3(2.6, 1.0, -30.0),
}
## [arm_k, hand_k, arm_w] per form; a form missing here keeps 1.0 (King, the night and day forms).
const ARMS: Dictionary[StringName, Vector3] = {
	FORM_BASE: Vector3(0.85, 0.9, 0.9),
	FORM_STOCKY: Vector3(0.72, 0.78, 0.8),
	FORM_MILD: Vector3(0.85, 0.9, 0.9),
	## The tank is base Rivet grown (HaulerLook bulks the arms further from these).
	FORM_HAULER: Vector3(0.72, 0.78, 0.8),
}
## n5-cast: [leg_k, leg_w, gait_k] per form (missing = 1.0): leg_k lengthens the thigh and shin and
## raises the hip with them (the lanky gait), leg_w thins them (lean piston legs), gait_k scales
## GAIT_SCALE so the slimmer body keeps a long stride in metres.
const LEGS: Dictionary[StringName, Vector3] = {
	FORM_BASE: Vector3(1.15, 1.0, 1.15),
}
## Stride (ASK rivet-motion-2, default B, 21:21): gait_scale 1.3 lets the feet reach past the
## guard at a walk (0.68 m vs 0.53 m at 1.0); the sprint stride adds 20 % above the run speed.
const GAIT_SCALE: float = 1.3
const SPRINT_STRIDE: float = 0.2
## The owner's 2026-11-04 baseline ("increase baseline of main character with 50%"): walk 6.75,
## sprint 9.3 m/s (combat.json, rivet_motion.json). The gait keeps the evening's pose and stride
## at the new speeds (BodyPlan.speed_k), so the cadence rises 1.5x. The Hauler keeps 1.0.
const SPEED_K: float = 1.5
## Which form RigPool builds; a dev scene may flip it before the pool's first build.
static var form: StringName = FORM_BASE


static func build(p_form: StringName = &"") -> BodyPlan:
	var key: StringName = form if p_form == &"" else p_form
	var f: Vector3 = FORMS.get(key, FORMS[FORM_BASE])
	var arms: Vector3 = ARMS.get(key, Vector3.ONE)
	var legs: Vector3 = LEGS.get(key, Vector3.ONE)
	var p: BodyPlan = BodyPlan.new()
	p.kind = BodyPlan.Kind.RIVET
	p.name = "rivet"
	p.art_dir = "rivet"
	p.size_k = f.x
	p.torso_pos = Vector2(-20, 0)
	p.head_part = "helmet"
	p.head_pos = Vector2(12, 0)
	p.collar_part = "collar"
	p.collar_pos = Vector2(-14, 0)
	p.hip_y = 78.0
	p.hip_z = 250.0
	_legs(p, legs.x)
	p.leg_w = legs.y
	_arms(p, f.y, f.z)
	_proportion(p, arms.x, arms.y)
	p.arm_w = arms.z
	p.hand_open = "claw_open"
	p.hand_closed = "claw_closed"
	p.hand_pistol = "claw_pistol"
	p.gun_arm = BodyPlan.L
	p.melee_arm = BodyPlan.L
	p.hose_tex = "hose"
	p.hose_from = Vector2(-95, 70)
	p.hip_follow = 1.0
	p.gait_scale = GAIT_SCALE * legs.z
	p.sprint_stride = SPRINT_STRIDE
	p.speed_k = 1.0 if key == FORM_HAULER else SPEED_K
	return p


static func _legs(p: BodyPlan, leg_k: float) -> void:
	p.hip_z *= leg_k
	p.thigh_part = PackedStringArray(["l_thigh", "r_thigh"])
	p.thigh_len = 166.0 * leg_k
	p.thigh_draw = 166.0 * leg_k
	p.shin_part = PackedStringArray(["l_shin", "r_shin"])
	p.shin_len = 137.0 * leg_k
	p.shin_draw = 137.0 * leg_k
	p.foot_part = PackedStringArray(["l_foot", "r_foot"])
	p.foot_toeoff = PackedStringArray(["l_foot_toeoff", "r_foot_toeoff"])


static func _arms(p: BodyPlan, guard_k: float, hand_z: float) -> void:
	p.shoulder = [Vector3(-6, -158, 0), Vector3(-6, 158, 0)]
	p.upper_part = PackedStringArray(["l_upperarm", "r_upperarm"])
	p.upper_len = 159.0
	p.upper_draw = 159.0
	p.fore_part = PackedStringArray(["l_forearm", "r_forearm"])
	p.fore_len = PackedFloat32Array([182.0, 182.0])
	p.fore_draw = PackedFloat32Array([182.0, 182.0])
	p.endon_below = 0.45
	p.endon_upper_len = 48.0
	p.endon_fore_len = 37.0
	p.endon_upper = PackedStringArray(["l_upperarm_endon", "r_upperarm_endon"])
	p.endon_fore = PackedStringArray(["l_forearm_endon", "r_forearm_endon"])
	var g: Vector3 = Vector3(guard_k, lerpf(1.0, guard_k, 0.5), 1.0)
	p.hand_ready = [Vector3(300, -205, hand_z) * g, Vector3(285, 205, hand_z) * g]
	p.hand_relax = [Vector3(60, -180, -300), Vector3(60, 180, -300)]


## Shortens both arm segments by arm_k (the art squashes along its length, the width stays) and
## pulls the guard and hang targets toward the shoulder by the same factor; hand_k sizes the claw.
static func _proportion(p: BodyPlan, arm_k: float, hand_k: float) -> void:
	p.upper_len *= arm_k
	p.upper_draw *= arm_k
	for s: int in 2:
		p.fore_len[s] *= arm_k
		p.fore_draw[s] *= arm_k
		p.hand_ready[s] = _toward(p.shoulder[s], p.hand_ready[s], arm_k)
		p.hand_relax[s] = _toward(p.shoulder[s], p.hand_relax[s], arm_k)
	p.endon_upper_len *= arm_k
	p.endon_fore_len *= arm_k
	p.hand_k = hand_k


static func _toward(sh: Vector3, tgt: Vector3, k: float) -> Vector3:
	return sh + (tgt - sh) * k
