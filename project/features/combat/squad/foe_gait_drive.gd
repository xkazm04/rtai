class_name FoeGaitDrive
extends RefCounted
## Runs each ranged wave member's FoeGait (n31): picks its mode before steering, caps the FIGHT
## walk, faces the run in TRAVEL and gates the trigger. `split = false` (`--foe-moves=legacy`, or
## squad.gait "legacy") never consults a gait: today's single gait, bit for bit.

const FLAG: String = "--foe-moves"
## A shield escort's FIGHT walk keeps at least this share over the carrier's pace (stays shadowed).
const ESCORT_PACE_K: float = 1.2

var split: bool = true


func _init(roster: EnemyRoster) -> void:
	var flag: String = LaunchArgs.value(FLAG)
	split = flag == "split" if flag != "" else roster.gait_split


func uses(e: EnemyAgent) -> bool:
	return split and not e.melee()


func steer(mind: SquadMind, want: Vector2, pit: EnemyPit) -> void:
	var e: EnemyAgent = mind.agent
	if not uses(e):
		EnemyMotor.steer(e, want, pit.rivet_pos, pit)
		return
	var g: FoeGait = e.gait
	var dist: float = e.pos.distance_to(pit.rivet_pos)
	g.panic = mind.motion == EnemyAgent.State.PANIC
	var now: bool = FoeGait.urgent(g.panic, dist, e.arch)
	var far: bool = dist > e.arch.attack_m or not e.sees
	var mode: FoeGait.Mode = FoeGait.wanted(now, far, moving(mind))
	g.update(pit.tick, mode, now, pit.roster.gait_min_ticks, pit.roster.gait_settle_ticks)
	if g.mode == FoeGait.Mode.FIGHT:
		var cap: float = g.speed_cap(e.arch)
		if mind.mobile_goal.is_finite():
			cap = maxf(cap, ESCORT_PACE_K * pit.roster.archetype(&"shield_robot").speed_mps)
		EnemyMotor.steer(e, want, pit.rivet_pos, pit, cap)
	else:
		EnemyMotor.steer(e, want, Vector2.INF, pit)


func may_fire(mind: SquadMind, tick: int) -> bool:
	return not uses(mind.agent) or mind.agent.gait.may_fire(tick)


## A ranged wave member on a TRAVEL run carries its gun low: no aim row, no aim arm.
static func gun_down(arena: CombatArena, h: Fighter) -> bool:
	var squad: ArenaSquad = arena.squad_ai
	if squad == null or not squad.minds.has(h.id):
		return false
	var e: EnemyAgent = squad.minds[h.id].agent
	return squad.gaits.uses(e) and e.gait.mode == FoeGait.Mode.TRAVEL


## Walking to cover, a flank spot, a shield shoulder or along a route (not strafing or holding).
static func moving(mind: SquadMind) -> bool:
	if mind.strafing:
		return false
	var to: Vector2 = mind.destination()
	return to.is_finite() and mind.agent.pos.distance_to(to) > FoeGait.ARRIVED_M
