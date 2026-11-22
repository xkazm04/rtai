extends GutTest

var session: GauntletSession
var waves: GauntletWaves
var hud: GauntletHud


func before_each() -> void:
	var run: GauntletRun = GauntletRun.new()
	var picker: GauntletPilot = GauntletPilot.new()
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	session = GauntletSession.open_street(bus, data, run, picker)
	waves = GauntletWaves.attach(session, run, picker, 0)
	hud = GauntletHud.new()
	hud.session = session
	hud.run = run
	hud.waves = waves
	add_child(hud)


func after_each() -> void:
	hud.free()
	session.close()


func _enter(timeout_ticks: int) -> void:
	session.street.timeout_ticks = timeout_ticks
	session.stage.arena.rivet.pos.x = session.street.current().end_x() + 0.1
	session.step()


func _check_timer(seconds: float, color: Color) -> void:
	hud._process(0.0)
	assert_almost_eq(waves.seconds_left(session.stage.tick), seconds, 0.00001)
	assert_eq(hud._time.self_modulate * hud._time.get_theme_color(&"font_color"), color)


func test_timer_warns_from_exactly_ten_seconds_left() -> void:
	_check_timer(-1.0, GauntletHud.PAPER)
	_enter(11 * SimClock.TICK_RATE)
	_check_timer(11.0, GauntletHud.PAPER)
	for i: int in SimClock.TICK_RATE - 1:
		session.step()
	_check_timer(10.0 + SimClock.TICK_DT, GauntletHud.PAPER)
	session.step()
	_check_timer(10.0, PlayerGuardView.AMBER)
	session.step()
	_check_timer(10.0 - SimClock.TICK_DT, PlayerGuardView.AMBER)


func test_final_allowed_wave_has_no_reinforcement_timer() -> void:
	waves._limit = 1
	_enter(SimClock.TICK_RATE)
	_check_timer(-1.0, GauntletHud.PAPER)


func test_timer_stops_while_reinforcements_wait_for_a_spawn_slot() -> void:
	session.street.max_alive = 1
	_enter(1)
	_check_timer(SimClock.TICK_DT, PlayerGuardView.AMBER)
	session.step()
	assert_eq(waves.live_wave_count(), 1)
	_check_timer(-1.0, GauntletHud.PAPER)


func test_wave_six_uses_its_own_deadline_when_stacked_onto_wave_five() -> void:
	waves._run.wave = 4
	session.stage.arena.rivet.pos.x = session.street.current().end_x() + 0.1
	session.step()
	var first: int = session.stage.tick
	assert_eq(waves._run.wave, 5)
	assert_eq(waves.seconds_left(first), 90.0)
	var next: int = first + 90 * SimClock.TICK_RATE
	waves.step(session.stage, next - 1)
	assert_eq(waves.live_wave_count(), 1)
	waves.step(session.stage, next)
	assert_eq(waves.live_wave_count(), 2)
	assert_eq(waves.seconds_left(next), 45.0)
	waves.step(session.stage, next + 45 * SimClock.TICK_RATE)
	assert_eq(waves.live_wave_count(), 3)


func test_zero_late_timeout_uses_the_regular_deadline_for_wave_six() -> void:
	session.street.late_timeout_ticks = 0
	waves._run.wave = 5
	session.stage.arena.rivet.pos.x = session.street.current().end_x() + 0.1
	session.step()
	assert_eq(waves._run.wave, 6)
	var deadline: int = session.stage.tick + 90 * SimClock.TICK_RATE
	assert_eq(waves.seconds_left(session.stage.tick), 90.0)
	waves.step(session.stage, deadline - 1)
	assert_eq(waves.live_wave_count(), 1)
	waves.step(session.stage, deadline)
	assert_eq(waves.live_wave_count(), 2)
	var timed_out: bool = waves._run.waves[-2].timed_out
	assert_true(timed_out)
