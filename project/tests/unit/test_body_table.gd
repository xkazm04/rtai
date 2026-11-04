extends GutTest


func test_shipped_table_loads() -> void:
	var t: BodyTable = BodyTable.load_default()
	assert_true(t.ok(), "; ".join(t.errors()))


func test_rivet_is_only_slightly_larger_than_a_human() -> void:
	var t: BodyTable = BodyTable.load_default()
	var ratio: float = t.radius(&"rivet_base") / t.radius(&"human")
	assert_between(ratio, 1.0, 1.35)


func test_a_human_always_loses_to_rivet() -> void:
	var t: BodyTable = BodyTable.load_default()
	var r: BodyRule = t.rule(&"rivet_base", &"human")
	assert_eq(r.walk, &"shove")
	assert_eq(r.run, &"knockdown")
	assert_gt(t.share(&"rivet_base", &"human"), 0.5, "the human takes most of the overlap")
	assert_eq(t.rule(&"human", &"rivet_base").run, &"blocked")


func test_robots_and_bosses_are_blocked_both_ways() -> void:
	var t: BodyTable = BodyTable.load_default()
	for other: StringName in [&"rivet_base", &"human", &"robot", &"boss"]:
		for big: StringName in [&"robot", &"boss"]:
			assert_eq(t.rule(other, big).run, &"blocked", "%s -> %s" % [other, big])
			assert_eq(t.rule(big, other).run, &"blocked", "%s -> %s" % [big, other])


func test_a_missing_rule_is_a_load_error() -> void:
	var raw: Dictionary = DataTable.open(BodyTable.PATH, BodyTable.SCHEMA).raw.duplicate(true)
	var rules: Array = raw["rules"]
	rules.remove_at(0)
	var t: BodyTable = BodyTable.from_table(
		DataTable.parse(JSON.stringify(raw), BodyTable.SCHEMA, "t")
	)
	assert_false(t.ok())


## The shove/tackle line is per class (the attacker's): Rivet's walk must shove, a fleeing or
## rioting human (4.5 m/s in the sim) must be a run into Rivet, so it is blocked, never a shove.
func test_run_line_is_per_class() -> void:
	var t: BodyTable = BodyTable.load_default()
	assert_gt(t.run_mps(&"rivet_base"), 6.75, "Rivet's 6.75 m/s walk is a walk")
	assert_lt(t.run_mps(&"human"), 4.5, "a 4.5 m/s fleeing human is a run")
	var runner: BodyContact = BodyContact.resolve(
		t,
		&"human",
		&"rivet_base",
		PackedVector2Array([Vector2.ZERO, Vector2(0.7, 0)]),
		Vector2(4.5, 0)
	)
	assert_eq(runner.result, &"blocked")


func test_a_class_without_run_mps_is_a_load_error() -> void:
	var raw: Dictionary = DataTable.open(BodyTable.PATH, BodyTable.SCHEMA).raw.duplicate(true)
	var classes: Array = raw["classes"]
	var human: Dictionary = classes[1]
	assert_eq(str(human["id"]), "human")
	@warning_ignore("return_value_discarded")
	human.erase("run_mps")
	var t: BodyTable = BodyTable.from_table(
		DataTable.parse(JSON.stringify(raw), BodyTable.SCHEMA, "t")
	)
	assert_false(t.ok())


func test_blocked_contact_holds_the_defender() -> void:
	var t: BodyTable = BodyTable.load_default()
	var c: BodyContact = BodyContact.resolve(
		t,
		&"rivet_base",
		&"robot",
		PackedVector2Array([Vector2.ZERO, Vector2(0.5, 0)]),
		Vector2(6, 1)
	)
	assert_eq(c.result, &"blocked")
	assert_eq(c.b_pos, Vector2(0.5, 0))
	assert_almost_eq(c.a_vel.x, 0.0, 1e-5)
	assert_almost_eq(c.a_vel.y, 1.0, 1e-5, "the tangent is kept")


func test_arena_rivet_never_ends_inside_a_guard() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), bus, RngRegistry.new(3).stream(&"combat")
	)
	var guard: Fighter = arena.spawn_guard(Vector2.ZERO)
	guard.pos = arena.rivet.pos + Vector2(0.2, 0.0)
	var n: int = ArenaBodies.resolve(arena, Vector2(3.0, 0.0))
	var t: BodyTable = ArenaBodies.table()
	var rs: float = t.radius(RivetBody.CLASS) + t.radius(RivetBody.PERSON)
	assert_eq(n, 1)
	assert_almost_eq(arena.rivet.pos.distance_to(guard.pos), rs, 1e-4)


func test_arena_sprint_knocks_a_guard_back() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), bus, RngRegistry.new(3).stream(&"combat")
	)
	var guard: Fighter = arena.spawn_guard(Vector2.ZERO)
	guard.pos = arena.rivet.pos + Vector2(0.5, 0.0)
	@warning_ignore("return_value_discarded")
	ArenaBodies.resolve(arena, Vector2(9.0, 0.0))  # a sprint over the 7.5 m/s line
	assert_gt(arena.rivet.pos.distance_to(guard.pos), 1.5, "knocked back by the rule's 1.6 m")


## The shove/tackle line is Rivet's own speed into a body (body.cpp), so his quest walk must stay
## under it: a walk always shoves, and only a sprint (above walk speed) tackles. If combat's walk
## speed is raised past rivet_base run_mps, every brush with a person becomes a knockdown.
func test_rivet_walk_speed_never_tackles() -> void:
	var walk: float = CombatTuning.shipped().rivet["walk_mps"]
	var t: BodyTable = BodyTable.load_default()
	var run: float = t.run_mps(RivetBody.CLASS)
	var why: String = "combat walk_mps %.2f vs bodies rivet_base run_mps %.2f" % [walk, run]
	assert_lt(walk, run, why)
