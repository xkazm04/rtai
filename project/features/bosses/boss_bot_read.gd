class_name BossBotRead
extends RefCounted
## `--bot-human`: the boss bot reads tells like a fair human player, not a perfect one. Each
## windup it sees begins, it rolls once (its own RNG stream, `boss_bot`, so the fight replays)
## whether this tell is read (READ_P) and how late (REACT_TICKS + 0..REACT_SPREAD); an unread tell
## is walked into. Its aim sways AIM_SWAY_DEG on a slow sine, so some shots miss small targets.
## Encounter-balance-simulation: the dodging bot is the skill ceiling, the standing bot the floor,
## this one the middle each attack's hit rate is judged against.

const READ_P: float = 0.7
const REACT_TICKS: int = 18
const REACT_SPREAD: int = 14
const AIM_SWAY_DEG: float = 9.0
const SWAY_RATE: float = 0.07

var _rng: RandomNumberGenerator
## Per threat (a BossFight): [was in a windup last tick, reads this tell, react ticks].
var _plan: Dictionary = {}


func _init(rng: RandomNumberGenerator) -> void:
	_rng = rng


## Called each tick for every threat before the bot reads any of them.
func see(f: BossFight) -> void:
	var winding: bool = f.state == BossFight.State.WINDUP
	var p: Array = _plan.get(f, [false, true, REACT_TICKS])
	if winding and not p[0]:
		p = [true, _rng.randf() < READ_P, REACT_TICKS + _rng.randi_range(0, REACT_SPREAD)]
	p[0] = winding
	_plan[f] = p


## Does the bot react to this threat's tell yet (read, and past its own reaction time)?
func reacts(f: BossFight) -> bool:
	var p: Array = _plan.get(f, [false, true, REACT_TICKS])
	if f.state == BossFight.State.WINDUP:
		return p[1] and f.t >= p[2]
	return p[1]  # the active window: only a read tell is still being dodged


## The aim a human's hand gives: the true aim swayed on a slow sine.
static func sway(aim: Vector2, tick: int) -> Vector2:
	return aim.rotated(deg_to_rad(AIM_SWAY_DEG) * sin(float(tick) * SWAY_RATE))
