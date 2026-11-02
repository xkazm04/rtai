extends GutTest
## Camera feel as data (core/render/camera_rig.gd): eased zoom between the modes, look-ahead,
## shake and hit-stop, and what reduced motion turns off.


func test_the_modes_are_the_locked_scales() -> void:
	var rig: CameraRig = CameraRig.new()
	assert_eq(rig.ppm(), 32.0)
	rig.snap(&"car")
	assert_eq(rig.ppm(), 48.0)
	rig.snap(&"arena")
	assert_eq(rig.ppm(), 64.0)


func test_a_mode_change_eases_monotonically_on_the_tick() -> void:
	var rig: CameraRig = CameraRig.new()
	rig.set_mode(&"car", 0)
	var prev: float = rig.ppm()
	for t: int in range(1, rig.ease_ticks + 1):
		rig.step(t, Vector2.ZERO)
		assert_gte(rig.ppm(), prev)
		prev = rig.ppm()
	assert_eq(rig.ppm(), 48.0)


func test_look_ahead_leads_the_car_up_to_its_cap() -> void:
	var rig: CameraRig = CameraRig.new()
	rig.snap(&"car")
	for t: int in 600:
		rig.step(t, Vector2(80, 0))
	var cap: float = rig.modes[&"car"]["look_ahead_max_m"]
	assert_almost_eq(rig.offset_px(32.0).x, cap * 32.0, 1.0)
	assert_almost_eq(rig.offset_px(32.0).y, 0.0, 0.001)


func test_a_shake_decays_to_nothing_and_repeats_exactly() -> void:
	var a: CameraRig = CameraRig.new()
	var b: CameraRig = CameraRig.new()
	for rig: CameraRig in [a, b]:
		rig.kick(&"explosion", 10)
		rig.step(13, Vector2.ZERO)
	assert_gt(a.offset_px(32.0).length(), 0.0)
	assert_eq(a.offset_px(32.0), b.offset_px(32.0))
	a.step(10 + 24, Vector2.ZERO)
	assert_eq(a.offset_px(32.0), Vector2.ZERO)


func test_reduced_motion_drops_shake_and_hitstop() -> void:
	var rig: CameraRig = CameraRig.new()
	assert_gt(rig.hitstop_ticks(&"melee_hit"), 0)
	rig.reduced_motion = true
	rig.kick(&"explosion", 0)
	rig.step(2, Vector2.ZERO)
	assert_eq(rig.offset_px(32.0), Vector2.ZERO)
	assert_eq(rig.hitstop_ticks(&"melee_hit"), 0)


func test_vehicle_events_switch_the_mode() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var rig: CameraRig = CameraRig.new()
	rig.snap(&"car")
	rig.listen(bus, null)
	bus.vehicle_exited.emit(3)
	assert_eq(rig.mode, &"on_foot")
	bus.vehicle_entered.emit(3)
	assert_eq(rig.mode, &"car")
