class_name StreetKnockdown
extends RefCounted
## n17 npc-react (owner: "impact on npcs are terrible"; brief item 5, a blast lifts; DEFECTS 11): a
## LIVING knockdown (a blast, Dent's ram, a stomp: human_reactions.json knockdown, "falls along the
## hit, slides, lies 1.4 s, gets up") drew no fall on a street person: StreetWalkerFall.down() was
## dying-or-dead only, so the whole figure stood upright under a lean for 2.2 s. Now the person's
## own fall grid plays it: buckle -> mid-fall -> lying over the first FALL_END of the family, the
## lying frame until RISE_AT, the frames back up to the buckle by UP_END, then the walk again. No
## dead-plan (the lying frame is the grid's own), faced along the blow like a death's fall.
## ON false = the before (the upright lean).
const ON: bool = true
const KIND: StringName = &"knockdown"
## Of the knockdown's progress: down by FALL_END, lies until RISE_AT, standing again at UP_END.
const FALL_END: float = 0.12
const RISE_AT: float = 0.78
const UP_END: float = 0.92


## True while `rig` is knocked down and not yet back on its feet (a living fall).
static func down(rig: CutRig) -> bool:
	var r: HumanReact = rig.react
	return ON and r != null and not r.dying and r.kind == KIND and r.progress() < UP_END


## The death-fall progress the knockdown's progress `p` draws as (StreetWalkerFall.fall_frame):
## the fall's own span down, its lying frame held, the span played back to 0 on the way up.
static func fall_progress(p: float) -> float:
	var lying: float = StreetWalkerFall.FALL_AT[StreetWalkerFall.FALL_AT.size() - 1]
	if p < FALL_END:
		return lying * p / FALL_END
	if p < RISE_AT:
		return lying
	return lying * maxf(1.0 - (p - RISE_AT) / (UP_END - RISE_AT), 0.0)
