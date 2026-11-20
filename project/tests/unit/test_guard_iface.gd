extends GutTest


func test_guard_block_loads_all_eight_settings() -> void:
	var t: DataTable = DataTable.open(CombatTuning.TABLE, CombatTuning.SCHEMA)
	assert_eq(t.object(t.raw, "guard").size(), 8)
	var g: GuardTuning = GuardTuning.load_table()
	assert_eq(g.arc_deg, 120.0)
	assert_eq(g.move_k, 0.45)
	assert_eq(g.meter_max, 100.0)
	assert_eq(g.drain_per_round, 12.0)
	assert_eq(g.refill_per_s, 40.0)
	assert_eq(g.refill_delay_s, 0.6)
	assert_eq(g.stagger_s, 0.8)
	assert_eq(g.melee_drain, 20.0)


func test_weapon_spec_loads_optional_round_and_rejects_unknown_sizes() -> void:
	assert_eq(Shot.new().size, &"small")
	var t: DataTable = DataTable.open(WeaponTable.TABLE, WeaponTable.SCHEMA)
	var row: Dictionary = t.array(t.raw, "weapons")[0]
	assert_false(row.has("round"))
	assert_eq(WeaponSpec.from_row(t, row).round, &"small")
	row["round"] = "large"
	assert_eq(WeaponSpec.from_row(t, row).round, &"large")
	assert_true(t.ok(), str(t.errors()))
	row["round"] = "medium"
	assert_eq(WeaponSpec.from_row(t, row).round, &"small")
	assert_false(t.ok())


func test_combat_weapon_round_reaches_the_fired_shot() -> void:
	var t: DataTable = DataTable.open(CombatTuning.TABLE, CombatTuning.SCHEMA)
	var row: Dictionary = t.object(t.object(t.raw, "weapons"), "gloria")
	var path: String = TestTmp.dir("guard").path_join("combat.json")
	for value: String in ["", "large", "medium"]:
		if value != "":
			row["round"] = value
		var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		assert_true(f.store_string(JSON.stringify(t.raw)))
		f.close()
		var tuning: CombatTuning = CombatTuning.shipped(path)
		var w: CombatTuning.Weapon = tuning.weapon(&"gloria")
		var expected: StringName = &"large" if value == "large" else &"small"
		assert_eq(tuning.ok(), value != "medium")
		assert_eq(w.round, expected)
		assert_eq(Shot.fire(Fighter.new(), Vector2.RIGHT, w).size, expected)


func test_guard_bit_is_unique_and_survives_a_packed_aim() -> void:
	var actions: PlayerActions = PlayerActions.shipped()
	var used: Array[int] = []
	for row: Dictionary in actions.rows:
		var b: int = actions.bit(StringName(str(row["id"])))
		if b >= 0:
			assert_false(used.has(b), str(row["id"]))
			used.append(b)
	var guard: int = actions.bit(&"guard")
	assert_eq(guard, 30)
	var aim: int = PlayerCommand.pack_aim(Vector2.LEFT, actions, 10.0)
	var tick: TickInput = TickInput.unpack(TickInput.new(aim | (1 << guard)).pack())
	assert_true(tick.is_pressed(guard))
	assert_eq(tick.buttons & ~(1 << guard), aim)
