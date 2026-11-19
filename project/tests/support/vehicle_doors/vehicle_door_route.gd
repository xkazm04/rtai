class_name VehicleDoorRoute
extends InputSource
## Enter the parked sedan, drive west along the block for three seconds, brake and step out.
## The scenario and the matching 70-degree shots sample exactly these use edges and axes.

const ENTER: int = 120
const DRIVE: int = 134
const EXIT: int = DRIVE + 3 * SimClock.TICK_RATE
const END: int = 10 * SimClock.TICK_RATE


static func park(svc: VehicleService, car: VehicleBody, lane: Vector2) -> void:
	car.pos = lane + Vector2(24.0, -3.0)
	car.head = Vector2.LEFT
	svc.world.set_focus(car.pos + Vector2(1.6, 3.0), false)


func sample(tick: int) -> TickInput:
	if tick == ENTER or tick == EXIT:
		return TickInput.new(1 << VehicleService.BIT_USE)
	if tick >= DRIVE and tick < DRIVE + 125:
		return TickInput.new(0, 0, -56)
	if tick >= DRIVE + 125 and tick < EXIT:
		return TickInput.new(1 << VehicleService.BIT_HANDBRAKE)
	return TickInput.new()
