extends GutTest


func test_pulse_scales_both_motors_by_the_gain_not_the_length() -> void:
	var full: Vector3 = HandheldRumble.pulse(&"player_hit", 1.0)
	var half: Vector3 = HandheldRumble.pulse(&"player_hit", 0.5)
	assert_almost_eq(half.x, full.x * 0.5, 0.0001)
	assert_almost_eq(half.y, full.y * 0.5, 0.0001)
	assert_eq(half.z, full.z)


func test_unknown_kind_and_zero_gain_play_nothing() -> void:
	var rumble: HandheldRumble = HandheldRumble.new(0.0)
	assert_false(rumble.play(&"player_hit"))
	rumble.gain = 1.0
	assert_false(rumble.play(&"no_such_pulse"))
	assert_eq(rumble.played, 0)
	rumble.free()


func test_weaker_pulse_never_cuts_a_running_stronger_one() -> void:
	var rumble: HandheldRumble = HandheldRumble.new(1.0)
	assert_true(rumble.play(&"boss_engaged"))
	assert_false(rumble.play(&"hijacked"))
	assert_true(rumble.play(&"player_hit"))
	assert_eq(rumble.played, 2)
	assert_eq(rumble.last, HandheldRumble.pulse(&"player_hit", 1.0))
	var counted: Dictionary = {&"boss_engaged": 1, &"player_hit": 1}
	assert_eq(rumble.by_kind, counted, "counted per kind, not the cut one")
	rumble.free()


func test_events_bus_drives_it_when_in_the_tree() -> void:
	var rumble: HandheldRumble = HandheldRumble.new(1.0)
	add_child_autofree(rumble)
	Events.player_hit.emit(&"fists")
	assert_eq(rumble.played, 1)
	assert_eq(rumble.last, HandheldRumble.pulse(&"player_hit", 1.0))


func test_desktop_row_has_no_rumble_and_deck_does() -> void:
	assert_eq(DeviceProfile.of("desktop").rumble, 0.0)
	assert_gt(DeviceProfile.of("deck").rumble, 0.0)


func test_a_rising_hurt_tick_plays_rivet_hurt_once() -> void:
	var rumble: HandheldRumble = HandheldRumble.new(1.0)
	assert_false(rumble.see_hurt(-1000000), "the first read only primes")
	assert_true(rumble.see_hurt(120))
	assert_false(rumble.see_hurt(120), "the same hurt is not felt twice")
	assert_eq(rumble.played, 1)
	assert_eq(rumble.last, HandheldRumble.pulse(&"rivet_hurt", 1.0))
	rumble.free()


func test_feel_hurt_without_a_live_rumble_is_a_no_op() -> void:
	assert_null(HandheldRumble._live)
	HandheldRumble.feel_hurt(5)
	assert_null(HandheldRumble._live)
