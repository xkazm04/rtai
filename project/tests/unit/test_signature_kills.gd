extends GutTest
## Lane brutality: the signature-kill framework (table, gib pool, marks) is data-driven and
## deterministic: the same seed throws the same gibs; a changed seed or dice draw is caught.


func _kills(seed_value: int, gore: String = "full") -> SignatureKills:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	table.gore_full = SignatureKillTable.gore_from_args(gore)
	var reg: RngRegistry = RngRegistry.new(seed_value)
	return SignatureKills.new(table, reg.stream(&"brutality"))


func _ev(v: int, at: Vector2, dir: Vector2, weapon: StringName, human: bool = true) -> KillEvent:
	var e: KillEvent = KillEvent.make(v, at, dir, weapon)
	e.human = human
	return e


func _run(k: SignatureKills, ticks: int) -> PackedByteArray:
	@warning_ignore("return_value_discarded")
	k.on_kill(_ev(7, Vector2(3.0, 4.0), Vector2(1.0, 0.2), &"rocket_launcher"))
	for t: int in ticks:
		k.step(t)
		if t == 40:
			@warning_ignore("return_value_discarded")
			k.on_kill(_ev(8, Vector2(6.0, 4.0), Vector2(-1.0, 0.0), &"rocket_launcher"))
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	k.write_state(out)
	return out.data_array


func test_table_loads_the_rocket_row() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	assert_eq(table.problems.size(), 0, str(table.problems))
	var row: SignatureKill = table.for_weapon(&"rocket_launcher")
	assert_not_null(row)
	assert_eq(row.style, &"gib")
	assert_eq(row.pieces.size(), 6)


func test_same_seed_same_gibs() -> void:
	assert_eq(_run(_kills(91), 240), _run(_kills(91), 240))


func test_planted_fault_is_caught() -> void:
	var a: PackedByteArray = _run(_kills(91), 240)
	assert_ne(a, _run(_kills(92), 240), "another seed throws other gibs")
	var k: SignatureKills = _kills(91)
	@warning_ignore("return_value_discarded")
	k.on_kill(_ev(7, Vector2(3.0, 4.0), Vector2(1.0, 0.2), &"rocket_launcher"))
	k.gibs.vel[2] *= 1.01
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	for t: int in 240:
		k.step(t)
		if t == 40:
			@warning_ignore("return_value_discarded")
			k.on_kill(_ev(8, Vector2(6.0, 4.0), Vector2(-1.0, 0.0), &"rocket_launcher"))
	k.write_state(out)
	assert_ne(out.data_array, a, "a planted 1 % velocity fault moves the hash")


func test_gibs_fly_then_rest() -> void:
	var k: SignatureKills = _kills(5)
	assert_true(k.on_kill(_ev(1, Vector2.ZERO, Vector2.RIGHT, &"rocket_launcher")))
	for t: int in 10:
		k.step(t)
	var flew: bool = false
	for i: int in 6:
		flew = flew or k.gibs.z[i] > 0.0
	assert_true(flew, "parts are airborne after the hit-stop")
	for t: int in 600:
		k.step(10 + t)
	for i: int in 6:
		assert_true(k.gibs.at_rest(i), "piece %d at rest after 10 s" % i)
		assert_gt(k.gibs.pos[i].x, -3.0, "thrown along the blast")


func test_reduced_gore_and_robots_take_the_standard_death() -> void:
	var k: SignatureKills = _kills(5, "reduced")
	assert_false(k.on_kill(_ev(1, Vector2.ZERO, Vector2.RIGHT, &"rocket_launcher")))
	var full: SignatureKills = _kills(5)
	assert_false(full.on_kill(_ev(2, Vector2.ZERO, Vector2.RIGHT, &"rocket_launcher", false)))
	assert_false(full.on_kill(_ev(3, Vector2.ZERO, Vector2.RIGHT, &"pistol")))
	assert_true(full.on_kill(_ev(4, Vector2.ZERO, Vector2.RIGHT, &"rocket_launcher")))
	assert_false(full.on_kill(_ev(4, Vector2.ZERO, Vector2.RIGHT, &"rocket_launcher")), "once")


func test_leftover_budget_recycles_the_oldest_marks() -> void:
	var k: SignatureKills = _kills(5)
	var n: int = k.table.leftover_budget + 5
	for v: int in n:
		@warning_ignore("return_value_discarded")
		k.on_kill(_ev(v, Vector2(v, 0.0), Vector2.RIGHT, &"rocket_launcher"))
	assert_eq(k.marks.marks.size(), k.table.leftover_budget)
	var live: int = 0
	for i: int in GibSim.CAPACITY:
		live += 1 if k.gibs.live(i) else 0
	assert_eq(live, GibSim.CAPACITY, "the pool never grows past its capacity")


func test_hand_cannon_blows_the_body_back_in_one_piece() -> void:
	var k: SignatureKills = _kills(11)
	assert_true(k.on_kill(_ev(1, Vector2.ZERO, Vector2.RIGHT, &"hand_cannon")))
	var row: SignatureKill = k.table.for_weapon(&"hand_cannon")
	assert_true(row.whole_body())
	for t: int in 600:
		k.step(t)
	var body: int = -1
	for i: int in GibSim.CAPACITY:
		if k.gibs.live(i) and k.gibs.piece[i] == SignatureKill.BODY:
			body = i
	assert_gt(body, -1)
	var flew: float = k.gibs.pos[body].x
	assert_between(flew, 3.0, 9.0, "blown back along the shot, then slid (%.2f m)" % flew)
	assert_lt(absf(k.gibs.pos[body].y), 1.5, "stays on the shot line")


func test_a_wall_stops_the_parts() -> void:
	var k: SignatureKills = _kills(11)
	k.push_out = func(p: Vector2) -> Vector2: return Vector2(minf(p.x, 2.0), p.y)
	assert_true(k.on_kill(_ev(1, Vector2.ZERO, Vector2.RIGHT, &"hand_cannon")))
	for t: int in 600:
		k.step(t)
	for i: int in GibSim.CAPACITY:
		if k.gibs.live(i):
			assert_lte(k.gibs.pos[i].x, 2.0, "piece %d stopped by the wall at x = 2 m" % i)


func test_a_fire_death_chars_in_place_with_an_ash_heap_and_no_blood() -> void:
	var k: SignatureKills = _kills(5)
	assert_true(k.on_kill(_ev(4, Vector2(2.0, 2.0), Vector2(0.0, 1.0), &"burn")))
	var burns: int = k.by_style.get(&"burn", 0)
	assert_eq(burns, 1)
	var m: KillMarks.Mark = k.marks.marks[0]
	assert_eq(m.drops.size(), 0, "a fire death sprays no blood")
	assert_gt(m.ash_m, 0.0)
	assert_gt(m.ash_from, 0, "the heap grows in after the char stands")
	for t: int in 240:
		k.step(t)
	for i: int in GibSim.CAPACITY:
		if k.gibs.live(i):
			assert_eq(k.gibs.piece[i], SignatureKill.BODY)
			assert_lt(k.gibs.pos[i].distance_to(Vector2(2.0, 2.0)), 0.5, "the char stays put")


func test_a_flame_puff_kill_by_kind_burned_also_chars() -> void:
	var k: SignatureKills = _kills(6)
	var e: KillEvent = _ev(9, Vector2(1.0, 1.0), Vector2.RIGHT, &"flamethrower")
	e.damage_type = &"burned"
	assert_true(k.on_kill(e))
	assert_true(
		k.marked_near(Vector2(1.0, 1.0) * SimConst.PX_PER_M), "the standard blood is vetoed"
	)
	assert_false(k.marked_near(Vector2(9.0, 9.0) * SimConst.PX_PER_M))
