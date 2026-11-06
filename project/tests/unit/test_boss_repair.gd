extends GutTest
## Owner call C (n7-king): the optional per-boss `rivet_repair_delay_s` sets Rivet's repair delay
## for the fight on the stage's own CombatTuning; absent, combat.json's delay stands.

const ROW: String = """{"schema": "gtai.bosses/1", "doc": "t",
"arenas": {"a": {"area": "pit", "boss_at": [0, 0], "rivet_at": [-5, 0], "add_spawns": [[1, 1]],
"doc": "t"}},
"bosses": {"b": {"arena": "a", "hp": 100, "move_mps": 0, "radius_m": 1, "rng": "boss_b", "doc": "t",
%s
"phases": [
 {"id": "one", "hp_below": 1, "attacks": ["jab"], "gap_s": 0.5, "transition_s": 1, "doc": "t"}],
"attacks": {"jab": {"shape": "line", "windup_s": 1, "aim_lock_s": 0.25, "active_s": 0.5,
 "recovery_s": 1, "punish_s": 0.5, "punish_k": 2, "cooldown_s": 0, "damage": 10, "range_m": 10,
 "width_m": 1, "min_m": 0, "max_m": 50, "weight": 1, "doc": "t"}}}}}"""


func _spec(extra: String) -> BossSpec:
	var t: DataTable = DataTable.parse(ROW % extra, "gtai.bosses/1", "t")
	return BossSpec.from_table(t, &"b")


func test_delay_field_sets_the_fights_repair_delay() -> void:
	var tuning: CombatTuning = CombatTuning.shipped()
	var spec: BossSpec = _spec('"rivet_repair_delay_s": 6.5,')
	assert_not_null(spec)
	spec.apply_repair(tuning)
	assert_eq(tuning.rivet["repair_delay_s"], 6.5)


func test_absent_field_keeps_combat_json_delay() -> void:
	var tuning: CombatTuning = CombatTuning.shipped()
	var before: float = tuning.rivet["repair_delay_s"]
	_spec("").apply_repair(tuning)
	assert_eq(tuning.rivet["repair_delay_s"], before)
	assert_eq(BossSpec.shipped(&"king").rivet_repair_delay_s, 20.0, "King: fair")


## Planted fault: a spec that reads -1 (the field ignored) must not reach the 6.5 s delay.
func test_planted_ignored_field_is_caught() -> void:
	var tuning: CombatTuning = CombatTuning.shipped()
	var spec: BossSpec = _spec('"rivet_repair_delay_s": 6.5,')
	spec.rivet_repair_delay_s = -1.0
	spec.apply_repair(tuning)
	assert_ne(tuning.rivet["repair_delay_s"], 6.5, "an ignored field leaves combat.json's delay")


## The delay is what CombatArena._repair reads: no heal before it, healing after it.
func test_arena_repair_waits_for_the_boss_delay() -> void:
	var tuning: CombatTuning = CombatTuning.shipped()
	_spec('"rivet_repair_delay_s": 6,').apply_repair(tuning)
	var bus: EventBus = autofree(EventBus.new())
	var arena: CombatArena = CombatArena.new(tuning, bus, RngRegistry.new(1).stream(&"combat"))
	arena.rivet.hp = 50.0
	arena.rivet.hurt_tick = 0
	for i: int in SimClock.TICK_RATE * 5:
		arena.step(i)
	assert_eq(arena.rivet.hp, 50.0, "no repair 5 s after a hit under a 6 s delay")
	for i: int in SimClock.TICK_RATE * 2:
		arena.step(SimClock.TICK_RATE * 6 + i)
	assert_gt(arena.rivet.hp, 50.0, "repair starts after the 6 s delay")
