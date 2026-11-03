class_name KingPlan
extends RefCounted
## King, the robot gang boss, on Rivet's cutout rig (d5-cast, 2026-11-03; was a static plan-view
## sprite, art/d5/king/king_top.png). Same skeleton and part layout as Rivet (art/king/ carries
## Rivet's part names, sizes and pivots: the layout-template technique, King's parts restyled in
## one Codex edit and sliced with Rivet's alpha), except the megaphone forearm (r_forearm), keyed
## wider than the torch. No hose. A boss: a touch bigger than Rivet's base form.

const SIZE_K: float = 1.3


static func build() -> BodyPlan:
	var p: BodyPlan = RivetPlan.build(RivetPlan.FORM_BASE)
	p.name = "king"
	p.art_dir = "king"
	p.size_k = SIZE_K
	p.hose_tex = ""
	return p
