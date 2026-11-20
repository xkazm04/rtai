class_name DentCarTop
extends RefCounted
## The road print removes spot colours. Draw the held flat car once on Dent's actor canvas,
## with the tilt shader's soul paint and the original top atlas footprint.

const ATLAS: Texture2D = preload("res://features/city/art/vehicles/traffic_atlas.png")

var node: MultiMeshInstance2D = VehicleCardMesh.make(1, preload(VehicleCards.SHADER), 3, 4)


func _init(parent: DentView) -> void:
	node.texture = ATLAS
	node.z_as_relative = false
	node.z_index = RenderLayers.z(&"actors") - 1
	node.hide()
	parent.add_child(node)
	node.add_to_group(_group(parent.stage))


## Only suppress the road body if its replacement is actually visible in this viewport.
static func covers(floor_view: CanvasItem, stage: CollectCallStage, car: VehicleBody) -> bool:
	if car.state != VehicleBody.State.HIJACKED:
		return false
	for item: Node in floor_view.get_tree().get_nodes_in_group(_group(stage)):
		var plate: CanvasItem = item as CanvasItem
		if plate.get_viewport() == floor_view.get_viewport() and plate.is_visible_in_tree():
			return true
	return false


func sync(cars: Array[VehicleBody], ppm: float) -> void:
	var count: int = 0
	if ViewMode.shared().is_flat():
		node.scale = Vector2.ONE * ppm / SimConst.PX_PER_M
		var mesh: MultiMesh = node.multimesh
		if mesh.instance_count < cars.size():
			mesh.instance_count = cars.size()
		for car: VehicleBody in cars:
			if car.state != VehicleBody.State.HIJACKED:
				continue
			mesh.set_instance_transform_2d(count, VehicleView.car_xf(car.pos, car.head))
			mesh.set_instance_color(count, Color.WHITE)
			mesh.set_instance_custom_data(count, _cell(car))
			count += 1
	node.multimesh.visible_instance_count = count
	node.modulate = (
		VehicleStageCards.tint_of(VehicleBody.State.HIJACKED) if count > 0 else Color.WHITE
	)
	node.visible = count > 0


static func _cell(car: VehicleBody) -> Color:
	var wear: int = VehicleCards.wear(car.state, car.id)
	return Color(car.art, 0, wear + VehicleCards.duty(car.art, car.vel.length()), 0)


static func _group(stage: CollectCallStage) -> StringName:
	return StringName("dent_flat_car_%d" % stage.get_instance_id())
