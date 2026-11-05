class_name TonnageHook
extends ArenaHook
## The ghosts' attack views in the arena (station `hauler_pad`, arena_stations/ghost-powers.json),
## lane ghost-powers: Tonnage's slam telegraph and landing marks, Dent's tether, heat and blast,
## Kerf's blink lines and cuts, Ohm's bolts (GhostAttackViews, shared with quest 1) on the printed
## path's actor layer (or the city block's), for the bound player's StagePilot. Sim-free: the
## attacks themselves run in the ghost stages through StagePilot, so quest 1 and the arena share
## one code path.

var views: GhostAttackViews = null
var _stage: ArenaStage = null


func setup(stage: ArenaStage, _ctx: WorldContext) -> void:
	_stage = stage


func attach_view(p_view: Node) -> void:
	var cc: CollectCallView = p_view as CollectCallView
	if cc == null or _stage == null:
		return
	var reduced: bool = LaunchArgs.has("--reduced-motion")
	views = GhostAttackViews.attach(GhostAttackViews.layer_of(cc), _stage, reduced, true)
	if views != null and views.dent != null and "--cam=car" in OS.get_cmdline_user_args():
		views.dent.follow_cam = cc
