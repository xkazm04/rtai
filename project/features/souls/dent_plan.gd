class_name DentPlan
extends RefCounted
## Dent, the crash-test ghost (TARGETS.md ghost_dent_mechanic.jpg), as a humanoid body plan on
## the shared CutRig: base Rivet's plan (RivetPlan FORM_BASE: lengths, guard, gait) with Dent's
## parts (features/characters/art/dent: the r2 Codex sheet resized to Rivet's part px, pivots at
## the joint discs). No collar, hose, claws or end-on cells: the open hand is drawn on the
## forearm, the pelvis is a blank. size_k is the form row's (ghost_forms.json dent.size_k)
## against base Rivet, so Dent stands about Rivet's height, a touch broader.

const ART_DIR: String = "dent"
const BLANK: String = "blank"


static func build(form_size_k: float = 1.05) -> BodyPlan:
	var p: BodyPlan = RivetPlan.build(RivetPlan.FORM_BASE)
	p.name = "dent"
	p.art_dir = ART_DIR
	p.size_k *= form_size_k
	p.pelvis_part = BLANK
	p.collar_part = ""
	p.hand_open = ""
	p.hand_closed = ""
	p.hand_pistol = ""
	p.hose_tex = ""
	p.endon_upper = PackedStringArray()
	p.endon_fore = PackedStringArray()
	p.foot_toeoff = PackedStringArray()
	return p


## Every part name the plan draws (the test checks each one loads and is measured).
static func parts(p: BodyPlan) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray([p.torso_part, p.head_part, p.pelvis_part])
	for names: PackedStringArray in [p.upper_part, p.fore_part, p.thigh_part, p.shin_part]:
		out.append_array(names)
	out.append_array(p.foot_part)
	return out
