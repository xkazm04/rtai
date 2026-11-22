class_name GhostDeployView
extends Node2D
## One presentation per printed actor layer, shared by combinations of rig and attack hosts.

var stage: CollectCallStage
var reduced_motion: bool
var _body: GhostDeployBody = GhostDeployBody.new()
var _fx: GhostDeployEffects = GhostDeployEffects.new()
var _tick: int = -1


static func attach(layer: CanvasLayer, source: CollectCallStage, calm: bool) -> void:
	if layer == null or source == null or source.pilot == null or source.pilot.ghosts == null:
		return
	if layer.has_node(^"GhostDeployView"):
		return
	var view: GhostDeployView = GhostDeployView.new()
	view.name = &"GhostDeployView"
	view.stage = source
	view.reduced_motion = calm
	layer.add_child(view)


func _ready() -> void:
	var marker: GhostDeployMarker = GhostDeployMarker.new()
	marker.stage = stage
	marker.z_index = RenderLayers.z(&"actors") - GhostFormView.Z_OVER_RIGS
	add_child(marker)
	_body.stage = stage
	_body.calm = reduced_motion
	_body.z_index = RenderLayers.z(&"actors") + GhostFormView.Z_OVER_RIGS
	add_child(_body)
	_fx.stage = stage
	_fx.calm = reduced_motion
	_fx.body = _body
	add_child(_fx)
	process_priority = 23


func _process(_delta: float) -> void:
	if stage.tick == _tick:
		return
	var steps: int = clampi(stage.tick - _tick, 1, 4)
	_tick = stage.tick
	var ghost: GhostDeploy = stage.pilot.ghosts.deploy
	if ghost.phase != GhostDeploy.Phase.ACTIVE:
		_body.dismiss()
		_fx.hide()
		return
	var age: int = stage.tick - ghost.strike.release_tick
	_body.show_strike(ghost, age, mini(age + 1, steps))
	_fx.z_index = (
		RenderLayers.z(&"vehicles") + 1
		if ghost.form != HaulerStage.GHOST
		else RenderLayers.z(&"actors") - 2
	)
	_fx.show()
	_fx.queue_redraw()
