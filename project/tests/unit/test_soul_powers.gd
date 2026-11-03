extends GutTest

var _ended: Array[StringName] = []


func _powers() -> SoulPowers:
	var t: PowerTable = PowerTable.load_default()
	assert_true(t.ok(), "; ".join(t.errors()))
	return SoulPowers.new(t)


func _run(p: SoulPowers, n: int) -> void:
	for i: int in n:
		p.tick()


func test_shipped_table_loads_both_souls() -> void:
	var t: PowerTable = PowerTable.load_default()
	assert_true(t.ok(), "; ".join(t.errors()))
	assert_not_null(t.row(&"hauler"))
	assert_not_null(t.row(&"gearbox"))


func test_power_runs_its_duration_then_cools_down() -> void:
	var p: SoulPowers = _powers()
	var d: PowerDef = p.table.row(&"hauler")
	assert_eq(p.try_activate(&"hauler"), SoulPowers.OK)
	_run(p, d.duration_ticks - 1)
	assert_true(p.is_active(&"hauler"))
	p.tick()
	assert_false(p.is_active(&"hauler"))
	assert_eq(p.try_activate(&"hauler"), SoulPowers.COOLING)
	_run(p, d.cooldown_ticks)
	assert_eq(p.try_activate(&"hauler"), SoulPowers.OK)


func test_one_power_at_a_time() -> void:
	var p: SoulPowers = _powers()
	assert_eq(p.try_activate(&"gearbox"), SoulPowers.OK)
	assert_eq(p.try_activate(&"hauler"), SoulPowers.BUSY)
	assert_eq(p.try_activate(&"gearbox"), SoulPowers.ACTIVE)


func test_using_a_soul_raises_madness_and_full_madness_refuses() -> void:
	var p: SoulPowers = _powers()
	assert_eq(p.try_activate(&"hauler"), SoulPowers.OK)
	assert_eq(p.madness, p.table.row(&"hauler").madness_cost)
	assert_true(p.interrupt(&"car"))
	p.madness = p.table.madness_max - 1.0
	assert_eq(p.try_activate(&"gearbox"), SoulPowers.MAD)


func test_madness_decays_while_no_power_runs() -> void:
	var p: SoulPowers = _powers()
	p.madness = 10.0
	_run(p, SimClock.TICK_RATE)
	assert_almost_eq(p.madness, 10.0 - p.table.madness_decay_per_s, 0.001)


func test_interrupt_follows_the_row() -> void:
	var p: SoulPowers = _powers()
	assert_eq(p.ended.connect(_on_ended), OK)
	assert_eq(p.try_activate(&"hauler"), SoulPowers.OK)
	assert_false(p.interrupt(&"hit"), "the tank shrugs off a hit")
	assert_true(p.interrupt(&"car"))
	assert_eq(_ended, [&"car"] as Array[StringName])
	assert_eq(p.try_activate(&"gearbox"), SoulPowers.OK)
	assert_true(p.interrupt(&"hit"), "a hit breaks the remote link")


func test_start_and_end_emit_the_soul_barks() -> void:
	var p: SoulPowers = _powers()
	var barks: Array[StringName] = []
	var on_start: Callable = func(_id: StringName, b: StringName) -> void: barks.append(b)
	var on_end: Callable = func(_i: StringName, _r: StringName, b: StringName) -> void:
		barks.append(b)
	assert_eq(p.started.connect(on_start), OK)
	assert_eq(p.ended.connect(on_end), OK)
	assert_eq(p.try_activate(&"gearbox"), SoulPowers.OK)
	_run(p, p.table.row(&"gearbox").duration_ticks)
	assert_eq(barks, [&"soul_gearbox_on", &"soul_gearbox_off"] as Array[StringName])


func test_a_missing_field_is_a_load_error() -> void:
	var raw: Dictionary = DataTable.open(PowerTable.PATH, PowerTable.SCHEMA).raw.duplicate(true)
	var rows: Array = raw["rows"]
	var r: Dictionary = rows[0]
	assert_true(r.erase("cooldown_s"))
	var t: PowerTable = PowerTable.from_table(
		DataTable.parse(JSON.stringify(raw), PowerTable.SCHEMA, "t")
	)
	assert_false(t.ok())


func _on_ended(_id: StringName, reason: StringName, _bark: StringName) -> void:
	_ended.append(reason)
