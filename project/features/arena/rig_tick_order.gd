class_name RigTickOrder
extends RefCounted
## n17 npc-react (owner: "precision of reactions on npc"): ArenaRigs fills the rig feed at process
## priority RIG_PRIORITY so CharacterRigs poses from it this frame, but the World (priority 0)
## stepped the sim AFTER it: every cast rig drew the frame's sim one tick old. A struck cop showed
## his wound a tick after the hit (DEFECTS 10: katana hit tick 68, first frame t69), and on a kill
## tick the live rig still stood while the kill's own copy already drew its first cell (two
## figures, DEFECTS 14). The sibling World now steps first (WORLD_FIRST: still after the dev
## frame probes at -4096); `--rig-order=before` keeps the old order (the before of the films).

const RIG_PRIORITY: int = -1
const WORLD_FIRST: int = -2


## Gives `host` (the ArenaRigs) its feed priority and puts its sibling World before it.
static func place(host: Node) -> void:
	host.process_priority = RIG_PRIORITY
	if LaunchArgs.value("--rig-order") == "before" or host.get_parent() == null:
		return
	for ch: Node in host.get_parent().get_children():
		if ch is World:
			ch.process_priority = WORLD_FIRST
