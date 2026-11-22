extends GutTest


func test_rocket_withholds_fire_near_rivet_and_fires_at_ten_metres() -> void:
	var view: BotView = BotView.new()
	var controls: PlayerActions = PlayerActions.shipped(true)
	var skill: BotProfile = BotProfile.shipped(&"expert")
	skill.aim_error_deg = 0.0
	skill.reaction_ticks = 0
	var brain: GauntletBot = GauntletBot.new(view, controls, skill, 8)
	var rocket: WeaponSpec = WeaponTable.shipped().weapon(&"rocket_launcher")
	var slot: BotView.Slot = BotView.Slot.new()
	slot.index = 1
	slot.splash_m = rocket.splash_radius_m
	slot.reach = rocket.range_m
	view.held_slots().append(slot)
	view.player().current_slot = slot.index
	var foe: BotView.Hostile = BotView.Hostile.new()
	foe.id = 1
	view.hostiles().append(foe)
	for distance: float in [1.0, 2.5, slot.splash_m + view.player().radius + skill.blast_margin_m]:
		foe.pos = Vector2.RIGHT * distance
		assert_false(brain.sample(0).is_pressed(controls.bit(&"fire")), str(distance))
	foe.pos = Vector2.RIGHT * 10.0
	assert_true(brain.sample(1).is_pressed(controls.bit(&"fire")))
	# A wall before the distant target stops the shot.
	view.solid_props().append(Rect2(1.5, -0.2, 0.5, 0.4))
	assert_false(brain.sample(2).is_pressed(controls.bit(&"fire")))
	var intent: GauntletBot.Intent = GauntletBot.Intent.new()
	intent.reach = 10.0
	intent.aim = Vector2.RIGHT
	assert_false(BotArsenal.clear_shot(view, intent, controls, skill.blast_margin_m))
	view.solid_props()[0] = Rect2(6.0, -0.2, 0.5, 0.4)
	assert_true(BotArsenal.clear_shot(view, intent, controls, skill.blast_margin_m))
