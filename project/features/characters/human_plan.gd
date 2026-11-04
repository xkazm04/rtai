class_name HumanPlan
extends RefCounted
## Cop and pedestrian body plans derived from their parts.json (the spike's CharDefs.human()):
## cap-to-cap limb lengths and the torso / pelvis spans, lengthened past the drawn length
## (LEG_K, ARM_K) because the guides were drawn short and a 0.5 m leg cannot carry a 0.6 m step.

const LEG_K: float = 1.5
const ARM_K: float = 1.15
## n5-cast (2026-11-04, the owner: "cops ... closer to crowd in their default state"): one human
## footprint. The cop art is drawn broader than the ped's (torso 288 vs 213 part px across), so
## the cop scale drops 1.45 -> 1.0 (shoulder span 1.31 -> 0.90 m, the ped's 0.83 m) and the cop
## limbs are lengthened by LIMB_K (= the ped's size_k / the cop's) to the ped's limb lengths:
## the same height and stride, narrower everywhere. Back to the old cop: COP_SIZE_K 1.45 and
## COP_LIMB_K 1.0. The ped is the footprint's one authority (PED_SIZE_K).
const PED_SIZE_K: float = 1.25
const COP_SIZE_K: float = 1.0
const COP_LIMB_K: float = PED_SIZE_K / COP_SIZE_K


static func cop() -> BodyPlan:
	var p: BodyPlan = _human(BodyPlan.Kind.COP, "cop", "head_cap", 0.30, COP_LIMB_K)
	p.size_k = COP_SIZE_K
	p.gait_scale = 0.8
	p.gun_arm = BodyPlan.R
	p.gun_cell = "forearm_pistol"
	p.melee_arm = BodyPlan.R
	p.shield_part = "shield"
	p.shield_pos = Vector2(PartLibrary.of("cop").span("forearm") * 0.75, -20)
	return p


static func ped() -> BodyPlan:
	var p: BodyPlan = _human(BodyPlan.Kind.PED, "ped", "head_hair", 0.22, 1.0)
	p.size_k = PED_SIZE_K
	p.gait_scale = 0.72
	p.ready_stance = false
	return p


static func _human(
	kind: BodyPlan.Kind, who: String, head: String, head_dx: float, limb_k: float
) -> BodyPlan:
	var lib: PartLibrary = PartLibrary.of(who)
	var p: BodyPlan = BodyPlan.new()
	p.kind = kind
	p.name = who
	p.art_dir = who
	p.limb_lod = false
	var tsz: Vector2 = lib.size("torso")
	var depth: float = tsz.x
	p.head_part = head
	p.head_pos = Vector2(depth * head_dx, 0)
	p.pelvis_pos = Vector2(-depth * 0.05, 0)
	p.hip_y = lib.size("pelvis").y * 0.28
	_legs(p, lib, limb_k)
	_arms(p, lib, tsz.y * 0.5 - tsz.y * 0.14, depth, limb_k)
	return p


static func _legs(p: BodyPlan, lib: PartLibrary, limb_k: float) -> void:
	p.thigh_draw = lib.span("thigh")
	p.thigh_len = p.thigh_draw * LEG_K * limb_k
	p.shin_draw = lib.span("shin")
	p.shin_len = p.shin_draw * LEG_K * limb_k
	p.hip_z = (p.thigh_len + p.shin_len) * 0.86
	p.foot_toeoff = PackedStringArray(["foot_toeoff", "foot_toeoff"])
	p.foot_fwd = 10.0


static func _arms(p: BodyPlan, lib: PartLibrary, sy: float, depth: float, limb_k: float) -> void:
	p.upper_draw = lib.span("upperarm")
	p.upper_len = p.upper_draw * ARM_K * limb_k
	var fd: float = lib.span("forearm")
	p.fore_draw = PackedFloat32Array([fd, fd])
	var fl: float = fd * ARM_K * limb_k
	p.fore_len = PackedFloat32Array([fl, fl])
	p.shoulder = [Vector3(-depth * 0.06, -sy, 0), Vector3(-depth * 0.06, sy, 0)]
	p.endon_upper = PackedStringArray(["upperarm_endon", "upperarm_endon"])
	p.endon_fore = PackedStringArray(["forearm_endon", "forearm_endon"])
	p.endon_upper_len = lib.span("upperarm_endon") + 1.0
	p.endon_fore_len = lib.span("forearm_endon") + 1.0
	p.endon_round = true
	var reach: float = p.upper_len + p.fore_len[0]
	p.hand_ready = [Vector3(reach * 0.7, -sy * 0.75, -30), Vector3(reach * 0.7, sy * 0.75, -30)]
	p.hand_relax = [
		Vector3(reach * 0.12, -sy * 1.05, -reach * 0.9),
		Vector3(reach * 0.12, sy * 1.05, -reach * 0.9)
	]
