extends GutTest
## features/souls GhostForms: the form state machine's enter, exit and switch timings on whole
## ticks, the SoulPowers cost model under it, and a planted fault (a switch taken
## mid-transformation) caught by check().

var _events: Array[String] = []


func _forms() -> GhostForms:
	var t: GhostFormTable = GhostFormTable.load_default()
	assert_true(t.ok(), "; ".join(t.errors()))
	var pt: PowerTable = PowerTable.load_default()
	assert_true(pt.ok(), "; ".join(pt.errors()))
	var g: GhostForms = GhostForms.new(t, SoulPowers.new(pt))
	_events.clear()
	_watch(g)
	return g


func _watch(g: GhostForms) -> void:
	var w: Callable = func(a: StringName, b: StringName, n: int) -> void:
		_log("in %s>%s %d" % [a, b, n])
	@warning_ignore("return_value_discarded")
	g.form_entering.connect(w)
	@warning_ignore("return_value_discarded")
	g.form_entered.connect(func(a: StringName) -> void: _log("entered %s" % a))
	@warning_ignore("return_value_discarded")
	g.form_exiting.connect(func(a: StringName, n: int) -> void: _log("out %s %d" % [a, n]))
	@warning_ignore("return_value_discarded")
	g.form_exited.connect(func(a: StringName) -> void: _log("exited %s" % a))


func _log(line: String) -> void:
	_events.append(line)


func _run(g: GhostForms, n: int) -> void:
	for i: int in n:
		g.powers.tick()
		g.tick()


func test_table_has_the_four_ghosts_in_order_with_their_aliases() -> void:
	var t: GhostFormTable = GhostFormTable.load_default()
	assert_eq(t.order, [&"tonnage", &"dent", &"kerf", &"ohm"] as Array[StringName])
	assert_eq(t.form(&"tonnage").power, &"hauler")
	assert_eq(t.form(&"dent").power, &"gearbox")
	assert_gt(t.form(&"tonnage").size_k, 2.5, "Tonnage is about 3x Rivet")
	assert_lt(t.form(&"ohm").size_k, 1.0, "Ohm is smaller than Rivet")
	assert_gt(t.form(&"kerf").top_mps, t.form(&"dent").top_mps, "Kerf is the fastest")
	assert_ne(t.form(&"tonnage").anchor(&"press_head"), Vector2.ZERO)


func test_enter_takes_enter_s_and_lands_through_the_in_between_pose() -> void:
	var g: GhostForms = _forms()
	var f: GhostFormDef = g.table.form(&"tonnage")
	assert_eq(g.press_transform(), SoulPowers.OK)
	assert_eq(g.current(), GhostForms.BASE, "no form (no attacks) mid-transformation")
	_run(g, f.enter_ticks / 2)
	assert_eq(g.stage(), 1, "past the midpoint = the in-between pose")
	_run(g, f.enter_ticks - f.enter_ticks / 2 - 1)
	assert_false(g.settled())
	_run(g, 1)
	assert_eq(g.current(), &"tonnage")
	assert_eq(_events, ["in base>tonnage %d" % f.enter_ticks, "entered tonnage"])


func test_exit_returns_to_base_and_the_power_cools_down() -> void:
	var g: GhostForms = _forms()
	var f: GhostFormDef = g.table.form(&"tonnage")
	assert_eq(g.press_transform(), SoulPowers.OK)
	_run(g, f.enter_ticks)
	assert_eq(g.press_transform(), SoulPowers.OK)
	_run(g, f.exit_ticks)
	assert_eq(g.current(), GhostForms.BASE)
	assert_true(g.settled())
	assert_gt(g.powers.cooldown_left(&"hauler"), 0)
	assert_eq(g.press_transform(), SoulPowers.COOLING, "the cost model holds")


func test_power_expiry_exits_the_form_by_itself() -> void:
	var g: GhostForms = _forms()
	assert_eq(g.press_transform(), SoulPowers.OK)
	var d: PowerDef = g.powers.table.row(&"hauler")
	_run(g, d.duration_ticks)
	assert_eq(g.phase, GhostForms.EXITING)
	_run(g, g.table.form(&"tonnage").exit_ticks)
	assert_eq(g.current(), GhostForms.BASE)


func test_next_selects_in_base_and_switches_through_the_flash_in_a_form() -> void:
	var g: GhostForms = _forms()
	assert_eq(g.press_next(), SoulPowers.OK)
	assert_eq(g.selected, &"dent")
	assert_eq(g.press_transform(), SoulPowers.OK)
	_run(g, g.table.form(&"dent").enter_ticks)
	assert_eq(g.press_next(), SoulPowers.OK)
	assert_eq(g.phase, GhostForms.SWITCHING)
	_run(g, g.table.switch_ticks)
	assert_eq(g.current(), &"kerf")
	assert_true(g.powers.is_active(&"kerf"))
	assert_gt(g.powers.cooldown_left(&"gearbox"), 0)
	assert_lt(
		g.table.switch_ticks, g.table.form(&"kerf").enter_ticks, "the flash beats a base pass"
	)


func test_requests_mid_transformation_are_refused() -> void:
	var g: GhostForms = _forms()
	assert_eq(g.press_transform(), SoulPowers.OK)
	_run(g, 5)
	assert_eq(g.press_next(), GhostForms.BUSY)
	assert_eq(g.press_transform(), GhostForms.BUSY)
	_run(g, 200)
	assert_eq(g.current(), &"tonnage")
	assert_eq(g.press_next(), SoulPowers.OK)
	_run(g, 3)
	assert_eq(g.switch_to(&"ohm"), GhostForms.BUSY, "no switch mid-flash")
	_run(g, 200)
	assert_eq(g.check(), [] as Array[String])


func test_planted_mid_transformation_switch_is_caught() -> void:
	var g: GhostForms = _forms()
	g.selected = &"dent"
	assert_eq(g.press_transform(), SoulPowers.OK)
	_run(g, g.table.form(&"dent").enter_ticks)
	g.plant_mid_switch = true
	assert_eq(g.press_next(), SoulPowers.OK)
	_run(g, 5)
	assert_eq(g.switch_to(&"ohm"), SoulPowers.OK, "the plant lets the cut through")
	_run(g, 200)
	assert_eq(g.check().size(), 1, "check() catches the cut transformation")
