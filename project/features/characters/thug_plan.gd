class_name ThugPlan
extends RefCounted
## The robot thug (enemies.json robot_thug): a squat street-gang brawler on Rivet's cutout rig,
## its own proportions, no longer King's plan at a smaller size (lane human-reactions, brief
## item 5). Short legs on a wide stance, long heavy arms that reach for the claw swing, the head
## carried low and forward, short heavy steps. No collar (vermilion is Rivet's collar only), no
## hose. It wears its own parts (art/thug/, weapon-art dae102b7: Rivet's layout in dark gunmetal,
## one round optic, no red, no vermilion), so ART_DIR is the one line to swap back to "king".

const SIZE_K: float = 1.05
const ART_DIR: String = "thug"
const LEG_K: float = 0.82
const STANCE_K: float = 1.25
const ARM_K: float = 1.15
const ARM_W: float = 1.3
const GAIT_K: float = 0.85
## Part px the head sits further forward than Rivet's (a low, forward-carried head).
const HEAD_FWD: float = 8.0


static func build(size_k: float = SIZE_K) -> BodyPlan:
	var p: BodyPlan = RivetPlan.build(RivetPlan.FORM_OPEN)
	p.name = "thug"
	p.art_dir = ART_DIR
	p.size_k = size_k
	p.collar_part = ""
	p.hose_tex = ""
	p.d5_warm = 0.0  # the warm tan close-up steel is Rivet's own read (n5-cast)
	p.thigh_len *= LEG_K
	p.thigh_draw *= LEG_K
	p.shin_len *= LEG_K
	p.shin_draw *= LEG_K
	p.hip_y *= STANCE_K
	p.head_pos.x += HEAD_FWD
	p.upper_len *= ARM_K
	p.upper_draw *= ARM_K
	for s: int in 2:
		p.fore_len[s] *= ARM_K
		p.fore_draw[s] *= ARM_K
		p.hand_ready[s] = _toward(p.shoulder[s], p.hand_ready[s], ARM_K)
		p.hand_relax[s] = _toward(p.shoulder[s], p.hand_relax[s], ARM_K)
	p.arm_w *= ARM_W
	p.gait_scale *= GAIT_K
	return p


static func _toward(sh: Vector3, tgt: Vector3, k: float) -> Vector3:
	return sh + (tgt - sh) * k
