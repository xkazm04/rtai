class_name ArenaCars
extends VehicleWorld
## The powers pad's cars: every station spawn of kind "car" is a parked VehicleService car (the
## vehicles lane's real body, damage states and the soul-hijacked teal plate), so Gearbox (the
## ghost-powers lane's GearboxLink) has real cars to pick, link and drive into enemies, and a
## Hauler ram has something to hit. The arena world is open floor: no traffic, no solids.
## On-foot entry is off (player_pos() is far away): quest 1's stage has no driving seat for Rivet
## yet; the cars move only when a power drives them. ArenaStage.cars() hands them to the hooks.

## Where try_enter() looks for the player: nowhere a car can be.
const NOWHERE: Vector2 = Vector2(1.0e7, 1.0e7)
## The spawn's car model when it names none (vehicle_handling.json row).
const KIND: StringName = &"sedan"
## Traffic atlas art ids for the parked cars (CitySpawner CAR_ART 0-7), cycled by spawn order.
const ART_IDS: int = 8

var service: VehicleService = null


## A VehicleService over ArenaCars added to `world` after the stage (so a power that drives a car
## this tick sees it move the same tick), the stations' cars parked on it; returns the cars' world.
static func attach(world: World, stage: ArenaStage) -> ArenaCars:
	var cars: ArenaCars = ArenaCars.new()
	var svc: VehicleService = VehicleService.new()
	svc.world = cars
	cars.service = svc
	world.add_system(svc)
	stage.vehicles = svc
	Log.info("arena", "powers pad: %d cars parked" % cars.park(stage.stations, stage.plan.base))
	return cars


## Parks one car per "car" spawn (nose east, +x) under `base`; returns how many were parked.
func park(stations: ArenaStations, base: Vector2) -> int:
	var n: int = 0
	for s: ArenaStation in stations.stations:
		for sp: ArenaStation.Spawn in s.spawns:
			if sp.kind != "car":
				continue
			@warning_ignore("return_value_discarded")
			service.spawn_parked(KIND, base + sp.at, Vector2.RIGHT, n % ART_IDS)
			n += 1
	return n


func player_pos() -> Vector2:
	return NOWHERE


## Any station brings cars (the session adds the service only then).
static func wanted(stations: ArenaStations) -> bool:
	for s: ArenaStation in stations.stations:
		for sp: ArenaStation.Spawn in s.spawns:
			if sp.kind == "car":
				return true
	return false
