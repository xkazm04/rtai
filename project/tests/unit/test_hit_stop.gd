extends GutTest
## Hit-stop and the car look-ahead feed (core/render/camera_rig.gd, core/render/fx_triggers.gd,
## SimClock.hold): a cue's `hitstop` holds wall time without changing a tick, reduced motion and
## the cooldown drop it, and the look-ahead reads the focus motion per tick.

const RIVET: int = 77


func _triggers(clock: SimClock, rig: CameraRig, bus: EventBus) -> FxTriggers:
	var t: FxTriggers = FxTriggers.new()
	t.rig = rig
	t.player_id = RIVET
	t.listen(bus, clock, Callable())
	return t


func test_every_cue_hitstop_names_a_camera_hitstop() -> void:
	var t: FxTriggers = FxTriggers.new()
	var rig: CameraRig = CameraRig.new()
	for id: StringName in t.rows:
		var stop: String = t.rows[id]["hitstop"]
		assert_true(stop == "" or rig.hitstops.has(StringName(stop)), "%s hitstop" % id)


func test_a_hold_freezes_ticks_then_the_clock_runs_on() -> void:
	var clock: SimClock = SimClock.new()
	clock.hold(3 * SimClock.TICK_DT)
	var steps: int = 0
	for i: int in 3:
		steps += clock.advance(SimClock.TICK_DT)
	assert_eq(steps, 0)
	assert_almost_eq(clock.held(), 0.0, 1e-9)
	assert_eq(clock.advance(SimClock.TICK_DT), 1)


func test_rivet_hit_holds_the_clock_once_inside_the_cooldown() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var clock: SimClock = SimClock.new()
	var t: FxTriggers = _triggers(clock, CameraRig.new(), bus)
	bus.player_hit.emit(&"rifle")
	assert_almost_eq(clock.held(), 3 * SimClock.TICK_DT, 1e-9)
	bus.player_hit.emit(&"rifle")
	assert_eq(t.stops, 1)


func test_only_rivets_kills_stop_the_game() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var clock: SimClock = SimClock.new()
	var t: FxTriggers = _triggers(clock, CameraRig.new(), bus)
	bus.actor_killed.emit(5, 6, &"shot")
	assert_eq(t.stops, 0)
	bus.actor_killed.emit(RIVET, 6, &"shot")
	assert_eq(t.stops, 1)
	assert_almost_eq(clock.held(), 6 * SimClock.TICK_DT, 1e-9)


func test_reduced_motion_never_holds() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var clock: SimClock = SimClock.new()
	var rig: CameraRig = CameraRig.new()
	rig.reduced_motion = true
	var t: FxTriggers = _triggers(clock, rig, bus)
	bus.actor_killed.emit(RIVET, 6, &"shot")
	assert_eq(t.stops, 0)
	assert_eq(clock.held(), 0.0)


func test_the_look_ahead_reads_the_focus_motion() -> void:
	var rig: CameraRig = CameraRig.new()
	rig.snap(&"car")
	var at: Vector2 = Vector2.ZERO
	for tick: int in 600:
		at += Vector2(15.0, 0.0) * SimClock.TICK_DT
		rig.follow(tick, at)
		rig.follow(tick, at)
	var want: float = minf(15.0 * 0.35, 7.0) * 32.0
	assert_almost_eq(rig.offset_px(32.0).x, want, 1.0)


func test_a_focus_jump_leads_nothing() -> void:
	var rig: CameraRig = CameraRig.new()
	rig.snap(&"car")
	rig.follow(0, Vector2.ZERO)
	for tick: int in range(1, 200):
		rig.follow(tick, Vector2(500.0, 0.0))
	assert_almost_eq(rig.offset_px(32.0).x, 0.0, 0.001)


func test_a_robo_tazer_hit_adds_the_crackle_once() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var t: FxTriggers = _triggers(SimClock.new(), CameraRig.new(), bus)
	bus.player_hit.emit(&"robo-tazer")
	bus.player_hit.emit(&"rifle")
	assert_eq(t.fired[&"player_hit"], 2)
	assert_eq(t.fired[&"player_hit_robo_tazer"], 1)
