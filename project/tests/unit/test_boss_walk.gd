extends GutTest
## The boss framework's walk and adds pacing: a walk blocked head-on by cover sidesteps round it
## (the gang pinned behind a crate row, n7 iteration 2), and a phase never asks for more adds than
## its max_total (phase 2 had become a wall of adds).

const TABLE: String = """{"schema": "gtai.bosses/1", "doc": "t",
"arenas": {"a": {"area": "pit", "boss_at": [0, 0], "rivet_at": [-5, 0], "add_spawns": [[1, 1]],
"doc": "t"}},
"bosses": {"b": {"arena": "a", "hp": 100, "move_mps": 3, "radius_m": 0.5, "rng": "boss_b",
"keep_m": 1, "doc": "t",
"phases": [
 {"id": "one", "hp_below": 1, "attacks": ["jab"], "gap_s": 0.2, "transition_s": 0, "doc": "t",
  "adds": {"archetype": "robot_thug", "count": 3, "every_s": 0.5, "max_total": %d}}],
"attacks": {"jab": {"shape": "line", "windup_s": 1, "aim_lock_s": 0.25, "active_s": 0.5,
 "recovery_s": 1, "punish_s": 0.5, "punish_k": 2, "cooldown_s": 0, "damage": 10, "range_m": 1,
 "width_m": 1, "min_m": 0, "max_m": 0.2, "weight": 1, "doc": "t"}}}}}"""

var _asked: int = 0


func _fight(max_total: int) -> BossFight:
	var t: DataTable = DataTable.parse(TABLE % max_total, "gtai.bosses/1", "t")
	var spec: BossSpec = BossSpec.from_table(t, &"b")
	var f: BossFight = BossFight.new(spec, RngRegistry.new(3).stream(spec.rng), Vector2.ZERO)
	f.body.id = 9100
	return f


func _on_adds(_archetype: StringName, count: int) -> void:
	_asked += count


func test_blocked_walk_sidesteps_round_cover() -> void:
	var f: BossFight = _fight(0)
	f.start()
	var walls: ArenaWalls = ArenaWalls.new()
	walls.boxes.append(Rect2(3.0, -3.0, 1.0, 6.0))  # a crate row head-on between boss and target
	var target: Vector2 = Vector2(10.0, 0.0)
	for i: int in 900:
		@warning_ignore("return_value_discarded")
		f.step(i, target, 0.4)
		f.body.pos = walls.push_out(f.body.pos, f.body.radius_m)
	assert_lt(f.body.pos.distance_to(target), 2.0, "walked round the cover to the target")
	# The fault the detour fixes: a straight walk stops dead at the cover's face.
	var straight: Vector2 = Vector2.ZERO
	for i: int in 900:
		straight = walls.push_out(straight + Vector2.RIGHT * 0.05, 0.5)
	assert_gt(straight.distance_to(target), 6.0, "without the detour the walk is pinned")


func test_phase_adds_stop_at_max_total() -> void:
	var f: BossFight = _fight(5)
	assert_eq(f.adds_wanted.connect(_on_adds), OK)
	_asked = 0
	f.start()
	for i: int in 600:
		@warning_ignore("return_value_discarded")
		f.step(i, Vector2(30.0, 0.0), 0.4)
	assert_eq(_asked, 5, "3 at the phase start + 2 more, then none")


func test_no_max_total_keeps_asking() -> void:
	var f: BossFight = _fight(0)
	assert_eq(f.adds_wanted.connect(_on_adds), OK)
	_asked = 0
	f.start()
	for i: int in 600:
		@warning_ignore("return_value_discarded")
		f.step(i, Vector2(30.0, 0.0), 0.4)
	assert_gt(_asked, 30, "every 0.5 s for 10 s")


func test_adds_part_and_step_off_the_boss() -> void:
	var boss: BossFight = _fight(0)
	var adds: BossAdds = BossAdds.new()
	for i: int in 3:
		var f: BossFight = _fight(0)
		f.body.pos = Vector2(4.0, 0.0)  # three adds stacked on one spot
		adds.fights.append(f)
	adds.fights[2].body.pos = Vector2(0.3, 0.0)  # one inside the boss
	adds.separate(boss)
	var a: Vector2 = adds.fights[0].body.pos
	var b: Vector2 = adds.fights[1].body.pos
	assert_gte(a.distance_to(b), 0.99, "the stacked pair parted to their radii (0.5 + 0.5)")
	assert_gte(adds.fights[2].body.pos.length(), 0.99, "the add stepped off the boss")
