class_name FoeGait
extends RefCounted
## Two ways for a ranged foe to move (owner, n31). FIGHT: a slow walk (fight_speed_k of its
## speed) that may shoot. TRAVEL: today's full-speed run (chase, cover, flank, retreat, panic) that
## may not. A mode is held min_ticks before an ordinary switch; a morale break or Rivet inside
## danger_m switches to TRAVEL at once. TRAVEL -> FIGHT settles settle_ticks before a round.

enum Mode { FIGHT, TRAVEL }

## A foe this close to its cover or flank spot is holding there, not travelling to it.
const ARRIVED_M: float = 0.6
## n31 setting G: with Rivet in range and sight, a walk to a spot this close or closer is an
## in-range adjustment (FIGHT: slow, may fire); only a longer walk is TRAVEL.
const TRAVEL_MIN_M: float = 3.0
const NEVER: int = -1000000

var mode: Mode = Mode.FIGHT
var mode_since_tick: int = NEVER
var settle_until_tick: int = NEVER
var panic: bool = false


## The mode a foe wants this tick. `moving`: it walks to cover, a flank spot or along a route.
static func wanted(now: bool, out_of_reach: bool, moving: bool) -> Mode:
	return Mode.TRAVEL if now or out_of_reach or moving else Mode.FIGHT


## A morale break or Rivet inside danger_m: the retreat that skips the hold.
static func urgent(panicked: bool, dist_m: float, arch: EnemyRoster.Archetype) -> bool:
	return panicked or dist_m < arch.danger_m


func update(tick: int, want: Mode, now: bool, min_ticks: int, settle_ticks: int) -> void:
	if want == mode:
		return
	if not (now and want == Mode.TRAVEL) and tick - mode_since_tick < min_ticks:
		return
	mode = want
	mode_since_tick = tick
	if want == Mode.FIGHT:
		settle_until_tick = tick + settle_ticks


func may_fire(tick: int) -> bool:
	return mode == Mode.FIGHT and tick >= settle_until_tick


func speed_cap(arch: EnemyRoster.Archetype) -> float:
	if mode == Mode.FIGHT:
		return arch.fight_speed_k * arch.speed_mps
	return arch.speed_mps * (1.6 if panic else 1.0)
