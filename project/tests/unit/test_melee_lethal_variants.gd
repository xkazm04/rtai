extends GutTest


func test_each_actual_fighter_selects_its_kill_including_dropped_gear() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	assert_true(table.problems.is_empty(), str(table.problems))
	for w: StringName in [&"katana", &"plasma_sword", &"chainsaw", &"electro_baton"]:
		var base: SignatureKill = table.for_weapon(w)
		var k: SignatureKills = SignatureKills.new(table, RngRegistry.new(48).stream(&"brutality"))
		var played: Array[SignatureKill] = []
		@warning_ignore("return_value_discarded")
		k.killed.connect(
			func(_id: int, _n: int, row: SignatureKill, _at: Vector2, _dir: Vector2) -> void:
				played.append(row)
		)
		for id: StringName in [
			&"patrol_cop", &"riot_cop", &"swat", &"contractor", &"rocket_trooper"
		]:
			var f: Fighter = Fighter.make(Fighter.Kind.GUARD, played.size(), Vector2.ZERO, 1)
			f.archetype = id
			assert_true(k.on_kill(KillEvent.of_fighter(f, Vector2.RIGHT, w)))
			var row: SignatureKill = played.back()
			assert_ne(row, base)
			assert_eq(row, table.for_weapon(w, id))
			assert_true(row.pieces.has(SignatureKill.KIT))
		assert_eq(played.size(), 5)
		assert_eq(table.for_weapon(w, &"future_human"), base)
	table.gore_full = false
	assert_null(table.for_weapon(&"katana", &"patrol_cop"))
	var reduced: SignatureKills = SignatureKills.new(
		table, RngRegistry.new(48).stream(&"brutality")
	)
	var patrol: Fighter = Fighter.make(Fighter.Kind.GUARD, 1, Vector2.ZERO, 1)
	patrol.archetype = &"patrol_cop"
	for w: StringName in [&"katana", &"plasma_sword", &"chainsaw", &"electro_baton"]:
		assert_false(reduced.on_kill(KillEvent.of_fighter(patrol, Vector2.RIGHT, w)))
	assert_true(reduced.consumed.is_empty())
	assert_eq(reduced.gibs.kills, 0)
