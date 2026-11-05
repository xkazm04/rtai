extends GutTest
## features/souls GhostLocks (d7-calls ghost-powers-5): ghost_forms.json `unlock` per ghost (Dent
## waits for act_dent), G skipping a locked ghost and Q refusing it once the story turns the lock
## on, and every ghost free while it is off (the showcase paths) or when its act is done.


func _forms() -> GhostForms:
	var t: GhostFormTable = GhostFormTable.load_default()
	assert_true(t.ok(), "; ".join(t.errors()))
	return GhostForms.new(t, SoulPowers.new(PowerTable.load_default()))


func test_the_table_names_dent_s_act_and_frees_the_rest() -> void:
	var t: GhostFormTable = GhostFormTable.load_default()
	assert_eq(t.form(&"dent").unlock, &"act_dent")
	for id: StringName in [&"tonnage", &"kerf", &"ohm"]:
		assert_eq(t.form(id).unlock, &"", "%s is free from the start" % id)


func test_off_every_ghost_is_free() -> void:
	var g: GhostForms = _forms()
	assert_false(g.locks.on, "a fresh GhostForms (arena, --bot=ghosts) locks nothing")
	assert_true(g.locks.allows(g.table, &"dent"))
	assert_eq(StagePilot.new(PlayerActions.shipped()).ghosts.forms.locks.on, false)


func test_g_skips_the_locked_ghost_and_q_refuses_it() -> void:
	var g: GhostForms = _forms()
	g.apply_locks([])
	assert_eq(g.selected, &"tonnage")
	assert_eq(g.press_next(), SoulPowers.OK)
	assert_eq(g.selected, &"kerf", "G passes Dent by")
	g.selected = &"dent"  # forced, as a stale save or a bug would
	assert_eq(g.press_transform(), GhostLocks.LOCKED)
	assert_eq(g.current(), GhostForms.BASE)


func test_a_form_never_switches_into_the_locked_ghost() -> void:
	var g: GhostForms = _forms()
	g.apply_locks([])
	assert_eq(g.press_transform(), SoulPowers.OK)
	for i: int in g.table.form(&"tonnage").enter_ticks:
		g.tick()
	assert_eq(g.switch_to(&"dent"), GhostLocks.LOCKED)
	assert_eq(g.current(), &"tonnage", "the refused switch keeps the form")


func test_the_act_frees_dent() -> void:
	var g: GhostForms = _forms()
	g.apply_locks([&"act_dent"])
	@warning_ignore("return_value_discarded")
	g.press_next()
	assert_eq(g.selected, &"dent")


func test_a_locked_selection_moves_to_the_first_free_ghost() -> void:
	var g: GhostForms = _forms()
	g.selected = &"dent"
	g.apply_locks([])
	assert_eq(g.selected, &"tonnage")
