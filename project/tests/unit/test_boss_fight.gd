extends GutTest
## The boss framework (features/bosses): phases by hp, attack timing in ticks, the aim lock, hits
## that never cancel an attack, no skipped phase, determinism, and planted faults that must fail.

const TABLE: String = """{"schema": "gtai.bosses/1", "doc": "t",
"arenas": {"a": {"area": "pit", "boss_at": [0, 0], "rivet_at": [-5, 0], "add_spawns": [[1, 1]],
"doc": "t"}},
"bosses": {"b": {"arena": "a", "hp": 100, "move_mps": 0, "radius_m": 1, "rng": "boss_b", "doc": "t",
"phases": [
 {"id": "one", "hp_below": 1, "attacks": ["jab"], "gap_s": 0.5, "transition_s": 1, "doc": "t"},
 {"id": "two", "hp_below": 0.6, "attacks": ["jab"], "gap_s": 0.5, "transition_s": 1, "doc": "t",
  "adds": {"archetype": "robot_thug", "count": 3}},
 {"id": "three", "hp_below": 0.3, "attacks": ["jab"], "gap_s": 0.5, "transition_s": 1, "doc": "t"}],
"attacks": {"jab": {"shape": "line", "windup_s": 1, "aim_lock_s": 0.25, "active_s": 0.5,
 "recovery_s": 1, "punish_s": 0.5, "punish_k": 2, "cooldown_s": 0, "damage": 10, "range_m": 10,
 "width_m": 1, "min_m": 0, "max_m": 50, "weight": 1, "doc": "t"}}}}}"""


func _fight(seed_v: int = 7) -> BossFight:
	var spec: BossSpec = BossSpec.from_table(DataTable.parse(TABLE, "gtai.bosses/1", "t"), &"b")
	var rng: RandomNumberGenerator = RngRegistry.new(seed_v).stream(spec.rng)
	var f: BossFight = BossFight.new(spec, rng, Vector2.ZERO)
	f.start()
	return f


## Runs until the state is `s` (or `limit` ticks); returns the ticks taken.
func _until(f: BossFight, s: BossFight.State, target: Vector2, limit: int = 600) -> int:
	for i: int in limit:
		if f.state == s:
			return i
		@warning_ignore("return_value_discarded")
		f.step(i, target, 0.5)
	return -1


func test_shipped_king_loads() -> void:
	var k: BossSpec = BossSpec.shipped(&"king")
	assert_not_null(k)
	assert_eq(k.phases.size(), 3)
	assert_true(BossMoves.make(k.script_path) is KingMoves, "King's own moves load")
	for p: BossSpec.Phase in k.phases:
		for a: StringName in p.attacks:
			assert_true(k.attacks.has(a), "phase %s names attack %s" % [p.id, a])


func test_attack_timing_in_ticks() -> void:
	var f: BossFight = _fight()
	var target: Vector2 = Vector2(5, 0)
	assert_eq(_until(f, BossFight.State.WINDUP, target), 30, "gap 0.5 s")
	assert_eq(_until(f, BossFight.State.ACTIVE, target), 60, "windup 1 s")
	assert_eq(_until(f, BossFight.State.RECOVER, target), 30, "active 0.5 s")
	assert_eq(_until(f, BossFight.State.IDLE, target), 60, "recovery 1 s")


func test_standing_target_is_hit_once_per_attack() -> void:
	var f: BossFight = _fight()
	var dealt: float = 0.0
	for i: int in 30 + 60 + 30:
		dealt += f.step(i, Vector2(5, 0), 0.5)
	assert_eq(dealt, 10.0)
	assert_eq(f.hits, 1)


func test_dodge_after_lock_is_safe_and_planted_no_lock_hits() -> void:
	for planted: bool in [false, true]:
		var f: BossFight = _fight()
		f.plant_no_lock = planted
		var dealt: float = 0.0
		for i: int in 30 + 60 + 30:
			var at: Vector2 = Vector2(5, 0) if i < 30 + 50 else Vector2(5, 4)  # moves after the lock
			dealt += f.step(i, at, 0.5)
		assert_eq(dealt, 10.0 if planted else 0.0, "planted no-lock %s" % planted)


func test_hits_never_cancel_an_active_attack() -> void:
	var f: BossFight = _fight()
	@warning_ignore("return_value_discarded")
	_until(f, BossFight.State.ACTIVE, Vector2(5, 0))
	@warning_ignore("return_value_discarded")
	f.hurt(45.0)  # past phase two's threshold mid-attack
	assert_eq(f.state, BossFight.State.ACTIVE)
	assert_eq(f.phase, 0)
	@warning_ignore("return_value_discarded")
	_until(f, BossFight.State.TRANSITION, Vector2(5, 0))
	@warning_ignore("return_value_discarded")
	_until(f, BossFight.State.IDLE, Vector2(5, 0))
	assert_eq(f.phase, 1)


func test_no_skipped_phase_and_transition_is_invulnerable() -> void:
	var f: BossFight = _fight()
	assert_eq(f.hurt(95.0), 40.0, "held at phase two's threshold")
	assert_eq(f.state, BossFight.State.TRANSITION)
	assert_eq(f.hurt(10.0), 0.0, "invulnerable in the transition")
	@warning_ignore("return_value_discarded")
	_until(f, BossFight.State.IDLE, Vector2(5, 0))
	assert_eq(f.phase, 1)


func test_punish_window_takes_more() -> void:
	var f: BossFight = _fight()
	@warning_ignore("return_value_discarded")
	_until(f, BossFight.State.RECOVER, Vector2(5, 0))
	assert_eq(f.hurt(5.0), 10.0, "punish_k 2")


func test_phase_adds_and_defeat_signals() -> void:
	var f: BossFight = _fight()
	watch_signals(f)
	@warning_ignore("return_value_discarded")
	f.hurt(40.0)
	@warning_ignore("return_value_discarded")
	_until(f, BossFight.State.IDLE, Vector2(5, 0))
	assert_signal_emitted_with_parameters(f, "adds_wanted", [&"robot_thug", 3])
	assert_signal_emitted_with_parameters(f, "phase_changed", [1, &"two"])
	f.start(2)
	@warning_ignore("return_value_discarded")
	f.hurt(999.0)
	assert_eq(f.state, BossFight.State.DEFEATED)
	assert_signal_emitted(f, "defeated")


func test_start_at_phase_sets_hp() -> void:
	var f: BossFight = _fight()
	f.start(2)
	assert_eq(f.phase, 2)
	assert_almost_eq(f.hp_frac(), 0.3, 0.0001)


func test_same_seed_same_fight() -> void:
	var digests: Array[PackedByteArray] = []
	for run: int in 2:
		var f: BossFight = _fight(11)
		var out: StreamPeerBuffer = StreamPeerBuffer.new()
		for i: int in 900:
			@warning_ignore("return_value_discarded")
			f.step(i, Vector2(5.0 + sin(i * 0.05) * 3.0, 0), 0.5)
			f.write_state(out)
		digests.append(out.data_array)
	assert_eq(digests[0], digests[1])
