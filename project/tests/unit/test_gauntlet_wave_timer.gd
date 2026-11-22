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
