class_name VehicleWorld
extends RefCounted
## What the vehicles feature needs from the world around it (LAY-05: vehicles never names the
## city). The composition root hands VehicleService a subclass over the bubble sim
## (boot/city_vehicle_world.gd); tests hand it this base, an empty world with no solids.
## Records are flat floats so a sim snapshot maps onto them without objects.

## cars_near() record: slot, police (0/1), x, y, heading x, heading y, speed, art id.
const CAR_STRIDE: int = 8
## people_near() record: slot, x, y, dead (0/1).
const PERSON_STRIDE: int = 4


## Called once per tick before any query (a subclass caches its snapshot here).
func refresh() -> void:
	pass


func cars_near(_at: Vector2, _radius: float) -> PackedFloat64Array:
	return PackedFloat64Array()


func people_near(_at: Vector2, _radius: float) -> PackedFloat64Array:
	return PackedFloat64Array()


## A solid 1 m cell (building, prop, unloaded) at (x, y).
func solid(_x: float, _y: float) -> bool:
	return false


## Removes a sim car (hijacked, or wrecked and handed over as a body).
func take_car(_slot: int) -> void:
	pass


## The thrown-out driver: a person appears at `at`, facing `away`.
func eject_driver(_at: Vector2, _away: Vector2, _art: int) -> void:
	pass


## A car hit a person at `vel`: true when it killed them (else a knockdown shove).
func strike_person(_slot: int, _vel: Vector2, _kill: bool) -> bool:
	return _kill


## Render-only state of a sim car (VehicleBody.State) for the view's atlas pick (custom.y).
func set_car_state(_slot: int, _state: int) -> void:
	pass


## The bubble centre and pursuit target follow `at` while in_car; on foot the world steers.
func set_focus(_at: Vector2, _in_car: bool) -> void:
	pass


## Where the player stands on foot.
func player_pos() -> Vector2:
	return Vector2.ZERO
