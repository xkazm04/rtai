extends RefCounted
## n31 foes (b4j): why a ranged foe with a clear line inside its range is in TRAVEL (no fire).
## One count per foe-tick, keyed by wave then cause: urgent_panic, urgent_near (Rivet inside
## danger_m), far_unseen (out of its sight cone), escort, cover, flank, route (moving to a spot
## FoeGait.ARRIVED_M+ away; *_short when that spot is within SHORT_M), hold (no TRAVEL reason
## this tick, kept by the min-mode hold). `fight` counts the same foe-ticks in FIGHT. Read-only.

const SHORT_M: float = 3.0

var counts: Dictionary[int, Dictionary] = {}


## `mind` null (legacy gait or no mind) counts nothing.
func note(wave: int, mind: SquadMind, rivet: Vector2) -> void:
	if mind == null or mind.agent.melee() or mind.agent.gait == null:
		return
	var e: EnemyAgent = mind.agent
	var row: Dictionary = counts.get(wave, {})
	var cause: String = "fight" if e.gait.mode == FoeGait.Mode.FIGHT else cause_of(mind, rivet)
	row[cause] = row.get(cause, 0) + 1
	counts[wave] = row


static func cause_of(mind: SquadMind, rivet: Vector2) -> String:
	var e: EnemyAgent = mind.agent
	if mind.motion == EnemyAgent.State.PANIC:
		return "urgent_panic"
	if e.pos.distance_to(rivet) < e.arch.danger_m:
		return "urgent_near"
	if not e.sees:
		return "far_unseen"
	var to: Vector2 = mind.destination()
	if mind.strafing or not to.is_finite() or e.pos.distance_to(to) <= FoeGait.ARRIVED_M:
		return "hold"
	var short: String = "_short" if e.pos.distance_to(to) <= SHORT_M else ""
	if mind.mobile_goal.is_finite():
		return "escort" + short
	if mind.motion == EnemyAgent.State.COVER:
		return "cover" + short
	if mind.motion == EnemyAgent.State.FLANK:
		return "flank" + short
	return "route" + short


func to_dict() -> Dictionary:
	var out: Dictionary = {}
	for wave: int in counts:
		out[str(wave)] = counts[wave]
	return out
