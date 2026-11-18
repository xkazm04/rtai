class_name ArenaSquadLooks
extends RefCounted
## Existing cast variants and the production melee windup rendered on the rig's strike clip.

## The riot cop's look (RigVariant.crowd: the shield), worn by the pit's --riot guards.
const RIOT_LOOK: int = 6
const PATROL_LOOK: int = 5

var _swing_start: Dictionary[int, int] = {}


## human-reactions' patrol/riot/SWAT mix by actor id; under --riot the shield is worn only by
## the pit's armored riot cops (the mix's other riot picks dress as patrol).
static func look(h: Fighter, riot_enabled: bool, armored: bool) -> int:
	if h.archetype == &"swat":
		return RigVariant.SWAT
	if h.archetype == &"riot_cop":
		return RIOT_LOOK
	if h.archetype in [&"patrol_cop", &"contractor"]:
		return PATROL_LOOK
	var squad: int = RigVariant.squad_index_for(h.id)
	if not riot_enabled:
		return squad
	if armored:
		return RIOT_LOOK
	return PATROL_LOOK if squad == RIOT_LOOK else squad


func swing(h: Fighter, feed: RigFeed, i: int) -> void:
	if h.swing_left == 0 or not h.alive():
		@warning_ignore("return_value_discarded")
		_swing_start.erase(h.id)
		return
	if _swing_start.get(h.id, -1) != h.swing_tick:
		_swing_start[h.id] = h.swing_tick
		feed.clip[i] = RigClips.Clip.STRIKE
		feed.clip_arg[i] = RigInput.pack_strike(h.swing_left, 4, 12, BodyPlan.R)
