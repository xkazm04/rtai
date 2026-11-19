class_name VehicleService
extends WorldSystem
## The player's cars (ARC-04 sim system on the 60 Hz tick): enter a parked car, hijack an occupied
## sim car (its driver is thrown out), drive it with the VehicleBody handling, crash it (damage
## states, then a wreck that stays wreck_s seconds), run people over, and get out again.
## API: try_enter(at) / exit() / driving / soul_hijack_traffic(slot); README.md has the rest.

const BIT_USE: int = 0
const BIT_HANDBRAKE: int = 1
const ENTER_R: float = 3.6
const DOOR_OFF: float = 2.0

var world: VehicleWorld = VehicleWorld.new()
var profiles: Dictionary[StringName, VehicleProfile] = {}
var rules: VehicleDamage = null
var doors: VehicleDoors = VehicleDoors.shipped()
## Every car the service owns (parked, driven, wrecks), in creation order.
var cars: Array[VehicleBody] = []
## The car Rivet drives, or null on foot.
var driving: VehicleBody = null
## The sim traffic this service rammed or soul-hijacked (render states, damage).
var traffic: VehicleTraffic = null
## Render cues (crash, wreck, screech, horn) read off the cars after each step.
var cues: VehicleCues = VehicleCues.new()
var last_us: int = 0  ## the last step() in us, and max_us the worst (bench only, not sim state)
var max_us: int = 0
var _contacts: VehicleContacts = null
var _events: EventBus = null
var _next_id: int = 1
var _use_was: bool = false


func setup(ctx: WorldContext) -> void:
	_events = ctx.events
	profiles = VehicleProfile.load_all()
	rules = VehicleDamage.load_rules()
	_contacts = VehicleContacts.new(rules, profiles)
	traffic = VehicleTraffic.new(rules)


## An empty car parked at `at` (missions and tests place them).
func spawn_parked(kind: StringName, at: Vector2, head: Vector2, art: int = 0) -> VehicleBody:
	var p: VehicleProfile = profiles.get(kind, profiles.get(&"sedan"))
	var b: VehicleBody = VehicleBody.new(_next_id, p, at, head)
	b.art = art
	_next_id += 1
	cars.append(b)
	return b


## Enters the nearest empty service car within ENTER_R, else hijacks the nearest sim car.
## Returns the vehicle id, or -1 when nothing is in reach (or already driving).
func try_enter(at: Vector2) -> int:
	if driving != null or doors.car != null:
		return -1
	world.refresh()
	var best: VehicleBody = null
	for b: VehicleBody in cars:
		var d: float = b.pos.distance_to(at)
		if (
			b.state != VehicleBody.State.WRECK
			and d < ENTER_R
			and (best == null or d < best.pos.distance_to(at))
		):
			best = b
	var parked: bool = best != null
	if not parked:
		best = traffic.hijack(at, self, _events)
	if best == null:
		return -1
	if doors.enabled and (parked or best.speed() == 0.0):
		return best.id if doors.begin(self, best, at, true) else -1
	seat(best)
	return best.id


func seat(b: VehicleBody) -> void:
	driving = b
	world.set_focus(b.pos, true)
	_events.vehicle_entered.emit(b.id)


## Gets out on the driver's side; the car stays where it stops. Returns where Rivet stands.
func exit() -> Vector2:
	if driving == null or doors.car != null:
		return world.player_pos()
	var b: VehicleBody = driving
	var door: Vector2 = b.pos + Vector2(b.head.y, -b.head.x) * DOOR_OFF
	if doors.enabled:
		if b.speed() < doors.exit_max_mps and b.state != VehicleBody.State.WRECK:
			return doors.foot if doors.begin(self, b, door, false) else b.pos
		door = VehicleDoorPath.clear_side(self, b, doors.radius)
		if door == Vector2.INF:
			return b.pos
	finish_exit(b, door)
	return door


func finish_exit(b: VehicleBody, at: Vector2) -> void:
	driving = null
	world.set_focus(at, false)
	_events.vehicle_exited.emit(b.id)


## "Hijacked by the soul" (Gearbox): the teal plate on a sim car, until it takes damage.
func soul_hijack_traffic(slot: int) -> void:
	traffic.soul_hijack(slot, world)


## The same for a service car (parked or driven): the teal plate shows while it is undamaged.
func soul_hijack(vehicle_id: int) -> void:
	for b: VehicleBody in cars:
		if b.id == vehicle_id:
			b.soul_hijacked = true
			b.state = rules.state_for(b.hp_lost, true)


func step(tick: int, input: TickInput) -> void:
	var t0: int = Time.get_ticks_usec()
	_step(input)
	cues.observe(cars, driving, _contacts.traffic_hits.size(), tick, world)
	last_us = Time.get_ticks_usec() - t0
	max_us = maxi(max_us, last_us)


func _step(input: TickInput) -> void:
	world.refresh()
	var use: bool = input.is_pressed(BIT_USE)
	if use and not _use_was:
		if driving == null:
			@warning_ignore("return_value_discarded")
			try_enter(world.player_pos())
		else:
			@warning_ignore("return_value_discarded")
			exit()
	_use_was = use
	var axis: Vector2 = Vector2(input.move_x, input.move_y) / TickInput.AXIS_MAX
	_contacts.begin()
	for b: VehicleBody in cars:
		var mine: bool = b == driving and b != doors.car
		var hb: bool = input.is_pressed(BIT_HANDBRAKE) if mine else true
		b.step(SimClock.TICK_DT, -axis.y if mine else 0.0, axis.x if mine else 0.0, hb)
		_collide(b)
	_age_wrecks()
	world.set_obstacles(VehicleContacts.hull_points(cars))
	for slot: int in traffic.settle(_contacts.traffic_hits, _contacts.traffic_art, world):
		traffic.take(slot, world, self)
	for k: int in range(0, _contacts.struck.size(), 2):
		_events.pedestrian_struck.emit(_contacts.struck[k], _contacts.struck[k + 1] == 1)
	if doors.car != null:
		doors.advance(self)
	elif driving != null:
		world.set_focus(driving.pos, true)
		if driving.state == VehicleBody.State.WRECK:
			@warning_ignore("return_value_discarded")
			exit()


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(cars.size())
	out.put_32(driving.id if driving != null else 0)
	for b: VehicleBody in cars:
		for f: float in [
			b.pos.x, b.pos.y, b.head.x, b.head.y, b.vel.x, b.vel.y, b.hp_lost, b.spin, b.wheel
		]:
			out.put_double(f)
		out.put_32(b.state)
	doors.write_state(out)


## A standing car (parked, a wreck) still meets traffic: it is shoved and both cars take damage.
func _collide(b: VehicleBody) -> void:
	_contacts.traffic(b, world)
	_contacts.burn(b, world)
	if b.speed() < 0.05 and b != driving:
		return
	_contacts.hull(b, world)
	_contacts.people(b, world)
	for o: VehicleBody in cars:
		if o != b:
			_contacts.pair(b, o)


func _age_wrecks() -> void:
	for k: int in range(cars.size() - 1, -1, -1):
		var b: VehicleBody = cars[k]
		if b.state == VehicleBody.State.WRECK and b != driving:
			b.wreck_t += SimClock.TICK_DT
			if b.wreck_t > rules.wreck_s:
				cars.remove_at(k)
