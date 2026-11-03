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

const FORM_BASE: StringName = &"base"
## The pre-2026-11-03 numbers (2.5 x 2.6 m footprint, 2.0x a cop's length); kept for A/B frames.
const FORM_NIGHT: StringName = &"night"
## The open guard (hands level and forward): King's stance, a boss squares up.
const FORM_OPEN: StringName = &"open"
## The Hauler ghost tank (features/souls): 2.6 = base 1.2 x (0.9 / 0.42), the rivet_ghost radius.
const FORM_HAULER: StringName = &"hauler"
const FORMS: Dictionary[StringName, Vector3] = {
	FORM_BASE: Vector3(1.2, 0.7, -250.0),
	FORM_OPEN: Vector3(1.1, 0.85, -30.0),
	FORM_NIGHT: Vector3(1.3, 1.0, -30.0),
	FORM_HAULER: Vector3(2.6, 1.0, -30.0),
}
## Which form RigPool builds; a dev scene may flip it before the pool's first build.
static var form: StringName = FORM_BASE


static func build(p_form: StringName = &"") -> BodyPlan:
	var f: Vector3 = FORMS.get(form if p_form == &"" else p_form, FORMS[FORM_BASE])
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
	_legs(p)
	_arms(p, f.y, f.z)
	p.hand_open = "claw_open"
	p.hand_closed = "claw_closed"
	p.hand_pistol = "claw_pistol"
	p.gun_arm = BodyPlan.L
	p.melee_arm = BodyPlan.L
	p.hose_tex = "hose"
	p.hose_from = Vector2(-95, 70)
	return p


static func _legs(p: BodyPlan) -> void:
	p.thigh_part = PackedStringArray(["l_thigh", "r_thigh"])
	p.thigh_len = 166.0
	p.thigh_draw = 166.0
	p.shin_part = PackedStringArray(["l_shin", "r_shin"])
	p.shin_len = 137.0
	p.shin_draw = 137.0
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
