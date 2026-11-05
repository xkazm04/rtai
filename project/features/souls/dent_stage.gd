class_name DentStage
extends RefCounted
## Dent (the crash-test ghost; the old gearbox soul), lane ghost-powers, for the bound player on
## an arena stage with cars. power_gearbox (G / RB) seizes the car nearest Rivet's aim line
## (pick_on_line; the teal tether: the car's soul plate shows), and the car drives where he aims
## (Steer: GearboxLink.step, turn-limited; the arena's walls stop it). Every fighter the car hits
## is struck (car_damage, thrown along its nose). Overload: the car heats over overload_s while
## seized; once past arm_k it blows on the next impact (a body or a wall), on a melee press (the
## command) or at full heat: a car-bomb blast of blast_radius_m (blast_damage, weapon dent_blast:
## the gib kill) and the car is wrecked. Tuning: ghost_attacks.json `dent` + powers.json `gearbox`.

const ID: StringName = &"gearbox"
const GHOST: StringName = &"dent"
## A landing spot this close to another car's centre is on that car (a car is ~4.6 x 1.9 m).
const HOP_CLEAR_M: float = 2.6

var powers: SoulPowers
var link: GearboxLink
var attacks: GhostAttacks
## The seized car (null = none), its heat 0..1, and the last blast (tick -1 = none, where).
var car: VehicleBody = null
var heat: float = 0.0
var blast_tick: int = -1
var blast_at: Vector2 = Vector2.ZERO
var strikes: int = 0
var blasts: int = 0
var seizes: int = 0
## Ticks Dent spent riding a seized car's roof (ghost_attacks.json dent.ride).
var rides: int = 0
## Rivet's distance from the last blast (m, -1 = none; ride 0 keeps him clear). Telemetry only.
var blast_gap_m: float = -1.0
## The last seize that found no car (tick, -1 = none) and the aim point it reached for: the view
## lashes the tether out and lets it fray. Not sim state (never read back by the sim).
var miss_tick: int = -1
var miss_to: Vector2 = Vector2.ZERO
var misses: int = 0
var _struck: Dictionary[int, bool] = {}
## ghost-forms: GhostPilot owns the shared SoulPowers; the Dent form is the running gearbox power,
## so a seize needs it running and a let-go never ends it (the form keeps its own clock).
var _shared: bool = false


func _init(table: PowerTable, p_attacks: GhostAttacks = null) -> void:
	attacks = p_attacks if p_attacks != null else GhostAttacks.shipped()
	powers = SoulPowers.new(table)
	link = GearboxLink.new(table.gearbox)
	link.bind(powers)


## ghost-forms: run on GhostPilot's SoulPowers (GhostForms activates the form and ticks it).
func share(p_powers: SoulPowers) -> void:
	powers = p_powers
	link.bind(powers)
	_shared = true


static func shipped() -> DentStage:
	return DentStage.new(PowerTable.load_default())


func num(key: StringName) -> float:
	return attacks.num(GHOST, key)


## One tick: `power` = the G press, `melee` = the overload command, `aim` = Rivet's aim (unit),
## `reach_m` = the cursor's distance (0 = none: the pad). Standing (ride 0) the car drives to the
## point he aims at, the cursor's reach when there is one (d7-calls ghost-powers-3).
func drive(
	stage: CollectCallStage, power: bool, melee: bool, aim: Vector2, reach_m: float = 0.0
) -> void:
	var rivet: Fighter = stage.arena.rivet
	var reticle: Vector2 = rivet.pos + aim.normalized() * num(&"aim_m")  # the seize's aim line
	if stage.vehicles == null:
		# no car service here (the invented quest arena): the press still lashes out and misses
		if power and _shared and rivet.alive() and powers.is_active(ID):
			_miss(stage, reticle)
		return
	if power and car == null and rivet.alive() and _may_seize():
		_seize(stage, reticle)
	if not _shared:
		powers.tick()
	if car == null:
		return
	if not link.linked() or car.state == VehicleBody.State.WRECK:
		_let_go()
		return
	var steer: float = reach_m if reach_m > 0.0 and num(&"ride") <= 0.0 else num(&"aim_m")
	link.step(rivet.pos + aim.normalized() * steer)
	var wall: bool = _wall(stage)
	car.pos = link.pos
	car.head = Vector2.from_angle(link.heading)
	car.vel = car.head * link.speed
	if riding() and rivet.alive():
		rivet.pos = car.pos  # the bucking-bull ride: Dent sits on the roof it steers
		rides += 1
	heat = minf(1.0, heat + SimClock.TICK_DT / maxf(0.1, num(&"overload_s")))
	var hit: bool = _strike(stage) or wall
	if heat >= 1.0 or (heat >= num(&"arm_k") and (hit or melee)):
		_blast(stage)


## True while Dent rides the seized car (ghost_attacks.json dent.ride): the pilot stops his walk.
func riding() -> bool:
	return car != null and num(&"ride") > 0.0


## True while a car is seized (the pilot skips the jab: melee is the overload command).
func owns_melee() -> bool:
	return car != null


func _may_seize() -> bool:
	if _shared:
		return powers.is_active(ID)
	return powers.try_activate(ID) == &"ok"


func _seize(stage: CollectCallStage, reticle: Vector2) -> void:
	var spots: PackedVector2Array = PackedVector2Array()
	var live: Array[VehicleBody] = []
	for b: VehicleBody in stage.cars():
		if b.state != VehicleBody.State.WRECK:
			live.append(b)
			@warning_ignore("return_value_discarded")
			spots.push_back(b.pos)
	var i: int = pick_on_line(stage.arena.rivet.pos, reticle, spots)
	var linked: bool = i >= 0 and link.link(i, spots[i], live[i].head.angle())
	if not linked:
		_miss(stage, reticle)
		if not _shared:
			@warning_ignore("return_value_discarded")
			powers.interrupt(&"car")  # nothing in reach: the soul lets go at once
		return
	car = live[i]
	stage.vehicles.soul_hijack(car.id)
	heat = 0.0
	seizes += 1
	_struck.clear()


func _miss(stage: CollectCallStage, reticle: Vector2) -> void:
	miss_tick = stage.tick
	miss_to = reticle
	misses += 1


## The soft lock along the aim: the car nearest the line from Rivet to the aim point (within
## gearbox.lock_radius_m of it and gearbox.range_m of Rivet); ties to the lower index. -1 = none.
func pick_on_line(rivet: Vector2, reticle: Vector2, cars: PackedVector2Array) -> int:
	var best: int = -1
	var best_d: float = link.num(&"lock_radius_m")
	for i: int in cars.size():
		if cars[i].distance_to(rivet) > link.num(&"range_m"):
			continue
		var d: float = Geometry2D.get_closest_point_to_segment(cars[i], rivet, reticle).distance_to(
			cars[i]
		)
		if d < best_d or (d <= best_d and best == -1):
			best = i
			best_d = d
	return best


## The stage's walls (the arena's, the city's buildings and kerbs) stop the car (it slides along
## them); true on a contact this tick.
func _wall(stage: CollectCallStage) -> bool:
	var out: Vector2 = push_out(stage, link.pos, num(&"car_reach_m") * 0.5)
	if out == link.pos:
		return false
	link.pos = out
	return true


func _strike(stage: CollectCallStage) -> bool:
	var reach: float = num(&"car_reach_m")
	var hit: bool = false
	for h: Fighter in stage.arena.hostiles:
		if not h.alive() or _struck.has(h.id) or h.pos.distance_to(car.pos) > reach + h.radius_m:
			continue
		_struck[h.id] = true
		h.pos += car.head * num(&"car_knock_m")
		stage.arena.hit_dir = car.head
		stage.arena.hit_at = h.pos
		stage.arena.damage(h, num(&"car_damage"), stage.arena.rivet.id, &"dent_car")
		strikes += 1
		hit = true
	return hit


func _blast(stage: CollectCallStage) -> void:
	blast_tick = stage.tick
	blast_at = car.pos
	blasts += 1
	var r: float = num(&"blast_radius_m")
	for h: Fighter in stage.arena.hostiles:
		var to: Vector2 = h.pos - blast_at
		if not h.alive() or to.length() > r:
			continue
		var dir: Vector2 = to.normalized() if to.length() > 0.01 else car.head
		h.pos += dir * num(&"car_knock_m") * (1.0 - to.length() / r)
		stage.arena.hit_dir = dir
		stage.arena.hit_at = h.pos
		stage.arena.damage(h, num(&"blast_damage"), stage.arena.rivet.id, &"dent_blast")
	car.hp_lost = maxf(car.hp_lost, stage.vehicles.rules.hp)
	car.state = stage.vehicles.rules.state_for(car.hp_lost, car.soul_hijacked)
	car.vel = Vector2.ZERO
	if riding():  # he jumps clear behind it as it goes up
		stage.arena.rivet.pos = _hop_spot(stage)
	blast_gap_m = stage.arena.rivet.pos.distance_to(blast_at)
	link.crashed = true
	_let_go()


## Where Dent lands: ride_hop_m behind the blown car, else to its left or right, the first spot
## with no other live car within HOP_CLEAR_M (a parked car is not a wall); walls push it out.
func _hop_spot(stage: CollectCallStage) -> Vector2:
	var hop: float = num(&"ride_hop_m")
	var side: Vector2 = car.head.orthogonal()
	var spots: Array[Vector2] = [-car.head * hop, side * hop, -side * hop]
	for off: Vector2 in spots:
		var p: Vector2 = push_out(stage, blast_at + off, stage.arena.rivet.radius_m)
		if _clear(stage, p):
			return p
	return push_out(stage, blast_at + spots[0], stage.arena.rivet.radius_m)


## `p` pushed out of the stage's solids: the arena's walls, else the city's cells, else as is.
static func push_out(stage: CollectCallStage, p: Vector2, r: float) -> Vector2:
	var arena: ArenaStage = stage as ArenaStage
	if arena != null:
		return arena.walls.push_out(p, r)
	return stage.cells.push_out(p, r) if stage.cells != null else p


func _clear(stage: CollectCallStage, p: Vector2) -> bool:
	for b: VehicleBody in stage.cars():
		if b != car and b.state != VehicleBody.State.WRECK and b.pos.distance_to(p) < HOP_CLEAR_M:
			return false
	return true


func _let_go() -> void:
	if powers.active == ID and not _shared:
		@warning_ignore("return_value_discarded")
		powers.interrupt(&"car")
	link.release()
	car = null
	heat = 0.0


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(blast_tick)
	out.put_32(strikes)
	out.put_32(seizes)
	out.put_float(heat)
	out.put_float(link.pos.x)
	out.put_float(link.pos.y)
