class_name GhostNumberKeys
extends RefCounted
## Number slots follow ghost_forms.json deploy_slots (1 Dent, 2 Tonnage, 3 Kerf, 4 Ohm), never the
## row order. The pad has its own cycle order.

const ACTIONS: Array[StringName] = [
	&"ghost_deploy_1", &"ghost_deploy_2", &"ghost_deploy_3", &"ghost_deploy_4"
]


static func action(table: GhostFormTable, id: StringName) -> StringName:
	var slot: int = table.deploy_slots.find(id)
	return ACTIONS[slot] if slot >= 0 and slot < ACTIONS.size() else &""


static func hint(table: GhostFormTable, id: StringName) -> String:
	var binding: StringName = action(table, id)
	var label: String = ObjectiveHint.key_name(binding)
	return "" if label == String(binding) else label


static func pressed(c: PlayerCommand, actions: PlayerActions, forms: GhostForms) -> StringName:
	for i: int in mini(ACTIONS.size(), forms.table.deploy_slots.size()):
		if c.was_pressed(actions, ACTIONS[i]):
			var id: StringName = forms.table.deploy_slots[i]
			if forms.locks.allows(forms.table, id):
				return id
	return &""


static func in_car(stage: CollectCallStage) -> bool:
	var svc: VehicleService = stage.vehicles
	return svc != null and (svc.driving != null or svc.doors.car != null)


## The stage runs before its vehicle service. A shared press near a possible seat waits
## for the service's decision. Only the vehicle service attempts entry or changes seats.
static func car_may_enter(svc: VehicleService) -> bool:
	if svc == null:
		return false
	var at: Vector2 = svc.world.player_pos()
	for body: VehicleBody in svc.cars:
		if (
			body.state != VehicleBody.State.WRECK
			and body.pos.distance_to(at) < VehicleService.ENTER_R
		):
			return true
	return not svc.world.cars_near(at, VehicleService.ENTER_R + 1.0).is_empty()
