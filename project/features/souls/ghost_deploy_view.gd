class_name GhostDeployView
extends Node2D
## One presentation per printed actor layer, shared by combinations of rig and attack hosts.

var stage: CollectCallStage
var reduced_motion: bool
## The print stage's or city view's camera: Tonnage's dump kicks it (null = no kick).
var camera: CameraRig = null
var dump_kick: TonnageDumpKick = TonnageDumpKick.shipped()
var _body: GhostDeployBody = GhostDeployBody.new()
var _fx: GhostDeployEffects = GhostDeployEffects.new()
var _tick: int = -1


static func attach(
	layer: CanvasLayer, source: CollectCallStage, calm: bool, cam: CameraRig = null
) -> void:
	if layer == null or source == null or source.pilot == null or source.pilot.ghosts == null:
		return
	var existing: GhostDeployView = layer.get_node_or_null(^"GhostDeployView") as GhostDeployView
	if existing != null:
		existing.reduced_motion = existing.reduced_motion or calm
		existing.camera = existing.camera if existing.camera != null else cam
		return
	var view: GhostDeployView = GhostDeployView.new()
	view.name = &"GhostDeployView"
	view.stage = source
	view.reduced_motion = calm
	view.camera = cam
	layer.add_child(view)


func _ready() -> void:
	var marker: GhostDeployMarker = GhostDeployMarker.new()
	marker.stage = stage
	marker.z_index = RenderLayers.z(&"actors") - GhostFormView.Z_OVER_RIGS
	add_child(marker)
	_body.stage = stage
	add_child(_body)
	_fx.stage = stage
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
		_fx.visible = _fx.lingers()
		_fx.queue_redraw()
		return
	var age: int = stage.tick - ghost.start_tick
	@warning_ignore("return_value_discarded")
	dump_kick.step(ghost, stage.tick, camera, reduced_motion)
	_body.calm = reduced_motion
	_fx.calm = reduced_motion
	_body.z_index = RenderLayers.z(&"actors") + GhostFormView.Z_OVER_RIGS
	_fx.z_index = RenderLayers.z(&"vehicles") + 1
	if ghost.form == OhmStage.GHOST:
		# The squad paints its turret and shield on the FX band, including during the short.
		_body.z_index = RenderLayers.z(&"fx") + 1
		_fx.z_index = _body.z_index + 1
	elif ghost.form == HaulerStage.GHOST:
		_fx.z_index = RenderLayers.z(&"actors") - 2
	_body.show_strike(ghost, age, mini(age + 1, steps))
	_fx.show()
	_fx.queue_redraw()
