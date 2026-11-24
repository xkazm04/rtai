extends GutTest

const VICTIMS: Dictionary[StringName, Array] = {
	&"patrol_cop": ["cap", "cop_patrol_smg_stitch.png", [0, 3, 7, 13, 21]],
	&"riot_cop": ["helmet", "cop_riot_pistol_snap.png", [0, 4, 10, 13]],
	&"swat": ["rifle", "swat_between_fall.png", [0, 9, 16, 22, 30]],
	&"contractor": ["pistol", "contractor_fall.png", [0, 4, 14]],
	&"rocket_trooper": ["tube", "rocket_trooper_fall.png", [2, 20, 39]]
}

var art: GDScript


func before_all() -> void:
	art = load("res://features/combat/kills/kill_rake_art.gd")


func test_each_rake_has_its_own_drawn_death_timing_and_discarded_item() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	assert_eq(table.problems.size(), 0)
	var base: SignatureKill = table.for_weapon(&"claw", &"")
	assert_eq(base.id, &"claw_rake_kill")
	assert_eq(base.style, &"rake")
	assert_eq(base.pieces, PackedInt32Array([SignatureKill.BODY]))
	for victim: StringName in VICTIMS:
		var row: SignatureKill = table.for_weapon(&"claw", victim)
		var expected: Array = VICTIMS[victim]
		assert_ne(row, base)
		assert_eq(row.victim, victim)
		assert_eq(String(row.kit), str(expected[0]))
		assert_true(row.pieces.has(SignatureKill.KIT))
		assert_eq(row.pieces.has(SignatureKill.PLATE_A), victim == &"riot_cop")
		var extra: KillTrackRows.Extra = KillTrackRows.of(row.id)
		var path: String = KillDeathCells.path_of(extra, "p70", "cop/head_cap")
		assert_eq(path, "p70/" + str(expected[1]))
		assert_true(ResourceLoader.exists(StreetWalkerCards.DIR + path))
		var ticks: Array = expected[2]
		assert_eq(extra.cells_at, PackedInt32Array(ticks))
		assert_eq(KillDeathCells.frame_at(extra, 60), extra.cells_at.size() - 1)
	assert_eq(table.for_weapon(&"claw_shock").id, &"claw_throw")
	table.gore_full = false
	assert_null(table.for_weapon(&"claw", &"riot_cop"))


func test_fan_starts_at_the_gouge_and_finishes_after_its_staggered_release() -> void:
	for i: int in 11:
		var delay: int = i % 3
		for age: int in range(-1, 22):
			var u: float = art.call(&"flight", age, i)
			assert_almost_eq(u, clampf(float(age - delay) / 17.0, 0.0, 1.0), 0.000001)
		var start: Vector2 = art.call(&"drop_offset", i, 1, Vector2.RIGHT, 0.0)
		assert_eq(start, Vector2.ZERO)
		var finish: Vector2 = art.call(&"drop_offset", i, 1, Vector2.RIGHT, 1.0)
		var left: Vector2 = art.call(&"drop_offset", i, 1, Vector2.LEFT, 1.0)
		var midway: Vector2 = art.call(&"drop_offset", i, 1, Vector2.RIGHT, 0.5)
		assert_gt(finish.x, 0.32)
		assert_lte(finish.x, 1.38)
		assert_true((finish + left).is_equal_approx(Vector2.DOWN * 1.48))
		assert_true(midway.is_equal_approx(finish * 0.5 - Vector2.DOWN * 0.275))
		var repeated: Vector2 = art.call(&"drop_offset", i, 1, Vector2.RIGHT, 1.0)
		assert_eq(finish, repeated)


func test_blood_pool_reaches_its_final_size_and_stops_redrawing() -> void:
	var ground: KillGround = autofree(KillGround.new())
	ground.mark = KillMarks.Mark.new()
	ground.mark.tick = 48
	ground.mark.rake = true
	assert_true(ground.needs_reprint(78))
	assert_false(ground.needs_reprint(79))
	ground.mark.rake = false
	assert_false(ground.needs_reprint(78))
