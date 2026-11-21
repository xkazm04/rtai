extends GutTest


func test_rest_uses_each_profiles_share_of_current_max_hp() -> void:
	var view: BotView = BotView.new()
	var actions: PlayerActions = PlayerActions.shipped()
	view.player().street_max_hp = 200.0
	for id: StringName in [&"novice", &"average", &"expert"]:
		var skill: BotProfile = BotProfile.shipped(id)
		var brain: GauntletBot = GauntletBot.new(view, actions, skill, 1)
		var ready: float = 200.0 * skill.rest_hp
		view.player().hp = ready - 1
		assert_eq(brain.sample(0).move_x, 0)
		view.player().hp = ready
		assert_gt(brain.sample(1).move_x, 0)


func test_retreat_lasts_until_repaired_while_novice_keeps_chasing() -> void:
	var view: BotView = BotView.new()
	var actions: PlayerActions = PlayerActions.shipped()
	var target: BotView.Hostile = BotView.Hostile.new()
	target.pos = Vector2(10, 0)
	view.hostiles().append(target)
	view.player().street_max_hp = 100.0
	view.player().hp = 20.0
	var expert: BotProfile = BotProfile.shipped(&"expert")
	var brain: GauntletBot = GauntletBot.new(view, actions, expert, 1)
	var t: TickInput = brain.sample(0)
	assert_lt(t.move_x, 0)
	assert_true(t.is_pressed(actions.bit(&"sprint")))
	view.player().hp = 100 * expert.retreat_hp + 1
	assert_lt(brain.sample(1).move_x, 0)
	view.player().hp = 100 * expert.rest_hp
	assert_gt(brain.sample(2).move_x, 0)
	brain = GauntletBot.new(view, actions, BotProfile.shipped(&"novice"), 1)
	view.player().hp = 1
	assert_gt(brain.sample(0).move_x, 0)
