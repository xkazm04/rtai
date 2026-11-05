extends GutTest
## Lane n7-ranged: the camera side of the shared hit feel (FeelCam + FeelBudget). The caps hold
## under a 30-hit frame and a Gatling second, --feel=off means no effect, overrides apply.


func _cam(clock: SimClock = null) -> FeelCam:
	return FeelCam.attach(null, clock, HitFeel.shipped())


func test_thirty_hits_in_one_tick_stay_inside_the_cap() -> void:
	var clock: SimClock = SimClock.new()
	var cam: FeelCam = _cam(clock)
	var held: int = 0
	for i: int in 30:
		held += cam.hit(&"rocket_launcher", &"blast", Vector2.RIGHT, i % 2 == 0, 1000)
	assert_eq(cam.hits, 30)
	assert_eq(cam.kicks, cam.budget.kicks_per_tick, "one tick starts at most kicks_per_tick")
	assert_lte(held, cam.budget.hitstop_ticks_per_second, "one tick holds at most the window")
	assert_lte(clock.held(), cam.budget.hitstop_ticks_per_second * SimClock.TICK_DT + 1e-6)
	var cap_px: float = cam.feel.cap["kick_px_max"]
	assert_lte(cam.offset_px(1000, 1.0).length(), cap_px + 10.0 + 1e-3, "kick cap + one shake")
	assert_gt(cam.budget.refused, 0)


func test_a_gatling_second_is_steady_not_a_blur() -> void:
	var cam: FeelCam = _cam(SimClock.new())
	var held: int = 0
	var peak: float = 0.0
	for t: int in 60:
		if t % 4 == 0:  # 15 rounds a second
			held += cam.hit(&"gatling", &"medium", Vector2.RIGHT, false, 2000 + t)
		peak = maxf(peak, cam.offset_px(2000 + t, 1.0).length())
	assert_eq(held, 0, "the gatling override: no stop per round")
	var cap_px: float = cam.feel.cap["kick_px_max"]
	assert_lte(peak, cap_px, "sustained fire stays under the kick cap")
	assert_gt(peak, 0.0, "but it does kick")


func test_kicks_run_along_the_hit_and_ease_back_to_zero() -> void:
	var cam: FeelCam = _cam()
	@warning_ignore("return_value_discarded")
	cam.hit(&"hand_cannon", &"heavy", Vector2.LEFT, false, 500)
	var first: Vector2 = cam.offset_px(500, 1.0)
	assert_lt(first.x, -1.0, "along the hit")
	assert_lt(cam.offset_px(505, 1.0).length(), first.length())
	assert_eq(cam.offset_px(600, 1.0), Vector2.ZERO, "back to the frame exactly")


func test_off_means_no_effect() -> void:
	var clock: SimClock = SimClock.new()
	var cam: FeelCam = _cam(clock)
	cam.feel.enabled = false
	for i: int in 30:
		assert_eq(cam.hit(&"mini_nuke", &"blast", Vector2.UP, true, 10 + i), 0)
	assert_eq(cam.offset_px(12, 1.0), Vector2.ZERO)
	assert_eq(clock.held(), 0.0)
	assert_eq(cam.kicks, 0)


func test_reduced_motion_means_no_effect() -> void:
	var cam: FeelCam = _cam(SimClock.new())
	cam.reduced_motion = true
	assert_eq(cam.hit(&"hand_cannon", &"heavy", Vector2.UP, true, 10), 0)
	assert_eq(cam.offset_px(10, 1.0), Vector2.ZERO)


func test_a_weapon_override_sits_on_top_of_its_class() -> void:
	var feel: HitFeel = HitFeel.shipped()
	var plasma: StringName = feel.camera_row(&"plasma_rifle", &"medium", false)["hitstop"]
	var gat: StringName = feel.camera_row(&"gatling", &"medium", false)["hitstop"]
	var gat_kill: StringName = feel.camera_row(&"gatling", &"medium", true)["kill_hitstop"]
	assert_eq(plasma, &"rivet_hit")
	assert_eq(gat, &"")
	assert_eq(gat_kill, feel.kill_hitstop)
	var plain: float = feel.camera_row(&"pistol", &"light", false)["kick_px"]
	var kill: float = feel.camera_row(&"pistol", &"light", true)["kick_px"]
	assert_gt(kill, plain, "kills kick harder")


func test_the_hit_strength_scales_the_kick() -> void:
	var a: FeelCam = _cam()
	var b: FeelCam = _cam()
	@warning_ignore("return_value_discarded")
	a.hit(&"pistol", &"light", Vector2.RIGHT, false, 10)
	@warning_ignore("return_value_discarded")
	b.hit(&"pistol", &"light", Vector2.RIGHT * 0.5, false, 10)
	assert_almost_eq(b.offset_px(10, 1.0).x, a.offset_px(10, 1.0).x * 0.5, 1e-4)


func test_the_budget_window_refills_after_a_second() -> void:
	var b: FeelBudget = FeelBudget.from_cap(
		{"hitstop_ticks_per_second": 12, "shakes_per_second": 2}
	)
	assert_eq(b.take_stop(0, 8), 8)
	assert_eq(b.take_stop(10, 8), 4, "trimmed to what the window has left")
	assert_eq(b.take_stop(20, 8), 0)
	assert_eq(b.take_stop(70, 8), 8, "the window moved on")
	assert_true(b.take_shake(0))
	assert_true(b.take_shake(1))
	assert_false(b.take_shake(2))
	assert_true(b.take_shake(61))


func test_a_blast_kill_keeps_the_longer_blast_stop() -> void:
	var rig: CameraRig = CameraRig.new()
	var cam: FeelCam = _cam(SimClock.new())
	var blast: int = cam.hit(&"rocket_launcher", &"blast", Vector2.RIGHT, true, 100)
	assert_eq(blast, rig.hitstop_ticks(&"boss_hit"), "not the shorter kill stop")
	var light: int = cam.hit(&"pistol", &"light", Vector2.RIGHT, true, 1000)
	assert_eq(light, rig.hitstop_ticks(&"kill"), "a light kill takes the kill stop")
