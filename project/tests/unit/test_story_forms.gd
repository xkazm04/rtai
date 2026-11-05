extends GutTest
## boot/collect_call StoryForms: the ghost forms on quest 1's shipped sprite cast. The table turns
## them on; with a pilot the view draws the form bodies (CastView leaves Rivet's sprite out while
## one stands in); with no pilot it falls back to the voice alone (StoryVoice).


func _stage(with_pilot: bool) -> CollectCallStage:
	var stage: CollectCallStage = CollectCallPlay.begin().stage
	if with_pilot:
		stage.pilot = StagePilot.new(PlayerActions.shipped())
	return stage


func _view() -> CollectCallView:
	var view: CollectCallView = CollectCallView.new()
	add_child_autofree(view)
	return view


func _host() -> Node:
	var host: Node = Node.new()
	add_child_autofree(host)
	return host


func test_the_shipped_table_turns_the_story_forms_on() -> void:
	assert_true(GhostFormTable.load_default().story_forms, "ghost_forms.json story_forms")
	assert_null(StoryForms.attach(Node.new(), null, null, false), "no view, nothing")


func test_with_a_pilot_the_view_draws_the_forms_in_the_actor_layer() -> void:
	var view: CollectCallView = _view()
	var s: StoryForms = StoryForms.attach(_host(), view, _stage(true), true)
	assert_not_null(s.form_view, "the form view")
	assert_null(s.voice, "the view's own apparition is the voice: no second ghost")
	assert_true(view.cast_view.forms_drawn, "the sprite steps out for the bodies")
	assert_true(s.form_view.reduced_motion, "the player's setting, not the launch flag")
	assert_eq(s.form_view.get_parent(), view.print_stage.actor_layer(), "the printed actors' layer")


func test_without_a_pilot_the_voice_shows_alone() -> void:
	var view: CollectCallView = _view()
	var s: StoryForms = StoryForms.attach(_host(), view, _stage(false), false)
	assert_null(s.form_view, "no pilot, no form")
	assert_not_null(s.voice, "the voice alone")
	assert_false(view.cast_view.forms_drawn, "the sprite stays")


func test_the_sprite_steps_out_from_the_in_between_pose_until_the_exit_midpoint() -> void:
	var g: GhostForms = GhostForms.new(
		GhostFormTable.load_default(), SoulPowers.new(PowerTable.load_default())
	)
	var f: GhostFormDef = g.table.form(g.table.order[0])
	assert_false(StoryForms.stands_in(g), "base")
	assert_eq(g.press_transform(), SoulPowers.OK)
	assert_false(StoryForms.stands_in(g), "the first stage is still Rivet")
	_run(g, f.enter_ticks / 2 + 1)
	assert_true(StoryForms.stands_in(g), "past the in-between pose the body stands in")
	_run(g, f.enter_ticks)
	assert_true(g.settled() and StoryForms.stands_in(g), "settled in the form")
	assert_gt(StoryForms.bar_lift_m(g), StoryForms.BAR_LIFT_M, "Tonnage's bar rides over the press")
	assert_eq(g.press_transform(), SoulPowers.OK)
	assert_true(StoryForms.stands_in(g), "the exit's first stage is still the body")
	_run(g, f.exit_ticks)
	assert_false(StoryForms.stands_in(g), "back to base: Rivet's sprite")
	assert_eq(StoryForms.bar_lift_m(g), StoryForms.BAR_LIFT_M, "base: the bar where it was")


func _run(g: GhostForms, n: int) -> void:
	for i: int in n:
		g.powers.tick()
		g.tick()


func test_the_card_folds_to_one_chip_while_a_line_is_up() -> void:
	var view: CollectCallView = _view()
	var s: StoryForms = StoryForms.attach(_host(), view, _stage(true), false)
	var hud: GhostFormHud = s.form_view.hud
	hud.sync(s.form_view.pilot.ghosts.forms)
	view.hud_view.state.say("Rivet", "Okay.")
	s._process(0.0)
	assert_true(hud.compact, "a line is up: folded")
	assert_eq(hud.shown_chips(), [hud.selected] as Array[StringName], "in base: the selected ghost")
	view.hud_view.state.silent()
	s._process(0.0)
	assert_false(hud.compact, "the line closed")
	assert_eq(hud.shown_chips().size(), 4, "all four again")


func test_each_forms_bar_rides_clear_of_its_drawn_body() -> void:
	var t: GhostFormTable = GhostFormTable.load_default()
	assert_gt(t.form(&"kerf").bar_m, 1.6, "Kerf's front blades reach about 1.6 m forward")
	assert_gt(t.form(&"tonnage").bar_m, t.form(&"tonnage").radius_m * 1.7, "over the press")
	for id: StringName in t.order:
		assert_gte(t.form(id).bar_m, StoryForms.BAR_LIFT_M, "never below base Rivet's bar")
