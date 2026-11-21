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


func test_controls_default_and_unknown_values_use_legacy() -> void:
	LaunchArgs.parse([])
	assert_eq(ControlsMode.id(), &"legacy")
	LaunchArgs.parse(["--controls=typo"])
	assert_false(ControlsMode.wheel())
	assert_string_contains(Log.recent()[-1], "[WARN]")
	assert_string_contains(Log.recent()[-1], "typo")


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
