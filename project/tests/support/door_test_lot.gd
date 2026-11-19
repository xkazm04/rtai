class_name DoorTestLot
extends VehicleWorld
## A parked-car test lot with one optional solid cell and one optional traffic record.

var foot: Vector2 = Vector2(1.6, 3.0)
var blocked: bool = false
var enclosed: bool = false
var sim_cars: PackedFloat64Array = []


func solid(x: float, y: float) -> bool:
	return enclosed or (blocked and floori(x) == 0 and floori(y) == 2)


func cars_near(_p: Vector2, _r: float) -> PackedFloat64Array:
	return sim_cars


func take_car(_slot: int) -> void:
	sim_cars.clear()


func player_pos() -> Vector2:
	return foot


func set_focus(p: Vector2, _seated: bool) -> void:
	foot = p
