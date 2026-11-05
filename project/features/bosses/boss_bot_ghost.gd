class_name BossBotGhost
extends RefCounted
## `--bot=boss --ghost=<tonnage|dent|kerf|ohm>`: the boss bot takes a ghost's soul and uses its
## melee attack on the fight, the way the ghost-powers beats do (G presses pick the ghost in
## GhostPilot's order, Q transforms, the attack waits for the settled form). It presses melee
## at most every CADENCE ticks with the boss inside the ghost's REACH_M, first whenever the boss
## (or an add) is in a windup: Ohm's bolt dazes a boss's tell (BossFight.daze).
## `--ghost-tells` keeps it for the tells only.

const ORDER: Array[StringName] = [&"tonnage", &"dent", &"kerf", &"ohm"]
const REACH_M: Dictionary = {&"tonnage": 3.2, &"dent": 6.0, &"kerf": 8.0, &"ohm": 10.5}
const SELECT_AT: int = 40
const TAKE_AT: int = 46
const FIRST_AT: int = 100
const CADENCE: int = 30
## Dent: the bot fires on a car from this close (inside the soft lock's reach).
const SEIZE_M: float = 7.0

var ghost: StringName
## `--ghost-tells`: the power is saved for the boss's tells (a reader interrupts with Ohm's bolt);
## default: used on cooldown whenever the boss is in reach.
var save_for_tells: bool = OS.get_cmdline_user_args().has("--ghost-tells")
var presses: int = 0
var _start: int = -1
var _last: int = -1000
## Dent: a live car within SEIZE_M (car_goal sets it).
var _near: bool = false
## Dent: a car was seized (one per soul: afterwards the bot fights the boss again).
var _seized: bool = false


func _init(p_ghost: StringName) -> void:
	ghost = p_ghost if ORDER.has(p_ghost) else &"ohm"


## The band the bot holds: a short-reach ghost (Tonnage's slam) closes in to strike once the soul
## is taken; otherwise the bot's own band.
func hold_m(f: BossFight, band_m: float) -> float:
	var reach: float = REACH_M[ghost] + f.body.radius_m - 0.6
	return reach if _start >= 0 and reach < band_m else band_m


## The ghost's buttons this tick (a bit mask over PlayerActions).
func buttons(tick: int, hook: BossHook, me: Vector2, actions: PlayerActions) -> int:
	if _start < 0:
		if ghost == &"dent" and not _near:  # Dent: walk to a car first, then take the soul
			return 0
		_start = tick
	var local: int = tick - _start
	var picks: int = ORDER.find(ghost)
	if local >= SELECT_AT and local < SELECT_AT + picks * 2 and (local - SELECT_AT) % 2 == 0:
		return 1 << actions.bit(&"power_gearbox")
	if local == TAKE_AT:
		return 1 << actions.bit(&"power_hauler")
	if local < FIRST_AT or tick - _last < CADENCE or not _wants(hook, me):
		return 0
	_last = tick
	presses += 1
	return 1 << actions.bit(&"melee")


func _wants(hook: BossHook, me: Vector2) -> bool:
	var reach: float = REACH_M[ghost]
	var f: BossFight = hook.fight
	if f.state == BossFight.State.DEFEATED or me.distance_to(f.body.pos) > reach + f.body.radius_m:
		return false
	if f.state == BossFight.State.WINDUP:
		return true
	for a: BossFight in hook.adds.fights:
		if a.state != BossFight.State.DEFEATED and me.distance_to(a.body.pos) <= reach:
			return true
	return not save_for_tells and f.state != BossFight.State.TRANSITION


## Dent: the nearest live car to walk to and fire on (the fire press seizes the car nearest the
## aim line), until one is seized; then Vector2.INF (the seized car steers by the aim at the
## boss, and the melee press in reach blows it). The soul is taken only once a car is within
## SEIZE_M, so the form's time is spent on the car, not the walk. Only cars on the fight's floor
## (`area`, BossHook.bounds) count: a car on another pad drew the bot off the floor (it7: 0 seized
## in 5 full fights). INF for the other ghosts.
func car_goal(cars: Array[VehicleBody], me: Vector2, area: Rect2) -> Vector2:
	if ghost != &"dent" or _seized:
		return Vector2.INF
	var best: Vector2 = Vector2.INF
	for b: VehicleBody in cars:
		if b.state == VehicleBody.State.WRECK or not area.has_point(b.pos):
			continue
		if b.soul_hijacked:
			_seized = true
			return Vector2.INF
		if me.distance_to(b.pos) < me.distance_to(best):
			best = b.pos
	_near = best != Vector2.INF and me.distance_to(best) <= SEIZE_M
	return best


## True once the form is taken and settled (the attack presses wait for it).
func settled(tick: int) -> bool:
	return _start >= 0 and tick - _start >= FIRST_AT
