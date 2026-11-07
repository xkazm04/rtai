class_name QuestGuardCast
extends RefCounted
## n8-view it14: under the rig cast (quest 1's shipped card path, ArenaRigs) the quest's
## contractors (Fighter GUARD, the hi-vis dock guards with rifles) stay on the cast view, where the
## street lane's drawn dock-guard cards stand and lie (StreetQuestCards), instead of dressing as
## blue police rigs (police blue is for police only). Rivet, the boss and the dev arena's fighters
## keep their rigs. ON false = every quest fighter on the rigs as cops (n8-view it7).

const ON: bool = true


## True when `h` is a quest 1 contractor the cast view draws (never in an ArenaStage).
static func takes(stage: CollectCallStage, h: Fighter) -> bool:
	return ON and not stage is ArenaStage and h.kind == Fighter.Kind.GUARD
