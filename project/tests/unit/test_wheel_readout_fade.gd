extends GutTest


func _make_view() -> WheelReadoutView:
	var view: WheelReadoutView = autofree(WheelReadoutView.new())
	view._wheel = RivetWheel.new()
	var ctx: WorldContext = World.build_context(Events, Data, 22)
	view._arena = CombatArena.new(CombatTuning.shipped(), Events, ctx.rng.stream(&"combat"))
	return view


func test_readout_holds_then_fades_from_opening_and_from_the_most_recent_switch() -> void:
	var view: WheelReadoutView = _make_view()
	for age: int in range(-1, 62):
		view._arena.tick = age
		view._process(0.0)
		assert_eq(view.visible, age >= 0 and age < 60, "visibility at tick %d" % age)
		var alpha: float = clampf(float(60 - age) / 24.0, 0.0, 1.0)
		assert_almost_eq(view.modulate.a, alpha, 0.00001, "opacity at tick %d" % age)
	view._wheel.switched_tick = view._arena.tick
	view._process(0.0)
	assert_true(view.visible)
	assert_eq(view.modulate.a, 1.0)


func test_each_cycle_press_shows_hands_even_when_it_is_the_only_entry() -> void:
	var view: WheelReadoutView = _make_view()
	var actions: PlayerActions = PlayerActions.shipped()
	view._arena.tick = 60
	for action: StringName in [&"weapon_next", &"weapon_prev"]:
		view._process(0.0)
		assert_false(view.visible)
		var input: TickInput = TickInput.new(1 << actions.bit(action))
		var press: PlayerCommand = PlayerCommand.decode(input, 0, actions)
		view._wheel.step(press, actions, view._arena)
		assert_eq(view._wheel.order(), [&"hands"])
		assert_eq(view._wheel.selected(), &"hands")
		assert_eq(view._wheel.switched_tick, -1)
		view._process(0.0)
		assert_true(view.visible)
		assert_eq(view.modulate.a, 1.0)
		view._arena.tick += 59
		view._process(0.0)
		assert_true(view.visible)
		assert_almost_eq(view.modulate.a, 1.0 / 24.0, 0.00001)
		view._arena.tick += 1
		view._process(0.0)
		assert_false(view.visible)


func test_hud_attaches_a_hidden_readout_only_when_a_wheel_exists() -> void:
	var layer: Node2D = autofree(Node2D.new())
	var hud: HudView = HudView.new()
	layer.add_child(hud)
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	WheelReadoutView.attach(hud, null)
	WheelReadoutView.attach(hud, stage)
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	stage.pilot.wheel = null
	WheelReadoutView.attach(hud, stage)
	assert_eq(layer.get_child_count(), 1)
	stage.pilot.wheel = RivetWheel.new()
	WheelReadoutView.attach(hud, stage)
	assert_eq(layer.get_child_count(), 2)
	var view: WheelReadoutView = layer.get_child(1) as WheelReadoutView
	assert_not_null(view)
	assert_false(view.visible)
