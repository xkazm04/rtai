extends GutTest

var arena: CombatArena
var victim: Fighter


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	arena = CombatArena.new(CombatTuning.shipped(), bus, RngRegistry.new(41).stream(&"combat"))
	arena.tick = 73
	victim = arena.spawn_guard(Vector2.RIGHT)
	victim.hp = 100.0


func _land(weapon: StringName, single: bool = true, stun: int = -1) -> FighterFx:
	var table: MeleeTable = MeleeTable.weapon(weapon)
	table.single_swing = single
	var combo: MeleeCombo = MeleeCombo.new(table)
	combo.press()
	if stun >= 0:
		combo.current().stun_ticks = stun
	var outcome: MeleeLethal.Contact = MeleeLethal.Contact.NORMAL
	if weapon == &"chainsaw":
		outcome = MeleeLethal.Contact.GRIND
	assert_true(MeleeContact.new().land(arena, victim, combo, Vector2.RIGHT, outcome))
	return arena.areas.effect(victim) if arena.areas != null else null


func test_both_saw_rows_hold_for_sixteen_ticks_without_electric_marks() -> void:
	for single: bool in [true, false]:
		var fx: FighterFx = _land(&"chainsaw", single)
		assert_eq(fx.stun_ticks, 16)
		assert_eq(fx.hold_look_until, arena.tick + 16)
		for age: int in 16:
			assert_true(fx.holds())
			assert_false(StunCrowd.electric(fx, arena.tick + age))
			fx.tick_timers()
		assert_false(fx.holds())


func test_baton_shows_current_on_contact_even_during_a_saw_hold() -> void:
	for after_saw: bool in [false, true]:
		if after_saw:
			@warning_ignore("return_value_discarded")
			_land(&"chainsaw")
		var fx: FighterFx = _land(&"electro_baton")
		assert_eq(fx.stun_ticks, 90)
		assert_eq(fx.hold_look_until, -1)
		assert_true(StunCrowd.electric(fx, arena.tick))


func test_marks_resume_after_the_hold_if_another_stun_lasts_longer() -> void:
	var fx: FighterFx = _land(&"electro_baton")
	@warning_ignore("return_value_discarded")
	_land(&"chainsaw")
	assert_eq(fx.stun_ticks, 90)
	assert_false(StunCrowd.electric(fx, fx.hold_look_until))
	assert_true(StunCrowd.electric(fx, fx.hold_look_until + 1))
	fx.stun_ticks = 0
	assert_false(StunCrowd.electric(fx, fx.hold_look_until + 1))


func test_zero_tick_hit_creates_no_effect_and_one_tick_is_a_hold() -> void:
	assert_null(_land(&"chainsaw", true, 0))
	var fx: FighterFx = _land(&"chainsaw", true, 1)
	assert_eq(fx.stun_ticks, 1)
	assert_eq(fx.hold_look_until, arena.tick + 1)


func test_hold_look_is_absent_from_serialized_fighter_state() -> void:
	var fx: FighterFx = _land(&"chainsaw")
	var with_hold: StreamPeerBuffer = StreamPeerBuffer.new()
	fx.write_state(with_hold)
	fx.hold_look_until = -1
	var without_hold: StreamPeerBuffer = StreamPeerBuffer.new()
	fx.write_state(without_hold)
	assert_gt(with_hold.get_size(), 0)
	assert_eq(with_hold.data_array, without_hold.data_array)
