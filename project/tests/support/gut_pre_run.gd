extends GutHookScript
## GUT's pre-run hook (.gutconfig.json pre_run_script): the unit suite runs under the `top` view.
## n9 made combo the boot default; a test that wants a tilt asks for it by id (ViewMode.of or
## ViewMode.select).


func run() -> void:
	ViewMode.select("top")
	var mode: String = OS.get_environment("GTAI_CONTROLS")
	if mode in ["wheel", "legacy"]:
		_restore_controls(mode)
		# Some fixtures reparse the OS command line in after_each(), dropping the override.
		var runner: GutMain = gut
		@warning_ignore("return_value_discarded")
		runner.end_test.connect(_restore_controls.bind(mode))


func _restore_controls(mode: String) -> void:
	if LaunchArgs.value("--controls") != mode:
		var args: PackedStringArray = LaunchArgs.unknown()
		for flag: String in LaunchArgs.KNOWN_FLAGS:
			if LaunchArgs.has(flag) and flag != "--controls":
				@warning_ignore("return_value_discarded")
				args.append(flag + "=" + LaunchArgs.value(flag))
		@warning_ignore("return_value_discarded")
		args.append("--controls=" + mode)
		LaunchArgs.parse(args)
