class_name MeleeWound
extends RefCounted
## n7-melee (combat-notes' next step 1): Rivet's melee hit that does not kill (a riot cop or SWAT
## at 2 hp takes the claw's 1, the katana's 1.5) played no wound: PlayerMelee lands through
## CombatArena.damage, which emits no struck. CombatArena.wounded (view only) now reports it, and
## this gate queues the melee wound family along Rivet -> victim once per strike: the chainsaw
## grind lands every tick, so a victim wounded less than GAP_TICKS ago is skipped.
## Render only: it reads the arena and writes nothing back. `--soft-swing` = none (the night's).

## About one strike's active window plus its follow-through (the chainsaw grind restarts the
## wound at most every 12 ticks, 5 a second, instead of 60).
const GAP_TICKS: int = 12

## DECISION n7-melee 2026-11-05: a melee hit that lands damage plays a body wound even on a riot
## cop's front (the claw reaches past the slab). The shield family with its sparks said "blocked"
## while the sim took his hp (he dies on the next jab). False = the slab takes it (the first cut).
static var past_slab: bool = true

var played: int = 0
var gated: int = 0
## Fighter id -> the tick its last wound was queued.
var _last: Dictionary[int, int] = {}


## True when a wound on fighter `id` at `tick` plays (and records it); false inside the gap.
func admit(id: int, tick: int) -> bool:
	var last: int = _last.get(id, -1000000)
	if tick - last < GAP_TICKS:
		gated += 1
		return false
	_last[id] = tick
	played += 1
	return true


## The pending hit for a non-lethal melee wound on `victim` by `weapon` (empty when it does not
## play): [id, Rivet -> victim dir, lethal false, &"melee", cover false, weapon].
func hit(arena: CombatArena, victim: Fighter, weapon: StringName) -> Array:
	if victim == arena.rivet or not admit(victim.id, arena.tick):
		return []
	var d: Vector2 = victim.pos - arena.rivet.pos
	d = d.normalized() if d.length() > 0.001 else -victim.facing
	return [victim.id, d, false, &"melee", false, weapon]
