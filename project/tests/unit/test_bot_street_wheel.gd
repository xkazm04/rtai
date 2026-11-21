extends GutTest


func test_range_choice_cycles_the_occupied_wheel_slots_in_both_directions() -> void:
	var actions: PlayerActions = PlayerActions.shipped()
	var view: BotView = BotView.new()
	view.player().wheel = true
	view.player().current_slot = 0
	for i: int in [0, 2, 3]:
		var slot: BotView.Slot = BotView.Slot.new()
		slot.index = i
		slot.action = RivetCarry.SLOT_ACTIONS[i]
		slot.reach = 10.0 + i * 5
		view.held_slots().append(slot)
	var foe: BotView.Hostile = BotView.Hostile.new()
	foe.pos = Vector2(24, 0)
	view.hostiles().append(foe)
	var skill: BotProfile = BotProfile.shipped(&"expert")
	var brain: GauntletBot = GauntletBot.new(view, actions, skill, 12)
	@warning_ignore("return_value_discarded")
	brain.sample(0)
	var turn: TickInput = brain.sample(skill.reaction_ticks)
	assert_true(turn.is_pressed(actions.bit(&"weapon_prev")))
	view.player().current_slot = 3
	foe.pos.x = 7
	turn = brain.sample(skill.reaction_ticks + 1)
	assert_true(turn.is_pressed(actions.bit(&"weapon_next")))
	assert_true(turn.is_pressed(actions.bit(&"fire")))
	view.player().current_slot = 0
	turn = brain.sample(skill.reaction_ticks + 2)
	assert_false(turn.is_pressed(actions.bit(&"weapon_next")))


func test_approach_leaves_a_margin_inside_the_selected_weapons_range() -> void:
	var view: BotView = BotView.new()
	var gun: BotView.Slot = BotView.Slot.new()
	gun.reach = 10.0
	view.held_slots().append(gun)
	var foe: BotView.Hostile = BotView.Hostile.new()
	foe.pos.x = 9.0
	view.hostiles().append(foe)
	var brain: GauntletBot = GauntletBot.new(
		view, PlayerActions.shipped(), BotProfile.shipped(&"average"), 1
	)
	assert_gt(brain.sample(0).move_x, 0)
	foe.pos.x = 8.7
	var strafing: TickInput = brain.sample(1)
	assert_eq(strafing.move_x, 0)
	assert_gt(absi(strafing.move_y), 0)
