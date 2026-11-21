extends GutTest

const Entry = preload("res://dev/gauntlet/gauntlet.gd")

var entry: Entry
var view: GauntletPickView


func before_each() -> void:
	entry = Entry.new()
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	entry.run.seed = 7
	var picker: GauntletPilot = GauntletPilot.new()
	entry.session = GauntletSession.open_street(bus, data, entry.run, picker)
	entry.waves = GauntletWaves.attach(entry.session, entry.run, picker, 1)
	entry.waves.manual_picks = true
	view = GauntletPickView.new()
	view.waves = entry.waves
	view.run = entry.run
	add_child(view)


func after_each() -> void:
	view.free()
	entry.session.close()
	entry.free()


func _clear() -> void:
	var s: GauntletSession = entry.session
	s.stage.arena.rivet.pos.x = s.street.current().end_x() + 0.1
	s.step()
	for foe: Fighter in s.stage.arena.hostiles:
		s.stage.arena.damage(foe, foe.max_hp * 10, s.stage.arena.rivet.id, &"claw")
	s.step()


func test_last_clear_freezes_at_its_tick_until_a_number_key_is_released() -> void:
	_clear()
	var tick: int = entry.session.tick()
	for frame: int in 12:
		entry._physics_process(SimClock.TICK_DT)
	assert_eq(entry.session.tick(), tick)
	assert_false(entry.waves.done)
	assert_true(entry.run.picks.is_empty())
	assert_true(view.visible)
	var offers: Array[StringName] = entry.waves.pending.duplicate()
	assert_eq(view._cards.get_child_count(), offers.size())
	var event: InputEventAction = InputEventAction.new()
	event.action = RivetCarry.SLOT_ACTIONS[1]
	event.pressed = true
	view._input(event)
	assert_false(entry.waves.done)
	event.pressed = false
	view._input(event)
	assert_true(entry.waves.done)
	assert_false(view.visible)
	assert_eq(entry.run.picks[0], {"wave": 1, "offered": offers, "taken": offers[1]})


func test_a_pick_resumes_the_next_tick_without_reapplying_the_bonus() -> void:
	entry.waves._limit = 2
	_clear()
	var tick: int = entry.session.tick()
	var card: Button = view._cards.get_child(2) as Button
	card.pressed.emit()
	assert_false(view.visible)
	assert_false(entry.waves.done)
	card.pressed.emit()
	entry._physics_process(SimClock.TICK_DT)
	assert_eq(entry.session.tick(), tick + 1)
	assert_eq(entry.run.picks.size(), 1)


func test_click_applies_the_only_eligible_card() -> void:
	var rows: Dictionary[StringName, Dictionary] = entry.waves.draw.rows
	var row: Dictionary = rows[&"stat_speed_10"]
	rows.clear()
	rows[&"stat_speed_10"] = row
	_clear()
	assert_eq(view._cards.get_child_count(), 1)
	assert_false(entry.waves.choose(1))
	(view._cards.get_child(0) as Button).pressed.emit()
	assert_false(view.visible)
	assert_true(entry.waves.done)
	assert_eq(entry.run.mods.value(&"speed"), 1.1)


func test_every_shipped_offer_has_a_translated_kind_and_title() -> void:
	var english: Translation = GauntletHud.ENGLISH
	for row: Dictionary in entry.waves.draw.rows.values():
		var kind: String = str(row["kind"]).to_upper()
		var ref: String = str(row["ref"]).to_upper()
		var title: StringName = english.get_message("GAUNTLET__%s__%s" % [kind, ref])
		var category: StringName = english.get_message("GAUNTLET__KIND__%s" % kind)
		assert_ne(title, &"", "title for %s" % ref)
		assert_ne(category, &"", "kind for %s" % kind)


func test_empty_draw_finishes_without_showing_the_screen() -> void:
	entry.waves.draw.rows.clear()
	_clear()
	assert_true(entry.waves.done)
	assert_false(view.visible)
	assert_true(entry.run.picks.is_empty())
