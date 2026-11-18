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
var rounds: int
var hits: int
var damage_taken: float
var deaths: int


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
	fired.clear()
	states.clear()
	super.step(p_tick)


func _step_hostile(h: Fighter) -> void:
	if not squad.has(h):
		super._step_hostile(h)
		return
	var before: Vector2 = h.pos
	var count: int = shots.size()
	var telling: bool = guard_tell != null and (h.tell_left > 0 or h.burst_left > 0)
	var start: int = Time.get_ticks_usec()
	super._step_hostile(h)
	var elapsed: int = Time.get_ticks_usec() - start
	hostile_us += elapsed
	costs.append(elapsed)
	stepped += 1
	if shots.size() > count:
		fired[h.id] = true
		rounds += shots.size() - count
	states[h.id] = _state(h, before, telling)


func _state(h: Fighter, before: Vector2, telling: bool) -> String:
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
