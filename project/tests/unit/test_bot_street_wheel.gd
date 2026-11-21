extends GutTest


func test_range_choice_cycles_the_occupied_wheel_slots_in_both_directions() -> void:
	var actions: PlayerActions = PlayerActions.shipped()
	var view: BotView = BotView.new()
	view.player().wheel_size = 5
	view.player().current_slot = 1
	for i: int in range(1, 5):
		var slot: BotView.Slot = BotView.Slot.new()
		slot.index = i
		slot.reach = 10.0 + i * 5
		view.held_slots().append(slot)
	var foe: BotView.Hostile = BotView.Hostile.new()
	foe.pos = Vector2(29, 0)
	view.hostiles().append(foe)
	var skill: BotProfile = BotProfile.shipped(&"expert")
	var brain: GauntletBot = GauntletBot.new(view, actions, skill, 12)
	@warning_ignore("return_value_discarded")
	brain.sample(0)
	var turn: TickInput = brain.sample(skill.reaction_ticks)
	assert_true(turn.is_pressed(actions.bit(&"weapon_prev")))
	view.player().current_slot = 4
	foe.pos.x = 7
	turn = brain.sample(skill.reaction_ticks + 1)
	assert_true(turn.is_pressed(actions.bit(&"weapon_next")))
	assert_true(turn.is_pressed(actions.bit(&"fire")))
	view.player().current_slot = 1
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


func test_two_weapons_on_the_same_grip_keep_their_own_wheel_positions_and_ranges() -> void:
	var run: GauntletRun = GauntletRun.new()
	run.controls = &"wheel"
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var s: GauntletSession = GauntletSession.open_street(bus, data, run, GauntletPilot.new())
	s.step()
	var draw: GauntletDraw = GauntletDraw.new(s.world.context().rng)
	for id: StringName in [&"weapon_flamethrower", &"weapon_gatling"]:
		assert_true(s.bonuses.apply(draw.rows[id]))
		s.step()
	var view: BotViewArena = BotViewArena.new(s.stage, s.actions, true)
	view.refresh()
	var near: BotView.Slot = view.weapon_for(5.0, GauntletBot.MELEE_M)
	var far: BotView.Slot = view.weapon_for(12.0, GauntletBot.MELEE_M)
	assert_ne(near.index, far.index)
	assert_eq(view.player().current_slot, far.index)
	var turn: TickInput = TickInput.new(1 << s.actions.bit(view.select_slot(near)), 0, 0)
	s.pilot.wheel.step(PlayerCommand.decode(turn, 0, s.actions), s.actions, s.stage.arena)
	view.refresh()
	assert_eq(s.pilot.wheel.selected(), &"flamethrower")
	assert_eq(view.player().current_slot, near.index)
	assert_eq(near.reach, s.stage.arena.gun.trigger.spec.range_m)
	assert_eq(view.select_slot(far), &"weapon_next")
	s.close()
	PlayerActions.shipped().install()
