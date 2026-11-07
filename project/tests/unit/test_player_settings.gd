extends GutTest

var _path: String = TestTmp.dir("unit").path_join("settings.json")


func test_settings_round_trip_and_rebind() -> void:
	PlayerActions.shipped().install()
	var s: PlayerSettings = PlayerSettings.new()
	s.volume = 0.3
	s.reduced_motion = true
	s.rebind(&"interact", "G")
	assert_eq(ObjectiveHint.key_name(&"interact"), "G", "the InputMap now carries G")
	assert_eq(DirAccess.make_dir_recursive_absolute(_path.get_base_dir()), OK)
	assert_eq(s.save(_path), OK)
	var back: PlayerSettings = PlayerSettings.load_or_default(_path)
	assert_almost_eq(back.volume, 0.3, 0.0001)
	assert_true(back.reduced_motion)
	assert_eq(back.keys, {"interact": "G"} as Dictionary[String, String])
	PlayerActions.shipped().install()
	assert_eq(ObjectiveHint.key_name(&"interact"), "E", "defaults back for the other tests")


func test_bad_file_falls_back_to_defaults() -> void:
	var f: FileAccess = FileAccess.open(_path, FileAccess.WRITE)
	var body: String = (
		'{"schema": "gtai.player-settings/1", "volume": "loud", "reduced_motion": "yes",'
		+ ' "keys": {"fire": "Q"}}'
	)
	assert_true(f.store_string(body))
	f.close()
	var back: PlayerSettings = PlayerSettings.load_or_default(_path)
	assert_almost_eq(back.volume, 0.8, 0.0001)
	assert_eq(back.keys.size(), 0, "fire is not keyboard-rebindable")
	assert_false(back.reduced_motion, "a non-bool flag falls back to off")


func test_apply_carries_the_saved_rebinds() -> void:
	PlayerActions.shipped().install()
	var s: PlayerSettings = PlayerSettings.new()
	s.keys = {"interact": "G"} as Dictionary[String, String]
	s.apply()
	assert_eq(ObjectiveHint.key_name(&"interact"), "G", "apply() rebinds what was saved")
	PlayerActions.shipped().install()


func test_frame_cap_round_trips_and_bad_caps_fall_back() -> void:
	assert_eq(DirAccess.make_dir_recursive_absolute(_path.get_base_dir()), OK)
	var s: PlayerSettings = PlayerSettings.new()
	assert_eq(s.frame_cap, 0, "the default is the device row's own cap")
	s.frame_cap = 40
	assert_eq(s.save(_path), OK)
	assert_eq(PlayerSettings.load_or_default(_path).frame_cap, 40)
	var f: FileAccess = FileAccess.open(_path, FileAccess.WRITE)
	assert_true(f.store_string('{"schema": "gtai.player-settings/1", "frame_cap": 45}'))
	f.close()
	assert_eq(PlayerSettings.load_or_default(_path).frame_cap, 0, "45 is not offered")


func test_rumble_round_trips_and_bad_levels_fall_back_to_full() -> void:
	assert_eq(DirAccess.make_dir_recursive_absolute(_path.get_base_dir()), OK)
	var s: PlayerSettings = PlayerSettings.new()
	assert_eq(s.rumble, 1.0, "the default is the row's full gain")
	s.rumble = 0.0
	assert_eq(s.save(_path), OK)
	assert_eq(PlayerSettings.load_or_default(_path).rumble, 0.0, "off survives a restart")
	s.rumble = 0.5
	s.apply()
	assert_eq(HandheldRumble.player_gain, 0.5, "apply() carries the level")
	HandheldRumble.player_gain = 1.0
	PlayerActions.shipped().install()
	var f: FileAccess = FileAccess.open(_path, FileAccess.WRITE)
	assert_true(f.store_string('{"schema": "gtai.player-settings/1", "rumble": 0.7}'))
	f.close()
	assert_eq(PlayerSettings.load_or_default(_path).rumble, 1.0, "0.7 is not offered")


func test_frame_cap_drives_the_engine_and_device_restores_it() -> void:
	var before: int = Engine.max_fps
	var s: PlayerSettings = PlayerSettings.new()
	s.frame_cap = 30
	s.apply_frame_cap()
	assert_eq(Engine.max_fps, 30)
	s.frame_cap = 0
	Engine.max_fps = 77
	s.apply_frame_cap()
	var row: int = DeviceProfile.shared().max_fps
	assert_eq(Engine.max_fps, row if row >= 0 else 77, "device: the row's cap, none on desktop")
	s.frame_cap = 40
	s.apply()
	assert_eq(Engine.max_fps, 40, "apply() carries the cap with the other settings")
	PlayerActions.shipped().install()
	Engine.max_fps = before
