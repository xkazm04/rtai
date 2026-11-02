class_name RivetPlan
extends RefCounted
## Rivet's body plan: the cutout lane's RIVET2 numbers (tuned against the bind sheet), unchanged
## for the D4 parts, which were drawn to the same layout templates (anchor torso 297 px).


static func build() -> BodyPlan:
	var p: BodyPlan = BodyPlan.new()
	p.kind = BodyPlan.Kind.RIVET
	p.name = "rivet"
	p.art_dir = "rivet"
	p.size_k = 1.3
	p.torso_pos = Vector2(-20, 0)
	p.head_part = "helmet"
	p.head_pos = Vector2(12, 0)
	p.collar_part = "collar"
	p.collar_pos = Vector2(-14, 0)
	p.hip_y = 78.0
	p.hip_z = 250.0
	_legs(p)
	_arms(p)
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


static func _arms(p: BodyPlan) -> void:
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
	p.hand_ready = [Vector3(300, -205, -30), Vector3(285, 205, -30)]
	p.hand_relax = [Vector3(60, -180, -300), Vector3(60, 180, -300)]
