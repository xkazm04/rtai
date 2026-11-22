extends GutTest

var _saved: PackedStringArray


func before_each() -> void:
	_saved = LaunchArgs.unknown()
	for flag: String in LaunchArgs.KNOWN_FLAGS:
		if LaunchArgs.has(flag):
			@warning_ignore("return_value_discarded")
			_saved.append("%s=%s" % [flag, LaunchArgs.value(flag)])


func after_each() -> void:
	LaunchArgs.parse(_saved)
	PlayerActions.shipped().install()


func test_controls_default_and_unknown_values_use_wheel() -> void:
	LaunchArgs.parse([])
	assert_eq(ControlsMode.id(), &"wheel")
	LaunchArgs.parse(["--controls=typo"])
	assert_true(ControlsMode.wheel())
	assert_string_contains(Log.recent()[-1], "[WARN]")
	assert_string_contains(Log.recent()[-1], "typo")
	LaunchArgs.parse(["--controls=legacy"])
	assert_eq(ControlsMode.id(), &"legacy")


func test_only_wheel_records_guard_and_moves_the_right_mouse_binding() -> void:
	var mouse: InputEventMouseButton = InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_RIGHT
	var space: InputEventKey = InputEventKey.new()
	space.physical_keycode = OS.find_keycode_from_string("Space")
	var trigger: InputEventJoypadMotion = InputEventJoypadMotion.new()
	trigger.axis = JOY_AXIS_TRIGGER_LEFT
	trigger.axis_value = 1.0
	for mode: String in ["legacy", "wheel", "legacy"]:
		LaunchArgs.parse(["--controls=" + mode])
		assert_true(LaunchArgs.unknown().is_empty())
		var wheel: bool = mode == "wheel"
		assert_eq(ControlsMode.wheel(), wheel)
		var actions: PlayerActions = PlayerActions.shipped()
		actions.install()
		assert_eq(mouse.is_action(&"guard"), wheel)
		assert_eq(mouse.is_action(&"melee"), not wheel)
		assert_eq(trigger.is_action(&"guard"), wheel)
		assert_true(space.is_action(&"melee"))
		assert_false(space.is_action(&"guard"))
		var input: LiveInput = LiveInput.new(actions)
		Input.action_press(&"guard")
		for cover: bool in [false, true]:
			actions.enable_cover_input(cover)
			assert_eq(input.sample(0).is_pressed(actions.bit(&"guard")), wheel)
		Input.action_release(&"guard")


func test_saved_player_controls_override_the_playback_launch_options() -> void:
	var path: String = TestTmp.dir("controls_replay").path_join("player.json")
	for mode: String in ["legacy", "wheel"]:
		LaunchArgs.parse(["--controls=" + mode, "--wheel-start=drawn"])
		var world: World = autofree(World.new())
		var bus: EventBus = autofree(EventBus.new())
		var data: DataStore = autofree(DataStore.new())
		world.start(bus, data, 7)
		ControlsReplay.bind(world.loop(), PlayerActions.shipped())
		world.loop().start_recording()
		var tape: ReplayLog = world.loop().finish_recording()
		LaunchArgs.parse(["--controls=wheel" if mode == "legacy" else "--controls=legacy"])
		assert_eq(tape.save(path), OK)
		assert_not_null(ControlsReplay.load_for_playback(path))
		assert_eq(String(ControlsMode.id()), mode)
		assert_eq(ControlsMode.start_drawn(), mode == "wheel")


func test_replay_without_controls_metadata_uses_legacy() -> void:
	var path: String = TestTmp.dir("controls_replay").path_join("old.json")
	assert_eq(ReplayLog.new(7).save(path), OK)
	LaunchArgs.parse(["--controls=wheel", "--wheel-start=drawn"])
	assert_not_null(ControlsReplay.load_for_playback(path))
	assert_eq(ControlsMode.id(), &"legacy")
	assert_false(ControlsMode.start_drawn())
