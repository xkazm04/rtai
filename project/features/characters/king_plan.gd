class_name KingPlan
extends RefCounted
## King, the robot gang boss, on Rivet's cutout rig (d5-cast, 2026-11-03; was a static plan-view
## sprite, art/d5/king/king_top.png). Same skeleton and part layout as Rivet (art/king/ carries
## Rivet's part names, sizes and pivots: the layout-template technique, King's parts restyled in
## one Codex edit and sliced with Rivet's alpha), except the megaphone forearm (r_forearm), keyed
## wider than the torch. No hose. A boss: a touch bigger than Rivet's base form, in the open guard
## (Rivet's base form hunches; King squares up).

const SIZE_K: float = 1.3


## size_k: the boss scale (an arena dial; the owner may pick a smaller King, see rig_footprint).
static func build(size_k: float = SIZE_K) -> BodyPlan:
	var p: BodyPlan = RivetPlan.build(RivetPlan.FORM_OPEN)
	p.name = "king"
	p.art_dir = "king"
	p.size_k = size_k
	p.hose_tex = ""
	p.head_visor = false  # the star crown has no visor slot (n5-cast)
	p.core_tan = false  # the tan work-plate sticker is Rivet's own read (n5-cast)
	p.d5_warm = 0.0  # the warm tan close-up steel is Rivet's own read (n5-cast)
	return p
