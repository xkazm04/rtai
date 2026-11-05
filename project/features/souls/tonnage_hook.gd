class_name TonnageHook
extends ArenaHook
## Tonnage in the arena (station `hauler_pad`, arena_stations/ghost-powers.json), lane
## ghost-powers: the slam's telegraph and landing marks on the printed path's actor layer (or the
## city block's), for the bound player's HaulerStage. Sim-free: the attack itself runs in
## HaulerStage through StagePilot, so quest 1 and the arena share one code path.

var view: TonnageView = null
## Dent's tether, heat and blast (the same pad hosts the ghosts' views until each has its own).
var dent_view: DentView = null
## Kerf's blink paths and cut lines (reads stage.pilot.kerf when the reel sets it).
var kerf_view: KerfView = null
## Ohm's bolts (reads stage.pilot.ohm when the reel sets it).
var ohm_view: OhmView = null
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
	if _stage.pilot.dent != null:
		dent_view = DentView.new()
		dent_view.z_index = RenderLayers.z(&"actors") + 1
		dent_view.ppm = SimConst.PX_PER_M
		dent_view.reduced_motion = view.reduced_motion
		dent_view.dent = _stage.pilot.dent
		dent_view.stage = _stage
		if "--cam=car" in OS.get_cmdline_user_args():
			dent_view.follow_cam = cc
		layer.add_child(dent_view)
	kerf_view = KerfView.new()
	kerf_view.z_index = RenderLayers.z(&"actors") + 1
	kerf_view.ppm = SimConst.PX_PER_M
	kerf_view.reduced_motion = view.reduced_motion
	kerf_view.stage = _stage
	layer.add_child(kerf_view)
	ohm_view = OhmView.new()
	ohm_view.z_index = RenderLayers.z(&"actors") + 2
	ohm_view.ppm = SimConst.PX_PER_M
	ohm_view.reduced_motion = view.reduced_motion
	ohm_view.stage = _stage
	layer.add_child(ohm_view)
