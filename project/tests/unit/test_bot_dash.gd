extends GutTest

var view: BotView
var profile: BotProfile
var actions: PlayerActions
var brain: GauntletBot


func before_each() -> void:
	view = BotView.new()
	view.player().can_dash = true
	view.player().dash_m = 4.5
	profile = BotProfile.shipped(&"expert")
	profile.dash_chance = 1.0
	actions = PlayerActions.shipped(true)
	brain = GauntletBot.new(view, actions, profile, 81)


func _round() -> BotView.Round:
	var shot: BotView.Round = BotView.Round.new()
	shot.id = 1
	shot.size = Shot.LARGE
	shot.pos = Vector2(5, 0)
	shot.vel = Vector2.LEFT * 13.0
	view.incoming().append(shot)
	return shot


func _pressed(input: TickInput) -> bool:
	return input.is_pressed(actions.bit(&"dash"))


func test_large_round_draws_one_sideways_dash_after_read() -> void:
	var shot: BotView.Round = _round()
	for tick: int in profile.dash_read_ticks:
		assert_false(_pressed(brain.sample(tick)))
		shot.pos += shot.vel * SimClock.TICK_DT
	var press: TickInput = brain.sample(profile.dash_read_ticks)
	assert_true(_pressed(press))
	assert_eq(press.move_x, 0)
	assert_eq(absi(press.move_y), TickInput.AXIS_MAX)
	assert_false(_pressed(brain.sample(profile.dash_read_ticks + 1)))


func test_early_roll_has_priority_but_late_impact_can_dash() -> void:
	profile.dash_read_ticks = 0
	var me: BotView.Player = view.player()
	me.can_roll = true
	me.iframe_from = 3
	me.iframe_to = 9
	me.roll_m = 2.0
	me.roll_ticks = 12
	var shot: BotView.Round = _round()
	shot.splash_m = 2.5
	shot.pos.x = 2.0
	assert_false(_pressed(brain.sample(0)))
	shot.pos.x = 0.7
	assert_true(_pressed(brain.sample(1)))


func test_stomp_dashes_outward_only_inside_the_telegraphed_radius() -> void:
	var foe: BotView.Hostile = BotView.Hostile.new()
	foe.id = 3
	foe.tell = &"large"
	foe.stomp_m = 3.5
	foe.tell_ticks = 48
	foe.pos = Vector2(-3.6, 0)
	view.hostiles().append(foe)
	assert_false(_pressed(brain.sample(0)))
	assert_false(_pressed(brain.sample(profile.dash_read_ticks)))
	foe.pos.x = -2.0
	foe.tell_ticks -= profile.dash_read_ticks + 1
	var press: TickInput = brain.sample(profile.dash_read_ticks + 1)
	assert_true(_pressed(press))
	assert_eq(press.move_x, TickInput.AXIS_MAX)
	assert_eq(press.move_y, 0)


func test_round_must_threaten_rivet_and_skill_is_drawn_once() -> void:
	var shot: BotView.Round = _round()
	profile.dash_read_ticks = 0
	profile.dash_chance = 0.0
	assert_false(_pressed(brain.sample(0)))
	profile.dash_chance = 1.0
	assert_false(_pressed(brain.sample(1)))
	shot.id = 2
	shot.pos.y = 2.0
	assert_false(_pressed(brain.sample(2)))
	shot.splash_m = 2.5
	shot.landing = Vector2(0, 2)
	shot.remaining_m = 4.0
	view.player().can_dash = false
	assert_false(_pressed(brain.sample(3)))
	view.player().can_dash = true
	assert_true(_pressed(brain.sample(4)))


func test_overlapping_waves_count_their_own_dash_interval() -> void:
	var stage: ArenaStage = VaultTrial.stage_for(false)
	var first: GauntletWaveStats = GauntletWaveStats.new()
	var second: GauntletWaveStats = GauntletWaveStats.new()
	var a: Dictionary = {}
	var b: Dictionary = {}
	first.begin(stage)
	stage.pilot.motion.dashes += 1
	second.begin(stage)
	stage.pilot.motion.dashes += 1
	first.finish(stage, a)
	second.finish(stage, b)
	var first_count: int = a["dashes"]
	assert_eq(first_count, 2)
	var second_count: int = b["dashes"]
	assert_eq(second_count, 1)


func test_shipped_profiles_read_dashes_at_their_own_skill() -> void:
	var skills: Dictionary = {&"novice": [0.2, 30], &"average": [0.6, 16], &"expert": [0.9, 8]}
	for id: StringName in skills:
		var row: BotProfile = BotProfile.shipped(id)
		var expected: Array = skills[id]
		assert_eq([row.dash_chance, row.dash_read_ticks], expected)
