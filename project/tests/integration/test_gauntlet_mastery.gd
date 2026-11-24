extends GutTest

var run: GauntletRun
var session: GauntletSession
var picker: GauntletTestPlayer
var waves: GauntletWaves
var forms: GhostForms


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	run = GauntletRun.new()
	run.seed = 1
	run.profile = &"average"
	picker = GauntletTestPlayer.new()
	picker.configure(run.profile, &"random", run.seed)
	session = GauntletSession.open_street(bus, data, run, InputSource.new())
	picker.bind(run, session)
	waves = GauntletWaves.attach(session, run, picker, 3)
	waves.manual_picks = true
	forms = session.pilot.ghosts.forms
	forms.table.mastery_free = false
	assert_true(session.bonuses.apply(waves.draw.rows[&"ghost_ohm"]))


func after_each() -> void:
	session.close()


func _enter() -> void:
	session.stage.arena.rivet.pos = Vector2(session.street.current().end_x() + 0.1, 0)
	session.step()


func _clear() -> void:
	var arena: CombatArena = session.stage.arena
	for foe: Fighter in arena.hostiles:
		if foe.alive():
			arena.damage(foe, foe.max_hp * 10.0, arena.rivet.id, &"claw")
	session.step()


func test_first_rest_after_threshold_offers_and_redeems_only_that_form() -> void:
	_enter()
	forms.bond.record(&"ohm", 4, 4)
	_clear()
	assert_false(waves.pending.has(&"master_ohm"))
	assert_true(waves.choose(picker.pick(waves.pending)))
	_enter()
	forms.bond.record(&"ohm", 0, 1)
	assert_true(waves.pending.is_empty())
	assert_false(forms.bond.mastered(&"ohm"))
	_clear()
	assert_eq(waves.pending.size(), 3)
	assert_has(waves.pending, &"master_ohm")
	assert_true(waves.choose(picker.pick(waves.pending)))
	var taken: StringName = run.picks[1]["taken"]
	assert_eq(taken, &"master_ohm")
	assert_true(forms.bond.mastered(&"ohm"))
	assert_false(forms.bond.mastered(&"tonnage"))
	var before: float = run.waves[0]["bond"][&"ohm"]
	var after: float = run.waves[1]["bond"][&"ohm"]
	assert_eq(before, 28.0)
	assert_eq(after, 30.0)
	_enter()
	_clear()
	assert_false(waves.pending.has(&"master_ohm"))


func test_disabled_bond_keeps_the_old_draw_rng_and_wave_shape() -> void:
	forms.bond.enabled = false
	forms.bond.record(&"ohm", 30, 0)
	var old_rng: RngRegistry = RngRegistry.new(run.seed)
	var old_draw: GauntletDraw = GauntletDraw.new(old_rng)
	for id: StringName in old_draw.rows.keys():
		if old_draw.rows[id]["kind"] == "mastery":
			assert_true(old_draw.rows.erase(id))
	for wave: int in range(1, 4):
		_enter()
		_clear()
		var expected: Array[StringName] = old_draw.offer(wave, run.picks, session.bonuses.owned())
		assert_eq(waves.pending, expected)
		assert_eq(waves.draw._rng.state, old_draw._rng.state)
		assert_false(run.waves[-1].has("bond"))
		assert_true(waves.choose(picker.pick(waves.pending)))


func test_declined_masteries_return_and_new_offers_have_priority() -> void:
	for id: StringName in forms.table.order:
		assert_true(session.bonuses.apply(waves.draw.rows["ghost_" + String(id)]))
	for id: StringName in [&"dent", &"kerf"]:
		forms.bond.record(id, 30, 0)
	var first: Array[StringName] = waves.draw.offer(1, [], session.bonuses.owned())
	assert_eq(first.size(), 3)
	assert_has(first, &"master_dent")
	assert_has(first, &"master_kerf")
	assert_false(first[2].begins_with("master_"))
	var history: Array[Dictionary] = [{"offered": first, "taken": first[2]}]
	for id: StringName in [&"ohm", &"tonnage"]:
		forms.bond.record(id, 30, 0)
	var next: Array[StringName] = waves.draw.offer(2, history, session.bonuses.owned())
	assert_eq(next.size(), 3)
	assert_has(next, &"master_ohm")
	assert_has(next, &"master_tonnage")
	assert_true(next.has(&"master_dent") or next.has(&"master_kerf"))


func _rest(ids: Array[StringName]) -> void:
	for id: StringName in ids:
		if id != &"ohm":
			assert_true(session.bonuses.apply(waves.draw.rows["ghost_" + String(id)]))
	_enter()
	for id: StringName in ids:
		forms.bond.record(id, 30, 0)
	_clear()


func test_paid_mastery_ends_the_rest_when_mastery_free_is_off() -> void:
	_rest([&"ohm"])
	var offered: Array[StringName] = waves.pending.duplicate()
	assert_has(offered, &"master_ohm")
	assert_true(waves.choose(offered.find(&"master_ohm")))
	assert_true(waves.pending.is_empty())
	assert_eq(run.picks.size(), 1)


func test_free_mastery_leaves_the_rest_open_for_one_normal_pick() -> void:
	forms.table.mastery_free = true
	_rest([&"ohm"])
	var offered: Array[StringName] = waves.pending.duplicate()
	assert_eq(offered.size(), 3)
	assert_true(waves.choose(offered.find(&"master_ohm")))
	assert_true(forms.bond.mastered(&"ohm"))
	assert_eq(waves.pending.size(), 2)
	assert_false(waves.pending.has(&"master_ohm"))
	assert_eq(run.picks.size(), 1)
	var first: StringName = run.picks[0]["taken"]
	assert_eq(first, &"master_ohm")
	var normal: StringName = waves.pending[1]
	assert_true(waves.choose(1))
	assert_true(waves.pending.is_empty())
	assert_eq(run.picks.size(), 2)
	var second: StringName = run.picks[1]["taken"]
	var shown: Array[StringName] = run.picks[1]["offered"]
	assert_eq(second, normal)
	assert_eq(shown, offered)
	assert_false(waves.pending.has(&"master_ohm"))


func test_two_free_masteries_then_one_normal_card() -> void:
	forms.table.mastery_free = true
	_rest([&"ohm", &"kerf"])
	assert_has(waves.pending, &"master_ohm")
	assert_has(waves.pending, &"master_kerf")
	assert_true(waves.choose(waves.pending.find(&"master_ohm")))
	assert_true(waves.choose(waves.pending.find(&"master_kerf")))
	assert_eq(waves.pending.size(), 1)
	assert_true(forms.bond.mastered(&"ohm") and forms.bond.mastered(&"kerf"))
	assert_true(waves.choose(0))
	assert_true(waves.pending.is_empty())
	assert_eq(run.picks.size(), 3)


func test_a_rest_of_only_masteries_ends_after_they_are_taken() -> void:
	forms.table.mastery_free = true
	var ids: Array[StringName] = [&"dent", &"kerf", &"tonnage"]
	_rest(ids)
	assert_eq(waves.pending.size(), 3)
	for i: int in range(3):
		assert_true(String(waves.pending[0]).begins_with("master_"))
		assert_true(waves.choose(0))
	assert_true(waves.pending.is_empty())
	assert_eq(run.picks.size(), 3)
