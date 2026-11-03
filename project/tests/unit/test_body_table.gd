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
