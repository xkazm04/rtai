extends GutTest

var view: BotView
var profile: BotProfile
var defence: BotDefence


func before_each() -> void:
	view = BotView.new()
	view.player().can_guard = true
	view.player().radius = 0.5
	profile = BotProfile.shipped(&"expert")
	profile.roll_skill = 1.0
	profile.tells_read = 1.0
	profile.guard_lead_ticks = 5
	defence = BotDefence.new(profile, RngRegistry.new(42))


func _round(at: Vector2, vel: Vector2, size: StringName = &"small") -> BotView.Round:
	var shot: BotView.Round = BotView.Round.new()
	shot.id = view.incoming().size() + 1
	shot.pos = at
	shot.vel = vel
	shot.size = size
	view.incoming().append(shot)
	return shot


func test_guard_held_only_for_front_small_round_within_lead() -> void:
	var shot: BotView.Round = _round(Vector2(6.5, 0), Vector2.LEFT * 60.0)
	assert_eq(defence.choose(view, 0).action, &"")
	shot.pos.x = 5.5
	assert_eq(defence.choose(view, 1).action, &"guard")
	assert_eq(defence.choose(view, 2).aim, Vector2.RIGHT)
	view.player().facing = Vector2.LEFT
	assert_eq(defence.choose(view, 3).action, &"")
	view.player().facing = Vector2.RIGHT
	view.player().can_guard = false
	assert_eq(defence.choose(view, 4).action, &"")
	view.player().can_guard = true
	view.incoming().clear()
	assert_eq(defence.choose(view, 5).action, &"")


func test_expired_receding_stationary_and_wide_rounds_are_ignored() -> void:
	var shot: BotView.Round = _round(Vector2(4, 0), Vector2.LEFT * 60.0)
	shot.remaining_m = 3.4
	assert_eq(BotDefence.impact_ticks(shot, view.player()), INF)
	shot.remaining_m = 3.5
	assert_almost_eq(BotDefence.impact_ticks(shot, view.player()), 3.5, 0.001)
	shot.pos.y = 0.6
	assert_eq(defence.choose(view, 1).action, &"")
	shot.pos.y = 0
	shot.vel = Vector2.RIGHT
	assert_eq(BotDefence.impact_ticks(shot, view.player()), INF)
	shot.vel = Vector2.ZERO
	assert_eq(BotDefence.impact_ticks(shot, view.player()), INF)


func test_large_round_wins_over_more_imminent_small_and_rolls_across_path() -> void:
	view.player().can_roll = true
	@warning_ignore("return_value_discarded")
	_round(Vector2(1, 0), Vector2.LEFT * 60.0)
	var big: BotView.Round = _round(Vector2(4, 0), Vector2.LEFT * 60.0, &"large")
	var choice: BotDefence.Choice = defence.choose(view, 1)
	assert_eq(choice.action, &"roll")
	assert_eq(choice.move.length(), 1.0)
	assert_eq(choice.move.dot(big.vel), 0.0)
	assert_false(choice.cover)
	big.pos.x = 32.0
	assert_eq(defence.choose(view, 2).action, &"guard")


func test_nearest_of_two_large_rounds_sets_the_dodge_line() -> void:
	view.player().can_roll = true
	@warning_ignore("return_value_discarded")
	_round(Vector2(20, 0), Vector2.LEFT * 60.0, &"large")
	@warning_ignore("return_value_discarded")
	_round(Vector2(0, 3), Vector2.UP * 60.0, &"large")
	var choice: BotDefence.Choice = defence.choose(view, 1)
	assert_eq(absf(choice.move.x), 1.0)
	assert_eq(choice.move.y, 0.0)


func test_large_round_seeks_reachable_occluding_prop_without_roll() -> void:
	@warning_ignore("return_value_discarded")
	_round(Vector2(10, 0), Vector2.LEFT * 60.0, &"large")
	view.solid_props().append(Rect2(2, 1, 1, 1))
	view.solid_props().append(Rect2(3, -5, 1, 1))
	var choice: BotDefence.Choice = defence.choose(view, 0)
	assert_eq(choice.action, &"")
	assert_true(choice.cover)
	assert_gt(choice.move.y, 0.0)
	profile.cover_seek_m = 0.1
	assert_false(defence.choose(view, 1).cover)


func test_solid_already_between_shooter_and_body_holds_cover() -> void:
	view.player().can_roll = true
	view.solid_props().append(Rect2(2, -1, 1, 2))
	var shot: BotView.Round = _round(Vector2(7, 0), Vector2.LEFT * 60.0, &"large")
	var choice: BotDefence.Choice = defence.choose(view, 1)
	assert_true(choice.cover)
	assert_eq(choice.move, Vector2.ZERO)
	assert_eq(choice.action, &"")
	shot.size = &"small"
	assert_eq(defence.choose(view, 2).action, &"")


func test_unavoidable_blast_requests_only_available_tonnage() -> void:
	@warning_ignore("return_value_discarded")
	_round(Vector2(7, 0), Vector2.LEFT * 60.0, &"large")
	assert_eq(defence.choose(view, 1).form, &"")
	view.player().forms.append(&"tonnage")
	assert_eq(defence.choose(view, 2).form, &"tonnage")
	view.player().can_roll = true
	assert_eq(defence.choose(view, 3).form, &"")


func test_read_large_tell_reacts_once_delay_has_elapsed_and_resets() -> void:
	profile.reaction_ticks = 2
	view.player().can_roll = true
	var foe: BotView.Hostile = BotView.Hostile.new()
	foe.id = 9
	foe.pos = Vector2(5, 0)
	foe.facing = Vector2.LEFT
	foe.tell = &"large"
	view.hostiles().append(foe)
	assert_eq(defence.choose(view, 5).action, &"")
	assert_eq(defence.choose(view, 6).action, &"")
	assert_eq(defence.choose(view, 7).action, &"roll")
	foe.tell = &"small"
	assert_eq(defence.choose(view, 8).action, &"")
	profile.tells_read = 0.0
	foe.tell = &"large"
	assert_eq(defence.choose(view, 9).action, &"")
	assert_eq(defence.choose(view, 12).action, &"")
	profile.tells_read = 1.0
	assert_eq(defence.choose(view, 13).action, &"")
	foe.alive = false
	assert_eq(defence.choose(view, 14).action, &"")


func test_failed_roll_skill_is_not_rerolled_on_the_same_round() -> void:
	profile.roll_skill = 0.0
	view.player().can_roll = true
	@warning_ignore("return_value_discarded")
	_round(Vector2(5, 0), Vector2.LEFT * 60.0, &"large")
	assert_eq(defence.choose(view, 0).action, &"")
	profile.roll_skill = 1.0
	assert_eq(defence.choose(view, 1).action, &"")
	view.incoming().clear()
	assert_eq(defence.choose(view, 2).action, &"")
	@warning_ignore("return_value_discarded")
	_round(Vector2(5, 0), Vector2.LEFT * 60.0, &"large")
	assert_eq(defence.choose(view, 3).action, &"roll")
