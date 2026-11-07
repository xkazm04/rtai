extends GutTest

const BOSS_TABLE: String = """{"schema": "gtai.bosses/1", "doc": "t",
"arenas": {"a": {"area": "pit", "boss_at": [0, 0], "rivet_at": [-5, 0], "add_spawns": [[1, 1]],
"doc": "t"}},
"bosses": {"b": {"arena": "a", "hp": 100, "move_mps": 0, "radius_m": 1, "rng": "boss_b", "doc": "t",
"phases": [{"id": "one", "hp_below": 1, "attacks": ["jab"], "gap_s": 0.5, "transition_s": 1,
 "doc": "t"}],
"attacks": {"jab": {"shape": "line", "windup_s": 1, "aim_lock_s": 0.25, "active_s": 0.5,
 "recovery_s": 1, "punish_s": 0.5, "punish_k": 2, "cooldown_s": 0, "damage": 10, "range_m": 10,
 "width_m": 1, "min_m": 0, "max_m": 50, "weight": 1, "doc": "t"}}}}}"""


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


func test_a_landed_boss_hit_is_its_own_light_pulse_with_its_own_memo() -> void:
	var rumble: HandheldRumble = HandheldRumble.new(1.0)
	assert_false(rumble.see_hurt(-1000000))
	assert_false(rumble.see(&"boss_hit", 40), "the boss memo primes on its own first read")
	assert_true(rumble.see(&"boss_hit", 41))
	assert_eq(rumble.last, HandheldRumble.pulse(&"boss_hit", 1.0))
	assert_eq(rumble.by_kind, {&"boss_hit": 1} as Dictionary[StringName, int])
	var hit: Vector3 = HandheldRumble.pulse(&"boss_hit", 1.0)
	var hurt: Vector3 = HandheldRumble.pulse(&"rivet_hurt", 1.0)
	assert_lt(maxf(hit.x, hit.y), maxf(hurt.x, hurt.y), "a landed hit is lighter than a hurt")
	assert_lt(hit.z, hurt.z)
	rumble.free()


func test_a_landed_hit_never_cuts_a_running_hurt() -> void:
	var rumble: HandheldRumble = HandheldRumble.new(1.0)
	assert_true(rumble.play(&"rivet_hurt"))
	assert_false(rumble.play(&"boss_hit"), "the weaker pulse waits")
	assert_eq(rumble.last, HandheldRumble.pulse(&"rivet_hurt", 1.0))
	rumble.free()


func test_the_boss_bar_feels_a_hit_that_takes_hp() -> void:
	var rumble: HandheldRumble = HandheldRumble.new(1.0)
	add_child_autofree(rumble)
	var spec: BossSpec = BossSpec.from_table(
		DataTable.parse(BOSS_TABLE, "gtai.bosses/1", "t"), &"b"
	)
	var layer: CanvasLayer = CanvasLayer.new()
	add_child_autofree(layer)
	var bar: BossBar = BossBar.new()
	bar.fight = BossFight.new(spec, RngRegistry.new(3).stream(spec.rng), Vector2.ZERO)
	layer.add_child(bar)
	await wait_process_frames(2)
	assert_eq(rumble.played, 0, "the first frames only prime")
	assert_gt(bar.fight.hurt(10.0), 0.0)
	await wait_process_frames(3)
	var hits: int = rumble.by_kind.get(&"boss_hit", 0)
	assert_eq(hits, 1, "one hit, one pulse, however many frames")
