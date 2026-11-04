class_name TonnageHook
extends ArenaHook
## Tonnage in the arena (station `hauler_pad`, arena_stations/ghost-powers.json), lane
## ghost-powers: the slam's telegraph and landing marks on the printed path's actor layer (or the
## city block's), for the bound player's HaulerStage. Sim-free: the attack itself runs in
## HaulerStage through StagePilot, so quest 1 and the arena share one code path.

var view: TonnageView = null
var _stage: ArenaStage = null


func setup(stage: ArenaStage, _ctx: WorldContext) -> void:
	_stage = stage


func attach_view(p_view: Node) -> void:
	var cc: CollectCallView = p_view as CollectCallView
	if cc == null or _stage == null or _stage.pilot == null or _stage.pilot.hauler == null:
		return
	var layer: CanvasLayer = null
	if cc.print_stage != null:
		layer = cc.print_stage.actor_layer()
	elif cc.city_view != null:
		layer = cc.city_view.actor_layer()
	if layer == null:
		return
	view = TonnageView.new()
	view.z_index = RenderLayers.z(&"actors") - 2
	view.ppm = SimConst.PX_PER_M
	view.reduced_motion = LaunchArgs.has("--reduced-motion")
	view.hauler = _stage.pilot.hauler
	view.stage = _stage
	layer.add_child(view)
