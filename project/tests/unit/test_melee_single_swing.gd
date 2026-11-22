extends GutTest
## Drive the same held primary level that StagePilot passes to the combo. Count starts
## through recovery, including ticks after release when an old buffered hit used to begin.


func test_hands_click_and_repeat() -> void:
	_check_weapon(MeleeTable.shipped())


func test_chainsaw_click_and_repeat() -> void:
	_check_weapon(MeleeTable.weapon(&"chainsaw"))


func test_electro_baton_click_and_repeat() -> void:
	_check_weapon(MeleeTable.weapon(&"electro_baton"))


func test_katana_click_and_repeat() -> void:
	_check_weapon(MeleeTable.weapon(&"katana"))


func test_plasma_sword_click_and_repeat() -> void:
	var table: MeleeTable = MeleeTable.weapon(&"plasma_sword")
	_check_weapon(table)
	assert_gte(table.hits[0].active, 6)
	assert_eq(table.deflect_m, 1.6)


func _check_weapon(table: MeleeTable) -> void:
	assert_true(table.single_swing)
	assert_eq(table.hits.size(), 1)
	assert_true(MeleeSwing.SHAPES.has(table.swing_style))
	for down: int in [1, 6, 20]:
		var c: MeleeCombo = MeleeCombo.new(table)
		for tick: int in 100:
			_tick(c, tick < down)
		assert_eq(c.starts, 1, "%s, %d-tick click" % [table.id, down])
	var tap: MeleeCombo = MeleeCombo.new(table)
	for tick: int in 100:
		_tick(tap, tick == 0 or tick == 3)
		if tick == 3:
			assert_false(tap.buffered)
	assert_eq(tap.starts, 1, "a second click inside the swing is consumed")
	_check_repeat(table)


func _check_repeat(table: MeleeTable) -> void:
	var c: MeleeCombo = MeleeCombo.new(table)
	var h: MeleeHit = table.hits[0]
	var period: int = h.length() + h.grind_min_ticks
	var starts: Array[int] = []
	for tick: int in 2 * period:
		# A continuously held saw stays in the grind. Release it for the single tick that
		# lets the teeth come out, then hold again through the entire recovery.
		var release: int = h.windup + h.active - 1 + h.grind_min_ticks
		var down: bool = h.grind_ticks == 0 or tick % period != release
		var before: int = c.starts
		_tick(c, down)
		if c.starts != before:
			starts.append(tick)
			assert_eq(c.hit_index, 1)
	assert_eq(starts, [0, period], "the repeat waits for the complete recovery")


func _tick(c: MeleeCombo, down: bool) -> void:
	if down:
		c.press()
	c.holding = down
	c.step()


func test_disabling_the_table_switch_restores_the_katana_chain() -> void:
	var data: DataTable = DataTable.open(MeleeTable.WEAPONS, MeleeTable.WEAPONS_SCHEMA)
	data.raw["single_swing"] = false
	var c: MeleeCombo = MeleeCombo.new(MeleeTable.weapon_from(data, &"katana"))
	var started: Array = []
	for tick: int in 100:
		var before: int = c.starts
		_tick(c, tick < 6)
		if c.starts != before:
			started.append([tick, c.current().id])
	assert_eq(started, [[0, &"katana_1"], [11, &"katana_2"]])


func test_a_baton_hit_stuns_and_conducts_at_most_two_metal_hops() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), bus, RngRegistry.new(9).stream(&"combat")
	)
	var baton: PlayerMelee = PlayerMelee.new(MeleeTable.weapon(&"electro_baton"))
	for i: int in 4:
		var machine: Fighter = Fighter.make(
			Fighter.Kind.GUARD, i + 1, Vector2.RIGHT * (1 + i * 2), 5
		)
		machine.machine = true
		arena.hostiles.append(machine)
	var bystander: Fighter = Fighter.make(Fighter.Kind.GUARD, 5, Vector2(2.5, 1), 5)
	arena.hostiles.append(bystander)
	for tick: int in baton.combo.table.hits[0].windup:
		@warning_ignore("return_value_discarded")
		baton.step(arena, tick == 0, Vector2.RIGHT)
	assert_eq(arena.areas.chain_arcs.size(), 2)
	for i: int in 3:
		assert_eq(arena.areas.effect(arena.hostiles[i]).stun_ticks, 90)
	assert_null(arena.areas.effect(arena.hostiles[3]))
	assert_null(arena.areas.effect(bystander))
