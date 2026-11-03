extends GutTest

const PATH: String = "user://test_tmp/unit/settings.json"


func test_settings_round_trip_and_rebind() -> void:
	PlayerActions.shipped().install()
	var s: PlayerSettings = PlayerSettings.new()
	s.volume = 0.3
	s.reduced_motion = true
	s.rebind(&"interact", "G")
	assert_eq(ObjectiveHint.key_name(&"interact"), "G", "the InputMap now carries G")
	assert_eq(DirAccess.make_dir_recursive_absolute(PATH.get_base_dir()), OK)
	assert_eq(s.save(PATH), OK)
	var back: PlayerSettings = PlayerSettings.load_or_default(PATH)
	assert_almost_eq(back.volume, 0.3, 0.0001)
	assert_true(back.reduced_motion)
	assert_eq(back.keys, {"interact": "G"} as Dictionary[String, String])
	PlayerActions.shipped().install()
	assert_eq(ObjectiveHint.key_name(&"interact"), "E", "defaults back for the other tests")


func test_bad_file_falls_back_to_defaults() -> void:
	var f: FileAccess = FileAccess.open(PATH, FileAccess.WRITE)
	var body: String = '{"schema": "gtai.player-settings/1", "volume": "loud", "keys": {"fire": "Q"}}'
	assert_true(f.store_string(body))
	f.close()
	var back: PlayerSettings = PlayerSettings.load_or_default(PATH)
	assert_almost_eq(back.volume, 0.8, 0.0001)
	assert_eq(back.keys.size(), 0, "fire is not keyboard-rebindable")
