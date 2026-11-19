extends GutTest

var saved: PackedStringArray


func before_each() -> void:
	saved = LaunchArgs.unknown()
	for flag: String in LaunchArgs.KNOWN_FLAGS:
		if LaunchArgs.has(flag):
			@warning_ignore("return_value_discarded")
			saved.append("%s=%s" % [flag, LaunchArgs.value(flag)])


func after_each() -> void:
	LaunchArgs.parse(saved)


func test_all_legacy_headings_and_reaches_survive_an_independent_cover_press() -> void:
	var actions: PlayerActions = PlayerActions.shipped()
	for heading: int in 256:
		for reach: int in [0, 1, 8, 15]:
			var old: int = (heading | 0x100 | reach << 9) << 16
			var tick: TickInput = TickInput.new(old)
			var before: PlayerCommand = PlayerCommand.decode(tick, 0, actions)
			assert_false(before.is_held(actions, &"cover"))
			tick.buttons |= 1 << 29
			var after: PlayerCommand = PlayerCommand.decode(
				TickInput.unpack(tick.pack()), old, actions
			)
			assert_true(after.was_pressed(actions, &"cover"))
			assert_eq(after.aim, before.aim)
			assert_eq(after.aim_m, before.aim_m)
			if not after.was_pressed(actions, &"cover"):
				return


func test_flag_precedence_and_off_mode_live_recording() -> void:
	var table: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	var shipped: bool = table.object(table.raw, "cover")["enabled"]
	for flags: PackedStringArray in [
		PackedStringArray(),
		PackedStringArray(["--cover"]),
		PackedStringArray(["--no-cover"]),
		PackedStringArray(["--cover", "--no-cover"])
	]:
		LaunchArgs.parse(flags)
		var on: bool = (shipped or flags.has("--cover")) and not flags.has("--no-cover")
		var actions: PlayerActions = PlayerActions.shipped()
		actions.install()
		var pilot: StagePilot = StagePilot.new(actions)
		assert_eq(pilot.motion.cover.enabled, on)
		assert_eq(LaunchArgs.unknown().size(), 0)
		assert_true(InputMap.has_action(&"cover"))
		if not InputMap.has_action(&"cover"):
			return
		var input: LiveInput = LiveInput.new(actions)
		Input.action_press(&"cover")
		var tick: TickInput = input.sample(0)
		Input.action_release(&"cover")
		assert_eq(tick.buttons, (1 << 29) if on else 0)
