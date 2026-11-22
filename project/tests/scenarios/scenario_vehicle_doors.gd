extends Scenario
## The same three-second drive and slow exit used for the door film, on the real city port.
## Replay compares the stage/RNG hash, checkpoints, input and events; also compare foot positions.

const SEED: int = 31


class Drive:
	extends RefCounted
	var world: World = World.new()
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var svc: VehicleService = VehicleService.new()
	var trace: PackedVector2Array = []
	var log: ReplayLog
	var failure: String

	func start() -> void:
		world.start(bus, data, SEED)
		var city: CitySystem = CitySystem.new(true)
		world.add_system(city)
		city.spawner.targets = CityTargets.street(0, 0, 0)
		city.residency.update(city.focus)
		svc.world = CityVehicleWorld.new(city)
		world.add_system(svc)
		var lane: Vector2 = VehicleFrameSetup.east_lane(city)
		var car: VehicleBody = svc.spawn_parked(&"sedan", lane, Vector2.LEFT)
		VehicleDoorRoute.park(svc, car, lane)

	func drive(source: InputSource) -> void:
		var parked: Vector2 = svc.cars[0].pos
		world.loop().set_input(source)
		world.loop().start_recording()
		for i: int in VehicleDoorRoute.EXIT + svc.doors.exit_ticks + 1:
			world.loop().step()
			var foot: Vector2 = svc.world.player_pos()
			@warning_ignore("return_value_discarded")
			trace.append(foot)
			failure = _check_tick(i, foot)
			if failure != "":
				break
		if failure == "" and parked.distance_to(svc.cars[0].pos) < 5.0:
			failure = "the scripted drive did not travel five metres"
		log = world.loop().finish_recording()

	func _check_tick(i: int, foot: Vector2) -> String:
		var d: VehicleDoors = svc.doors
		var entering: bool = (
			i >= VehicleDoorRoute.ENTER and i < VehicleDoorRoute.ENTER + d.enter_ticks - 1
		)
		var leaving: bool = (
			i >= VehicleDoorRoute.EXIT and i < VehicleDoorRoute.EXIT + d.exit_ticks - 1
		)
		if (entering or leaving) != (d.car != null):
			var car: VehicleBody = svc.cars[0]
			var door: Vector2 = VehicleDoorPath.driver_door(car, d.radius)
			return (
				"duration at %d: enabled %s foot %s car %s door %s clear %s"
				% [
					i,
					d.enabled,
					foot,
					car.pos,
					door,
					VehicleDoorPath.clear(svc, foot, door, d.radius)
				]
			)
		if (
			d.car != null
			and (d.entering != entering or not VehicleDoorPath.clear(svc, foot, foot, d.radius))
		):
			return "wrong phase or foot collision at tick %d pos %s" % [i, foot]
		var seated: bool = (
			i >= VehicleDoorRoute.ENTER + d.enter_ticks - 1
			and i < VehicleDoorRoute.EXIT + d.exit_ticks - 1
		)
		if seated != (svc.driving != null):
			return "wrong seat ownership at tick %d" % i
		return ""

	func close() -> void:
		world.free()
		bus.free()
		data.free()


func run(_tree: SceneTree) -> String:
	var saved: PackedStringArray = LaunchArgs.unknown()
	for flag: String in LaunchArgs.KNOWN_FLAGS:
		if LaunchArgs.has(flag):
			@warning_ignore("return_value_discarded")
			saved.append("%s=%s" % [flag, LaunchArgs.value(flag)])
	LaunchArgs.parse(saved + PackedStringArray(["--car-doors"]))
	var first: Drive = Drive.new()
	first.start()
	first.drive(VehicleDoorRoute.new())
	first.close()
	var reason: String = first.failure
	if reason == "":
		var second: Drive = Drive.new()
		second.start()
		second.drive(ReplayInput.new(first.log))
		second.close()
		reason = second.failure
		if reason == "":
			reason = first.log.first_divergence(second.log)
		if reason == "" and first.trace != second.trace:
			reason = "door foot trace diverged"
	LaunchArgs.parse(saved)
	if reason == "":
		Log.info("vehicle_doors", "enter, drive, exit: two identical tapes " + first.log.final_hash)
	return reason
