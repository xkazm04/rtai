extends GutTest
## n8 view (owner d8, the bosses clip at 0:14): with bosses.json `aim_lock_at_windup` the aim and
## the ring freeze the moment the windup begins, so a step out of the ring early in the tell dodges.

const TABLE: String = """{"schema": "gtai.bosses/1", "doc": "t", %s
"arenas": {"a": {"area": "pit", "boss_at": [0, 0], "rivet_at": [-5, 0], "add_spawns": [[1, 1]],
"doc": "t"}},
"bosses": {"b": {"arena": "a", "hp": 100, "move_mps": 0, "radius_m": 1, "rng": "boss_b", "doc": "t",
"phases": [
 {"id": "one", "hp_below": 1, "attacks": ["jab"], "gap_s": 0.5, "transition_s": 1, "doc": "t"}],
"attacks": {"jab": {"shape": "line", "windup_s": 1, "aim_lock_s": 0.25, "active_s": 0.5,
 "recovery_s": 1, "punish_s": 0.5, "punish_k": 2, "cooldown_s": 0, "damage": 10, "range_m": 10,
 "width_m": 1, "min_m": 0, "max_m": 50, "weight": 1, "doc": "t"}}}}}"""


func _dealt(at_windup: bool) -> float:
	var flag: String = '"aim_lock_at_windup": %s,' % ("true" if at_windup else "false")
	var t: DataTable = DataTable.parse(TABLE % flag, "gtai.bosses/1", "t")
	var spec: BossSpec = BossSpec.from_table(t, &"b")
	var f: BossFight = BossFight.new(spec, RngRegistry.new(7).stream(spec.rng), Vector2.ZERO)
	f.start()
	var dealt: float = 0.0
	for i: int in 30 + 60 + 30:
		# the gap is 30 ticks; Rivet steps out 10 ticks into the 60-tick windup (before d8's lock)
		var at: Vector2 = Vector2(5, 0) if i < 30 + 10 else Vector2(5, 4)
		dealt += f.step(i, at, 0.5)
	return dealt


func test_a_step_out_early_in_the_windup_dodges_only_with_the_windup_lock() -> void:
	assert_eq(_dealt(true), 0.0, "frozen at the windup: the early step dodges")
	assert_eq(_dealt(false), 10.0, "d8 lock (0.25 s before active): the aim follows and hits")


func test_the_shipped_bosses_lock_every_attack_at_its_windup() -> void:
	for id: StringName in BossSpec.ids():
		var s: BossSpec = BossSpec.shipped(id)
		for k: StringName in s.attacks:
			assert_eq(s.attacks[k].lock, s.attacks[k].windup, "%s/%s" % [id, k])
