class_name FeelBudget
extends RefCounted
## The restraint on hit feel (hit_feel.json `cap`, lane n7-ranged): however many hits land, at most
## kicks_per_tick directional kicks start in one sim tick, at most shakes_per_second shakes start
## and at most hitstop_ticks_per_second hit-stop ticks are held in any 60-tick window. A Gatling
## burst, an Ohm chain or a crowd under a nuke then reads as weight, not a blur. View only: it
## gates camera effects and nothing the sim reads.

const WINDOW_TICKS: int = 60

var kicks_per_tick: int = 1
var shakes_per_second: int = 3
var hitstop_ticks_per_second: int = 12
## Evidence: requests refused by the cap since boot.
var refused: int = 0
var _tick: int = -1
var _kicks_now: int = 0
var _shakes: Array[int] = []
var _stops: Array[Vector2i] = []


static func from_cap(cap: Dictionary) -> FeelBudget:
	var b: FeelBudget = FeelBudget.new()
	var kicks: float = cap.get("kicks_per_tick", b.kicks_per_tick)
	var shakes: float = cap.get("shakes_per_second", b.shakes_per_second)
	var stops: float = cap.get("hitstop_ticks_per_second", b.hitstop_ticks_per_second)
	b.kicks_per_tick = roundi(kicks)
	b.shakes_per_second = roundi(shakes)
	b.hitstop_ticks_per_second = roundi(stops)
	return b


## True when one more directional kick may start at `tick` (and counts it).
func take_kick(tick: int) -> bool:
	if tick != _tick:
		_tick = tick
		_kicks_now = 0
	if _kicks_now >= kicks_per_tick:
		refused += 1
		return false
	_kicks_now += 1
	return true


## True when one more shake may start at `tick` (and counts it).
func take_shake(tick: int) -> bool:
	_shakes = _shakes.filter(func(t: int) -> bool: return tick - t < WINDOW_TICKS)
	if _shakes.size() >= shakes_per_second:
		refused += 1
		return false
	_shakes.append(tick)
	return true


## The hit-stop ticks granted of `ticks` asked at `tick`: trimmed to what the window has left.
func take_stop(tick: int, ticks: int) -> int:
	_stops = _stops.filter(func(s: Vector2i) -> bool: return tick - s.x < WINDOW_TICKS)
	var spent: int = 0
	for s: Vector2i in _stops:
		spent += s.y
	var granted: int = clampi(ticks, 0, maxi(hitstop_ticks_per_second - spent, 0))
	if granted < ticks:
		refused += 1
	if granted > 0:
		_stops.append(Vector2i(tick, granted))
	return granted
