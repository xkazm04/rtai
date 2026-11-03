class_name VehicleService
extends WorldSystem
## The player's cars (ARC-04 sim system on the 60 Hz tick): enter a parked car, hijack an occupied
## sim car (its driver is thrown out), drive it with the VehicleBody handling, crash it (damage
## states, then a wreck that stays wreck_s seconds), run people over, and get out again.
## API: try_enter(at) / exit() / driving / soul_hijack_traffic(slot); README.md has the input bits,
## the Events and the render cues (`cues`, VehicleCues).

const BIT_USE: int = 0
const BIT_HANDBRAKE: int = 1
const ENTER_R: float = 3.6
const DOOR_OFF: float = 2.0

var world: VehicleWorld = VehicleWorld.new()
var profiles: Dictionary[StringName, VehicleProfile] = {}
var rules: VehicleDamage = null
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
	if driving != null:
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
	if best == null:
		best = _hijack(at)
	if best == null:
		return -1
	driving = best
	world.set_focus(best.pos, true)
	_events.vehicle_entered.emit(best.id)
	return best.id


## Gets out on the driver's side; the car stays where it stops. Returns where Rivet stands.
func exit() -> Vector2:
	if driving == null:
		return world.player_pos()
	var b: VehicleBody = driving
	driving = null
	var door: Vector2 = b.pos + Vector2(b.head.y, -b.head.x) * DOOR_OFF
	world.set_focus(door, false)
	_events.vehicle_exited.emit(b.id)
	return door


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
	cues.observe(cars, driving, _contacts.traffic_hits.size(), tick)
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
		var mine: bool = b == driving
		var hb: bool = input.is_pressed(BIT_HANDBRAKE) if mine else true
		b.step(SimClock.TICK_DT, -axis.y if mine else 0.0, axis.x if mine else 0.0, hb)
		_collide(b)
	_age_wrecks()
	world.set_obstacles(VehicleContacts.hull_points(cars))
	for slot: int in traffic.settle(_contacts.traffic_hits, _contacts.traffic_art, world):
		traffic.take(slot, world, self)
	for k: int in range(0, _contacts.struck.size(), 2):
		_events.pedestrian_struck.emit(_contacts.struck[k], _contacts.struck[k + 1] == 1)
	if driving != null:
		world.set_focus(driving.pos, true)
		if driving.state == VehicleBody.State.WRECK:
			@warning_ignore("return_value_discarded")
			exit()


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(cars.size())
	out.put_32(driving.id if driving != null else 0)
	for b: VehicleBody in cars:
		for f: float in [b.pos.x, b.pos.y, b.head.x, b.head.y, b.vel.x, b.vel.y, b.hp_lost, b.spin]:
			out.put_double(f)
		out.put_32(b.state)


## A standing car (parked, a wreck) still meets traffic: it is shoved and both cars take damage.
func _collide(b: VehicleBody) -> void:
	_contacts.traffic(b, world)
	if b.speed() < 0.05 and b != driving:
		return
	_contacts.hull(b, world)
	_contacts.people(b, world)
	for o: VehicleBody in cars:
		if o != b:
			_contacts.pair(b, o)


func _hijack(at: Vector2) -> VehicleBody:
	var recs: PackedFloat64Array = world.cars_near(at, ENTER_R + 1.0)
	var best: int = -1
	var best_d: float = INF
	for r: int in range(0, recs.size(), VehicleWorld.CAR_STRIDE):
		var d: float = Vector2(recs[r + 2], recs[r + 3]).distance_to(at)
		if d < best_d:
			best_d = d
			best = r
	if best < 0:
		return null
	var head: Vector2 = Vector2(recs[best + 4], recs[best + 5])
	var police: bool = recs[best + 1] > 0.5
	var kind: StringName = VehicleProfile.archetype_of_variant(int(recs[best + 7]), police)
	var slot: int = int(recs[best])
	var b: VehicleBody = spawn_parked(
		kind, Vector2(recs[best + 2], recs[best + 3]), head, int(recs[best + 7])
	)
	b.vel = head * recs[best + 6]
	b.hp_lost = traffic.lost_of(slot)
	b.soul_hijacked = traffic.soul(slot)
	b.state = rules.state_for(b.hp_lost, b.soul_hijacked)
	traffic.forget(slot, world)
	world.take_car(slot)
	world.eject_driver(
		b.pos + Vector2(b.head.y, -b.head.x) * DOOR_OFF, Vector2(b.head.y, -b.head.x), 0
	)
	_events.vehicle_hijacked.emit(kind)
	return b


func _age_wrecks() -> void:
	for k: int in range(cars.size() - 1, -1, -1):
		var b: VehicleBody = cars[k]
		if b.state == VehicleBody.State.WRECK and b != driving:
			b.wreck_t += SimClock.TICK_DT
			if b.wreck_t > rules.wreck_s:
				cars.remove_at(k)
