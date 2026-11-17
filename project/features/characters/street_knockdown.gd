class_name StreetKnockdown
extends RefCounted
## n17 npc-react (owner: "impact on npcs are terrible"; brief item 5, a blast lifts; DEFECTS 11): a
## LIVING knockdown (a blast, Dent's ram, a stomp: human_reactions.json knockdown, 2.2 s) let the
## parts draw him lying, then popped from lying straight to standing (film k_0a65_64 t130 -> t150).
## Now the person's own fall grid plays it: buckle -> mid-fall -> lying over the first FALL_END
## (about as fast as the parts went down: t72), the lying frame until RISE_AT, the frames back up
## to the buckle by UP_END, then the walk. No dead-plan, faced along the blow like a death's fall.
## ON false = the before.
const ON: bool = true
const KIND: StringName = &"knockdown"
## Of the knockdown's progress: down by FALL_END, lies until RISE_AT, standing again at UP_END.
const FALL_END: float = 0.04
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
