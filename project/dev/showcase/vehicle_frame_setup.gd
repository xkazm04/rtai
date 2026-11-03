class_name VehicleFrameSetup
extends RefCounted
## Builds vehicle_frame's world the way World._register_features does (city, vehicles, view with
## the camera rig listening to Events, characters, the vehicle view), parks a sedan on the first
## long east-bound lane near the city start, stands Rivet beside it and a pedestrian in the lane
## 26 m ahead. Route: the fixed input plan (enter at tick 30).

const LANE_TILES: int = 10


class Route:
	extends InputSource
	const USE: int = 1 << VehicleService.BIT_USE
	const HB: int = 1 << VehicleService.BIT_HANDBRAKE
	const A: int = TickInput.AXIS_MAX
	## [until tick, buttons, move_x, move_y], first match wins.
	const PLAN: Array[Array] = [
		[30, 0, 0, 0],
		[31, USE, 0, 0],
		[195, 0, 0, -A],
		[210, 0, 64, -A],
		[225, 0, -64, -A],
		[355, 0, 0, -A],
		[415, HB, -A, -64],
		[585, 0, 0, A],
		[1 << 30, 0, 0, 0],
	]

	func sample(tick: int) -> TickInput:
		for row: Array in PLAN:
			var until: int = row[0]
			var buttons: int = row[1]
			var mx: int = row[2]
			var my: int = row[3]
			if tick < until:
				return TickInput.new(buttons, mx, my)
		return TickInput.new()


## [VehicleService, CityCharacters, CityView]; `parent` receives the view.
static func build(world: World, parent: Node, look: StringName) -> Array[Object]:
	var city: CitySystem = CitySystem.new(true)
	world.add_system(city)
	city.spawner.targets = CityTargets.street(140, 6, 1)
	var svc: VehicleService = VehicleService.new()
	world.add_system(svc)
	var vw: CityVehicleWorld = CityVehicleWorld.new(city)
	svc.world = vw
	city.residency.update(city.focus)
	var lane: Vector2 = east_lane(city)
	@warning_ignore("return_value_discarded")
	svc.spawn_parked(&"sedan", lane, Vector2.RIGHT, 0)
	vw.set_focus(lane + Vector2(0.5, -2.2), false)
	var ped: Vector2 = lane + Vector2(26.0, 0.0)
	@warning_ignore("return_value_discarded")
	city.sim.spawn(PackedFloat64Array([SimConst.K_PED, ped.x, ped.y, 0, 1, 2, 0, 0.0, 0, 0]))
	var view: CityView = CityView.new()
	if look != &"":
		view.look_id = look
	view.rig = CameraRig.new()
	view.rig.snap(&"on_foot")
	view.rig.listen(Events, world.context().clock)
	parent.add_child(view)
	view.setup(city)
	view.fx_triggers.player_id = CityCharacters.RIVET_ID
	var rivet_px: Callable = func() -> Vector2: return city.target * SimConst.PX_PER_M
	view.fx_triggers.listen(Events, world.context().clock, rivet_px)
	var characters: CityCharacters = CityCharacters.new(city, view, world.context())
	vw.characters = characters
	view.actor_layer().add_child(CityVehicleWorld.make_view(svc, view))
	return [svc, characters, view]


## The east-bound lane of the first east-west road with LANE_TILES road tiles ahead.
static func east_lane(city: CitySystem) -> Vector2:
	var s: Vector2 = city.focus
	for dy: int in range(0, 24):
		for sgn: int in [1, -1]:
			var y: float = floorf(s.y / 8.0) * 8.0 + 4.0 + dy * sgn * 8.0
			for dx: int in range(-12, 12):
				var x: float = floorf(s.x / 8.0) * 8.0 + 4.0 + dx * 8.0
				if _straight(city, x, y):
					return Vector2(x, y + CitySimState.LANE_OFF[0])
	return s


static func _straight(city: CitySystem, x: float, y: float) -> bool:
	for k: int in LANE_TILES:
		if city.sim.tile_at(x + k * 8.0, y) != SimConst.T_ROAD_H:
			return false
	return true
