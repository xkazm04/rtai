class_name BossBotGhost
extends RefCounted
## `--bot=boss --ghost=<tonnage|dent|kerf|ohm>`: the boss bot takes a ghost's soul and uses its
## melee attack on the fight, the way the ghost-powers beats do (G presses pick the ghost in
## GhostPilot's order, Q transforms, the attack waits for the settled form). It presses melee
## at most every CADENCE ticks with the boss inside the ghost's REACH_M, first whenever the boss
## (or an add) is in a windup: Ohm's bolt dazes a boss's tell (BossFight.daze).

const ORDER: Array[StringName] = [&"tonnage", &"dent", &"kerf", &"ohm"]
const REACH_M: Dictionary = {&"tonnage": 3.2, &"dent": 6.0, &"kerf": 8.0, &"ohm": 10.5}
const SELECT_AT: int = 40
const TAKE_AT: int = 46
const FIRST_AT: int = 100
const CADENCE: int = 30

var ghost: StringName
var presses: int = 0
var _start: int = -1
var _last: int = -1000


func _init(p_ghost: StringName) -> void:
	ghost = p_ghost if ORDER.has(p_ghost) else &"ohm"


## The ghost's buttons this tick (a bit mask over PlayerActions).
func buttons(tick: int, hook: BossHook, me: Vector2, actions: PlayerActions) -> int:
	if _start < 0:
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
	return tick_free(hook)


## Off a tell, the ghost still attacks the boss (a human uses the power on cooldown).
static func tick_free(hook: BossHook) -> bool:
	return hook.fight.state != BossFight.State.TRANSITION
