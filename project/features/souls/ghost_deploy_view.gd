class_name GhostDeployView
extends Node2D
## One presentation per printed actor layer, shared by combinations of rig and attack hosts.

var stage: CollectCallStage
var reduced_motion: bool


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
