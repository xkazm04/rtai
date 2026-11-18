class_name FightProbeArena
extends CombatArena
## Dev-only observer attached before tick zero. Keep the arena's identity (hooks and their signal
## connections already refer to it), all script fields, and the original RNG stream.

var squad: Array[Fighter]
var fired: Dictionary[int, bool] = {}
var states: Dictionary[int, String] = {}
var sampled: Callable
var hostile_us: int
var stepped: int
var costs: Array[int] = []
var sight_total: int = 0
var peak_sight: int
var assignment_us: int
var assignment_ticks: int
var rounds: int
var hits: int
var damage_taken: float
var deaths: int
var _started_us: int = -1


func _init() -> void:
	# set_script initializes the subclass before attach restores the existing arena fields.
	super(CombatTuning.shipped(), null, null)


static func attach(arena: CombatArena) -> FightProbeArena:
	var saved: Dictionary[StringName, Variant] = {}
	for field: Dictionary in arena.get_property_list():
		var usage: int = field.usage
		var key: StringName = field.name
		if usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			saved[key] = arena.get(key)
	arena.set_script(FightProbeArena)
	for key: StringName in saved:
		arena.set(key, saved[key])
	return arena as FightProbeArena


func step(p_tick: int) -> void:
	hostile_us = 0
	stepped = 0
	peak_sight = 0
	fired.clear()
	states.clear()
	if squad_ai != null and rivet.alive():
		_started_us = Time.get_ticks_usec()
	super.step(p_tick)


func _step_hostile(h: Fighter) -> void:
	# Includes the pre-loop bookkeeping up to the first live hostile, once per squad tick.
	if _started_us >= 0:
		assignment_us += Time.get_ticks_usec() - _started_us
		assignment_ticks += 1
		_started_us = -1
	if not squad.has(h):
		super._step_hostile(h)
		return
	var before: Vector2 = h.pos
	var count: int = shots.size()
	var telling: bool = guard_tell != null and (h.tell_left > 0 or h.burst_left > 0)
	var sights: int = guard_map.sight_checks if squad_ai != null else 0
	var pursuit: GuardPursuit = h.pursuit if squad_ai == null else null
	var age: int = pursuit._ticks if pursuit != null else -1
	var start: int = Time.get_ticks_usec()
	super._step_hostile(h)
	var elapsed: int = Time.get_ticks_usec() - start
	var checks: int = guard_map.sight_checks - sights if squad_ai != null else 0
	if pursuit != null and pursuit._ticks != age:
		# GuardPursuit.advance performs one target LOS on first advance or a refresh slot.
		checks = int(age == 0 or (age + h.id) % GuardPursuit.CHECK_TICKS == 0)
	peak_sight = maxi(peak_sight, checks)
	sight_total += checks
	hostile_us += elapsed
	costs.append(elapsed)
	stepped += 1
	if shots.size() > count:
		fired[h.id] = true
		rounds += shots.size() - count
	states[h.id] = _state(h, before, telling)


func _state(h: Fighter, before: Vector2, telling: bool) -> String:
	if squad_ai != null and squad_ai.minds.has(h.id):
		return str(EnemyAgent.State.keys()[squad_ai.minds[h.id].agent.state]).to_lower()
	# The pursuit caches sight between route checks. GuardTell's committed burst bypasses it.
	if not telling and h.pursuit != null and h.pursuit._blocked:
		return "route"
	if h.pos != before:
		return "approach"
	if h.tell_left > 0:
		return "tell"
	if fired.has(h.id) or h.burst_left > 0:
		return "burst"
	return "cooldown"


func _step_shots() -> void:
	# All guards have stepped, including anyone whose new round hits or dies on this same tick.
	if _started_us >= 0:
		assignment_us += Time.get_ticks_usec() - _started_us
		assignment_ticks += 1
		_started_us = -1
	if sampled.is_valid():
		sampled.call()
	super._step_shots()


func damage(
	victim: Fighter, amount: float, killer_id: int, weapon: StringName, kind: StringName = &"shot"
) -> void:
	var hp: float = victim.hp
	super.damage(victim, amount, killer_id, weapon, kind)
	if victim == rivet and victim.hp < hp:
		damage_taken += hp - victim.hp
		hits += 1
		deaths += 0 if victim.alive() else 1
