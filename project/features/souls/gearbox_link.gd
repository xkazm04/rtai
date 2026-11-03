class_name GearboxLink
extends RefCounted
## Gearbox, the delivery-and-driver soul (powers.json `gearbox`): remote-hijack a car in view.
## pick() is the soft lock (the nearest car to the reticle within lock_radius_m, and within
## range_m of Rivet). While linked the car drives at drive_mps toward the reticle, turning at
## most turn_dps, and wrecks on a contact above crash_mps. Rivet stays on foot and slowed
## (rivet_move_k): the cost. Residue (residue_s > 0, an upgrade): when the link is released the car
## keeps driving its last order for residue_s, unsteered. The host owns the car and feeds it.

const NONE: int = -1

## The linked car's index in the host's car list (NONE when unlinked), its pose and speed.
var car: int = NONE
var pos: Vector2 = Vector2.ZERO
var heading: float = 0.0
var speed: float = 0.0
var crashed: bool = false
## Counters for evidence: links made, crashes, bodies the car struck.
var links: int = 0
var crashes: int = 0
var strikes: int = 0
## Residue ticks left (0 = Rivet steers, or no residue); the order the car keeps while coasting.
var coast_ticks: int = 0
var _order: Vector2 = Vector2.ZERO
var _t: Dictionary = {}


func _init(tuning: Dictionary) -> void:
	_t = tuning


func num(key: StringName) -> float:
	return SoulTuning.num(_t, key)


## The soft lock: index of the car nearest `reticle` (within lock_radius_m) that is also within
## range_m of `rivet`; NONE when no car qualifies. Ties go to the lower index (deterministic).
func pick(rivet: Vector2, reticle: Vector2, cars: PackedVector2Array) -> int:
	var best: int = NONE
	var best_d: float = num(&"lock_radius_m")
	for i: int in cars.size():
		if cars[i].distance_to(rivet) > num(&"range_m"):
			continue
		var d: float = cars[i].distance_to(reticle)
		if d <= best_d and (best == NONE or d < best_d):
			best = i
			best_d = d
	return best


## Takes the car `index` at pose (at, p_heading); true when linked.
func link(index: int, at: Vector2, p_heading: float) -> bool:
	if index == NONE:
		return false
	car = index
	pos = at
	heading = p_heading
	speed = 0.0
	crashed = false
	coast_ticks = 0
	_order = at + Vector2.from_angle(p_heading)
	links += 1
	return true


## True while the car is under the soul's order (steered, or coasting on residue).
func linked() -> bool:
	return car != NONE and not crashed


## True while Rivet steers the car himself (not coasting).
func steered() -> bool:
	return linked() and coast_ticks == 0


## Rivet's move scale this tick (slowed only while steering a car; residue costs nothing).
func rivet_move_k() -> float:
	return num(&"rivet_move_k") if steered() else 1.0


## One tick: the car turns toward `reticle` (its last order while coasting; turn-limited) and
## speeds up to drive_mps. The residue runs out -> the link drops.
func step(reticle: Vector2) -> void:
	if not linked():
		return
	if coast_ticks > 0:
		reticle = _order
		coast_ticks -= 1
		if coast_ticks == 0:
			_drop()
			return
	else:
		_order = reticle
	var dt: float = SimClock.TICK_DT
	var to: Vector2 = reticle - pos
	if to.length() > 0.5:
		var want: float = to.angle()
		var max_turn: float = deg_to_rad(num(&"turn_dps")) * dt
		heading += clampf(angle_difference(heading, want), -max_turn, max_turn)
	speed = move_toward(speed, num(&"drive_mps"), num(&"drive_mps") * dt)
	pos += Vector2.from_angle(heading) * speed * dt


## A contact (a body, a car or a wall) at the car's current speed: true when it wrecks the car.
func contact() -> bool:
	if not linked():
		return false
	strikes += 1
	if speed > num(&"crash_mps"):
		crashed = true
		crashes += 1
	return crashed


## The power ended or was interrupted: with residue the car coasts on its last order, otherwise
## the link drops. The car keeps its pose for the host.
func release() -> void:
	var ticks: int = roundi(num(&"residue_s") / SimClock.TICK_DT)
	if steered() and ticks > 0:
		coast_ticks = ticks
		return
	_drop()


func _drop() -> void:
	car = NONE
	speed = 0.0
	coast_ticks = 0


## Wire to SoulPowers.ended so the link drops when the gearbox power ends.
func bind(powers: SoulPowers) -> void:
	@warning_ignore("return_value_discarded")
	powers.ended.connect(_on_end)


func _on_end(id: StringName, _reason: StringName, _bark: StringName) -> void:
	if id == &"gearbox":
		release()
