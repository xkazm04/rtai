class_name VehicleFrameSetup
extends RefCounted
## Builds vehicle_frame's world the way World._register_features does (city, vehicles, view with
## the camera rig listening to Events, characters, the vehicle view), parks a sedan on the first
## long east-bound lane near the city start, stands Rivet beside it and a pedestrian in the lane
## 26 m ahead. Route: the fixed input plan (enter at tick 30).

const LANE_TILES: int = 10
## The yield scene parks the sedan this far into the straight (mid-block, as in
## scenario_vehicle_yield) and stands Rivet on the kerb, so the cars behind can pass it.
const PARK_AHEAD_M: float = 24.0

## --scene=yield: three sim cars come up behind the parked sedan (traffic yields to service cars).
static var chasers: bool = false
## --blind: the port drops the obstacle feed (traffic cannot see service cars: the "before").
static var blind: bool = false
## --car-zoom: the camera starts in the car mode (48 px/m) even on foot (the yield scene at 48).
static var car_zoom: bool = false
## --grade=<id>: a lights.json grade (night shows the car and fire lights).
static var grade: StringName = &""


class Blind:
	extends CityVehicleWorld

	func set_obstacles(_xy: PackedFloat64Array) -> void:
		pass


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


class Carnage:
	extends Route
	const RAM: Array[Array] = [
		[30, 0, 0, 0],
		[31, USE, 0, 0],
		[200, 0, 0, -A],
		[300, 0, 0, A],
		[400, 0, 0, -A],
		[500, 0, 0, A],
		[600, 0, 0, -A],
		[700, 0, 0, A],
		[748, 0, 0, -A],
		[1 << 30, 0, 0, 0],
	]

	func sample(tick: int) -> TickInput:
		for row: Array in RAM:
			var until: int = row[0]
			var buttons: int = row[1]
			var mx: int = row[2]
			var my: int = row[3]
			if tick < until:
				return TickInput.new(buttons, mx, my)
		return TickInput.new()


## --scene=depth (n8): Rivet walks a loop round the parked sedan, behind it (north: the card covers
## him) and in front of it (south: he must draw over the card), every LOOP ticks.
class Depth:
	extends Route
	## Walking pace: the focus moves at CitySystem.FOCUS_SPEED * axis / 127 (16 = 3.1 m/s).
	const W: int = 16
	const LOOP: int = 410
	const WALK: Array[Array] = [
		[20, 0, 0, 0],
		[80, 0, -W, 0],
		[160, 0, 0, W],
		[270, 0, W, 0],
		[350, 0, 0, -W],
		[LOOP, 0, -W, 0],
	]

	func sample(tick: int) -> TickInput:
		for row: Array in WALK:
			var until: int = row[0]
			var mx: int = row[2]
			var my: int = row[3]
			if tick % LOOP < until:
				return TickInput.new(0, mx, my)
		return TickInput.new()


## [VehicleService, CityCharacters, CityView]; `parent` receives the view. carnage: Rivet stands
## by a stopped taxi (to hijack) with a stopped sedan and pickup 40 / 47 m down the lane to ram.
static func build(world: World, parent: Node, look: StringName, carnage: bool) -> Array[Object]:
	var city: CitySystem = CitySystem.new(true)
	world.add_system(city)
	city.spawner.targets = CityTargets.street(140, 6, 1)
	var svc: VehicleService = VehicleService.new()
	world.add_system(svc)
	var vw: CityVehicleWorld = Blind.new(city) if blind else CityVehicleWorld.new(city)
	svc.world = vw
	city.residency.update(city.focus)
	_stage(city, svc, vw, carnage)
	var view: CityView = CityView.new()
	if look != &"":
		view.look_id = look
	view.rig = CameraRig.new()
	view.rig.snap(&"car" if car_zoom else &"on_foot")
	view.rig.listen(Events, world.context().clock)
	parent.add_child(view)
	view.setup(city)
	if grade != &"":
		view.lights.set_grade(grade)
	view.fx_triggers.player_id = CityCharacters.RIVET_ID
	var rivet_px: Callable = func() -> Vector2: return city.target * SimConst.PX_PER_M
	view.fx_triggers.listen(Events, world.context().clock, rivet_px)
	var characters: CityCharacters = CityCharacters.new(city, view, world.context())
	vw.characters = characters
	view.actor_layer().add_child(CityVehicleWorld.make_view(svc, view))
	return [svc, characters, view]


## Parks the scene's cars and stands Rivet on the first long east-bound lane.
static func _stage(
	city: CitySystem, svc: VehicleService, vw: CityVehicleWorld, carnage: bool
) -> void:
	var lane: Vector2 = east_lane(city)
	if chasers:
		lane += Vector2(PARK_AHEAD_M, 0.0)
	vw.set_focus(lane + Vector2(0.5, -6.5 if chasers else -2.2), false)
	if carnage:
		for c: Vector3 in [Vector3(0, 3, 0), Vector3(40, 0, 0), Vector3(47, 5, 0)]:
			var at: Vector2 = lane + Vector2(c.x, 0)
			var spec: Array = [SimConst.K_CAR, at.x, at.y, 1, 0, c.y, 0, 0.0, at.y, 0]
			@warning_ignore("return_value_discarded")
			city.sim.spawn(PackedFloat64Array(spec))
	else:
		@warning_ignore("return_value_discarded")
		svc.spawn_parked(&"sedan", lane, Vector2.RIGHT, 0)
		for back: float in [20.0, 34.0, 48.0] if chasers else []:
			var at: Vector2 = lane - Vector2(back, 0.0)
			var car: Array = [SimConst.K_CAR, at.x, at.y, 1.0, 0.0, int(back) % 5, 0, 12.0, at.y, 0]
			@warning_ignore("return_value_discarded")
			city.sim.spawn(PackedFloat64Array(car))
		if chasers:
			return
		var ped: Vector2 = lane + Vector2(26.0, 0.0)
		var spec: Array = [SimConst.K_PED, ped.x, ped.y, 0, 1, 2, 0, 0.0, 0, 0]
		@warning_ignore("return_value_discarded")
		city.sim.spawn(PackedFloat64Array(spec))


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
