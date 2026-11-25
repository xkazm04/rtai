extends RefCounted
## n31 foes (b4a): the engaged rule. An enemy-tick is engaged when the foe fired a round within
## the last burst duration + cooldown + 0.1 s of the weapon it actually fires, is winding up,
## firing or mid burst, or sits in its FoeGait settle window. A wave tick presses when, with 3 or
## more ranged alive, engaged + advancing >= max(3, ceil(ranged_alive / 3)). Read-only.

const SLACK_TICKS: int = 6
const PRESS_MIN: int = 3
const ADVANCE_MPS: float = 0.5
const ARRIVED_M: float = 0.6
const TRAVEL: int = 1


static func window_ticks(burst: int, gap_ticks: int, cooldown_ticks: int) -> int:
	return maxi(burst - 1, 0) * (gap_ticks + 1) + cooldown_ticks + SLACK_TICKS


static func engaged(tick: int, last_shot: int, window: int, busy: bool, settle: bool) -> bool:
	return busy or settle or (last_shot >= 0 and tick - last_shot <= window)


## The strict rule's busy: a round this tick, a burst under way, a wind-up or a FIRE state.
static func strict_busy(fired: bool, burst_left: int, state: EnemyAgent.State) -> bool:
	return (
		fired
		or burst_left > 0
		or state == EnemyAgent.State.WINDUP
		or state == EnemyAgent.State.FIRE
	)


static func pressing(ranged_alive: int, pushers: int) -> bool:
	return ranged_alive >= PRESS_MIN and pushers >= maxi(PRESS_MIN, ceili(ranged_alive / 3.0))


## Own-gun (squad.own_weapons, duck-typed) foes and explicit spawns fire arch.weapon.
static func foe_window(arch: EnemyRoster.Archetype, h: Fighter, t: CombatTuning, r: Object) -> int:
	var own: bool = r != null and r.get(&"own_weapons") == true and not arch.weapon.melee
	if not own and not arch.explicit_spawn and t != null and t.weapons.has(h.weapon):
		var t2: CombatTuning.Weapon = t.weapons[h.weapon]
		return window_ticks(t2.burst, t2.burst_gap_ticks, t2.cooldown_ticks)
	var w: EnemyWeapon = arch.weapon
	return window_ticks(w.burst, w.burst_gap_ticks, w.cooldown_ticks)


## The FoeGait settle window (TRAVEL -> FIGHT); duck-typed so old revs (no FoeGait) compile.
static func settling(agent: EnemyAgent, tick: int, split: bool) -> bool:
	var g: Object = agent.get(&"gait")
	if not split or g == null:
		return false
	var mode: int = g.get(&"mode")
	var until: int = g.get(&"settle_until_tick")
	return mode != TRAVEL and tick < until


## TRAVEL, or no split gait (legacy: one gait that may always advance).
static func loose_gait(agent: EnemyAgent, split: bool) -> bool:
	var g: Object = agent.get(&"gait")
	if not split or g == null:
		return true
	var mode: int = g.get(&"mode")
	return mode == TRAVEL


## The squad's FoeGaitDrive.split (false at a rev without FoeGait).
static func split_of(squad: ArenaSquad) -> bool:
	var gaits: Object = squad.get(&"gaits")
	return gaits != null and gaits.get(&"split") == true


static func advancing(agent: EnemyAgent, step: Vector2, rivet: Vector2, split: bool) -> bool:
	var to: Vector2 = rivet - agent.pos
	if to.length() < 0.01:
		return false
	return loose_gait(agent, split) and step.dot(to.normalized()) / SimClock.TICK_DT > ADVANCE_MPS


## Advancing (pressing share): toward Rivet in a loose gait, or walking to a firing spot.
static func pushing(mind: SquadMind, step: Vector2, arena: CombatArena, split: bool) -> bool:
	var rivet: Vector2 = arena.rivet.pos
	return advancing(mind.agent, step, rivet, split) or to_firing_spot(mind, rivet, arena.guard_map)


## Walking (not strafing) to a spot inside attack_m with a clear line to Rivet.
static func to_firing_spot(mind: SquadMind, rivet: Vector2, map: GuardRouteMap) -> bool:
	if mind.get(&"strafing") == true:
		return false
	var spot: Vector2 = mind.destination()
	if not spot.is_finite() or spot.distance_to(mind.agent.pos) <= ARRIVED_M:
		return false
	if spot.distance_to(rivet) > mind.agent.arch.attack_m:
		return false
	return map == null or map.clear_line(spot, rivet)
