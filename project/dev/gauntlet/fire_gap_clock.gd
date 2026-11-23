class_name FireGapClock
extends RefCounted
## Sample the trigger counters immediately after squad assignment, before its actual step.
## Each tick has one cause, in the same priority order as the production trigger.

const PARTS: Array[String] = [
	"tell",
	"aim_lock",
	"burst_gap",
	"cooldown",
	"volley_rest",
	"line_of_sight",
	"max_shooters",
	"reposition",
	"traverse",
	"trigger_setup",
	"muzzle"
]

var cooldown: int
var telling: int
var turret_phase: int
var burst_gap: int
var burst_left: int
var rocket_moving: bool
var walker_in_band: bool
var walker_recovering: bool
var slots_full: bool
var token: bool


func before(h: Fighter, mind: SquadMind, arena: CombatArena) -> void:
	var e: EnemyAgent = mind.agent
	cooldown = h.cooldown
	telling = h.tell_left
	burst_gap = h.burst_gap
	burst_left = maxi(h.burst_left, mind.paused_rounds)
	turret_phase = mind.turret.phase if mind.turret != null else -1
	walker_recovering = e.state == EnemyAgent.State.RECOVER
	if mind.walker != null:
		var distance: float = h.pos.distance_to(arena.rivet.pos)
		walker_in_band = absf(distance - e.arch.preferred_m) <= FoeWalker.BAND_HALF_M
	token = e.token
	var pit: EnemyPit = arena.squad_ai.pit
	slots_full = not token and EnemySquad.holders(pit.agents, false) >= pit.roster.max_shooters
	if mind.rocket != null:
		var visible: bool = arena.guard_map.clear_line(h.pos, arena.rivet.pos)
		rocket_moving = mind.rocket.needs_relocation(e, arena.rivet.pos, visible)


func reason(h: Fighter, mind: SquadMind, arena: CombatArena) -> String:
	var phase: String = ""
	if mind.turret != null:
		phase = _turret(h, mind.turret)
	elif mind.rocket != null:
		phase = _rocket(arena)
	elif mind.walker != null and telling > 0:
		phase = "tell"
	if not phase.is_empty():
		return phase
	if not mind.agent.sees:
		return "line_of_sight"
	if not mind.agent.has_shot_at(arena.rivet.pos):
		return "reposition"
	return _trigger(h, mind)


func _turret(h: Fighter, turret: FoeTurret) -> String:
	match turret_phase:
		FoeTurret.Phase.TELL:
			return (
				"traverse"
				if h.tell_left == telling and turret.phase == turret_phase
				else "aim_lock"
			)
		FoeTurret.Phase.SWEEP:
			return "burst_gap" if turret.phase == FoeTurret.Phase.SWEEP else "trigger_setup"
		FoeTurret.Phase.COOL:
			return "cooldown"
	return ""


func _rocket(arena: CombatArena) -> String:
	if telling > 0:
		return "aim_lock" if telling <= arena.guard_tell.lock_ticks else "tell"
	if rocket_moving:
		return "reposition"
	if (
		cooldown <= 1
		and token
		and arena.squad_ai.rockets.count() >= arena.squad_ai.pit.roster.max_shooters
	):
		return "max_shooters"
	return ""


func _trigger(h: Fighter, mind: SquadMind) -> String:
	if mind.agent.arch.explicit_spawn:
		if cooldown > 1 or (walker_recovering and cooldown > 0):
			return "cooldown"
	elif burst_left > 0 and burst_gap > h.burst_gap:
		return "burst_gap"
	elif cooldown > h.cooldown:
		return "cooldown"
	if slots_full:
		return "max_shooters"
	if not token or (mind.walker != null and h.tell_left == 0):
		return "traverse" if token and walker_in_band else "reposition"
	return "trigger_setup"
