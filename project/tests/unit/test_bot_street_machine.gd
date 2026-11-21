extends GutTest


func test_stomp_uses_available_time_then_roll_then_tonnage() -> void:
	var view: BotView = BotView.new()
	var me: BotView.Player = view.player()
	var foe: BotView.Hostile = BotView.Hostile.new()
	foe.stomp_m = 3.5
	foe.pos = Vector2(2, 0)
	me.walk_mps = 6
	me.roll_m = 3.2
	me.can_roll = true
	me.forms = [&"tonnage"]
	foe.tell_ticks = 60
	var choice: BotDefence.Choice = BotMachineFight.stomp(view, foe, true)
	assert_eq(choice.action, &"sprint")
	assert_lt(choice.move.x, 0.0)
	foe.tell_ticks = 4
	assert_eq(BotMachineFight.stomp(view, foe, true).action, &"roll")
	me.can_roll = false
	assert_eq(BotMachineFight.stomp(view, foe, true).form, &"tonnage")
	me.can_roll = true
	view.solid_props().append(Rect2(-1, -5, 0.4, 10))
	assert_eq(BotMachineFight.stomp(view, foe, true).form, &"tonnage")
	me.pos = Vector2(-4, 0)
	assert_true(BotMachineFight.stomp(view, foe, true).hold_position)


func test_machine_closes_after_discharge_and_circles_the_armoured_face() -> void:
	var view: BotView = BotView.new()
	view.player().hp = 100
	var foe: BotView.Hostile = BotView.Hostile.new()
	foe.archetype = &"war_machine"
	foe.stomp_m = 3.5
	foe.pos = Vector2(7, 0)
	foe.facing = Vector2.LEFT
	view.hostiles().append(foe)
	var actions: PlayerActions = PlayerActions.shipped()
	var brain: GauntletBot = GauntletBot.new(view, actions, BotProfile.shipped(&"expert"), 3)
	var t: TickInput = brain.sample(0)
	assert_gt(t.move_x, 0)
	assert_false(t.is_pressed(actions.bit(&"sprint")))
	foe.opening = true
	t = brain.sample(9)
	assert_true(t.is_pressed(actions.bit(&"sprint")))
	foe.archetype = &"sentry_turret"
	foe.stomp_m = 0
	foe.opening = false
	foe.pos = Vector2(1.3, 0)
	t = brain.sample(10)
	assert_true(t.is_pressed(actions.bit(&"melee")))
	assert_gt(absi(t.move_y), absi(t.move_x))
