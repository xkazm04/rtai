extends GutTest
## A leaping circle (BossAttack.leap_m): the ring tracks Rivet up to leap_m out, locks, and the
## boss lands on it as the windup ends; a step out of the locked ring dodges. Planted: leap_m 0.

const TABLE: String = """{"schema": "gtai.bosses/1", "doc": "t",
"arenas": {"a": {"area": "pit", "boss_at": [0, 0], "rivet_at": [-5, 0], "add_spawns": [[1, 1]],
"doc": "t"}},
"bosses": {"b": {"arena": "a", "hp": 100, "move_mps": 0, "radius_m": 1, "rng": "boss_b", "doc": "t",
"phases": [{"id": "one", "hp_below": 1, "attacks": ["slam"], "gap_s": 0.5, "transition_s": 1,
 "doc": "t"}],
"attacks": {"slam": {"shape": "circle", "windup_s": 1, "aim_lock_s": 0.25, "active_s": 0.25,
 "recovery_s": 1, "punish_s": 0.5, "punish_k": 2, "cooldown_s": 0, "damage": 20, "range_m": 0,
 "radius_m": 2, "leap_m": LEAP, "min_m": 0, "max_m": 50, "weight": 1, "doc": "t"}}}}}"""


func _fight(leap: String) -> BossFight:
	var t: DataTable = DataTable.parse(TABLE.replace("LEAP", leap), "gtai.bosses/1", "t")
	var spec: BossSpec = BossSpec.from_table(t, &"b")
	var f: BossFight = BossFight.new(spec, RngRegistry.new(7).stream(spec.rng), Vector2.ZERO)
	f.start()
	return f


## Steps through one attack against `target` (moved to `dodge` once the aim has locked).
func _run(f: BossFight, target: Vector2, dodge: Vector2) -> float:
	var dealt: float = 0.0
	for i: int in 200:
		var at: Vector2 = dodge if f.locked else target
		dealt += f.step(i, at, 0.5)
		if f.state == BossFight.State.RECOVER:
			break
	return dealt


func test_the_boss_lands_on_the_ring_and_hits_a_stander() -> void:
	var f: BossFight = _fight("5")
	var dealt: float = _run(f, Vector2(6, 0), Vector2(6, 0))
	assert_almost_eq(f.body.pos.x, 5.0, 0.01, "landed 5 m out (leap_m), on the locked ring")
	assert_eq(dealt, 20.0, "Rivet 1 m from the ring's centre")


func test_a_step_out_after_the_lock_dodges() -> void:
	var f: BossFight = _fight("5")
	assert_eq(_run(f, Vector2(6, 0), Vector2(6, 4)), 0.0, "4 m sideways after the lock")


func test_planted_no_leap_misses_the_stander_at_range() -> void:
	var f: BossFight = _fight("0")
	assert_eq(_run(f, Vector2(6, 0), Vector2(6, 0)), 0.0, "the ring stays on the boss")
	assert_almost_eq(f.body.pos.x, 0.0, 0.01)
