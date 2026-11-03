extends GutTest
## features/souls HaulerKick: a stomp landing in a view with no CameraRig holds the sim clock
## (hit-stop, camera.json stomp_hitstop) and shakes the camera (stomp_shake) once per stomp; a
## host rig takes the kick itself (zero offset back); reduced motion holds nothing.

var _h: HaulerStage
var _clock: SimClock


func before_each() -> void:
	_h = HaulerStage.shipped()
	_clock = SimClock.new()


func test_a_stomp_holds_the_clock_and_shakes_once() -> void:
	var kick: HaulerKick = HaulerKick.new()
	assert_eq(kick.step(_h, 10, _clock, null), Vector2.ZERO, "no stomp, no shake")
	_h.stomp_tick = 12
	var off: Vector2 = kick.step(_h, 12, _clock, null)
	var want: int = CameraRig.new().hitstop_ticks(_h.form.id_of(&"stomp_hitstop"))
	assert_gt(want, 0, "the stomp's hit-stop id holds ticks")
	assert_eq(kick.held_ticks, want)
	assert_almost_eq(_clock.held(), want * SimClock.TICK_DT, 1e-6)
	assert_gt(off.length(), 1.0, "the landing frame is shaken (world px)")
	@warning_ignore("return_value_discarded")
	kick.step(_h, 13, _clock, null)
	assert_eq(kick.kicks, 1, "one kick per stomp, not per frame")
	var late: Vector2 = kick.step(_h, 12 + 60, _clock, null)
	assert_eq(late, Vector2.ZERO, "the shake has run out a second later")


func test_a_host_rig_shakes_itself() -> void:
	var kick: HaulerKick = HaulerKick.new()
	var rig: CameraRig = CameraRig.new()
	_h.stomp_tick = 5
	assert_eq(kick.step(_h, 5, _clock, rig), Vector2.ZERO)
	rig.step(5, Vector2.ZERO)
	assert_gt(rig.offset_px(SimConst.PX_PER_M).length(), 1.0, "the host rig got the kick")
	assert_gt(_clock.held(), 0.0)


func test_reduced_motion_holds_nothing() -> void:
	var kick: HaulerKick = HaulerKick.new()
	kick.reduced_motion = true
	_h.stomp_tick = 5
	@warning_ignore("return_value_discarded")
	kick.step(_h, 5, _clock, null)
	var want: int = CameraRig.new().hitstop_ticks(_h.form.id_of(&"stomp_hitstop"))
	var rm: CameraRig = CameraRig.new()
	rm.reduced_motion = true
	assert_eq(kick.held_ticks, rm.hitstop_ticks(_h.form.id_of(&"stomp_hitstop")))
	assert_lte(kick.held_ticks, want)
