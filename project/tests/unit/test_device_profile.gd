extends GutTest


func test_default_is_the_untouched_desktop() -> void:
	var p: DeviceProfile = DeviceProfile.of("")
	assert_eq(p.id, &"desktop")
	assert_true(p.is_desktop())
	assert_false(p.is_handheld())
	assert_eq(p.max_fps, -1)
	assert_eq(p.zoom_k, 1.0)


func test_deck_row_is_the_panel_at_60() -> void:
	var p: DeviceProfile = DeviceProfile.of("deck")
	assert_eq(p.id, &"deck")
	assert_eq(p.window_size, Vector2i(1280, 800))
	assert_eq(p.max_fps, 60)
	assert_almost_eq(p.zoom_k, 1.5, 0.001)
	assert_true(p.is_handheld())
	assert_false(p.is_desktop())


func test_deck40_caps_at_40() -> void:
	assert_eq(DeviceProfile.of("deck40").max_fps, 40)


func test_select_reads_a_dash_as_underscore() -> void:
	var saved: DeviceProfile = DeviceProfile._shared
	assert_eq(DeviceProfile.select("switch-handheld").window_size, Vector2i(1280, 720))
	assert_eq(DeviceProfile.shared().id, &"switch_handheld")
	DeviceProfile._shared = saved


func test_unknown_id_falls_back_to_desktop() -> void:
	var p: DeviceProfile = DeviceProfile.of("toaster")
	assert_eq(p.id, &"desktop")
	assert_true(p.ids.has("deck"))


func test_launch_args_knows_the_flag() -> void:
	assert_true(LaunchArgs.KNOWN_FLAGS.has("--device"))


func test_camera_rig_zoom_k_scales_the_mode_ppm() -> void:
	var rig: CameraRig = CameraRig.new()
	var base: float = rig._target_ppm()
	rig.zoom_k = 1.5
	assert_almost_eq(rig._target_ppm(), base * 1.5, 0.001)
