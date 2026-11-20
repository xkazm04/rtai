extends GutTest

var view: BotView
var actions: PlayerActions
var profile: BotProfile
var brain: GauntletBot


func before_each() -> void:
	view = BotView.new()
	actions = PlayerActions.shipped()
	profile = BotProfile.shipped(&"expert")
	profile.form_use = 1.0
	brain = GauntletBot.new(view, actions, profile, 22)


func _foe(id: int, x: float, arch: StringName) -> BotView.Hostile:
	var foe: BotView.Hostile = BotView.Hostile.new()
	foe.id = id
	foe.pos = Vector2(x, 0)
	foe.archetype = arch
	foe.shooter = true
	view.hostiles().append(foe)
	return foe


func _slot(index: int, reach: float, melee: bool = false) -> void:
	var slot: BotView.Slot = BotView.Slot.new()
	slot.index = index
	slot.action = RivetCarry.SLOT_ACTIONS[index]
	slot.reach = reach
	slot.melee = melee
	view.held_slots().append(slot)


func test_large_windup_outranks_nearer_patrol_and_dead_targets_drop() -> void:
	var cop: BotView.Hostile = _foe(1, 2, &"patrol_cop")
	var rocket: BotView.Hostile = _foe(2, 12, &"rocket_trooper")
	assert_same(brain.priority_target(), cop)
	rocket.tell = &"large"
	assert_same(brain.priority_target(), rocket)
	rocket.alive = false
	assert_same(brain.priority_target(), cop)


func test_advances_and_reacts_before_firing_selects_range_and_counts_switches() -> void:
	assert_gt(brain.sample(0).move_x, 0)
	var foe: BotView.Hostile = _foe(2, 7, &"contractor")
	_slot(0, 9)
	_slot(1, 30)
	view.player().current_slot = 1
	assert_false(brain.sample(1).is_pressed(actions.bit(&"fire")))
	var attack: TickInput = brain.sample(1 + profile.reaction_ticks)
	assert_true(attack.is_pressed(actions.bit(&"weapon_slot_1")))
	assert_true(attack.is_pressed(actions.bit(&"fire")))
	foe.alive = false
	@warning_ignore("return_value_discarded")
	_foe(3, 20, &"swat")
	assert_false(brain.sample(20).is_pressed(actions.bit(&"fire")))
	assert_eq(brain.counters.targets_switched, 1)
	assert_false(brain.sample(40).is_pressed(actions.bit(&"weapon_slot_1")))


func test_hands_close_in_and_attack_with_no_gun_and_choose_carried_melee() -> void:
	var foe: BotView.Hostile = _foe(1, 8, &"contractor")
	assert_gt(brain.sample(0).move_x, 0)
	assert_false(brain.sample(20).is_pressed(actions.bit(&"fire")))
	foe.pos.x = 1
	assert_true(brain.sample(21).is_pressed(actions.bit(&"melee")))
	_slot(0, 30)
	_slot(1, 1.6, true)
	assert_true(brain.sample(22).is_pressed(actions.bit(&"weapon_slot_2")))


func test_guard_button_suppresses_fire_and_releases_on_clear_tick() -> void:
	actions.bits[&"guard"] = 30
	view.player().can_guard = true
	_slot(0, 35)
	@warning_ignore("return_value_discarded")
	_foe(1, 9, &"contractor")
	@warning_ignore("return_value_discarded")
	brain.sample(0)
	var shot: BotView.Round = BotView.Round.new()
	shot.pos = Vector2(3, 0)
	shot.vel = Vector2.LEFT * 60.0
	view.incoming().append(shot)
	var t: TickInput = brain.sample(20)
	assert_true(t.is_pressed(30))
	assert_false(t.is_pressed(actions.bit(&"fire")))
	view.incoming().clear()
	t = brain.sample(21)
	assert_false(t.is_pressed(30))
	assert_true(t.is_pressed(actions.bit(&"fire")))
	assert_eq(brain.counters.guard_ticks, 1)


func test_isolated_shooter_cycles_then_enters_kerf_and_uses_blink() -> void:
	@warning_ignore("return_value_discarded")
	_foe(1, 6, &"contractor")
	var me: BotView.Player = view.player()
	me.forms = [&"tonnage", &"dent", &"kerf", &"ohm"]
	me.selected = &"tonnage"
	assert_true(brain.sample(0).is_pressed(actions.bit(&"power_gearbox")))
	me.selected = &"dent"
	assert_false(brain.sample(1).is_pressed(actions.bit(&"power_gearbox")))
	assert_true(brain.sample(2).is_pressed(actions.bit(&"power_gearbox")))
	me.selected = &"kerf"
	assert_true(brain.sample(3).is_pressed(actions.bit(&"power_hauler")))
	me.form = &"kerf"
	assert_true(brain.sample(20).is_pressed(actions.bit(&"melee")))
	assert_eq(brain.counters.form_ticks[&"kerf"], 1)


func test_ghost_choice_uses_cluster_car_and_heavy_with_locks() -> void:
	var me: BotView.Player = view.player()
	me.forms = [&"ohm", &"dent", &"tonnage"]
	var foe: BotView.Hostile = _foe(1, 4, &"patrol_cop")
	@warning_ignore("return_value_discarded")
	_foe(2, 5, &"contractor")
	@warning_ignore("return_value_discarded")
	_foe(3, 6, &"riot_cop")
	var forms: BotForms = BotForms.new(RngRegistry.new(1))
	assert_eq(forms.desired(view, foe, 1, &""), &"ohm")
	me.forms.erase(&"ohm")
	me.car_pos = Vector2(2, 3)
	assert_eq(forms.desired(view, foe, 1, &""), &"dent")
	foe.robot = true
	foe.hp = 6
	assert_eq(forms.desired(view, foe, 1, &""), &"tonnage")
	me.forms.clear()
	assert_eq(forms.desired(view, foe, 1, &""), &"")
