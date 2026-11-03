class_name GearboxLink
extends RefCounted
## Gearbox, the delivery-and-driver soul (powers.json `gearbox`): remote-hijack a car in view.
## pick() is the soft lock (the nearest car to the reticle within lock_radius_m, and within
## range_m of Rivet). While linked the car drives at drive_mps toward the reticle, turning at
## most turn_dps, and wrecks on a contact above crash_mps. Rivet stays on foot and slowed
## (rivet_move_k): the cost. The host owns the car (VehicleService / a dev body) and feeds it.

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
	links += 1
	return true


func linked() -> bool:
	return car != NONE and not crashed


## Rivet's move scale this tick (slowed while steering a car).
func rivet_move_k() -> float:
	return num(&"rivet_move_k") if linked() else 1.0


## One tick: the car turns toward `reticle` (turn-limited) and speeds up to drive_mps.
func step(reticle: Vector2) -> void:
	if not linked():
		return
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


## Drops the link (the power ended or was interrupted). The car keeps its pose for the host.
func release() -> void:
	car = NONE
	speed = 0.0


## Wire to SoulPowers.ended so the link drops when the gearbox power ends.
func bind(powers: SoulPowers) -> void:
	@warning_ignore("return_value_discarded")
	powers.ended.connect(_on_end)


func _on_end(id: StringName, _reason: StringName, _bark: StringName) -> void:
	if id == &"gearbox":
		release()
